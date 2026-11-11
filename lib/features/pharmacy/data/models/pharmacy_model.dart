import '../../domain/entities/pharmacy.dart';
import '../../domain/entities/insurance.dart';
import 'insurance_model.dart';

class PharmacyModel extends Pharmacy {
  const PharmacyModel({
    required super.id,
    required super.name,
    required super.phone1,
    super.phone2,
    super.email,
    super.horaires,
    super.city,
    super.commune,
    super.district,
    super.description,
    super.pharmacistName,
    super.photo,
    required super.statut,
    super.location,
    required super.latitude,
    required super.longitude,
    super.assurances,
    super.distance,
    required super.isOpen,
    required super.isOnDuty,
    super.averageRating,
  });

  factory PharmacyModel.fromJson(Map<String, dynamic> json) {
    // L'API peut retourner id comme int ou String
    final idValue = json['id'];
    final id = idValue is int ? idValue.toString() : idValue as String;

    // Parser les assurances
    final assurancesList = json['assurances'] as List<dynamic>?;
    final assurances =
        assurancesList != null
            ? assurancesList
                .map((e) => InsuranceModel.fromJson(e as Map<String, dynamic>))
                .toList()
            : <Insurance>[];

    final coordinates = _readCoordinates(json);
    final latitude = coordinates.$1;
    final longitude = coordinates.$2;
    final hasGps = latitude != null && longitude != null;

    return PharmacyModel(
      id: id,
      name: json['name'] as String,
      phone1: json['phone1'] as String? ?? '',
      phone2: json['phone2'] as String?,
      email: json['email'] as String?,
      horaires: json['horaires'] as String?,
      city: json['city'] as String?,
      commune: json['commune'] as String?,
      district: json['district'] as String?,
      description: json['description'] as String?,
      pharmacistName: json['pharmacistName'] as String?,
      photo: json['photo'] as String?,
      statut: json['statut'] as String? ?? 'ACTIF',
      location: coordinates.$3,
      latitude: latitude,
      longitude: longitude,
      assurances: assurances,
      distance: hasGps ? _readDistance(json) : null,
      isOpen:
          json['isOpen'] as bool? ??
          true, // Par défaut true, à calculer selon horaires
      isOnDuty:
          json['isOnDuty'] as bool? ?? false, // Vient directement de l'API
      averageRating:
          json['averageRating'] != null
              ? ((json['averageRating'] as num?)?.toDouble() ?? null)
              : null,
    );
  }

  static (double?, double?, String?) _readCoordinates(
    Map<String, dynamic> json,
  ) {
    final rawLocation = json['location'];
    final location =
        rawLocation is String && rawLocation.trim().isNotEmpty
            ? rawLocation.trim()
            : null;
    var latitude = _asDouble(json['latitude']);
    var longitude = _asDouble(json['longitude']);
    if ((latitude == null || longitude == null) && location != null) {
      final parts = location.split(',');
      if (parts.length == 2) {
        latitude ??= double.tryParse(parts[0].trim());
        longitude ??= double.tryParse(parts[1].trim());
      }
    }
    if (latitude == null || longitude == null) {
      return (null, null, location);
    }
    return (latitude, longitude, location);
  }

  static double? _asDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  static double? _readDistance(Map<String, dynamic> json) {
    final raw = json['distanceInKm'] ?? json['distance'];
    if (raw == null) return null;
    if (raw is num) return raw.toDouble();
    return double.tryParse(raw.toString());
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone1': phone1,
      'phone2': phone2,
      'email': email,
      'horaires': horaires,
      'city': city,
      'commune': commune,
      'district': district,
      'description': description,
      'pharmacistName': pharmacistName,
      'photo': photo,
      'statut': statut,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'assurances':
          assurances.map((a) => (a as InsuranceModel).toJson()).toList(),
      'distance': distance,
      'isOpen': isOpen,
      'isOnDuty': isOnDuty,
      'averageRating': averageRating,
    };
  }

  PharmacyModel copyWith({
    String? id,
    String? name,
    String? phone1,
    String? phone2,
    String? email,
    String? horaires,
    String? city,
    String? commune,
    String? district,
    String? description,
    String? pharmacistName,
    String? photo,
    String? statut,
    String? location,
    double? latitude,
    double? longitude,
    List<Insurance>? assurances,
    double? distance,
    bool clearDistance = false,
    bool? isOpen,
    bool? isOnDuty,
    double? averageRating,
  }) {
    return PharmacyModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone1: phone1 ?? this.phone1,
      phone2: phone2 ?? this.phone2,
      email: email ?? this.email,
      horaires: horaires ?? this.horaires,
      city: city ?? this.city,
      commune: commune ?? this.commune,
      district: district ?? this.district,
      description: description ?? this.description,
      pharmacistName: pharmacistName ?? this.pharmacistName,
      photo: photo ?? this.photo,
      statut: statut ?? this.statut,
      location: location ?? this.location,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      assurances: assurances ?? this.assurances,
      distance: clearDistance ? null : (distance ?? this.distance),
      isOpen: isOpen ?? this.isOpen,
      isOnDuty: isOnDuty ?? this.isOnDuty,
      averageRating: averageRating ?? this.averageRating,
    );
  }
}
