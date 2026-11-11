import '../entities/client.dart';
import '../../../pharmacy/domain/entities/pharmacy.dart';

class AuthResponse {
  final Client client;
  final List<Pharmacy> nearestDutyPharmacies;
  final String? token;
  final String? tokenType;
  final int? expiresInSeconds;

  const AuthResponse({
    required this.client,
    required this.nearestDutyPharmacies,
    this.token,
    this.tokenType,
    this.expiresInSeconds,
  });
}
