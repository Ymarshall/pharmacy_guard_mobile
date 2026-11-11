import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/extensions/theme_extension.dart';
import '../../../../shared/extensions/context_extensions.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../shared/widgets/section_header.dart';
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
  ConsumerState<ReviewsSectionWidget> createState() =>
      _ReviewsSectionWidgetState();
}

class _ReviewsSectionWidgetState extends ConsumerState<ReviewsSectionWidget> {
  @override
  void initState() {
    super.initState();
    // Charger les commentaires et le rating summary après que le widget soit construit
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notifier = ref.read(
        reviewNotifierProvider(
          ReviewNotifierParams(clientId: widget.clientId),
        ).notifier,
      );
      notifier.loadReviews(pharmacyId: widget.pharmacyId, refresh: true);
      notifier.loadRatingSummary(widget.pharmacyId);
    });
  }

  Future<void> _showReviewDialog({Review? review}) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder:
          (context) => ReviewDialog(
            initialRating: review?.rating,
            initialComment: review?.comment,
            isEdit: review != null,
          ),
    );

    if (result != null && mounted) {
      final notifier = ref.read(
        reviewNotifierProvider(
          ReviewNotifierParams(clientId: widget.clientId),
        ).notifier,
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
        final error =
            ref
                .read(
                  reviewNotifierProvider(
                    ReviewNotifierParams(clientId: widget.clientId),
                  ),
                )
                .error;
        if (error == null) {
          context.showSnackBar(
            review != null
                ? 'Votre avis a été modifié'
                : 'Votre avis a été publié',
          );
        }
      }
    }
  }

  Future<void> _confirmDeleteReview(Review review) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
            ),
            title: const Text('Supprimer l\'avis'),
            content: const Text(
              'Êtes-vous sûr de vouloir supprimer votre avis ?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Annuler'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.error,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Supprimer'),
              ),
            ],
          ),
    );

    if (confirmed == true && mounted) {
      final notifier = ref.read(
        reviewNotifierProvider(
          ReviewNotifierParams(clientId: widget.clientId),
        ).notifier,
      );
      await notifier.deleteReview(review.id);

      if (mounted) {
        final error =
            ref
                .read(
                  reviewNotifierProvider(
                    ReviewNotifierParams(clientId: widget.clientId),
                  ),
                )
                .error;
        if (error == null) {
          context.showSnackBar('Votre avis a été supprimé');
        }
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
        const Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          child: SectionHeader(
            eyebrow: 'Communauté',
            title: 'Avis et commentaires',
          ),
        ),
        const SizedBox(height: 8),
        // Rating summary
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: RatingSummaryWidget(ratingSummary: reviewState.ratingSummary),
        ),
        const SizedBox(height: 16),
        // Bouton pour ajouter un avis (si l'utilisateur n'en a pas déjà un)
        if (reviewState.userReview == null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: double.infinity,
              child: PrimaryButton(
                label: 'Donner votre avis',
                icon: Icons.add_comment_outlined,
                onPressed:
                    reviewState.isLoading ? null : () => _showReviewDialog(),
              ),
            ),
          ),
        const SizedBox(height: 16),
        // Liste des commentaires
        if (reviewState.isLoading && reviewState.reviews.isEmpty)
          const Padding(padding: EdgeInsets.all(32), child: LoadingWidget())
        else if (reviewState.reviews.isEmpty)
          const EmptyState(
            icon: Icons.comment_outlined,
            message: 'Aucun commentaire pour le moment',
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
                    onEdit:
                        () => _showReviewDialog(review: reviewState.userReview),
                    onDelete:
                        () => _confirmDeleteReview(reviewState.userReview!),
                  ),
                // Afficher les autres commentaires
                ...reviewState.reviews
                    .where((review) => review.id != reviewState.userReview?.id)
                    .map(
                      (review) =>
                          ReviewItemWidget(review: review, isUserReview: false),
                    ),
                // Bouton pour charger plus
                if (reviewState.hasMore)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child:
                        reviewState.isLoadingMore
                            ? Center(
                              child: CircularProgressIndicator(
                                color: context.primary,
                              ),
                            )
                            : TextButton(
                              onPressed: () {
                                ref
                                    .read(
                                      reviewNotifierProvider(
                                        ReviewNotifierParams(
                                          clientId: widget.clientId,
                                        ),
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
                color: context.errorSurface,
                borderRadius: BorderRadius.circular(AppSpacing.controlRadius),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: context.error, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      reviewState.error!,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: context.error),
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
