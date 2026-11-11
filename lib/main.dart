import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app.dart';
import 'features/onboarding/startup_destination.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Plus Jakarta Sans est embarquée (assets/fonts). Pas de téléchargement.
  GoogleFonts.config.allowRuntimeFetching = false;
  // Lu avant le premier rendu : le splash connaît déjà la destination.
  final prefs = await SharedPreferences.getInstance();
  final onboardingCompleted = await loadOnboardingCompleted(prefs);
  runApp(
    App(sharedPreferences: prefs, onboardingCompleted: onboardingCompleted),
  );
}
