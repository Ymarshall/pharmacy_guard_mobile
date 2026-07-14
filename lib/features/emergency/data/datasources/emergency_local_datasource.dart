import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/storage_keys.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/emergency_number_model.dart';

abstract class EmergencyLocalDataSource {
  Future<List<EmergencyNumberModel>> getCachedEmergencyNumbers();
  Future<void> cacheEmergencyNumbers(List<EmergencyNumberModel> numbers);
  Future<void> clearCache();
}

class EmergencyLocalDataSourceImpl implements EmergencyLocalDataSource {
  final SharedPreferences sharedPreferences;

  EmergencyLocalDataSourceImpl(this.sharedPreferences);

  @override
  Future<List<EmergencyNumberModel>> getCachedEmergencyNumbers() async {
    try {
      final cachedData = sharedPreferences.getString(StorageKeys.emergencyNumbersCache);
      if (cachedData == null || cachedData.isEmpty) {
        throw const CacheException('Aucune donnée en cache');
      }

      final List<dynamic> jsonList = jsonDecode(cachedData) as List<dynamic>;
      return jsonList
          .map((json) => EmergencyNumberModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      if (e is CacheException) rethrow;
      throw CacheException('Erreur lors de la récupération du cache: ${e.toString()}');
    }
  }

  @override
  Future<void> cacheEmergencyNumbers(List<EmergencyNumberModel> numbers) async {
    try {
      final jsonList = numbers.map((number) => number.toJson()).toList();
      final jsonString = jsonEncode(jsonList);
      await sharedPreferences.setString(StorageKeys.emergencyNumbersCache, jsonString);
    } catch (e) {
      throw CacheException('Erreur lors de la mise en cache: ${e.toString()}');
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      await sharedPreferences.remove(StorageKeys.emergencyNumbersCache);
    } catch (e) {
      throw CacheException('Erreur lors de la suppression du cache: ${e.toString()}');
    }
  }
}

