import 'package:flutter/material.dart';

/// Palette de marque de Pharmacie de garde.
///
/// Le vert primaire est un vert forêt assombri (#236B40, contraste 6,5:1
/// avec le blanc). Le bandeau d'en-tête utilise [primaryDark], un cran
/// plus sombre. L'orange de marque et le bleu nuit restent en place ;
/// les badges « de garde » utilisent un orange adouci.
abstract final class AppColors {
  // Primaire — vert forêt profond (AA avec texte blanc)
  static const Color primary = Color(0xFF236B40);
  static const Color primaryDark = Color(0xFF184F2E);
  static const Color primaryLight = Color(0xFF4F9A5C);
  static const Color primarySurface = Color(0xFFE7F2EA);

  // Secondaire — orange de marque (historique `accent`)
  static const Color accent = Color(0xFFF57C00);
  static const Color accentDark = Color(0xFFE65100);
  static const Color accentLight = Color(0xFFFFB74D);
  static const Color secondary = accent;
  static const Color secondaryLight = accentLight;
  static const Color secondaryDark = accentDark;
  static const Color secondarySurface = Color(0xFFFFF3E0);

  // Tertiaire — information
  static const Color info = Color(0xFF1976D2);
  static const Color accentSurface = Color(0xFFE1E4F8);

  // Fonds
  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceLight = Color(0xFFF1F3F4);
  static const Color surfaceMuted = Color(0xFFF1F3F4);
  static const Color surfaceElevated = surface;
  static const Color surfaceSubtle = surfaceMuted;

  // Puces / pastels historiques
  static const Color chipMint = primarySurface;
  static const Color chipLavender = accentSurface;

  // Texte
  static const Color textPrimary = Color(0xFF0F2644);
  static const Color onSurface = textPrimary;
  static const Color textSecondary = Color(0xFF757575);
  static const Color textTertiary = Color(0xFF9E9E9E);
  static const Color textHint = textTertiary;
  static const Color textLight = Color(0xFFFFFFFF);

  // Statuts
  static const Color success = Color(0xFF4CAF50);
  static const Color successSurface = Color(0xFFE8F5E9);
  static const Color error = Color(0xFFD32F2F);
  static const Color errorSurface = Color(0xFFFFEBEE);
  static const Color warning = Color(0xFFC56A12);
  static const Color warningSurface = Color(0xFFFFF3E0);

  // Bordures / séparateurs
  static const Color divider = Color(0xFFEEEEEE);
  static const Color border = Color(0xFFE8EAED);
  static const Color borderLight = Color(0xFFF1F3F4);
  static const Color cardBorder = border;

  // Pharmacies
  static const Color pharmacyOpen = primary;
  static const Color pharmacyClosed = Color(0xFFD32F2F);
  static const Color pharmacyOnDuty = warning;

  // Ombres très légères (conservées pour les rares élévations)
  static const Color shadowLight = Color(0x08000000);
  static const Color shadowMedium = Color(0x0D000000);
  static const Color shadowDark = Color(0x14000000);

  static const Color glassBackground = Color(0x80FFFFFF);
  static const Color glassBorder = Color(0x33FFFFFF);

  // Sombre — mêmes fonds que le thème nuit existant, tokens alignés
  static const Color darkPrimary = primaryLight;
  static const Color darkPrimaryLight = Color(0xFF81C784);
  static const Color darkPrimaryDark = primary;
  static const Color darkPrimarySurface = Color(0xFF1B3320);

  static const Color darkSecondary = accentLight;
  static const Color darkSecondaryLight = Color(0xFFFFCC80);
  static const Color darkSecondaryDark = accent;
  static const Color darkSecondarySurface = Color(0xFF3D2A12);

  static const Color darkAccent = Color(0xFF64B5F6);
  static const Color darkAccentSurface = Color(0xFF1A2A40);

  static const Color darkSuccess = Color(0xFF81C784);
  static const Color darkSuccessSurface = Color(0xFF143420);
  static const Color darkWarning = accentLight;
  static const Color darkWarningSurface = Color(0xFF3A1F0A);
  static const Color darkError = Color(0xFFEF9A9A);
  static const Color darkErrorSurface = Color(0xFF3D1414);

  static const Color darkBackground = Color(0xFF0F1A24);
  static const Color darkSurface = Color(0xFF152A38);
  static const Color darkSurfaceElevated = Color(0xFF1C3548);
  static const Color darkSurfaceSubtle = Color(0xFF1A3040);
  static const Color darkOnSurface = textLight;
  static const Color darkTextSecondary = Color(0xFFB0BEC5);
  static const Color darkTextTertiary = Color(0xFF90A4AE);
  static const Color darkTextHint = Color(0xFF78909C);
  static const Color darkDivider = Color(0xFF243848);
  static const Color darkBorder = Color(0xFF2C4558);
  static const Color darkCardBorder = Color(0xFF243848);
}
