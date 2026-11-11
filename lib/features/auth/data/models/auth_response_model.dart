import '../../domain/entities/auth_response.dart';
import 'client_model.dart';
import '../../../pharmacy/data/models/pharmacy_model.dart';

class AuthResponseModel extends AuthResponse {
  const AuthResponseModel({
    required super.client,
    required super.nearestDutyPharmacies,
    super.token,
    super.tokenType,
    super.expiresInSeconds,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      client: ClientModel.fromJson(json['client'] as Map<String, dynamic>),
      nearestDutyPharmacies:
          (json['nearestDutyPharmacies'] as List<dynamic>?)
              ?.map(
                (pharmacyJson) => PharmacyModel.fromJson(
                  pharmacyJson as Map<String, dynamic>,
                ),
              )
              .toList() ??
          [],
      token: json['token'] as String?,
      tokenType: json['tokenType'] as String?,
      expiresInSeconds: (json['expiresInSeconds'] as num?)?.toInt(),
    );
  }

  /// Le jeton n'est pas sérialisé ici : il vit dans le coffre sécurisé.
  Map<String, dynamic> toJson() {
    return {
      'client': (client as ClientModel).toJson(),
      'nearestDutyPharmacies':
          nearestDutyPharmacies
              .map((pharmacy) => (pharmacy as PharmacyModel).toJson())
              .toList(),
    };
  }
}
