import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/auth_response_model.dart';

abstract class AuthLocalDataSource {
  Future<void> cacheAuthResponse(AuthResponseModel authResponse);
  Future<AuthResponseModel?> getCachedAuthResponse();
  Future<void> clearCache();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SharedPreferences sharedPreferences;
  static const String _authKey = 'cached_auth_response';

  AuthLocalDataSourceImpl(this.sharedPreferences);

  @override
  Future<void> cacheAuthResponse(AuthResponseModel authResponse) async {
    try {
      final jsonString = jsonEncode(authResponse.toJson());
      await sharedPreferences.setString(_authKey, jsonString);
    } catch (e) {
      throw CacheException('Erreur lors de la mise en cache: ${e.toString()}');
    }
  }

  @override
  Future<AuthResponseModel?> getCachedAuthResponse() async {
    try {
      final jsonString = sharedPreferences.getString(_authKey);
      if (jsonString != null) {
        final json = jsonDecode(jsonString) as Map<String, dynamic>;
        return AuthResponseModel.fromJson(json);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      await sharedPreferences.remove(_authKey);
    } catch (e) {
      throw CacheException('Erreur lors de la suppression du cache: ${e.toString()}');
    }
  }
}

