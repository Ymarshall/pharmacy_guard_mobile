import 'package:flutter/material.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/extensions/theme_extension.dart';

enum StatusBadgeVariant { success, warning, error, info, neutral, custom }

class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.label,
    this.color,
    this.textColor,
    this.icon,
    this.variant = StatusBadgeVariant.custom,
  });

  final String label;
  final Color? color;
  final Color? textColor;
  final IconData? icon;
  final StatusBadgeVariant variant;

  factory StatusBadge.success(String label, {IconData? icon}) => StatusBadge(
        label: label,
        icon: icon,
        variant: StatusBadgeVariant.success,
      );

  factory StatusBadge.warning(String label, {IconData? icon}) => StatusBadge(
        label: label,
        icon: icon,
        variant: StatusBadgeVariant.warning,
      );

  factory StatusBadge.error(String label, {IconData? icon}) => StatusBadge(
        label: label,
        icon: icon,
        variant: StatusBadgeVariant.error,
      );

  factory StatusBadge.info(String label, {IconData? icon}) => StatusBadge(
        label: label,
        icon: icon,
        variant: StatusBadgeVariant.info,
      );

  (Color, Color) _resolveColors(BuildContext context) {
    switch (variant) {
      case StatusBadgeVariant.success:
        return (context.successSurface, context.success);
      case StatusBadgeVariant.warning:
        return (context.warningSurface, context.warning);
      case StatusBadgeVariant.error:
        return (context.errorSurface, context.error);
      case StatusBadgeVariant.info:
        return (context.accentSurface, context.accent);
      case StatusBadgeVariant.neutral:
        return (context.surfaceSubtle, context.textSecondary);
      case StatusBadgeVariant.custom:
        return (
          color ?? context.primary.withValues(alpha: 0.15),
          textColor ?? context.primary,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final (bgColor, fgColor) = _resolveColors(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppSpacing.borderRadiusPill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: fgColor),
            const SizedBox(width: 4),
          ],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              softWrap: false,
              style: TextStyle(
                color: fgColor,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
