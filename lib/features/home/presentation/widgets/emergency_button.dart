import 'package:flutter/material.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/extensions/theme_extension.dart';
import '../../../../shared/widgets/icon_chip.dart';

class EmergencyButton extends StatelessWidget {
  final VoidCallback onPressed;

  const EmergencyButton({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: onPressed,
      elevation: 0,
      highlightElevation: 0,
      backgroundColor: context.surface,
      foregroundColor: context.onSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
        side: BorderSide(color: context.cardBorder),
      ),
      icon: IconChip(
        icon: Icons.phone_in_talk_outlined,
        size: 32,
        iconSize: 16,
        backgroundColor: context.errorSurface,
        iconColor: context.error,
      ),
      label: Text(
        'Numéros utiles',
        style: AppTypography.labelMedium.copyWith(
          color: context.onSurface,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
