import 'package:geolocator/geolocator.dart';

/// Distances et temps de trajet **estimés**.
///
/// La distance fournie par l'API (ou calculée ici) est une distance à vol
/// d'oiseau. Un trajet réel en ville est plus long (détours, sens uniques,
/// ponts) et plus lent (feux, embouteillages, stationnement). Les temps
/// sont donc des estimations, affichées précédées de « ≈ ».
class DistanceUtils {
  /// Rapport moyen distance routière / distance à vol d'oiseau en ville.
  static const double roadFactor = 1.4;

  /// Vitesse moyenne en voiture à Abidjan, circulation comprise.
  static const double drivingSpeedKmPerHour = 22.0;

  /// Temps fixe en voiture : démarrer, sortir du quartier, se garer.
  static const int drivingOverheadMinutes = 2;

  /// Temps minimal affiché en voiture.
  static const int minDrivingMinutes = 3;

  /// Vitesse moyenne à pied.
  static const double walkingSpeedKmPerHour = 4.5;

  /// `null` dès qu'une coordonnée manque : aucune distance n'est affichée.
  static double? distanceIfPossible(
    double? startLatitude,
    double? startLongitude,
    double? endLatitude,
    double? endLongitude,
  ) {
    if (startLatitude == null ||
        startLongitude == null ||
        endLatitude == null ||
        endLongitude == null) {
      return null;
    }
    return calculateDistance(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }

  /// Distance à vol d'oiseau entre deux points, en kilomètres.
  static double calculateDistance(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    return Geolocator.distanceBetween(
          startLatitude,
          startLongitude,
          endLatitude,
          endLongitude,
        ) /
        1000;
  }

  /// Distance routière estimée à partir de la distance à vol d'oiseau.
  static double estimateRoadDistance(double straightLineKm) =>
      straightLineKm * roadFactor;

  /// Formate la distance en texte lisible
  static String formatDistance(double distanceInKm) {
    if (distanceInKm < 1) {
      return '${(distanceInKm * 1000).round()} m';
    } else {
      return '${distanceInKm.toStringAsFixed(1)} km';
    }
  }

  /// Temps de marche estimé, en minutes (au moins 1).
  static int calculateWalkingTime(double distanceInKm) {
    final road = estimateRoadDistance(distanceInKm);
    final minutes = (road / walkingSpeedKmPerHour * 60).round();
    return minutes < 1 ? 1 : minutes;
  }

  /// Temps de trajet estimé en voiture, en minutes.
  static int calculateDrivingTime(double distanceInKm) {
    final road = estimateRoadDistance(distanceInKm);
    final minutes =
        (road / drivingSpeedKmPerHour * 60).round() + drivingOverheadMinutes;
    return minutes < minDrivingMinutes ? minDrivingMinutes : minutes;
  }

  static String _formatMinutes(int minutes) {
    if (minutes < 60) return '≈ $minutes min';
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return m == 0 ? '≈ $h h' : '≈ $h h ${m.toString().padLeft(2, '0')}';
  }

  /// Formate le temps de marche estimé, ex. « ≈ 12 min ».
  static String formatWalkingTime(double distanceInKm) =>
      _formatMinutes(calculateWalkingTime(distanceInKm));

  /// Formate le temps de trajet estimé en voiture, ex. « ≈ 7 min ».
  static String formatDrivingTime(double distanceInKm) =>
      _formatMinutes(calculateDrivingTime(distanceInKm));
}
