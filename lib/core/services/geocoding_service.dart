import 'package:geolocator/geolocator.dart';

class LocationInfo {
  final String city;
  final String commune;

  const LocationInfo({
    required this.city,
    required this.commune,
  });
}

abstract class GeocodingService {
  Future<LocationInfo> getLocationInfo(double latitude, double longitude);
}

class GeocodingServiceImpl implements GeocodingService {
  @override
  Future<LocationInfo> getLocationInfo(double latitude, double longitude) async {
    // Pour l'instant, utiliser des données factices basées sur les coordonnées
    // En production, utiliser un service de géocodage inverse comme Google Geocoding API
    
    // Coordonnées approximatives d'Abidjan
    // Abidjan: ~5.3600, -4.0083
    // Plateau: ~5.32, -4.03
    // Cocody: ~5.35, -4.01
    // Yopougon: ~5.33, -4.05
    
    // Déterminer la commune basée sur les coordonnées
    String commune;
    String city = 'Abidjan';
    
    if (latitude >= 5.30 && latitude <= 5.35 && longitude >= -4.04 && longitude <= -4.00) {
      commune = 'Plateau';
    } else if (latitude >= 5.34 && latitude <= 5.38 && longitude >= -4.02 && longitude <= -3.98) {
      commune = 'Cocody';
    } else if (latitude >= 5.30 && latitude <= 5.36 && longitude >= -4.06 && longitude <= -4.02) {
      commune = 'Yopougon';
    } else if (latitude >= 5.28 && latitude <= 5.32 && longitude >= -4.02 && longitude <= -3.98) {
      commune = 'Marcory';
    } else {
      // Par défaut, utiliser Plateau
      commune = 'Plateau';
    }
    
    return LocationInfo(city: city, commune: commune);
  }
}

