import 'dart:async';

import 'package:geolocator/geolocator.dart';
import '../errors/exceptions.dart';

/// Évite de reposer la question système juste après un refus
/// (ex. refus à l'inscription, puis arrivée sur l'accueil).
class LocationPrompt {
  LocationPrompt._();
  static bool askedThisSession = false;
}

abstract class LocationService {
  /// Position actuelle. Ne bloque jamais plus de ~15 s : lève une
  /// [LocationException] (avec sa [LocationIssue]) si la localisation est
  /// désactivée, refusée ou trop lente.
  Future<Position> getCurrentLocation({bool requestPermission = true});
  Future<bool> isLocationServiceEnabled();
  Future<LocationPermission> checkPermission();
  Future<LocationPermission> requestPermission();

  /// Ouvre l'écran système adapté (réglages de localisation ou de l'app).
  Future<bool> openSettingsFor(LocationIssue issue);

  double calculateDistance(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  );
}

class LocationServiceImpl implements LocationService {
  static const Duration _platformCallTimeout = Duration(seconds: 5);
  static const Duration _positionTimeout = Duration(seconds: 12);

  @override
  Future<Position> getCurrentLocation({bool requestPermission = true}) async {
    try {
      final serviceEnabled = await isLocationServiceEnabled().timeout(
        _platformCallTimeout,
        onTimeout: () => true,
      );
      if (!serviceEnabled) {
        throw const LocationException(
          'La localisation de votre téléphone est désactivée.',
          issue: LocationIssue.serviceDisabled,
        );
      }

      var permission = await checkPermission().timeout(
        _platformCallTimeout,
        onTimeout: () => LocationPermission.denied,
      );
      if (permission == LocationPermission.denied && requestPermission) {
        // Pas de timeout ici : l'utilisateur répond à la boîte système.
        LocationPrompt.askedThisSession = true;
        permission = await this.requestPermission();
      }
      if (permission == LocationPermission.deniedForever) {
        throw const LocationException(
          'L\'accès à la position est bloqué pour cette application.',
          issue: LocationIssue.deniedForever,
        );
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.unableToDetermine) {
        throw const LocationException(
          'Permission de localisation refusée.',
          issue: LocationIssue.denied,
        );
      }

      try {
        return await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            timeLimit: Duration(seconds: 10),
          ),
        ).timeout(_positionTimeout);
      } on TimeoutException {
        final last = await Geolocator.getLastKnownPosition().timeout(
          _platformCallTimeout,
          onTimeout: () => null,
        );
        if (last != null) return last;
        throw const LocationException(
          'Impossible d\'obtenir votre position pour le moment.',
          issue: LocationIssue.timeout,
        );
      }
    } on LocationException {
      rethrow;
    } on PermissionDeniedException {
      throw const LocationException(
        'Permission de localisation refusée.',
        issue: LocationIssue.denied,
      );
    } on LocationServiceDisabledException {
      throw const LocationException(
        'La localisation de votre téléphone est désactivée.',
        issue: LocationIssue.serviceDisabled,
      );
    } catch (e) {
      throw LocationException(
        'Erreur lors de la récupération de la position: ${e.toString()}',
      );
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
  Future<bool> openSettingsFor(LocationIssue issue) {
    if (issue == LocationIssue.serviceDisabled) {
      return Geolocator.openLocationSettings();
    }
    return Geolocator.openAppSettings();
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
        ) /
        1000; // Convert to kilometers
  }
}
