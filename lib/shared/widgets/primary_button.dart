import 'package:flutter/material.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';
import '../../core/extensions/theme_extension.dart';

enum ButtonVariant { primary, secondary, outline, text }

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = ButtonVariant.primary,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = true,
    this.backgroundColor,
    this.foregroundColor,
  });

  final String label;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final IconData? icon;
  final bool isLoading;
  final bool isFullWidth;
  final Color? backgroundColor;
  final Color? foregroundColor;

  bool get _isDisabled => onPressed == null && !isLoading;

  @override
  Widget build(BuildContext context) {
    final child = isLoading
        ? SizedBox(
            height: 16,
            width: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: foregroundColor ?? Colors.white,
            ),
          )
        : icon != null
            ? Row(
                mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 20),
                  const SizedBox(width: AppSpacing.sm),
                  Text(label),
                ],
              )
            : Text(label);

    final effectiveOnPressed = isLoading ? null : onPressed;
    final bg = backgroundColor ??
        (variant == ButtonVariant.secondary
            ? context.secondary
            : context.primary);
    final fg = foregroundColor ?? Colors.white;

    Widget button = switch (variant) {
      ButtonVariant.primary || ButtonVariant.secondary => ElevatedButton(
          onPressed: effectiveOnPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: bg,
            foregroundColor: fg,
            disabledBackgroundColor: bg,
            disabledForegroundColor: fg,
            minimumSize: const Size.fromHeight(AppSpacing.buttonHeight),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.controlRadius),
            ),
            textStyle: AppTypography.labelLarge.copyWith(
              color: fg,
              fontWeight: FontWeight.w700,
            ),
            elevation: 0,
          ),
          child: child,
        ),
      ButtonVariant.outline => OutlinedButton(
          onPressed: effectiveOnPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: backgroundColor ?? context.primary,
            minimumSize: const Size.fromHeight(AppSpacing.buttonHeight),
          ),
          child: child,
        ),
      ButtonVariant.text => TextButton(
          onPressed: effectiveOnPressed,
          child: child,
        ),
    };

    if (isFullWidth && variant != ButtonVariant.text) {
      button = SizedBox(width: double.infinity, child: button);
    }

    if (_isDisabled) {
      return Opacity(opacity: 0.5, child: button);
    }

    return button;
  }
}
