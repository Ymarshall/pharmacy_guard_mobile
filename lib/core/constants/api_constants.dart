import 'dart:io';

class ApiConstants {
  // Base URL
  // Sur Android Emulator, utiliser 10.0.2.2 pour accéder à localhost de la machine hôte
  // Sur iOS Simulator, localhost fonctionne directement
  static String get baseUrl {
    if (Platform.isAndroid) {
      // Android Emulator
      return 'http://10.0.2.2:8080/api';
    } else {
      // iOS Simulator ou autres plateformes
      return 'http://localhost:8080/api';
    }
  }

  // Endpoints
  static const String pharmaciesEndpoint = '/pharmacies';
  static const String searchEndpoint = '/search';
  static const String emergencyNumbersEndpoint = '/emergency-numbers';
  static const String authLoginEndpoint = '/auth/client/login';

  /// Inscription publique. Seul ce chemin est à ajuster quand le contrat
  /// backend sera figé. La réponse attendue est celle du login :
  /// `client`, `token`, `tokenType`, `expiresInSeconds`.
  static const String clientRegisterEndpoint = '/auth/client/register';
  static const String clientsEndpoint = '/clients';
  static const String nearestDutyPharmaciesEndpoint =
      '/client/pharmacies/nearest-duty';
  static const String nearestPharmaciesEndpoint = '/client/pharmacies/nearest';

  // Review endpoints
  static String pharmacyReviewsEndpoint(int pharmacyId) =>
      '/client/pharmacies/$pharmacyId/reviews';
  static String updateReviewEndpoint(int reviewId) =>
      '/client/pharmacies/reviews/$reviewId';
  static String deleteReviewEndpoint(int reviewId) =>
      '/client/pharmacies/reviews/$reviewId';
  static String pharmacyRatingSummaryEndpoint(int pharmacyId) =>
      '/client/pharmacies/$pharmacyId/rating-summary';

  // Report endpoints
  static const String reportDutyEndpoint = '/client/pharmacies/duty/report';

  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
