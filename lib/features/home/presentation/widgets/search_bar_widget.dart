import 'package:flutter/material.dart';
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
        if (onFlagTap != null) ...[
          const SizedBox(width: AppSpacing.md),
          IconButton(
            onPressed: onFlagTap,
            tooltip: 'Filtrer',
            icon: const Icon(Icons.tune),
            style: IconButton.styleFrom(
              foregroundColor: context.primary,
              backgroundColor: context.surface,
              minimumSize: const Size(48, 48),
              fixedSize: const Size(48, 48),
              side: BorderSide(color: context.border),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.controlRadius),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
