import '../../domain/entities/insurance.dart';

class InsuranceModel extends Insurance {
  const InsuranceModel({
    required super.id,
    required super.name,
    required super.description,
  });

  factory InsuranceModel.fromJson(Map<String, dynamic> json) {
    return InsuranceModel(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
    };
  }
}

