import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/data/mock_pharmacies.dart';
import '../models/pharmacy_model.dart';

abstract class PharmacyRemoteDataSource {
  Future<List<PharmacyModel>> getAllPharmacies();

  Future<List<PharmacyModel>> getNearestDutyPharmacies({
    required double latitude,
    required double longitude,
    int limit = 3,
  });

  Future<List<PharmacyModel>> getNearestPharmacies({
    required double latitude,
    required double longitude,
    double radius = 10.0,
  });

  Future<List<PharmacyModel>> getPharmaciesOnDuty({
    required double latitude,
    required double longitude,
    double radius = 10.0,
  });

  Future<PharmacyModel> getPharmacyById(String id);
}

class PharmacyRemoteDataSourceImpl implements PharmacyRemoteDataSource {
  final ApiClient apiClient;

  PharmacyRemoteDataSourceImpl(this.apiClient);

  @override
  Future<List<PharmacyModel>> getAllPharmacies() async {
    try {
      final response = await apiClient.getList(
        ApiConstants.pharmaciesEndpoint,
      );
      
      return response
          .map((json) => PharmacyModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on ServerException {
      rethrow;
    } on NetworkException {
      rethrow;
    } catch (e) {
      if (e is AppException) rethrow;
      throw ServerException('Erreur lors de la récupération des pharmacies: ${e.toString()}');
    }
  }

  @override
  Future<List<PharmacyModel>> getNearestDutyPharmacies({
    required double latitude,
    required double longitude,
    int limit = 3,
  }) async {
    try {
      final queryParams = {
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        'limit': limit.toString(),
      };
      final response = await apiClient.getList(
        ApiConstants.nearestDutyPharmaciesEndpoint,
        queryParameters: queryParams,
      );
      
      return response
          .map((json) => PharmacyModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on ServerException {
      rethrow;
    } on NetworkException {
      rethrow;
    } catch (e) {
      if (e is AppException) rethrow;
      throw ServerException('Erreur lors de la récupération des pharmacies: ${e.toString()}');
    }
  }

  @override
  Future<List<PharmacyModel>> getNearestPharmacies({
    required double latitude,
    required double longitude,
    double radius = 10.0,
  }) async {
    try {
      final queryParams = {
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        'limit': '3', // Limite de 3 pour les pharmacies les plus proches
      };
      final response = await apiClient.getList(
        ApiConstants.nearestPharmaciesEndpoint,
        queryParameters: queryParams,
      );
      
      return response
          .map((json) => PharmacyModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on ServerException {
      rethrow;
    } on NetworkException {
      rethrow;
    } catch (e) {
      if (e is AppException) rethrow;
      throw ServerException('Erreur lors de la récupération des pharmacies les plus proches: ${e.toString()}');
    }
  }

  @override
  Future<List<PharmacyModel>> getPharmaciesOnDuty({
    required double latitude,
    required double longitude,
    double radius = 10.0,
  }) async {
    // Utiliser les données factices pour l'instant
    await Future.delayed(const Duration(milliseconds: 500)); // Simuler un délai réseau
    
    final mockPharmacies = MockPharmacies.getPharmacies(
      userLatitude: latitude,
      userLongitude: longitude,
    );
    
    // Filtrer par rayon et garde, puis convertir en modèles
    // Note: Les données viennent maintenant de l'API, ce code n'est plus utilisé
    return mockPharmacies
        .where((p) => p.isOnDuty && p.distance != null && p.distance! <= radius)
        .map((p) => PharmacyModel.fromJson({
              'id': p.id,
              'name': p.name,
              'phone1': p.phone1,
              'phone2': p.phone2,
              'email': p.email,
              'horaires': p.horaires,
              'city': p.city,
              'commune': p.commune,
              'district': p.district,
              'description': p.description,
              'pharmacistName': p.pharmacistName,
              'photo': p.photo,
              'statut': p.statut,
              'location': '${p.latitude},${p.longitude}',
              'latitude': p.latitude,
              'longitude': p.longitude,
              'assurances': p.assurances.map((a) => {'id': a.id, 'name': a.name, 'description': a.description}).toList(),
              'distanceInKm': p.distance,
              'isOpen': p.isOpen,
              'isOnDuty': p.isOnDuty,
              'averageRating': null, // Données mockées, pas de rating
            }))
        .toList();
  }

  @override
  Future<PharmacyModel> getPharmacyById(String id) async {
    // Utiliser les données factices pour l'instant
    await Future.delayed(const Duration(milliseconds: 300)); // Simuler un délai réseau
    
    final mockPharmacies = MockPharmacies.getPharmacies();
    final pharmacy = mockPharmacies.firstWhere(
      (p) => p.id == id,
      orElse: () => throw const NotFoundException('Pharmacie non trouvée'),
    );
    
    return PharmacyModel.fromJson({
      'id': pharmacy.id,
      'name': pharmacy.name,
      'phone1': pharmacy.phone1,
      'phone2': pharmacy.phone2,
      'email': pharmacy.email,
      'horaires': pharmacy.horaires,
      'city': pharmacy.city,
      'commune': pharmacy.commune,
      'district': pharmacy.district,
      'description': pharmacy.description,
      'pharmacistName': pharmacy.pharmacistName,
      'photo': pharmacy.photo,
      'statut': pharmacy.statut,
      'location': '${pharmacy.latitude},${pharmacy.longitude}',
      'latitude': pharmacy.latitude,
      'longitude': pharmacy.longitude,
      'assurances': pharmacy.assurances.map((a) => {'id': a.id, 'name': a.name, 'description': a.description}).toList(),
      'distanceInKm': pharmacy.distance,
      'isOpen': pharmacy.isOpen,
      'isOnDuty': pharmacy.isOnDuty,
      'averageRating': null, // Données mockées, pas de rating
    });
  }
}

