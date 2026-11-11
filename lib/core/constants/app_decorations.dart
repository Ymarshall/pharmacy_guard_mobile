import 'package:flutter/material.dart';
import '../extensions/theme_extension.dart';
import 'app_colors.dart';
import 'app_spacing.dart';

abstract final class AppDecorations {
  static final shadowSm = [
    BoxShadow(
      color: AppColors.primaryDark.withValues(alpha: 0.03),
      blurRadius: 2,
      offset: const Offset(0, 1),
    ),
  ];

  static final shadowMd = [
    BoxShadow(
      color: AppColors.primaryDark.withValues(alpha: 0.04),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  static final shadowLg = [
    BoxShadow(
      color: AppColors.primaryDark.withValues(alpha: 0.05),
      blurRadius: 16,
      offset: const Offset(0, 6),
    ),
  ];

  static BoxDecoration cardDecoration(BuildContext context) => BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
        border: Border.all(color: context.cardBorder),
      );

  static BoxDecoration cardDecorationFlat(BuildContext context) =>
      BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
        border: Border.all(color: context.border),
      );

  static BoxDecoration accentCard(BuildContext context, Color accentColor) =>
      BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
        border: Border.all(color: accentColor.withValues(alpha: 0.28)),
      );

  static BoxDecoration coloredSurface(Color color) => BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(AppSpacing.borderRadiusSm),
      );

  static BoxDecoration selectedCard(BuildContext context, Color accentColor) =>
      BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
        border: Border.all(color: accentColor, width: 1.5),
      );

  static BoxDecoration inputFocusDecoration(BuildContext context) =>
      BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: context.primary.withValues(alpha: 0.10),
            blurRadius: 6,
            offset: const Offset(0, 0),
          ),
        ],
      );
}
