import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/emergency_number.dart';

abstract class EmergencyRepository {
  Future<Either<Failure, List<EmergencyNumber>>> getEmergencyNumbers();
}

