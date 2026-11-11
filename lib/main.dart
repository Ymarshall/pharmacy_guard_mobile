import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Plus Jakarta Sans est embarquée (assets/fonts). Pas de téléchargement.
  GoogleFonts.config.allowRuntimeFetching = false;
  // Initialiser SharedPreferences au démarrage
  final prefs = await SharedPreferences.getInstance();
  runApp(App(sharedPreferences: prefs));
}
