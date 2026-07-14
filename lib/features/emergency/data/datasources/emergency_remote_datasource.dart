import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/emergency_number_model.dart';

abstract class EmergencyRemoteDataSource {
  Future<List<EmergencyNumberModel>> getEmergencyNumbers();
}

class EmergencyRemoteDataSourceImpl implements EmergencyRemoteDataSource {
  final ApiClient apiClient;

  EmergencyRemoteDataSourceImpl(this.apiClient);

  @override
  Future<List<EmergencyNumberModel>> getEmergencyNumbers() async {
    try {
      // Essayer d'abord avec getList (si l'API retourne directement une liste)
      List<dynamic> jsonList;
      try {
        jsonList = await apiClient.getList(
          ApiConstants.emergencyNumbersEndpoint,
        );
      } catch (e) {
        // Si getList échoue, essayer avec get (format wrapper)
        final response = await apiClient.get(
          ApiConstants.emergencyNumbersEndpoint,
        );

        // Si l'API retourne un objet avec une clé 'data'
        if (response.containsKey('data') && response['data'] is List) {
          jsonList = response['data'] as List;
        }
        // Si l'API retourne un objet avec une clé 'results'
        else if (response.containsKey('results') && response['results'] is List) {
          jsonList = response['results'] as List;
        }
        // Si l'API retourne directement la liste comme valeur de la clé principale
        else if (response.isNotEmpty && response.values.first is List) {
          jsonList = response.values.first as List;
        }
        else {
          throw const ServerException('Format de réponse API invalide');
        }
      }

      return jsonList
          .map((json) => EmergencyNumberModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on ServerException {
      rethrow;
    } on NetworkException {
      rethrow;
    } catch (e) {
      if (e is AppException) rethrow;
      throw ServerException('Erreur lors de la récupération des numéros d\'urgence: ${e.toString()}');
    }
  }
}

