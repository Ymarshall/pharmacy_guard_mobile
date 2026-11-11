import 'package:flutter_test/flutter_test.dart';
import 'package:pharmacie_de_garde/core/constants/storage_keys.dart';
import 'package:pharmacie_de_garde/core/security/token_vault.dart';
import 'package:pharmacie_de_garde/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:pharmacie_de_garde/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:pharmacie_de_garde/features/auth/data/models/auth_response_model.dart';
import 'package:pharmacie_de_garde/features/auth/data/models/client_model.dart';
import 'package:pharmacie_de_garde/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/memory_secure_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('TokenVault', () {
    late MemorySecureKeyValueStore store;
    late DateTime now;
    late TokenVault vault;

    setUp(() {
      store = MemorySecureKeyValueStore();
      now = DateTime.utc(2026, 11, 11, 10);
      vault = TokenVault(store: store, now: () => now);
    });

    test('conserve le jeton tant qu\'il n\'est pas expiré', () async {
      await vault.save(
        token: 'jwt-valide',
        tokenType: 'Bearer',
        expiresInSeconds: 60,
      );

      final stored = await vault.readValid();
      expect(stored?.token, 'jwt-valide');
      expect(stored?.tokenType, 'Bearer');
      expect(stored?.expiresAt, now.add(const Duration(seconds: 60)));
    });

    test('efface le jeton dès qu\'il est expiré', () async {
      await vault.save(
        token: 'jwt-court',
        tokenType: 'Bearer',
        expiresInSeconds: 10,
      );

      now = now.add(const Duration(seconds: 10));
      expect(await vault.readValid(), isNull);
      expect(store.values.containsKey(StorageKeys.accessToken), isFalse);
      expect(
        store.values.containsKey(StorageKeys.accessTokenExpiresAt),
        isFalse,
      );
    });

    test('clear retire le jeton avant l\'expiration', () async {
      await vault.save(
        token: 'jwt-logout',
        tokenType: 'Bearer',
        expiresInSeconds: 3600,
      );
      await vault.clear();
      expect(await vault.readValid(), isNull);
      expect(store.values, isEmpty);
    });
  });

  group('session client', () {
    late MemorySecureKeyValueStore store;
    late DateTime now;
    late TokenVault vault;
    late AuthRepositoryImpl repository;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      store = MemorySecureKeyValueStore();
      now = DateTime.utc(2026, 11, 11, 10);
      vault = TokenVault(store: store, now: () => now);
      repository = AuthRepositoryImpl(
        remoteDataSource: _FakeAuthRemote(),
        localDataSource: AuthLocalDataSourceImpl(prefs),
        tokenVault: vault,
      );
    });

    test(
      'le login range le jeton hors des préférences et la déconnexion l\'efface',
      () async {
        final result = await repository.loginWithPhone('+2250700112233');
        final auth = result.fold(
          (failure) => fail(failure.message),
          (value) => value,
        );
        expect(auth.token, 'jwt-abc');

        final prefs = await SharedPreferences.getInstance();
        final raw = prefs.getString('cached_auth_response');
        expect(raw, isNotNull);
        expect(raw!.contains('jwt-abc'), isFalse);
        expect((await vault.readValid())?.token, 'jwt-abc');

        final signedOut = await repository.signOut();
        expect(signedOut.isRight(), isTrue);
        expect(await vault.readValid(), isNull);
        expect(prefs.getString('cached_auth_response'), isNull);
      },
    );

    test('une session expirée déconnecte au redémarrage', () async {
      await repository.loginWithPhone('+2250700112233');
      now = now.add(const Duration(hours: 2));

      final current = await repository.getCurrentAuth();
      final session = current.fold(
        (failure) => fail(failure.message),
        (value) => value,
      );
      expect(session, isNull);
      expect(await vault.readValid(), isNull);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('cached_auth_response'), isNull);
    });
  });
}

class _FakeAuthRemote implements AuthRemoteDataSource {
  @override
  Future<AuthResponseModel> register({required String phone}) {
    throw UnimplementedError();
  }

  @override
  Future<void> updateLocation({
    required int clientId,
    required double latitude,
    required double longitude,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<AuthResponseModel> login(String phone) async {
    return AuthResponseModel(
      client: ClientModel(
        id: 3,
        phone: phone,
        latitude: 5.36,
        longitude: -4.01,
        providerType: 'PHONE',
        isActive: true,
      ),
      nearestDutyPharmacies: const [],
      token: 'jwt-abc',
      tokenType: 'Bearer',
      expiresInSeconds: 3600,
    );
  }
}
