import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:pharmacie_de_garde/core/errors/exceptions.dart';
import 'package:pharmacie_de_garde/core/network/api_client.dart';
import 'package:pharmacie_de_garde/core/network/api_error_payload.dart';
import 'package:pharmacie_de_garde/core/network/protected_endpoints.dart';

void main() {
  const base = 'http://example.test/api';

  test('les lectures publiques n\'envoient pas le jeton', () async {
    final seen = <http.Request>[];
    final api = ApiClient(
      baseUrl: base,
      readAccessToken: () async => 'secret',
      client: MockClient((request) async {
        seen.add(request);
        return http.Response('[]', 200);
      }),
    );

    await api.getList('/pharmacies');
    await api.getList(
      '/client/pharmacies/search',
      queryParameters: {'name': 'plateau'},
    );
    await api.getList('/client/pharmacies/12/reviews');

    expect(seen, hasLength(3));
    for (final request in seen) {
      expect(request.headers.containsKey('authorization'), isFalse);
    }
    expect(ProtectedEndpoints.requiresBearer('GET', '/zones'), isFalse);
    expect(
      ProtectedEndpoints.requiresBearer('GET', '/emergency-numbers'),
      isFalse,
    );
    expect(
      ProtectedEndpoints.requiresBearer('POST', '/auth/client/login'),
      isFalse,
    );
    expect(
      ProtectedEndpoints.requiresBearer('POST', '/auth/client/register'),
      isFalse,
    );
    expect(ProtectedEndpoints.requiresBearer('POST', '/clients'), isFalse);
  });

  test('les appels protégés ajoutent Authorization Bearer', () async {
    final seen = <http.Request>[];
    final api = ApiClient(
      baseUrl: base,
      readAccessToken: () async => 'jwt-client',
      client: MockClient((request) async {
        seen.add(request);
        return http.Response('{"ok":true}', 200);
      }),
    );

    await api.post('/client/pharmacies/4/reviews', body: {'rating': 5});
    await api.put(
      '/clients/4/location',
      body: {'latitude': 5.3, 'longitude': -4.0},
    );
    await api.post(
      '/client/pharmacies/duty/report',
      body: {'pharmacyId': 4, 'clientId': 4},
    );
    await api.delete(
      '/client/pharmacies/reviews/9',
      queryParameters: {'clientId': '4'},
    );

    expect(seen, hasLength(4));
    for (final request in seen) {
      expect(request.headers['authorization'], 'Bearer jwt-client');
    }
  });

  test(
    'un 401 propose la reconnexion puis rejoue l\'appel avec le nouveau jeton',
    () async {
      var token = 'expire';
      var calls = 0;
      var reconnects = 0;
      final api = ApiClient(
        baseUrl: base,
        readAccessToken: () async => token,
        onUnauthorized: () async {
          reconnects += 1;
          token = 'frais';
          return true;
        },
        client: MockClient((request) async {
          calls += 1;
          if (request.headers['authorization'] != 'Bearer frais') {
            return http.Response(
              '{"status":"UNAUTHORIZED","statusCode":401,"message":"Authentification requise"}',
              401,
            );
          }
          return http.Response('{"id":1,"rating":5}', 200);
        }),
      );

      final body = await api.post(
        '/client/pharmacies/4/reviews',
        body: {'rating': 5},
      );
      expect(body['id'], 1);
      expect(reconnects, 1);
      expect(calls, 2);
    },
  );

  test('un 401 sans reconnexion expose un message français', () async {
    final api = ApiClient(
      baseUrl: base,
      readAccessToken: () async => null,
      onUnauthorized: () async => false,
      client: MockClient((request) async {
        return http.Response(
          '{"status":"UNAUTHORIZED","statusCode":401,"message":"Authentification requise"}',
          401,
        );
      }),
    );

    expect(
      () => api.post(
        '/client/pharmacies/duty/report',
        body: {'pharmacyId': 1, 'clientId': 2},
      ),
      throwsA(
        isA<UnauthorizedException>().having(
          (error) => error.message,
          'message',
          ApiErrorMessages.unauthorized,
        ),
      ),
    );
  });

  test('un 429 latin-1 reste lisible en français', () async {
    final payload = latin1.encode(
      '{"status":"TOO_MANY_REQUESTS","statusCode":429,"message":"Trop de tentatives de connexion. Réessayez dans une minute."}',
    );
    final api = ApiClient(
      baseUrl: base,
      client: MockClient((request) async => http.Response.bytes(payload, 429)),
    );

    expect(
      () => api.post('/auth/client/login', body: {'phone': '+2250700000000'}),
      throwsA(
        isA<RateLimitException>().having(
          (error) => error.message,
          'message',
          'Trop de tentatives de connexion. Réessayez dans une minute.',
        ),
      ),
    );
  });

  test('un 429 de connexion affiche le message de limitation', () async {
    final api = ApiClient(
      baseUrl: base,
      client: MockClient((request) async => http.Response('', 429)),
    );

    expect(
      () => api.post('/auth/client/login', body: {'phone': '+2250700000000'}),
      throwsA(
        isA<RateLimitException>().having(
          (error) => error.message,
          'message',
          ApiErrorMessages.rateLimit,
        ),
      ),
    );
  });

  test('les erreurs de champ ApiError sont reprises en français', () async {
    final api = ApiClient(
      baseUrl: base,
      client: MockClient((request) async {
        return http.Response(
          '{"statusCode":400,"status":"BAD_REQUEST","message":"Erreurs de validation","errors":{"phone":"Le numéro de téléphone est obligatoire"}}',
          400,
        );
      }),
    );

    expect(
      () => api.post('/auth/client/login', body: {'phone': ''}),
      throwsA(
        isA<ValidationException>().having(
          (error) => error.message,
          'message',
          'Le numéro de téléphone est obligatoire',
        ),
      ),
    );
  });

  test(
    'une inscription en conflit 409 indique que le numéro existe déjà',
    () async {
      final api = ApiClient(
        baseUrl: base,
        client: MockClient((request) async {
          expect(request.url.path, '/api/auth/client/register');
          expect(request.headers.containsKey('authorization'), isFalse);
          return http.Response(
            '{"statusCode":409,"status":"CONFLICT","message":"Ce numéro est déjà inscrit"}',
            409,
          );
        }),
      );

      expect(
        () => api.post(
          '/auth/client/register',
          body: {'phone': '+2250700112233'},
        ),
        throwsA(
          isA<ConflictException>().having(
            (error) => error.message,
            'message',
            contains('déjà inscrit'),
          ),
        ),
      );
    },
  );

  test('une inscription invalide reprend les erreurs de champ', () async {
    final api = ApiClient(
      baseUrl: base,
      client: MockClient((request) async {
        return http.Response(
          '{"statusCode":400,"message":"Erreurs de validation","errors":{"phone":"Le numéro de téléphone doit contenir entre 8 et 20 caractères"}}',
          400,
        );
      }),
    );

    expect(
      () => api.post('/auth/client/register', body: {'phone': '12'}),
      throwsA(
        isA<ValidationException>().having(
          (error) => error.message,
          'message',
          'Le numéro de téléphone doit contenir entre 8 et 20 caractères',
        ),
      ),
    );
  });

  test('un téléphone inconnu reste une absence de compte', () async {
    final api = ApiClient(
      baseUrl: base,
      client: MockClient((request) async {
        return http.Response(
          '{"statusCode":400,"message":"Numéro de téléphone non trouvé"}',
          400,
        );
      }),
    );

    expect(
      () => api.post('/auth/client/login', body: {'phone': '+2250799999999'}),
      throwsA(isA<NotFoundException>()),
    );
  });
}
