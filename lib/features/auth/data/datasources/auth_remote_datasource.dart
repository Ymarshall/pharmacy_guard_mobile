import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/auth_response_model.dart';

abstract class AuthRemoteDataSource {
  Future<AuthResponseModel> login(String phone);

  /// Inscription publique. Seul [ApiConstants.clientRegisterEndpoint] change
  /// quand le contrat backend est figé. La réponse a la forme du login.
  Future<AuthResponseModel> register({required String phone});

  Future<void> updateLocation({
    required int clientId,
    required double latitude,
    required double longitude,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient apiClient;

  AuthRemoteDataSourceImpl(this.apiClient);

  @override
  Future<AuthResponseModel> login(String phone) async {
    try {
      final response = await apiClient.post(
        ApiConstants.authLoginEndpoint,
        body: {'phone': phone},
      );
      return AuthResponseModel.fromJson(response);
    } on NotFoundException {
      rethrow;
    } on ServerException {
      rethrow;
    } on NetworkException {
      rethrow;
    } catch (e) {
      if (e is AppException) rethrow;
      throw ServerException('Erreur lors de la connexion: ${e.toString()}');
    }
  }

  @override
  Future<AuthResponseModel> register({required String phone}) async {
    try {
      final response = await apiClient.post(
        ApiConstants.clientRegisterEndpoint,
        body: {'phone': phone},
      );
      return AuthResponseModel.fromJson(response);
    } on ServerException {
      rethrow;
    } on NetworkException {
      rethrow;
    } catch (e) {
      if (e is AppException) rethrow;
      throw ServerException(
        'Erreur lors de la création du compte: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> updateLocation({
    required int clientId,
    required double latitude,
    required double longitude,
  }) async {
    try {
      await apiClient.put(
        '${ApiConstants.clientsEndpoint}/$clientId/location',
        body: {'latitude': latitude, 'longitude': longitude},
      );
    } on ServerException {
      rethrow;
    } on NetworkException {
      rethrow;
    } catch (e) {
      if (e is AppException) rethrow;
      throw ServerException(
        'Erreur lors de la mise à jour de la position: ${e.toString()}',
      );
    }
  }
}
