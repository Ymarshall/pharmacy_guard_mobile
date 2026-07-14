import 'package:geolocator/geolocator.dart';
import '../errors/exceptions.dart';

abstract class LocationService {
  Future<Position> getCurrentLocation();
  Future<bool> isLocationServiceEnabled();
  Future<LocationPermission> checkPermission();
  Future<LocationPermission> requestPermission();
  double calculateDistance(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  );
}

class LocationServiceImpl implements LocationService {
  @override
  Future<Position> getCurrentLocation() async {
    try {
      final serviceEnabled = await isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw const LocationException(
          'Les services de localisation sont désactivés',
        );
      }

      final permission = await checkPermission();
      if (permission == LocationPermission.denied) {
        final requested = await requestPermission();
        if (requested == LocationPermission.denied) {
          throw const LocationException(
            'Permission de localisation refusée',
          );
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw const LocationException(
          'Permission de localisation définitivement refusée',
        );
      }

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw const LocationException(
            'Timeout lors de la récupération de la position. '
            'Sur le simulateur, configurez une position dans les paramètres.',
          );
        },
      );
    } on LocationException {
      rethrow;
    } catch (e) {
      throw LocationException('Erreur lors de la récupération de la position: ${e.toString()}');
    }
  }

  @override
  Future<bool> isLocationServiceEnabled() {
    return Geolocator.isLocationServiceEnabled();
  }

  @override
  Future<LocationPermission> checkPermission() {
    return Geolocator.checkPermission();
  }

  @override
  Future<LocationPermission> requestPermission() {
    return Geolocator.requestPermission();
  }

  @override
  double calculateDistance(
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
}

