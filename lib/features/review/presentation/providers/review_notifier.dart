import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/review.dart';
import '../../domain/entities/rating_summary.dart';
import '../../domain/repositories/review_repository.dart';
import '../../../../core/providers/providers.dart' as providers;

class ReviewState {
  final List<Review> reviews;
  final RatingSummary? ratingSummary;
  final Review? userReview; // Le commentaire de l'utilisateur connecté
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final int currentPage;
  final bool hasMore;

  const ReviewState({
    this.reviews = const [],
    this.ratingSummary,
    this.userReview,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.currentPage = 0,
    this.hasMore = true,
  });

  ReviewState copyWith({
    List<Review>? reviews,
    RatingSummary? ratingSummary,
    Review? userReview,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    int? currentPage,
    bool? hasMore,
  }) {
    return ReviewState(
      reviews: reviews ?? this.reviews,
      ratingSummary: ratingSummary ?? this.ratingSummary,
      userReview: userReview ?? this.userReview,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error == '' ? null : (error ?? this.error),
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

class ReviewNotifier extends StateNotifier<ReviewState> {
  final ReviewRepository reviewRepository;
  final int clientId;

  ReviewNotifier({
    required this.reviewRepository,
    required this.clientId,
  }) : super(const ReviewState());

  Future<void> loadReviews({
    required int pharmacyId,
    bool refresh = false,
  }) async {
    if (refresh) {
      state = state.copyWith(isLoading: true, error: null, currentPage: 0);
    } else {
      state = state.copyWith(isLoadingMore: true, error: null);
    }

    final page = refresh ? 0 : state.currentPage;
    final result = await reviewRepository.getPharmacyReviews(
      pharmacyId: pharmacyId,
      page: page,
      size: 10,
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          isLoadingMore: false,
          error: failure.message,
        );
      },
      (reviews) {
        final allReviews = refresh ? reviews : [...state.reviews, ...reviews];
        final hasMore = reviews.length >= 10;

        // Trouver le commentaire de l'utilisateur
        Review? userReview;
        try {
          userReview = allReviews.firstWhere(
            (review) => review.clientId == clientId,
          );
        } catch (e) {
          userReview = state.userReview;
        }

        state = state.copyWith(
          reviews: allReviews,
          userReview: userReview,
          isLoading: false,
          isLoadingMore: false,
          currentPage: page + 1,
          hasMore: hasMore,
        );
      },
    );
  }

  Future<void> loadRatingSummary(int pharmacyId) async {
    final result = await reviewRepository.getRatingSummary(pharmacyId);

    result.fold(
      (failure) {
        // Ne pas afficher d'erreur pour le rating summary, juste ne pas l'afficher
      },
      (summary) {
        state = state.copyWith(ratingSummary: summary);
      },
    );
  }

  Future<void> createReview({
    required int pharmacyId,
    required int rating,
    required String comment,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await reviewRepository.createReview(
      pharmacyId: pharmacyId,
      clientId: clientId,
      rating: rating,
      comment: comment,
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
        );
      },
      (review) {
        // Ajouter le nouveau commentaire en début de liste
        final updatedReviews = [review, ...state.reviews];
        state = state.copyWith(
          reviews: updatedReviews,
          userReview: review,
          isLoading: false,
        );
        // Recharger le rating summary
        loadRatingSummary(pharmacyId);
      },
    );
  }

  Future<void> updateReview({
    required int reviewId,
    required int pharmacyId,
    required int rating,
    required String comment,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await reviewRepository.updateReview(
      reviewId: reviewId,
      pharmacyId: pharmacyId,
      clientId: clientId,
      rating: rating,
      comment: comment,
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
        );
      },
      (updatedReview) {
        // Mettre à jour le commentaire dans la liste
        final updatedReviews = state.reviews.map((review) {
          return review.id == reviewId ? updatedReview : review;
        }).toList();

        state = state.copyWith(
          reviews: updatedReviews,
          userReview: updatedReview,
          isLoading: false,
        );
        // Recharger le rating summary
        if (updatedReview.pharmacyId > 0) {
          loadRatingSummary(updatedReview.pharmacyId);
        }
      },
    );
  }

  Future<void> deleteReview(int reviewId) async {
    // Sauvegarder le pharmacyId avant de modifier le state
    int? pharmacyId;
    try {
      pharmacyId = state.userReview?.pharmacyId ?? 
                   state.reviews.firstWhere((review) => review.id == reviewId).pharmacyId;
    } catch (e) {
      // Si le commentaire n'est pas trouvé, on ne peut pas récupérer le pharmacyId
      pharmacyId = null;
    }
    
    state = state.copyWith(isLoading: true, error: null);

    final result = await reviewRepository.deleteReview(
      reviewId: reviewId,
      clientId: clientId,
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
        );
      },
      (_) {
        // Retirer le commentaire de la liste
        final updatedReviews = state.reviews.where((review) => review.id != reviewId).toList();

        // Mettre à jour le state immédiatement pour que le bouton apparaisse
        // Utiliser un nouveau state pour forcer la mise à jour
        state = ReviewState(
          reviews: updatedReviews,
          ratingSummary: state.ratingSummary,
          userReview: null,
          isLoading: false,
          isLoadingMore: false,
          error: null,
          currentPage: state.currentPage,
          hasMore: state.hasMore,
        );
        
        // Recharger le rating summary
        if (pharmacyId != null && pharmacyId > 0) {
          loadRatingSummary(pharmacyId);
        }
      },
    );
  }
}

final reviewNotifierProvider = StateNotifierProvider.family<ReviewNotifier, ReviewState, ReviewNotifierParams>(
  (ref, params) {
    final repository = ref.watch(providers.reviewRepositoryProvider);
    return ReviewNotifier(
      reviewRepository: repository,
      clientId: params.clientId,
    );
  },
);

class ReviewNotifierParams {
  final int clientId;

  ReviewNotifierParams({required this.clientId});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ReviewNotifierParams && other.clientId == clientId;
  }

  @override
  int get hashCode => clientId.hashCode;
}
