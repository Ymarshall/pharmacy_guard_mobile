import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../config/themes/colors.dart';
import '../../../../shared/styles/text_styles.dart';
import '../../../../shared/extensions/context_extensions.dart';
import '../widgets/rating_summary_widget.dart';
import '../widgets/review_item_widget.dart';
import '../widgets/review_dialog.dart';
import '../providers/review_notifier.dart';
import '../../domain/entities/review.dart';

class ReviewsSectionWidget extends ConsumerStatefulWidget {
  final int pharmacyId;
  final int clientId;

  const ReviewsSectionWidget({
    super.key,
    required this.pharmacyId,
    required this.clientId,
  });

  @override
  ConsumerState<ReviewsSectionWidget> createState() => _ReviewsSectionWidgetState();
}

class _ReviewsSectionWidgetState extends ConsumerState<ReviewsSectionWidget> {
  @override
  void initState() {
    super.initState();
    // Charger les commentaires et le rating summary après que le widget soit construit
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notifier = ref.read(
        reviewNotifierProvider(ReviewNotifierParams(clientId: widget.clientId)).notifier,
      );
      notifier.loadReviews(pharmacyId: widget.pharmacyId, refresh: true);
      notifier.loadRatingSummary(widget.pharmacyId);
    });
  }

  Future<void> _showReviewDialog({Review? review}) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => ReviewDialog(
        initialRating: review?.rating,
        initialComment: review?.comment,
        isEdit: review != null,
      ),
    );

    if (result != null && mounted) {
      final notifier = ref.read(
        reviewNotifierProvider(ReviewNotifierParams(clientId: widget.clientId)).notifier,
      );

      if (review != null) {
        // Modifier le commentaire existant
        await notifier.updateReview(
          reviewId: review.id,
          pharmacyId: widget.pharmacyId,
          rating: result['rating'] as int,
          comment: result['comment'] as String,
        );
      } else {
        // Créer un nouveau commentaire
        await notifier.createReview(
          pharmacyId: widget.pharmacyId,
          rating: result['rating'] as int,
          comment: result['comment'] as String,
        );
      }

      if (mounted) {
        context.showSnackBar(
          review != null ? 'Votre avis a été modifié' : 'Votre avis a été publié',
        );
      }
    }
  }

  Future<void> _confirmDeleteReview(Review review) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('Supprimer l\'avis'),
        content: const Text('Êtes-vous sûr de vouloir supprimer votre avis ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final notifier = ref.read(
        reviewNotifierProvider(ReviewNotifierParams(clientId: widget.clientId)).notifier,
      );
      await notifier.deleteReview(review.id);

      if (mounted) {
        context.showSnackBar('Votre avis a été supprimé');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final reviewState = ref.watch(
      reviewNotifierProvider(ReviewNotifierParams(clientId: widget.clientId)),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // En-tête de section
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Icon(Icons.rate_review, color: AppColors.primary, size: 24),
              const SizedBox(width: 8),
              Text(
                'Avis et commentaires',
                style: TextStyles.titleLarge,
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // Rating summary
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: RatingSummaryWidget(
            ratingSummary: reviewState.ratingSummary,
          ),
        ),
        const SizedBox(height: 16),
        // Bouton pour ajouter un avis (si l'utilisateur n'en a pas déjà un)
        if (reviewState.userReview == null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: reviewState.isLoading
                    ? null
                    : () => _showReviewDialog(),
                icon: const Icon(Icons.add_comment),
                label: const Text('Donner votre avis'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ),
        const SizedBox(height: 16),
        // Liste des commentaires
        if (reviewState.isLoading && reviewState.reviews.isEmpty)
          const Padding(
            padding: EdgeInsets.all(32),
            child: Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            ),
          )
        else if (reviewState.reviews.isEmpty)
          Padding(
            padding: const EdgeInsets.all(32),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.comment_outlined,
                    size: 64,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Aucun commentaire pour le moment',
                    style: TextStyles.bodyLarge.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                // Afficher le commentaire de l'utilisateur en premier s'il existe
                if (reviewState.userReview != null)
                  ReviewItemWidget(
                    review: reviewState.userReview!,
                    isUserReview: true,
                    onEdit: () => _showReviewDialog(review: reviewState.userReview),
                    onDelete: () => _confirmDeleteReview(reviewState.userReview!),
                  ),
                // Afficher les autres commentaires
                ...reviewState.reviews
                    .where((review) => review.id != reviewState.userReview?.id)
                    .map(
                      (review) => ReviewItemWidget(
                        review: review,
                        isUserReview: false,
                      ),
                    ),
                // Bouton pour charger plus
                if (reviewState.hasMore)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: reviewState.isLoadingMore
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primary,
                            ),
                          )
                        : TextButton(
                            onPressed: () {
                              ref
                                  .read(
                                    reviewNotifierProvider(
                                      ReviewNotifierParams(clientId: widget.clientId),
                                    ).notifier,
                                  )
                                  .loadReviews(pharmacyId: widget.pharmacyId);
                            },
                            child: const Text('Charger plus de commentaires'),
                          ),
                  ),
              ],
            ),
          ),
        // Afficher les erreurs
        if (reviewState.error != null)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.error),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: AppColors.error, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      reviewState.error!,
                      style: TextStyles.bodySmall.copyWith(
                        color: AppColors.error,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
