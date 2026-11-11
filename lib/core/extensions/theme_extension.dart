import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Couleurs sémantiques résolues selon la luminosité du thème.
/// Même contrat que l'extension de thème de l'application de référence.
extension AppThemeContext on BuildContext {
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  Color get primary => isDark ? AppColors.darkPrimary : AppColors.primary;
  Color get primaryLight =>
      isDark ? AppColors.darkPrimaryLight : AppColors.primaryLight;
  Color get primaryDark =>
      isDark ? AppColors.darkPrimaryDark : AppColors.primaryDark;
  Color get primarySurface =>
      isDark ? AppColors.darkPrimarySurface : AppColors.primarySurface;

  /// Orange de marque (secondaire).
  Color get secondary => isDark ? AppColors.darkSecondary : AppColors.secondary;
  Color get secondaryLight =>
      isDark ? AppColors.darkSecondaryLight : AppColors.secondaryLight;
  Color get secondaryDark =>
      isDark ? AppColors.darkSecondaryDark : AppColors.secondaryDark;
  Color get secondarySurface =>
      isDark ? AppColors.darkSecondarySurface : AppColors.secondarySurface;

  /// Couleur d'information (tertiaire), distincte de l'orange de marque.
  Color get accent => isDark ? AppColors.darkAccent : AppColors.info;
  Color get accentSurface =>
      isDark ? AppColors.darkAccentSurface : AppColors.accentSurface;

  Color get success => isDark ? AppColors.darkSuccess : AppColors.success;
  Color get successSurface =>
      isDark ? AppColors.darkSuccessSurface : AppColors.successSurface;
  Color get warning => isDark ? AppColors.darkWarning : AppColors.warning;
  Color get warningSurface =>
      isDark ? AppColors.darkWarningSurface : AppColors.warningSurface;
  Color get error => isDark ? AppColors.darkError : AppColors.error;
  Color get errorSurface =>
      isDark ? AppColors.darkErrorSurface : AppColors.errorSurface;

  Color get background =>
      isDark ? AppColors.darkBackground : AppColors.background;
  Color get surface => isDark ? AppColors.darkSurface : AppColors.surface;
  Color get surfaceElevated =>
      isDark ? AppColors.darkSurfaceElevated : AppColors.surfaceElevated;
  Color get surfaceSubtle =>
      isDark ? AppColors.darkSurfaceSubtle : AppColors.surfaceSubtle;
  Color get onSurface => isDark ? AppColors.darkOnSurface : AppColors.onSurface;
  Color get textSecondary =>
      isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
  Color get textTertiary =>
      isDark ? AppColors.darkTextTertiary : AppColors.textTertiary;
  Color get textHint => isDark ? AppColors.darkTextHint : AppColors.textHint;
  Color get divider => isDark ? AppColors.darkDivider : AppColors.divider;
  Color get border => isDark ? AppColors.darkBorder : AppColors.border;
  Color get cardBorder =>
      isDark ? AppColors.darkCardBorder : AppColors.cardBorder;
}
