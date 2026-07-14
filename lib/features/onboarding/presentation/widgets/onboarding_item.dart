import 'package:flutter/material.dart';
import '../../../../config/themes/colors.dart';
import '../../../../shared/styles/text_styles.dart';

class OnboardingItem extends StatelessWidget {
  final OnboardingItemData data;

  const OnboardingItem({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: data.color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              data.icon,
              size: 64,
              color: data.color,
            ),
          ),
          const SizedBox(height: 48),
          // Title
          Text(
            data.title,
            style: TextStyles.displaySmall.copyWith(
              color: data.color,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          // Description
          Text(
            data.description,
            style: TextStyles.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class OnboardingItemData {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  OnboardingItemData({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}

