import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';
import '../constants/app_typography.dart';
import 'widget_themes.dart';

abstract final class AppTheme {
  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData get lightTheme => light;
  static ThemeData get darkTheme => dark;

  /// Mode nuit automatique après 18h (comportement existant).
  static ThemeMode getThemeMode() {
    final hour = DateTime.now().hour;
    return hour >= 18 || hour < 6 ? ThemeMode.dark : ThemeMode.light;
  }

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    final colorScheme = isDark
        ? const ColorScheme.dark(
            primary: AppColors.darkPrimary,
            onPrimary: AppColors.darkBackground,
            secondary: AppColors.darkSecondary,
            onSecondary: AppColors.darkBackground,
            tertiary: AppColors.darkAccent,
            surface: AppColors.darkSurface,
            error: AppColors.darkError,
            onError: AppColors.darkBackground,
            onSurface: AppColors.darkOnSurface,
          )
        : const ColorScheme.light(
            primary: AppColors.primary,
            onPrimary: Colors.white,
            secondary: AppColors.secondary,
            onSecondary: Colors.white,
            tertiary: AppColors.info,
            surface: AppColors.surface,
            error: AppColors.error,
            onError: Colors.white,
            onSurface: AppColors.onSurface,
          );

    final textTheme = GoogleFonts.plusJakartaSansTextTheme(
      TextTheme(
        headlineLarge: AppTypography.headlineLarge,
        headlineMedium: AppTypography.headlineMedium,
        headlineSmall: AppTypography.headlineSmall,
        titleLarge: AppTypography.titleLarge,
        titleMedium: AppTypography.titleMedium,
        titleSmall: AppTypography.titleSmall,
        bodyLarge: AppTypography.bodyLarge,
        bodyMedium: AppTypography.bodyMedium,
        bodySmall: AppTypography.bodySmall,
        labelLarge: AppTypography.labelLarge,
        labelMedium: AppTypography.labelMedium,
        labelSmall: AppTypography.labelSmall,
      ),
    ).apply(
      bodyColor: isDark ? AppColors.darkOnSurface : AppColors.onSurface,
      displayColor: isDark ? AppColors.darkOnSurface : AppColors.onSurface,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      fontFamily: AppTypography.fontFamily,
      colorScheme: colorScheme,
      scaffoldBackgroundColor:
          isDark ? AppColors.darkBackground : AppColors.background,
      textTheme: textTheme,
      elevatedButtonTheme: WidgetThemes.elevatedButtonTheme(brightness),
      outlinedButtonTheme: WidgetThemes.outlinedButtonTheme(brightness),
      textButtonTheme: WidgetThemes.textButtonTheme(brightness),
      inputDecorationTheme: WidgetThemes.inputDecorationTheme(brightness),
      cardTheme: WidgetThemes.cardTheme(brightness),
      appBarTheme: WidgetThemes.appBarTheme(brightness),
      bottomNavigationBarTheme: WidgetThemes.bottomNavigationBarTheme(
        brightness,
      ),
      chipTheme: WidgetThemes.chipTheme(brightness),
      dialogTheme: WidgetThemes.dialogTheme(brightness),
      snackBarTheme: WidgetThemes.snackBarTheme(brightness),
      floatingActionButtonTheme: WidgetThemes.fabTheme(brightness),
      switchTheme: WidgetThemes.switchTheme(brightness),
      progressIndicatorTheme: WidgetThemes.progressTheme(brightness),
      dividerTheme: WidgetThemes.dividerTheme(brightness),
      listTileTheme: WidgetThemes.listTileTheme(brightness),
      dividerColor: isDark ? AppColors.darkDivider : AppColors.divider,
    );
  }
}
