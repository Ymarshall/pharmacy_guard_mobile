import 'package:permission_handler/permission_handler.dart';
import '../errors/exceptions.dart';

abstract class PermissionService {
  Future<bool> requestLocationPermission();
  Future<bool> checkLocationPermission();
  Future<bool> requestNotificationPermission();
  Future<bool> checkNotificationPermission();
}

class PermissionServiceImpl implements PermissionService {
  @override
  Future<bool> requestLocationPermission() async {
    try {
      final status = await Permission.location.request();
      return status.isGranted;
    } catch (e) {
      throw PermissionException(
        'Erreur lors de la demande de permission de localisation: ${e.toString()}',
      );
    }
  }

  @override
  Future<bool> checkLocationPermission() async {
    try {
      final status = await Permission.location.status;
      return status.isGranted;
    } catch (e) {
      throw PermissionException(
        'Erreur lors de la vérification de la permission de localisation: ${e.toString()}',
      );
    }
  }

  @override
  Future<bool> requestNotificationPermission() async {
    try {
      final status = await Permission.notification.request();
      return status.isGranted;
    } catch (e) {
      throw PermissionException(
        'Erreur lors de la demande de permission de notification: ${e.toString()}',
      );
    }
  }

  @override
  Future<bool> checkNotificationPermission() async {
    try {
      final status = await Permission.notification.status;
      return status.isGranted;
    } catch (e) {
      throw PermissionException(
        'Erreur lors de la vérification de la permission de notification: ${e.toString()}',
      );
    }
  }
}

