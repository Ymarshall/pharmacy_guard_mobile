import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/auth_response.dart';

abstract class AuthRepository {
  Future<Either<Failure, AuthResponse>> loginWithPhone(String phone);
  
  Future<Either<Failure, AuthResponse>> createClientAndLogin({
    required String phone,
    required double latitude,
    required double longitude,
  });

  Future<Either<Failure, void>> signOut();

  Future<Either<Failure, AuthResponse?>> getCurrentAuth();
}

