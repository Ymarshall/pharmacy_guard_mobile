import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/storage_keys.dart';
import '../providers/providers.dart';
import 'app_theme.dart';

class ThemeModeController extends StateNotifier<ThemeMode> {
  ThemeModeController(this._prefs) : super(_read(_prefs));

  final SharedPreferences _prefs;

  static ThemeMode _read(SharedPreferences prefs) {
    return AppTheme.resolveThemeMode(
      darkModeEnabled: prefs.getBool(StorageKeys.darkModeEnabled),
    );
  }

  bool get isDark => state == ThemeMode.dark;

  Future<void> setDarkMode(bool enabled) async {
    await _prefs.setBool(StorageKeys.darkModeEnabled, enabled);
    state = AppTheme.resolveThemeMode(darkModeEnabled: enabled);
  }
}

final themeModeProvider = StateNotifierProvider<ThemeModeController, ThemeMode>(
  (ref) {
    final prefs = ref.watch(sharedPreferencesInstanceProvider);
    return ThemeModeController(prefs);
  },
);
