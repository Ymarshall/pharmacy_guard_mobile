import 'package:flutter/material.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/extensions/theme_extension.dart';

class OnboardingItem extends StatelessWidget {
  final OnboardingItemData data;

  const OnboardingItem({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl2),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: data.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
            ),
            child: Icon(
              data.icon,
              size: 34,
              color: data.color,
            ),
          ),
          const SizedBox(height: AppSpacing.xl3),
          Text(
            data.title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: context.onSurface,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            data.description,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: context.textSecondary,
                  height: 1.55,
                ),
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
