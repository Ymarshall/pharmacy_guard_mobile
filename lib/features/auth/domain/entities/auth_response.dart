import '../entities/client.dart';
import '../../../pharmacy/domain/entities/pharmacy.dart';

class AuthResponse {
  final Client client;
  final List<Pharmacy> nearestDutyPharmacies;

  const AuthResponse({
    required this.client,
    required this.nearestDutyPharmacies,
  });
}

