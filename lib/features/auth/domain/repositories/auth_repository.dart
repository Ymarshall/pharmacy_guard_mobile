import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/auth_response.dart';

abstract class AuthRepository {
  Future<Either<Failure, AuthResponse>> loginWithPhone(String phone);

  /// Numéro inconnu : inscrit, stocke le jeton, puis la position est envoyée à part.
  Future<Either<Failure, AuthResponse>> registerClient({required String phone});

  Future<Either<Failure, void>> updateLocation({
    required int clientId,
    required double latitude,
    required double longitude,
  });

  Future<Either<Failure, void>> signOut();

  Future<Either<Failure, AuthResponse?>> getCurrentAuth();
}
