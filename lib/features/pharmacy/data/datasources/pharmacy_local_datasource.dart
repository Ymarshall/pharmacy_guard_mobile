import '../../../../core/errors/exceptions.dart';
import '../models/pharmacy_model.dart';

abstract class PharmacyLocalDataSource {
  Future<List<PharmacyModel>> getCachedPharmacies();
  Future<void> cachePharmacies(List<PharmacyModel> pharmacies);
  Future<PharmacyModel?> getCachedPharmacyById(String id);
  Future<void> clearCache();
}

class PharmacyLocalDataSourceImpl implements PharmacyLocalDataSource {
  // In a real implementation, you would use a local storage solution
  // like shared_preferences, hive, or sqflite
  List<PharmacyModel>? _cachedPharmacies;

  @override
  Future<List<PharmacyModel>> getCachedPharmacies() async {
    try {
      if (_cachedPharmacies != null) {
        return _cachedPharmacies!;
      }
      throw const CacheException('Aucune donnée en cache');
    } catch (e) {
      if (e is AppException) rethrow;
      throw CacheException('Erreur lors de la récupération du cache: ${e.toString()}');
    }
  }

  @override
  Future<void> cachePharmacies(List<PharmacyModel> pharmacies) async {
    try {
      print('💾 [PHARMACY CACHE] Mise en cache de ${pharmacies.length} pharmacies');
      _cachedPharmacies = pharmacies;
      print('✅ [PHARMACY CACHE] Cache mis à jour avec succès');
      // In a real implementation, save to local storage
    } catch (e) {
      print('❌ [PHARMACY CACHE] Erreur lors de la mise en cache: $e');
      throw CacheException('Erreur lors de la mise en cache: ${e.toString()}');
    }
  }

  @override
  Future<PharmacyModel?> getCachedPharmacyById(String id) async {
    try {
      if (_cachedPharmacies != null) {
        return _cachedPharmacies!.firstWhere(
          (pharmacy) => pharmacy.id == id,
          orElse: () => throw const NotFoundException('Pharmacie non trouvée'),
        );
      }
      return null;
    } catch (e) {
      if (e is AppException) rethrow;
      return null;
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      _cachedPharmacies = null;
      // In a real implementation, clear local storage
    } catch (e) {
      throw CacheException('Erreur lors de la suppression du cache: ${e.toString()}');
    }
  }
}

