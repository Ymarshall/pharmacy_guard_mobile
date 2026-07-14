import '../../domain/entities/rating_summary.dart';

class RatingSummaryModel extends RatingSummary {
  const RatingSummaryModel({
    required super.pharmacyId,
    required super.averageRating,
    required super.totalReviews,
    required super.ratingDistribution,
  });

  factory RatingSummaryModel.fromJson(Map<String, dynamic> json) {
    final distributionJson = json['ratingDistribution'] as Map<String, dynamic>? ?? {};
    final ratingDistribution = <int, int>{};
    
    distributionJson.forEach((key, value) {
      ratingDistribution[int.parse(key)] = value as int;
    });

    return RatingSummaryModel(
      pharmacyId: json['pharmacyId'] as int,
      averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0.0,
      totalReviews: json['totalReviews'] as int? ?? 0,
      ratingDistribution: ratingDistribution,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pharmacyId': pharmacyId,
      'averageRating': averageRating,
      'totalReviews': totalReviews,
      'ratingDistribution': ratingDistribution.map((key, value) => MapEntry(key.toString(), value)),
    };
  }
}
