import 'package:flutter/material.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/extensions/theme_extension.dart';

class IconChip extends StatelessWidget {
  const IconChip({
    super.key,
    required this.icon,
    this.size = 44,
    this.iconSize = 20,
    this.backgroundColor,
    this.iconColor,
  });

  final IconData icon;
  final double size;
  final double iconSize;
  final Color? backgroundColor;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor ?? context.primarySurface,
        borderRadius: BorderRadius.circular(AppSpacing.borderRadiusSm),
      ),
      child: Icon(
        icon,
        color: iconColor ?? context.primary,
        size: iconSize,
      ),
    );
  }
}
