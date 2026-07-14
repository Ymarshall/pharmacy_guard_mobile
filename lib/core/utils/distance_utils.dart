import 'package:geolocator/geolocator.dart';

class DistanceUtils {
  /// Calcule la distance entre deux points en kilomètres
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
    ) / 1000; // Convert to kilometers
  }

  /// Formate la distance en texte lisible
  static String formatDistance(double distanceInKm) {
    if (distanceInKm < 1) {
      return '${(distanceInKm * 1000).round()} m';
    } else {
      return '${distanceInKm.toStringAsFixed(1)} km';
    }
  }

  /// Calcule le temps de marche en minutes
  /// Vitesse moyenne de marche : 5 km/h
  static int calculateWalkingTime(double distanceInKm) {
    const walkingSpeedKmPerHour = 5.0;
    final timeInHours = distanceInKm / walkingSpeedKmPerHour;
    return (timeInHours * 60).round();
  }

  /// Calcule le temps de trajet en voiture en minutes
  /// Vitesse moyenne en ville : 30 km/h
  static int calculateDrivingTime(double distanceInKm) {
    const drivingSpeedKmPerHour = 30.0;
    final timeInHours = distanceInKm / drivingSpeedKmPerHour;
    return (timeInHours * 60).round();
  }

  /// Formate le temps de marche
  static String formatWalkingTime(double distanceInKm) {
    final minutes = calculateWalkingTime(distanceInKm);
    if (minutes < 1) {
      return '< 1 min';
    } else if (minutes == 1) {
      return '1 min';
    } else {
      return '$minutes min';
    }
  }

  /// Formate le temps de trajet en voiture
  static String formatDrivingTime(double distanceInKm) {
    final minutes = calculateDrivingTime(distanceInKm);
    if (minutes < 1) {
      return '< 1 min';
    } else if (minutes == 1) {
      return '1 min';
    } else {
      return '$minutes min';
    }
  }
}
