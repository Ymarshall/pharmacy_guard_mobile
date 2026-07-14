import '../../domain/entities/auth_response.dart';
import '../../domain/entities/client.dart';
import 'client_model.dart';
import '../../../pharmacy/data/models/pharmacy_model.dart';

class AuthResponseModel extends AuthResponse {
  const AuthResponseModel({
    required super.client,
    required super.nearestDutyPharmacies,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      client: ClientModel.fromJson(json['client'] as Map<String, dynamic>),
      nearestDutyPharmacies: (json['nearestDutyPharmacies'] as List<dynamic>?)
              ?.map((pharmacyJson) => PharmacyModel.fromJson(pharmacyJson as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'client': (client as ClientModel).toJson(),
      'nearestDutyPharmacies': nearestDutyPharmacies
          .map((pharmacy) => (pharmacy as PharmacyModel).toJson())
          .toList(),
    };
  }
}

