import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:pharmacie_de_garde/core/constants/api_constants.dart';
import 'package:pharmacie_de_garde/core/errors/failures.dart';
import 'package:pharmacie_de_garde/core/network/api_client.dart';
import 'package:pharmacie_de_garde/core/security/token_vault.dart';
import 'package:pharmacie_de_garde/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:pharmacie_de_garde/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:pharmacie_de_garde/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/memory_secure_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const phone = '+225 07 12 34 56 78';

  Future<({AuthRepositoryImpl repository, TokenVault vault})> build(
    http.Client client,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final vault = TokenVault(store: MemorySecureKeyValueStore());
    final api = ApiClient(
      client: client,
      baseUrl: 'http://example.test/api',
      readAccessToken: () async => (await vault.readValid())?.token,
    );
    return (
      repository: AuthRepositoryImpl(
        remoteDataSource: AuthRemoteDataSourceImpl(api),
        localDataSource: AuthLocalDataSourceImpl(prefs),
        tokenVault: vault,
      ),
      vault: vault,
    );
  }

  test('le 201 d\'inscription ne lit que le téléphone et stocke le jeton', () async {
    SharedPreferences.setMockInitialValues({});
    final harness = await build(
      MockClient((request) async {
        expect(request.url.path, '/api${ApiConstants.clientRegisterEndpoint}');
        expect(request.headers.containsKey('authorization'), isFalse);
        expect(jsonDecode(request.body), {'phone': phone});
        return http.Response('''
{"client":{"id":4,"email":null,"phone":"$phone","firstName":null,"lastName":null,"providerType":"PHONE","latitude":null,"longitude":null,"isActive":true,"createdAt":"2026-11-11T14:00:00","updatedAt":null},"token":"jwt-inscription","tokenType":"Bearer","expiresInSeconds":86400}
''', 201);
      }),
    );
    final repository = harness.repository;

    final result = await repository.registerClient(phone: phone);
    final session = result.fold(
      (failure) => fail(failure.message),
      (value) => value,
    );

    expect(session.token, 'jwt-inscription');
    expect(session.tokenType, 'Bearer');
    expect(session.expiresInSeconds, 86400);
    expect(session.client.id, 4);
    expect(session.client.latitude, isNull);
    expect(session.client.longitude, isNull);
    final stored = await harness.vault.readValid();
    expect(stored?.token, 'jwt-inscription');
    expect(stored?.tokenType, 'Bearer');
    expect(
      stored!.expiresAt.difference(DateTime.now()).inSeconds,
      inInclusiveRange(86390, 86400),
    );
    final restored = await repository.getCurrentAuth();
    expect(
      restored.fold(
        (failure) => fail(failure.message),
        (value) => value?.token,
      ),
      'jwt-inscription',
    );

    final prefs = await SharedPreferences.getInstance();
    expect(
      prefs.getString('cached_auth_response')!.contains('jwt-inscription'),
      isFalse,
    );
  });

  test('un 409 bascule vers une connexion, sans garder de jeton', () async {
    SharedPreferences.setMockInitialValues({});
    final harness = await build(
      MockClient((request) async {
        return http.Response(
          '{"status":"CONFLICT","statusCode":409,"message":"Un client avec ce numéro de téléphone existe déjà"}',
          409,
        );
      }),
    );

    final result = await harness.repository.registerClient(phone: phone);
    final failure = result.fold((error) => error, (_) => null);
    expect(failure, isA<ConflictFailure>());
    expect(
      failure!.message,
      'Un client avec ce numéro de téléphone existe déjà',
    );
    expect(await harness.vault.readValid(), isNull);
  });

  test('un 400 d\'inscription expose le message de validation', () async {
    SharedPreferences.setMockInitialValues({});
    final harness = await build(
      MockClient((request) async {
        return http.Response(
          '{"statusCode":400,"message":"Erreurs de validation","errors":{"phone":"Le numéro de téléphone doit être un numéro ivoirien valide"}}',
          400,
        );
      }),
    );

    final result = await harness.repository.registerClient(phone: phone);
    final failure = result.fold((error) => error, (_) => null);
    expect(failure, isA<ValidationFailure>());
    expect(
      failure!.message,
      'Le numéro de téléphone doit être un numéro ivoirien valide',
    );
    expect(
      (failure as ValidationFailure).fieldErrors['phone'],
      'Le numéro de téléphone doit être un numéro ivoirien valide',
    );
  });

  test('la position part après le jeton, avec le Bearer', () async {
    SharedPreferences.setMockInitialValues({});
    final headers = <String>[];
    final harness = await build(
      MockClient((request) async {
        if (request.url.path.endsWith('/register')) {
          expect(jsonDecode(request.body), {'phone': phone});
          return http.Response('''
{"client":{"id":4,"email":null,"phone":"$phone","firstName":null,"lastName":null,"providerType":"PHONE","latitude":null,"longitude":null,"isActive":true,"createdAt":null,"updatedAt":null},"token":"jwt-inscription","tokenType":"Bearer","expiresInSeconds":86400}
''', 201);
        }
        headers.add(request.headers['authorization'] ?? '');
        return http.Response(
          '{"id":4,"phone":"$phone","latitude":5.36,"longitude":-4.01,"providerType":"PHONE","isActive":true}',
          200,
        );
      }),
    );

    await harness.repository.registerClient(phone: phone);
    final updated = await harness.repository.updateLocation(
      clientId: 4,
      latitude: 5.36,
      longitude: -4.01,
    );
    expect(updated.isRight(), isTrue);
    expect(headers, ['Bearer jwt-inscription']);
  });
}
