import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/pharmacy.dart';
import '../repositories/pharmacy_repository.dart';

class GetPharmaciesOnDuty implements UseCase<List<Pharmacy>, GetPharmaciesOnDutyParams> {
  final PharmacyRepository repository;

  GetPharmaciesOnDuty(this.repository);

  @override
  Future<Either<Failure, List<Pharmacy>>> call(GetPharmaciesOnDutyParams params) async {
    return await repository.getPharmaciesOnDuty(
      latitude: params.latitude,
      longitude: params.longitude,
      radius: params.radius,
    );
  }
}

class GetPharmaciesOnDutyParams {
  final double latitude;
  final double longitude;
  final double radius;

  GetPharmaciesOnDutyParams({
    required this.latitude,
    required this.longitude,
    this.radius = 10.0,
  });
}

