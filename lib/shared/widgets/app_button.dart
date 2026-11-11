import 'package:flutter/material.dart';
import 'primary_button.dart';

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double? height;
  final IconData? icon;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final button = PrimaryButton(
      label: text,
      onPressed: onPressed,
      isLoading: isLoading,
      icon: icon,
      isFullWidth: width == null || width == double.infinity,
      variant: isOutlined ? ButtonVariant.outline : ButtonVariant.primary,
      backgroundColor: backgroundColor,
      foregroundColor: textColor,
    );

    if (width != null && width != double.infinity) {
      return SizedBox(width: width, height: height, child: button);
    }
    if (height != null) {
      return SizedBox(height: height, child: button);
    }
    return button;
  }
}
