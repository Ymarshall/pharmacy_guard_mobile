import '../../domain/entities/review.dart';

class ReviewModel extends Review {
  const ReviewModel({
    required super.id,
    required super.pharmacyId,
    super.pharmacyName,
    required super.clientId,
    super.clientName,
    required super.rating,
    required super.comment,
    required super.createdAt,
    required super.updatedAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    // Gérer les cas où certains champs peuvent être absents (notamment lors de la création)
    // L'API peut renvoyer seulement: pharmacyId, clientId, rating, comment
    
    // ID peut être absent lors de la création, on utilise 0 comme valeur temporaire
    final idValue = json['id'];
    final id = idValue is int 
        ? idValue 
        : (idValue != null ? int.tryParse(idValue.toString()) ?? 0 : 0);
    
    // pharmacyId est requis
    final pharmacyId = (json['pharmacyId'] as num?)?.toInt() ?? 0;
    
    // clientId est requis
    final clientId = (json['clientId'] as num?)?.toInt() ?? 0;
    
    // rating est requis
    final rating = (json['rating'] as num?)?.toInt() ?? 5;
    
    // comment peut être null ou absent
    final comment = json['comment'] as String? ?? '';
    
    // pharmacyName est optionnel
    final pharmacyName = json['pharmacyName'] as String?;
    
    // clientName est optionnel
    final clientName = json['clientName'] as String?;
    
    // Dates peuvent être absentes lors de la création
    final createdAtStr = json['createdAt'] as String?;
    final createdAt = createdAtStr != null 
        ? DateTime.tryParse(createdAtStr) ?? DateTime.now()
        : DateTime.now();
    
    final updatedAtStr = json['updatedAt'] as String?;
    final updatedAt = updatedAtStr != null 
        ? DateTime.tryParse(updatedAtStr) ?? DateTime.now()
        : DateTime.now();
    
    return ReviewModel(
      id: id,
      pharmacyId: pharmacyId,
      pharmacyName: pharmacyName,
      clientId: clientId,
      clientName: clientName,
      rating: rating,
      comment: comment,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pharmacyId': pharmacyId,
      'pharmacyName': pharmacyName,
      'clientId': clientId,
      'clientName': clientName,
      'rating': rating,
      'comment': comment,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'pharmacyId': pharmacyId,
      'clientId': clientId,
      'rating': rating,
      'comment': comment,
    };
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'rating': rating,
      'comment': comment,
    };
  }
}
