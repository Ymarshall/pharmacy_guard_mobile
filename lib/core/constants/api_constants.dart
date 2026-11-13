import 'dart:io';

class ApiConstants {
  // Base URL. Override at build time, e.g.:
  // flutter build apk --dart-define=API_BASE_URL=http://169.58.102.35:8081/api
  // Sur Android Emulator, 10.0.2.2 pointe vers le localhost de la machine hôte.
  // Sur iOS Simulator, localhost fonctionne directement.
  static const String _apiBaseUrlFromDefine = String.fromEnvironment('API_BASE_URL');

  static String get baseUrl {
    if (_apiBaseUrlFromDefine.isNotEmpty) {
      return _apiBaseUrlFromDefine;
    }
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:8080/api';
    }
    return 'http://localhost:8080/api';
  }

  // Endpoints
  static const String pharmaciesEndpoint = '/pharmacies';
  static const String searchEndpoint = '/search';
  static const String emergencyNumbersEndpoint = '/emergency-numbers';
  static const String authLoginEndpoint = '/auth/client/login';

  /// `POST /api/auth/client/register`, public. Corps `{ "phone" }` uniquement.
  /// 201 : même forme que le login (`client`, `token`, `tokenType`, `expiresInSeconds`).
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
