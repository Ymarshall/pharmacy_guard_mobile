import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_typography.dart';

abstract final class WidgetThemes {
  static ElevatedButtonThemeData elevatedButtonTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: isDark ? AppColors.darkPrimary : AppColors.primary,
        foregroundColor: isDark ? AppColors.darkBackground : Colors.white,
        minimumSize: const Size(64, AppSpacing.buttonHeight),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.controlRadius),
        ),
        textStyle: AppTypography.labelLarge.copyWith(
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
        ),
        elevation: 0,
        shadowColor: Colors.transparent,
      ),
    );
  }

  static OutlinedButtonThemeData outlinedButtonTheme(Brightness brightness) {
    final primary = brightness == Brightness.dark
        ? AppColors.darkPrimary
        : AppColors.primary;
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primary,
        minimumSize: const Size(64, AppSpacing.buttonHeight),
        side: BorderSide(color: primary, width: 1.2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.controlRadius),
        ),
        textStyle: AppTypography.labelLarge.copyWith(
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
        ),
      ),
    );
  }

  static TextButtonThemeData textButtonTheme(Brightness brightness) {
    final primary = brightness == Brightness.dark
        ? AppColors.darkPrimary
        : AppColors.primary;
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primary,
        textStyle: AppTypography.labelLarge.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  static InputDecorationTheme inputDecorationTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final fillColor =
        isDark ? AppColors.darkSurfaceElevated : AppColors.surface;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.border;
    final primary = isDark ? AppColors.darkPrimary : AppColors.primary;
    final error = isDark ? AppColors.darkError : AppColors.error;
    final hintColor = isDark ? AppColors.darkTextHint : AppColors.textHint;
    final labelColor =
        isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    return InputDecorationTheme(
      filled: true,
      fillColor: fillColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.controlRadius),
        borderSide: BorderSide(color: borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.controlRadius),
        borderSide: BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.controlRadius),
        borderSide: BorderSide(color: primary, width: 1.4),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.controlRadius),
        borderSide: BorderSide(color: error, width: 1.4),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.controlRadius),
        borderSide: BorderSide(color: error, width: 1.4),
      ),
      hintStyle: AppTypography.bodyMedium.copyWith(
        color: hintColor,
        fontWeight: FontWeight.w400,
      ),
      labelStyle: AppTypography.labelMedium.copyWith(
        color: labelColor,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  static CardThemeData cardTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    return CardThemeData(
      color: isDark ? AppColors.darkSurface : AppColors.surface,
      elevation: 0,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
        side: BorderSide(
          color: isDark ? AppColors.darkCardBorder : AppColors.cardBorder,
        ),
      ),
      margin: EdgeInsets.zero,
    );
  }

  static AppBarTheme appBarTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBackground : AppColors.background;
    final fg = isDark ? AppColors.darkOnSurface : AppColors.onSurface;
    return AppBarTheme(
      backgroundColor: bg,
      foregroundColor: fg,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      surfaceTintColor: Colors.transparent,
      systemOverlayStyle:
          isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      iconTheme: IconThemeData(color: fg),
      titleSpacing: AppSpacing.lg,
      titleTextStyle: AppTypography.titleMedium.copyWith(
        color: fg,
        fontSize: 17,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
      ),
    );
  }

  static BottomNavigationBarThemeData bottomNavigationBarTheme(
    Brightness brightness,
  ) {
    final isDark = brightness == Brightness.dark;
    return BottomNavigationBarThemeData(
      backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
      selectedItemColor: isDark ? AppColors.darkPrimary : AppColors.primary,
      unselectedItemColor:
          isDark ? AppColors.darkTextTertiary : AppColors.textTertiary,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
      selectedLabelStyle: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.4,
      ),
      unselectedLabelStyle: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.4,
      ),
    );
  }

  static ChipThemeData chipTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    return ChipThemeData(
      backgroundColor:
          isDark ? AppColors.darkSurfaceElevated : AppColors.surfaceSubtle,
      selectedColor:
          isDark ? AppColors.darkPrimarySurface : AppColors.primarySurface,
      labelStyle: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        fontFamily: AppTypography.fontFamily,
        color: isDark ? AppColors.darkOnSurface : AppColors.onSurface,
      ),
      shape: const StadiumBorder(),
      side: BorderSide.none,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
    );
  }

  static DialogThemeData dialogTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    return DialogThemeData(
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
        side: BorderSide(
          color: isDark ? AppColors.darkCardBorder : AppColors.cardBorder,
        ),
      ),
      titleTextStyle: AppTypography.titleMedium.copyWith(
        color: isDark ? AppColors.darkOnSurface : AppColors.onSurface,
        fontWeight: FontWeight.w700,
      ),
      contentTextStyle: AppTypography.bodyMedium.copyWith(
        color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
      ),
    );
  }

  static SnackBarThemeData snackBarTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    return SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: isDark ? AppColors.darkSurfaceElevated : AppColors.primaryDark,
      contentTextStyle: AppTypography.bodyMedium.copyWith(color: Colors.white),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.controlRadius),
      ),
    );
  }

  static FloatingActionButtonThemeData fabTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    return FloatingActionButtonThemeData(
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.surface,
      foregroundColor: isDark ? AppColors.darkSecondary : AppColors.secondary,
      elevation: 0,
      highlightElevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
        side: BorderSide(
          color: isDark ? AppColors.darkCardBorder : AppColors.cardBorder,
        ),
      ),
    );
  }

  static SwitchThemeData switchTheme(Brightness brightness) {
    final primary =
        brightness == Brightness.dark ? AppColors.darkPrimary : AppColors.primary;
    return SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return Colors.white;
        return null;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return primary;
        return null;
      }),
    );
  }

  static ProgressIndicatorThemeData progressTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    return ProgressIndicatorThemeData(
      color: isDark ? AppColors.darkPrimary : AppColors.primary,
      linearTrackColor:
          isDark ? AppColors.darkSurfaceSubtle : AppColors.surfaceSubtle,
    );
  }

  static DividerThemeData dividerTheme(Brightness brightness) {
    final color =
        brightness == Brightness.dark ? AppColors.darkDivider : AppColors.divider;
    return DividerThemeData(color: color, thickness: 1, space: 1);
  }

  static ListTileThemeData listTileTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    return ListTileThemeData(
      iconColor: isDark ? AppColors.darkPrimary : AppColors.primary,
      textColor: isDark ? AppColors.darkOnSurface : AppColors.onSurface,
      titleTextStyle: AppTypography.titleSmall.copyWith(
        color: isDark ? AppColors.darkOnSurface : AppColors.onSurface,
      ),
      subtitleTextStyle: AppTypography.bodySmall.copyWith(
        color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
      ),
    );
  }
}
