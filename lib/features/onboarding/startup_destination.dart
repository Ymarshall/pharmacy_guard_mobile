import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/storage_keys.dart';

enum AppStart { onboarding, login, home }

/// Décision connue avant le premier écran : pas d'onboarding si le booléen est déjà vrai.
AppStart resolveAppStart({
  required bool onboardingCompleted,
  required bool hasValidSession,
}) {
  if (!onboardingCompleted) return AppStart.onboarding;
  if (hasValidSession) return AppStart.home;
  return AppStart.login;
}

/// Lit `onboardingCompleted`. Reprend l'ancienne clé une seule fois.
Future<bool> loadOnboardingCompleted(SharedPreferences prefs) async {
  if (prefs.getBool(StorageKeys.onboardingCompleted) == true) return true;
  if (prefs.getBool('has_seen_onboarding') == true) {
    await prefs.setBool(StorageKeys.onboardingCompleted, true);
    return true;
  }
  return false;
}
