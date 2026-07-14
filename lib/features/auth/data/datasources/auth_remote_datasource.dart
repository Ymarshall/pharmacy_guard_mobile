import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/auth_response_model.dart';
import '../models/client_model.dart';

abstract class AuthRemoteDataSource {
  Future<AuthResponseModel> login(String phone);
  Future<ClientModel> createClient({
    required String phone,
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
      // Client n'existe pas, on doit le créer
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
  Future<ClientModel> createClient({
    required String phone,
    required double latitude,
    required double longitude,
  }) async {
    try {
      final response = await apiClient.post(
        ApiConstants.clientsEndpoint,
        body: {
          'phone': phone,
          'latitude': latitude,
          'longitude': longitude,
          'isActive': true,
        },
      );
      return ClientModel.fromJson(response);
    } on ServerException {
      rethrow;
    } on NetworkException {
      rethrow;
    } catch (e) {
      if (e is AppException) rethrow;
      throw ServerException('Erreur lors de la création du client: ${e.toString()}');
    }
  }
}

