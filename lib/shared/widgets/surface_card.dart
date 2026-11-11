import 'package:flutter/material.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/extensions/theme_extension.dart';
import 'tap_scale.dart';

enum CardElevation { flat, medium, elevated }

class SurfaceCard extends StatelessWidget {
  const SurfaceCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.margin,
    this.elevation = CardElevation.medium,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? margin;
  final CardElevation elevation;

  @override
  Widget build(BuildContext context) {
    final borderColor =
        elevation == CardElevation.flat ? context.border : context.cardBorder;
    final card = Padding(
      padding: margin ?? EdgeInsets.zero,
      child: Material(
        color: context.surface,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
          side: BorderSide(color: borderColor),
        ),
        child: Padding(
          padding: padding ?? AppSpacing.paddingLg,
          child: child,
        ),
      ),
    );

    if (onTap != null) {
      return TapScale(onTap: onTap, child: card);
    }
    return card;
  }
}
