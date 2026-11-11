import '../constants/storage_keys.dart';
import 'secure_key_value_store.dart';

class StoredAccessToken {
  final String token;
  final String tokenType;
  final DateTime expiresAt;

  const StoredAccessToken({
    required this.token,
    required this.tokenType,
    required this.expiresAt,
  });

  bool isValidAt(DateTime instant) => expiresAt.isAfter(instant);
}

/// Conserve le jeton client et son expiration, et l'efface s'il n'est plus valide.
class TokenVault {
  TokenVault({required SecureKeyValueStore store, DateTime Function()? now})
    : _store = store,
      _now = now ?? DateTime.now;

  final SecureKeyValueStore _store;
  final DateTime Function() _now;

  Future<void> save({
    required String token,
    required String tokenType,
    required int expiresInSeconds,
  }) async {
    final expiresAt = _now().add(Duration(seconds: expiresInSeconds));
    await _store.write(StorageKeys.accessToken, token);
    await _store.write(
      StorageKeys.accessTokenType,
      tokenType.isEmpty ? 'Bearer' : tokenType,
    );
    await _store.write(
      StorageKeys.accessTokenExpiresAt,
      expiresAt.toIso8601String(),
    );
  }

  /// Retourne le jeton encore valide, ou `null` après l'avoir effacé.
  Future<StoredAccessToken?> readValid() async {
    final token = await _store.read(StorageKeys.accessToken);
    final expiryRaw = await _store.read(StorageKeys.accessTokenExpiresAt);
    final tokenType =
        await _store.read(StorageKeys.accessTokenType) ?? 'Bearer';
    if (token == null || token.isEmpty || expiryRaw == null) {
      if (token != null || expiryRaw != null) await clear();
      return null;
    }
    final expiresAt = DateTime.tryParse(expiryRaw);
    if (expiresAt == null || !expiresAt.isAfter(_now())) {
      await clear();
      return null;
    }
    return StoredAccessToken(
      token: token,
      tokenType: tokenType,
      expiresAt: expiresAt,
    );
  }

  Future<void> clear() async {
    await _store.delete(StorageKeys.accessToken);
    await _store.delete(StorageKeys.accessTokenType);
    await _store.delete(StorageKeys.accessTokenExpiresAt);
  }
}
