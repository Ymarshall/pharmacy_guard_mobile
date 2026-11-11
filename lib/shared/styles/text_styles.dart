import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';

/// Façade historique vers [AppTypography].
/// Les écrans nouveaux lisent plutôt `Theme.of(context).textTheme`.
class TextStyles {
  static TextStyle get displayLarge => AppTypography.headlineLarge;
  static TextStyle get displayMedium => AppTypography.headlineMedium;
  static TextStyle get displaySmall => AppTypography.headlineSmall;
  static TextStyle get headlineLarge => AppTypography.headlineSmall;
  static TextStyle get headlineMedium => AppTypography.headlineSmall;
  static TextStyle get headlineSmall => AppTypography.titleLarge;
  static TextStyle get titleLarge => AppTypography.titleLarge;
  static TextStyle get titleMedium => AppTypography.titleMedium;
  static TextStyle get titleSmall => AppTypography.titleSmall;
  static TextStyle get bodyLarge => AppTypography.bodyLarge;
  static TextStyle get bodyMedium => AppTypography.bodyMedium;
  static TextStyle get bodySmall => AppTypography.bodySmall;
  static TextStyle get labelLarge => AppTypography.labelLarge;
  static TextStyle get labelMedium => AppTypography.labelMedium;
  static TextStyle get labelSmall => AppTypography.labelSmall;

  static TextStyle get button => AppTypography.labelLarge.copyWith(
        color: AppColors.textLight,
      );

  static TextStyle get caption => AppTypography.caption;
  static TextStyle get overline => AppTypography.labelSmall;
}
