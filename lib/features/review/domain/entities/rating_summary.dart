class RatingSummary {
  final int pharmacyId;
  final double averageRating; // Moyenne des notes (0-5)
  final int totalReviews; // Nombre total de commentaires
  final Map<int, int> ratingDistribution; // Distribution par note (1-5)

  const RatingSummary({
    required this.pharmacyId,
    required this.averageRating,
    required this.totalReviews,
    required this.ratingDistribution,
  });
}
