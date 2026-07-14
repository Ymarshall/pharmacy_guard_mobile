class Review {
  final int id;
  final int pharmacyId;
  final String? pharmacyName;
  final int clientId;
  final String? clientName;
  final int rating; // 1-5
  final String comment;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Review({
    required this.id,
    required this.pharmacyId,
    this.pharmacyName,
    required this.clientId,
    this.clientName,
    required this.rating,
    required this.comment,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Review && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
