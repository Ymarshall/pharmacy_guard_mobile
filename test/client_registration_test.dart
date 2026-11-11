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

  const phone = '+2250700112233';

  Future<AuthRepositoryImpl> build(http.Client client) async {
    final prefs = await SharedPreferences.getInstance();
    final vault = TokenVault(store: MemorySecureKeyValueStore());
    final api = ApiClient(
      client: client,
      baseUrl: 'http://example.test/api',
      readAccessToken: () async => (await vault.readValid())?.token,
    );
    return AuthRepositoryImpl(
      remoteDataSource: AuthRemoteDataSourceImpl(api),
      localDataSource: AuthLocalDataSourceImpl(prefs),
      tokenVault: vault,
    );
  }

  test('l\'inscription stocke le jeton renvoyé, comme le login', () async {
    SharedPreferences.setMockInitialValues({});
    String? seenPath;
    final repository = await build(
      MockClient((request) async {
        seenPath = request.url.path;
        expect(request.headers.containsKey('authorization'), isFalse);
        return http.Response('''
{"client":{"id":4,"phone":"$phone","latitude":0,"longitude":0,"providerType":"PHONE","isActive":true},"token":"jwt-inscription","tokenType":"Bearer","expiresInSeconds":3600}
''', 200);
      }),
    );

    final result = await repository.registerClient(phone: phone);
    final session = result.fold(
      (failure) => fail(failure.message),
      (value) => value,
    );

    expect(seenPath, '/api${ApiConstants.clientRegisterEndpoint}');
    expect(session.token, 'jwt-inscription');
    expect(session.client.id, 4);
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
    final repository = await build(
      MockClient((request) async {
        return http.Response(
          '{"statusCode":409,"message":"Ce numéro est déjà inscrit"}',
          409,
        );
      }),
    );

    final result = await repository.registerClient(phone: phone);
    final failure = result.fold((error) => error, (_) => null);
    expect(failure, isA<ConflictFailure>());
    expect(failure!.message, contains('déjà inscrit'));
  });

  test('un 400 d\'inscription expose le message de validation', () async {
    SharedPreferences.setMockInitialValues({});
    final repository = await build(
      MockClient((request) async {
        return http.Response(
          '{"message":"Erreurs de validation","errors":{"phone":"Le numéro de téléphone est obligatoire"}}',
          400,
        );
      }),
    );

    final result = await repository.registerClient(phone: phone);
    final failure = result.fold((error) => error, (_) => null);
    expect(failure, isA<ValidationFailure>());
    expect(failure!.message, 'Le numéro de téléphone est obligatoire');
  });

  test('la position part après le jeton, avec le Bearer', () async {
    SharedPreferences.setMockInitialValues({});
    final headers = <String>[];
    final repository = await build(
      MockClient((request) async {
        if (request.url.path.endsWith('/register')) {
          return http.Response('''
{"client":{"id":4,"phone":"$phone","latitude":0,"longitude":0,"providerType":"PHONE","isActive":true},"token":"jwt-inscription","tokenType":"Bearer","expiresInSeconds":3600}
''', 200);
        }
        headers.add(request.headers['authorization'] ?? '');
        return http.Response(
          '{"id":4,"phone":"$phone","latitude":5.36,"longitude":-4.01,"providerType":"PHONE","isActive":true}',
          200,
        );
      }),
    );

    await repository.registerClient(phone: phone);
    final updated = await repository.updateLocation(
      clientId: 4,
      latitude: 5.36,
      longitude: -4.01,
    );
    expect(updated.isRight(), isTrue);
    expect(headers, ['Bearer jwt-inscription']);
  });
}
