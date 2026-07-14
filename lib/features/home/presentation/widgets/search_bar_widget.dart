import 'package:flutter/material.dart';
import '../../../../config/themes/colors.dart';

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
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.primary.withOpacity(0.15),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.03),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.surface,
                hintText: 'Rechercher une pharmacie...',
                hintStyle: TextStyle(
                  color: AppColors.textTertiary,
                  fontSize: 14,
                ),
                prefixIcon: Icon(
                  Icons.search_outlined,
                  color: AppColors.primary,
                  size: 20,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Flag icon (Côte d'Ivoire colors) - Style Soft UI
        GestureDetector(
          onTap: onFlagTap,
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadowLight,
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Row(
                children: [
                  Container(
                    width: 16,
                    height: 48,
                    color: AppColors.accent, // Orange
                  ),
                  Container(
                    width: 16,
                    height: 48,
                    color: AppColors.surface, // White
                  ),
                  Container(
                    width: 16,
                    height: 48,
                    color: AppColors.primary, // Green
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
