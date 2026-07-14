import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/pharmacy.dart';

abstract class PharmacyRepository {
  Future<Either<Failure, List<Pharmacy>>> getAllPharmacies();

  Future<Either<Failure, List<Pharmacy>>> getNearestDutyPharmacies({
    required double latitude,
    required double longitude,
    int limit = 3,
  });

  Future<Either<Failure, List<Pharmacy>>> getNearestPharmacies({
    required double latitude,
    required double longitude,
    double radius = 10.0,
  });

  Future<Either<Failure, List<Pharmacy>>> getPharmaciesOnDuty({
    required double latitude,
    required double longitude,
    double radius = 10.0,
  });

  Future<Either<Failure, Pharmacy>> getPharmacyById(String id);
}

