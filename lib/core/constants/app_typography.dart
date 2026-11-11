import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Hiérarchie typographique du design system de référence.
///
/// La police Konnect n'est pas fournie avec cette application. Plus Jakarta
/// Sans (google_fonts) est utilisée comme alternative géométrique proche :
/// graisses 400–800, chasse serrée sur les titres, corps aéré.
abstract final class AppTypography {
  static String get fontFamily =>
      GoogleFonts.plusJakartaSans().fontFamily ?? 'PlusJakartaSans';

  static TextStyle get _base => GoogleFonts.plusJakartaSans(
        color: AppColors.onSurface,
      );

  static TextStyle get headlineLarge => _base.copyWith(
        fontSize: 30,
        fontWeight: FontWeight.w700,
        color: AppColors.primary,
        letterSpacing: -0.5,
        height: 1.15,
      );

  static TextStyle get headlineMedium => _base.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: AppColors.primary,
        letterSpacing: -0.4,
        height: 1.2,
      );

  static TextStyle get headlineSmall => _base.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: AppColors.primary,
        letterSpacing: -0.3,
        height: 1.25,
      );

  static TextStyle get titleLarge => _base.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        height: 1.3,
      );

  static TextStyle get titleMedium => _base.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.1,
        height: 1.35,
      );

  static TextStyle get titleSmall => _base.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        height: 1.4,
      );

  static TextStyle get bodyLarge => _base.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
        height: 1.55,
        letterSpacing: 0,
      );

  static TextStyle get bodyMedium => _base.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
        height: 1.5,
        letterSpacing: 0,
      );

  static TextStyle get bodySmall => _base.copyWith(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
        height: 1.5,
        letterSpacing: 0,
      );

  static TextStyle get labelLarge => _base.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        height: 1.4,
      );

  static TextStyle get labelMedium => _base.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
        height: 1.4,
      );

  static TextStyle get labelSmall => _base.copyWith(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: AppColors.textTertiary,
        letterSpacing: 0.6,
        height: 1.4,
      );

  static TextStyle get caption => _base.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.textTertiary,
        letterSpacing: 0.1,
        height: 1.5,
      );

  static TextStyle get displayScore => _base.copyWith(
        fontSize: 48,
        fontWeight: FontWeight.w700,
        letterSpacing: -1,
        height: 1.05,
      );

  /// Titre d'écran d'accueil / connexion (32, extra-bold), comme les écrans
  /// d'auth de la référence.
  static TextStyle get screenTitle => _base.copyWith(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        color: AppColors.onSurface,
        letterSpacing: -0.6,
        height: 1.1,
      );
}
