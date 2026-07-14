import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/review.dart';
import '../entities/rating_summary.dart';

abstract class ReviewRepository {
  Future<Either<Failure, Review>> createReview({
    required int pharmacyId,
    required int clientId,
    required int rating,
    required String comment,
  });

  Future<Either<Failure, Review>> updateReview({
    required int reviewId,
    required int pharmacyId,
    required int clientId,
    required int rating,
    required String comment,
  });

  Future<Either<Failure, void>> deleteReview({
    required int reviewId,
    required int clientId,
  });

  Future<Either<Failure, List<Review>>> getPharmacyReviews({
    required int pharmacyId,
    int page = 0,
    int size = 10,
  });

  Future<Either<Failure, RatingSummary>> getRatingSummary(int pharmacyId);
}
