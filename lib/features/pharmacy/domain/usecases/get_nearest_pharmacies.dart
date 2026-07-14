import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/pharmacy.dart';
import '../repositories/pharmacy_repository.dart';

class GetNearestPharmacies implements UseCase<List<Pharmacy>, GetNearestPharmaciesParams> {
  final PharmacyRepository repository;

  GetNearestPharmacies(this.repository);

  @override
  Future<Either<Failure, List<Pharmacy>>> call(GetNearestPharmaciesParams params) async {
    return await repository.getNearestPharmacies(
      latitude: params.latitude,
      longitude: params.longitude,
      radius: params.radius,
    );
  }
}

class GetNearestPharmaciesParams {
  final double latitude;
  final double longitude;
  final double radius;

  GetNearestPharmaciesParams({
    required this.latitude,
    required this.longitude,
    this.radius = 10.0,
  });
}

