import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/extensions/theme_extension.dart';

class SearchBarWidget extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onFlagTap;

  const SearchBarWidget({
    super.key,
    required this.controller,
    this.onChanged,
    this.onFlagTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            onChanged: onChanged,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: context.onSurface,
                ),
            decoration: InputDecoration(
              hintText: 'Rechercher une pharmacie...',
              prefixIcon: Icon(
                Icons.search,
                color: context.primary,
                size: 20,
              ),
              filled: true,
              fillColor: context.surface,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: 14,
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        GestureDetector(
          onTap: onFlagTap,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.controlRadius),
            child: SizedBox(
              width: 48,
              height: 48,
              child: Row(
                children: [
                  Container(width: 16, height: 48, color: AppColors.accent),
                  Container(width: 16, height: 48, color: AppColors.surface),
                  Container(width: 16, height: 48, color: AppColors.primary),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
