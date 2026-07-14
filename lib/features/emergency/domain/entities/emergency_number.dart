class EmergencyNumber {
  final int id;
  final String name;
  final String number;
  final String description;
  final EmergencyCategory category;
  final String icon; // Nom de l'icône Material Icons (ex: "local_police")
  final String color; // Code hexadécimal de la couleur (ex: "#FF0000")

  const EmergencyNumber({
    required this.id,
    required this.name,
    required this.number,
    required this.description,
    required this.category,
    required this.icon,
    required this.color,
  });
}

enum EmergencyCategory {
  medical,
  fire,
  police,
  bloodBank,
  other,
}

extension EmergencyCategoryExtension on EmergencyCategory {
  /// Convertit un EmergencyCategory en chaîne pour l'API
  String toApiString() {
    switch (this) {
      case EmergencyCategory.medical:
        return 'medical';
      case EmergencyCategory.fire:
        return 'fire';
      case EmergencyCategory.police:
        return 'police';
      case EmergencyCategory.bloodBank:
        return 'bloodbank';
      case EmergencyCategory.other:
        return 'other';
    }
  }
}

extension EmergencyCategoryStringExtension on String {
  /// Convertit une chaîne en EmergencyCategory
  EmergencyCategory toEmergencyCategory() {
    switch (toLowerCase()) {
      case 'medical':
      case 'medicale':
        return EmergencyCategory.medical;
      case 'fire':
      case 'pompiers':
        return EmergencyCategory.fire;
      case 'police':
        return EmergencyCategory.police;
      case 'bloodbank':
      case 'blood_bank':
      case 'banque_de_sang':
        return EmergencyCategory.bloodBank;
      default:
        return EmergencyCategory.other;
    }
  }
}

