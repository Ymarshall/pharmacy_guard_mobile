import '../../domain/entities/client.dart';

class ClientModel extends Client {
  const ClientModel({
    required super.id,
    required super.phone,
    required super.latitude,
    required super.longitude,
    required super.providerType,
    required super.isActive,
  });

  factory ClientModel.fromJson(Map<String, dynamic> json) {
    return ClientModel(
      id: json['id'] as int,
      phone: json['phone'] as String,
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      providerType: json['providerType'] as String? ?? 'PHONE',
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phone': phone,
      'latitude': latitude,
      'longitude': longitude,
      'providerType': providerType,
      'isActive': isActive,
    };
  }
}

