import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/auth_response.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../../../core/security/token_vault.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/auth_response_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;
  final TokenVault tokenVault;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.tokenVault,
  });

  @override
  Future<Either<Failure, AuthResponse>> loginWithPhone(String phone) async {
    try {
      final authResponse = await remoteDataSource.login(phone);
      await _persistSession(authResponse);
      return Right(authResponse);
    } on NotFoundException {
      // Client n'existe pas, on doit le créer avec géolocalisation
      return Left(
        NotFoundFailure(
          'Client non trouvé. Veuillez activer votre géolocalisation pour créer un compte.',
        ),
      );
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      if (e is AppException) {
        return Left(ServerFailure(e.message));
      }
      return Left(
        ServerFailure('Erreur lors de la connexion: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, AuthResponse>> registerClient({
    required String phone,
  }) async {
    try {
      final authResponse = await remoteDataSource.register(phone: phone);
      await _persistSession(authResponse);
      return Right(authResponse);
    } on ConflictException catch (e) {
      return Left(ConflictFailure(e.message));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message, fieldErrors: e.fieldErrors));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      if (e is AppException) {
        return Left(ServerFailure(e.message));
      }
      return Left(
        ServerFailure('Erreur lors de la création du compte: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> updateLocation({
    required int clientId,
    required double latitude,
    required double longitude,
  }) async {
    try {
      await remoteDataSource.updateLocation(
        clientId: clientId,
        latitude: latitude,
        longitude: longitude,
      );
      return const Right(null);
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message, fieldErrors: e.fieldErrors));
    } on UnauthorizedException catch (e) {
      return Left(ServerFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      if (e is AppException) {
        return Left(ServerFailure(e.message));
      }
      return Left(
        ServerFailure(
          'Erreur lors de la mise à jour de la position: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await tokenVault.clear();
      await localDataSource.clearCache();
      return const Right(null);
    } catch (e) {
      return Left(
        ServerFailure('Erreur lors de la déconnexion: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, AuthResponse?>> getCurrentAuth() async {
    try {
      final authResponse = await localDataSource.getCachedAuthResponse();
      if (authResponse == null) return const Right(null);
      final stored = await tokenVault.readValid();
      if (stored == null) {
        await localDataSource.clearCache();
        return const Right(null);
      }
      return Right(
        AuthResponseModel(
          client: authResponse.client,
          nearestDutyPharmacies: authResponse.nearestDutyPharmacies,
          token: stored.token,
          tokenType: stored.tokenType,
          expiresInSeconds:
              stored.expiresAt.difference(DateTime.now()).inSeconds,
        ),
      );
    } catch (e) {
      return Left(
        CacheFailure(
          'Erreur lors de la récupération de l\'authentification: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> _persistSession(AuthResponseModel authResponse) async {
    await localDataSource.cacheAuthResponse(authResponse);
    final token = authResponse.token;
    final expiresInSeconds = authResponse.expiresInSeconds;
    if (token != null && token.isNotEmpty && expiresInSeconds != null) {
      await tokenVault.save(
        token: token,
        tokenType: authResponse.tokenType ?? 'Bearer',
        expiresInSeconds: expiresInSeconds,
      );
    } else {
      await tokenVault.clear();
    }
  }
}
