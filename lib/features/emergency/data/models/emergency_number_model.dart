import '../../domain/entities/emergency_number.dart';

class EmergencyNumberModel extends EmergencyNumber {
  const EmergencyNumberModel({
    required super.id,
    required super.name,
    required super.number,
    required super.description,
    required super.category,
    required super.icon,
    required super.color,
  });

  factory EmergencyNumberModel.fromJson(Map<String, dynamic> json) {
    return EmergencyNumberModel(
      id: json['id'] as int,
      name: json['name'] as String,
      number: json['number'] as String,
      icon: json['icon'] as String? ?? 'info',
      description: json['description'] as String? ?? '',
      color: json['color'] as String? ?? '#FF0000',
      category: (json['category'] as String? ?? 'other').toEmergencyCategory(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'number': number,
      'icon': icon,
      'description': description,
      'color': color,
      'category': category.toApiString(),
    };
  }

  EmergencyNumberModel copyWith({
    int? id,
    String? name,
    String? number,
    String? icon,
    String? description,
    String? color,
    EmergencyCategory? category,
  }) {
    return EmergencyNumberModel(
      id: id ?? this.id,
      name: name ?? this.name,
      number: number ?? this.number,
      icon: icon ?? this.icon,
      description: description ?? this.description,
      color: color ?? this.color,
      category: category ?? this.category,
    );
  }
}

