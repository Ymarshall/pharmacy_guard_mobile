import 'package:flutter/material.dart';
import '../../../../config/themes/colors.dart';
import '../../../../shared/styles/text_styles.dart';
import '../../domain/entities/rating_summary.dart';

class RatingSummaryWidget extends StatelessWidget {
  final RatingSummary? ratingSummary;

  const RatingSummaryWidget({
    super.key,
    this.ratingSummary,
  });

  @override
  Widget build(BuildContext context) {
    if (ratingSummary == null || ratingSummary!.totalReviews == 0) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Icon(Icons.star_outline, color: AppColors.textSecondary, size: 24),
            const SizedBox(width: 12),
            Text(
              'Aucun avis pour le moment',
              style: TextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.star, color: Colors.amber, size: 32),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ratingSummary!.averageRating.toStringAsFixed(1),
                    style: TextStyles.displaySmall.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  Text(
                    '${ratingSummary!.totalReviews} ${ratingSummary!.totalReviews == 1 ? 'avis' : 'avis'}',
                    style: TextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Distribution des notes
          ...List.generate(5, (index) {
            final rating = 5 - index; // 5, 4, 3, 2, 1
            final count = ratingSummary!.ratingDistribution[rating] ?? 0;
            final percentage = ratingSummary!.totalReviews > 0
                ? count / ratingSummary!.totalReviews
                : 0.0;

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Text(
                    '$rating',
                    style: TextStyles.bodySmall.copyWith(
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.right,
                    textWidthBasis: TextWidthBasis.longestLine,
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.star, color: Colors.amber, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: LinearProgressIndicator(
                      value: percentage,
                      backgroundColor: AppColors.background,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$count',
                    style: TextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
