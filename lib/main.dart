import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialiser SharedPreferences au démarrage
  final prefs = await SharedPreferences.getInstance();
  runApp(App(sharedPreferences: prefs));
}
