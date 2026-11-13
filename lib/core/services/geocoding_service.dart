import 'package:geolocator/geolocator.dart';

class LocationInfo {
  final String city;
  final String commune;

  const LocationInfo({required this.city, required this.commune});

  /// Libellé d'affichage. Jamais un lieu inventé : si la zone est inconnue,
  /// retourne un texte générique.
  String get displayLabel {
    final area = commune.trim();
    final town = city.trim();
    if (area.isNotEmpty && town.isNotEmpty) return '$area, $town';
    if (area.isNotEmpty) return area;
    if (town.isNotEmpty) return town;
    return 'Position actuelle';
  }
}

abstract class GeocodingService {
  Future<LocationInfo> getLocationInfo(double latitude, double longitude);
}

class _GeoPlace {
  const _GeoPlace(
    this.name,
    this.latitude,
    this.longitude, {
    this.isNeighborhood = false,
  });

  final String name;
  final double latitude;
  final double longitude;
  final bool isNeighborhood;
}

/// Centroïdes approximatifs des communes d'Abidjan et de quelques quartiers.
const _places = <_GeoPlace>[
  // Communes
  _GeoPlace('Plateau', 5.3239, -4.0199),
  _GeoPlace('Cocody', 5.3550, -3.9865),
  _GeoPlace('Yopougon', 5.3369, -4.0897),
  _GeoPlace('Marcory', 5.3013, -3.9828),
  _GeoPlace('Treichville', 5.3093, -4.0058),
  _GeoPlace('Adjamé', 5.3535, -4.0267),
  _GeoPlace('Abobo', 5.4182, -4.0162),
  _GeoPlace('Koumassi', 5.2975, -3.9558),
  _GeoPlace('Port-Bouët', 5.2565, -3.9256),
  _GeoPlace('Attécoubé', 5.3325, -4.0410),
  _GeoPlace('Anyama', 5.4947, -4.0519),
  _GeoPlace('Bingerville', 5.3559, -3.8853),
  _GeoPlace('Songon', 5.3190, -4.2530),
  // Quartiers (prioritaires s'ils sont assez proches)
  _GeoPlace('Riviera Palmeraie', 5.3730, -3.9580, isNeighborhood: true),
  _GeoPlace('Riviera 3', 5.3650, -3.9550, isNeighborhood: true),
  _GeoPlace('Riviera Golf', 5.3560, -3.9650, isNeighborhood: true),
  _GeoPlace('Riviera 2', 5.3480, -3.9680, isNeighborhood: true),
  _GeoPlace('Deux Plateaux', 5.3540, -4.0010, isNeighborhood: true),
  _GeoPlace('Angré', 5.3920, -3.9780, isNeighborhood: true),
  _GeoPlace('Cocody Centre', 5.3510, -3.9860, isNeighborhood: true),
];

/// Distance max (m) pour attribuer un quartier, puis une commune.
const _neighborhoodMaxMeters = 2500.0;
const _communeMaxMeters = 25000.0;
const _abidjanMetroMaxMeters = 40000.0;

/// Résout la zone à partir des coordonnées : quartier le plus proche
/// s'il est dans un rayon court, sinon commune, sinon libellé générique.
LocationInfo resolveLocationInfo(double latitude, double longitude) {
  _GeoPlace? nearestNeighborhood;
  var neighborhoodDistance = double.infinity;
  _GeoPlace? nearestCommune;
  var communeDistance = double.infinity;

  for (final place in _places) {
    final distance = Geolocator.distanceBetween(
      latitude,
      longitude,
      place.latitude,
      place.longitude,
    );
    if (place.isNeighborhood) {
      if (distance < neighborhoodDistance) {
        neighborhoodDistance = distance;
        nearestNeighborhood = place;
      }
    } else if (distance < communeDistance) {
      communeDistance = distance;
      nearestCommune = place;
    }
  }

  if (nearestNeighborhood != null &&
      neighborhoodDistance <= _neighborhoodMaxMeters) {
    return LocationInfo(city: 'Abidjan', commune: nearestNeighborhood.name);
  }
  if (nearestCommune != null && communeDistance <= _communeMaxMeters) {
    return LocationInfo(city: 'Abidjan', commune: nearestCommune.name);
  }
  if (nearestCommune != null && communeDistance <= _abidjanMetroMaxMeters) {
    return const LocationInfo(city: 'Abidjan', commune: '');
  }
  return const LocationInfo(city: '', commune: '');
}

class GeocodingServiceImpl implements GeocodingService {
  @override
  Future<LocationInfo> getLocationInfo(
    double latitude,
    double longitude,
  ) async {
    return resolveLocationInfo(latitude, longitude);
  }
}
