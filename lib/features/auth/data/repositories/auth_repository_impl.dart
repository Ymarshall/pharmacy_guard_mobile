import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/auth_response.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/auth_response_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, AuthResponse>> loginWithPhone(String phone) async {
    try {
      final authResponse = await remoteDataSource.login(phone);
      await localDataSource.cacheAuthResponse(authResponse);
      return Right(authResponse);
    } on NotFoundException {
      // Client n'existe pas, on doit le créer avec géolocalisation
      return Left(NotFoundFailure('Client non trouvé. Veuillez activer votre géolocalisation pour créer un compte.'));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      if (e is AppException) {
        return Left(ServerFailure(e.message));
      }
      return Left(ServerFailure('Erreur lors de la connexion: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, AuthResponse>> createClientAndLogin({
    required String phone,
    required double latitude,
    required double longitude,
  }) async {
    try {
      // Créer le client
      final createdClient = await remoteDataSource.createClient(
        phone: phone,
        latitude: latitude,
        longitude: longitude,
      );
      
      // Puis se connecter pour obtenir la réponse complète avec les pharmacies
      final authResponse = await remoteDataSource.login(phone);
      await localDataSource.cacheAuthResponse(authResponse);
      return Right(authResponse);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      if (e is AppException) {
        return Left(ServerFailure(e.message));
      }
      return Left(ServerFailure('Erreur lors de la création du compte: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await localDataSource.clearCache();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Erreur lors de la déconnexion: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, AuthResponse?>> getCurrentAuth() async {
    try {
      final authResponse = await localDataSource.getCachedAuthResponse();
      return Right(authResponse);
    } catch (e) {
      return Left(CacheFailure('Erreur lors de la récupération de l\'authentification: ${e.toString()}'));
    }
  }
}
