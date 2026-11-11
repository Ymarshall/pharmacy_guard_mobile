import 'insurance.dart';

class Pharmacy {
  final String id;
  final String name;
  final String phone1;
  final String? phone2;
  final String? email;
  final String? horaires;
  final String? city;
  final String? commune;
  final String? district;
  final String? description;
  final String? pharmacistName;
  final String? photo;
  final String statut;
  final String? location; // Format "lat,lng", null si pas de GPS
  final double? latitude;
  final double? longitude;
  final List<Insurance> assurances;
  final double? distance; // in kilometers (calculé côté client)
  final bool isOpen; // Calculé côté client
  final bool isOnDuty; // Vient directement de l'API
  final double? averageRating; // Moyenne des notes (0-5)

  const Pharmacy({
    required this.id,
    required this.name,
    required this.phone1,
    this.phone2,
    this.email,
    this.horaires,
    this.city,
    this.commune,
    this.district,
    this.description,
    this.pharmacistName,
    this.photo,
    required this.statut,
    this.location,
    required this.latitude,
    required this.longitude,
    this.assurances = const [],
    this.distance,
    required this.isOpen,
    required this.isOnDuty,
    this.averageRating,
  });

  /// Faux quand le backend envoie `location: null` (pas de coordonnées).
  bool get hasGps => latitude != null && longitude != null;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Pharmacy && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
