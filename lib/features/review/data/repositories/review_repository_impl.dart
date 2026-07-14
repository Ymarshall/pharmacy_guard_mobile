import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/review.dart';
import '../../domain/entities/rating_summary.dart';
import '../../domain/repositories/review_repository.dart';
import '../datasources/review_remote_datasource.dart';

class ReviewRepositoryImpl implements ReviewRepository {
  final ReviewRemoteDataSource remoteDataSource;

  ReviewRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, Review>> createReview({
    required int pharmacyId,
    required int clientId,
    required int rating,
    required String comment,
  }) async {
    try {
      final review = await remoteDataSource.createReview(
        pharmacyId: pharmacyId,
        clientId: clientId,
        rating: rating,
        comment: comment,
      );
      return Right(review);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      if (e is AppException) {
        return Left(ServerFailure(e.message));
      }
      return Left(ServerFailure('Erreur lors de la création du commentaire: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Review>> updateReview({
    required int reviewId,
    required int pharmacyId,
    required int clientId,
    required int rating,
    required String comment,
  }) async {
    try {
      final review = await remoteDataSource.updateReview(
        reviewId: reviewId,
        pharmacyId: pharmacyId,
        clientId: clientId,
        rating: rating,
        comment: comment,
      );
      return Right(review);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      if (e is AppException) {
        return Left(ServerFailure(e.message));
      }
      return Left(ServerFailure('Erreur lors de la modification du commentaire: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteReview({
    required int reviewId,
    required int clientId,
  }) async {
    try {
      await remoteDataSource.deleteReview(
        reviewId: reviewId,
        clientId: clientId,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      if (e is AppException) {
        return Left(ServerFailure(e.message));
      }
      return Left(ServerFailure('Erreur lors de la suppression du commentaire: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Review>>> getPharmacyReviews({
    required int pharmacyId,
    int page = 0,
    int size = 10,
  }) async {
    try {
      final reviews = await remoteDataSource.getPharmacyReviews(
        pharmacyId: pharmacyId,
        page: page,
        size: size,
      );
      return Right(reviews);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      if (e is AppException) {
        return Left(ServerFailure(e.message));
      }
      return Left(ServerFailure('Erreur lors de la récupération des commentaires: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, RatingSummary>> getRatingSummary(int pharmacyId) async {
    try {
      final summary = await remoteDataSource.getRatingSummary(pharmacyId);
      return Right(summary);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      if (e is AppException) {
        return Left(ServerFailure(e.message));
      }
      return Left(ServerFailure('Erreur lors de la récupération des statistiques: ${e.toString()}'));
    }
  }
}
