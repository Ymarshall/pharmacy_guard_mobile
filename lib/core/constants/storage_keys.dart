class StorageKeys {
  // User preferences
  static const String userLocation = 'user_location';
  static const String searchRadius = 'search_radius';
  static const String favoritePharmacies = 'favorite_pharmacies';

  // App state
  static const String lastSearch = 'last_search';
  static const String notificationsEnabled = 'notifications_enabled';

  /// Thème sombre choisi par l'utilisateur. Absent ou false = thème clair.
  static const String darkModeEnabled = 'dark_mode_enabled';

  /// L'onboarding a été quitté via « Terminer » ou « Passer ».
  /// Une déconnexion ne remet pas cette valeur à false.
  static const String onboardingCompleted = 'onboardingCompleted';

  // Cache keys
  static const String emergencyNumbersCache = 'emergency_numbers_cache';

  // Jeton client (stockage sécurisé, jamais dans SharedPreferences).
  static const String accessToken = 'client_access_token';
  static const String accessTokenType = 'client_access_token_type';
  static const String accessTokenExpiresAt = 'client_access_token_expires_at';
}
