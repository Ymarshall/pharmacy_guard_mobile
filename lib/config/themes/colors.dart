import 'package:flutter/material.dart';

/// Palette alignée sur les écrans de référence (dashboard clair, vert forêt, texte bleu nuit).
class AppColors {
  // Primaire — vert forêt (boutons, progression, accents principaux)
  static const Color primary = Color(0xFF2E7D32);
  static const Color primaryDark = Color(0xFF1B5E20);
  static const Color primaryLight = Color(0xFF4CAF50);

  // Secondaire — actions / urgence lisibles sur fond clair (icônes secondaires, CTA outline)
  static const Color accent = Color(0xFFF57C00);
  static const Color accentDark = Color(0xFFE65100);
  static const Color accentLight = Color(0xFFFFB74D);

  // Fonds
  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceLight = Color(0xFFF1F3F4);
  static const Color surfaceMuted = Color(0xFFF1F3F4);

  // Puces / pastels (cartes type « parcours »)
  static const Color chipMint = Color(0xFFE8F5E9);
  static const Color chipLavender = Color(0xFFE1E4F8);

  // Texte
  static const Color textPrimary = Color(0xFF0F2644);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textTertiary = Color(0xFF9E9E9E);
  static const Color textLight = Color(0xFFFFFFFF);

  // Statuts
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFD32F2F);
  static const Color warning = Color(0xFFF57C00);
  static const Color info = Color(0xFF1976D2);

  // Bordures / séparateurs
  static const Color divider = Color(0xFFEEEEEE);
  static const Color border = Color(0xFFE8EAED);
  static const Color borderLight = Color(0xFFF1F3F4);

  // Pharmacies
  static const Color pharmacyOpen = Color(0xFF2E7D32);
  static const Color pharmacyClosed = Color(0xFFD32F2F);
  static const Color pharmacyOnDuty = Color(0xFFF57C00);

  // Ombres très légères (cartes type soft UI)
  static const Color shadowLight = Color(0x08000000);
  static const Color shadowMedium = Color(0x0D000000);
  static const Color shadowDark = Color(0x14000000);

  static const Color glassBackground = Color(0x80FFFFFF);
  static const Color glassBorder = Color(0x33FFFFFF);
}
