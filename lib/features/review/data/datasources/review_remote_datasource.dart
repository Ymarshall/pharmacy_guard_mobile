import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/review_model.dart';
import '../models/rating_summary_model.dart';

abstract class ReviewRemoteDataSource {
  Future<ReviewModel> createReview({
    required int pharmacyId,
    required int clientId,
    required int rating,
    required String comment,
  });
  
  Future<ReviewModel> updateReview({
    required int reviewId,
    required int pharmacyId,
    required int clientId,
    required int rating,
    required String comment,
  });
  
  Future<void> deleteReview({
    required int reviewId,
    required int clientId,
  });
  
  Future<List<ReviewModel>> getPharmacyReviews({
    required int pharmacyId,
    int page = 0,
    int size = 10,
  });
  
  Future<RatingSummaryModel> getRatingSummary(int pharmacyId);
}

class ReviewRemoteDataSourceImpl implements ReviewRemoteDataSource {
  final ApiClient apiClient;

  ReviewRemoteDataSourceImpl(this.apiClient);

  @override
  Future<ReviewModel> createReview({
    required int pharmacyId,
    required int clientId,
    required int rating,
    required String comment,
  }) async {
    try {
      final response = await apiClient.post(
        ApiConstants.pharmacyReviewsEndpoint(pharmacyId),
        body: {
          'pharmacyId': pharmacyId,
          'clientId': clientId,
          'rating': rating,
          'comment': comment,
        },
      );
      return ReviewModel.fromJson(response);
    } on ServerException {
      rethrow;
    } on NetworkException {
      rethrow;
    } catch (e) {
      if (e is AppException) rethrow;
      throw ServerException('Erreur lors de la création du commentaire: ${e.toString()}');
    }
  }

  @override
  Future<ReviewModel> updateReview({
    required int reviewId,
    required int pharmacyId,
    required int clientId,
    required int rating,
    required String comment,
  }) async {
    try {
      final response = await apiClient.put(
        ApiConstants.updateReviewEndpoint(reviewId),
        queryParameters: {
          'clientId': clientId.toString(),
        },
        body: {
          'pharmacyId': pharmacyId,
          'clientId': clientId,
          'rating': rating,
          'comment': comment,
        },
      );
      return ReviewModel.fromJson(response);
    } on ServerException {
      rethrow;
    } on NetworkException {
      rethrow;
    } catch (e) {
      if (e is AppException) rethrow;
      throw ServerException('Erreur lors de la modification du commentaire: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteReview({
    required int reviewId,
    required int clientId,
  }) async {
    try {
      await apiClient.delete(
        ApiConstants.deleteReviewEndpoint(reviewId),
        queryParameters: {
          'clientId': clientId.toString(),
        },
      );
    } on ServerException {
      rethrow;
    } on NetworkException {
      rethrow;
    } catch (e) {
      if (e is AppException) rethrow;
      throw ServerException('Erreur lors de la suppression du commentaire: ${e.toString()}');
    }
  }

  @override
  Future<List<ReviewModel>> getPharmacyReviews({
    required int pharmacyId,
    int page = 0,
    int size = 10,
  }) async {
    try {
      final response = await apiClient.getList(
        ApiConstants.pharmacyReviewsEndpoint(pharmacyId),
        queryParameters: {
          'page': page.toString(),
          'size': size.toString(),
        },
      );
      return response.map((json) => ReviewModel.fromJson(json as Map<String, dynamic>)).toList();
    } on ServerException {
      rethrow;
    } on NetworkException {
      rethrow;
    } catch (e) {
      if (e is AppException) rethrow;
      throw ServerException('Erreur lors de la récupération des commentaires: ${e.toString()}');
    }
  }

  @override
  Future<RatingSummaryModel> getRatingSummary(int pharmacyId) async {
    try {
      final response = await apiClient.get(
        ApiConstants.pharmacyRatingSummaryEndpoint(pharmacyId),
      );
      return RatingSummaryModel.fromJson(response);
    } on ServerException {
      rethrow;
    } on NetworkException {
      rethrow;
    } catch (e) {
      if (e is AppException) rethrow;
      throw ServerException('Erreur lors de la récupération des statistiques: ${e.toString()}');
    }
  }
}
