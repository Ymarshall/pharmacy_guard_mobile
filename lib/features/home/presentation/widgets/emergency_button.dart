import 'package:flutter/material.dart';
import '../../../../config/themes/colors.dart';

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
      backgroundColor: AppColors.surface,
      foregroundColor: AppColors.accent,
      elevation: 4,
      icon: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(
          Icons.phone_in_talk_outlined,
          color: Colors.white,
          size: 18,
        ),
      ),
      label: const Text(
        'Numéros utiles',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }
}
