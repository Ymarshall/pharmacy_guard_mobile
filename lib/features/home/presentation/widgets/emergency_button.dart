import 'package:flutter/material.dart';
import '../../../../core/extensions/theme_extension.dart';

class EmergencyButton extends StatelessWidget {
  final VoidCallback onPressed;

  const EmergencyButton({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed,
      tooltip: 'Numéros utiles',
      elevation: 2,
      highlightElevation: 2,
      backgroundColor: context.surface,
      foregroundColor: context.error,
      shape: CircleBorder(
        side: BorderSide(color: context.cardBorder),
      ),
      child: const Icon(Icons.phone_in_talk_outlined),
    );
  }
}
