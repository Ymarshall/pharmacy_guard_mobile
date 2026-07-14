import '../../features/emergency/domain/entities/emergency_number.dart';

class MockEmergencyNumbers {
  static List<EmergencyNumber> getEmergencyNumbers() {
    return [
      // Medical
      EmergencyNumber(
        id: '1',
        name: 'SAMU (Service d\'Aide Médicale Urgente)',
        number: '185',
        description: 'Service d\'urgence médicale 24h/24',
        category: EmergencyCategory.medical,
        icon: '🚑',
      ),
      EmergencyNumber(
        id: '2',
        name: 'Centre Anti-Poison',
        number: '+225 27 22 44 44 44',
        description: 'Urgences liées aux intoxications',
        category: EmergencyCategory.medical,
        icon: '☠️',
      ),
      EmergencyNumber(
        id: '3',
        name: 'Croix-Rouge',
        number: '+225 27 22 44 44 44',
        description: 'Assistance médicale et humanitaire',
        category: EmergencyCategory.medical,
        icon: '➕',
      ),
      // Fire
      EmergencyNumber(
        id: '4',
        name: 'Pompiers',
        number: '180',
        description: 'Service de secours et d\'incendie',
        category: EmergencyCategory.fire,
        icon: '🚒',
      ),
      // Police
      EmergencyNumber(
        id: '5',
        name: 'Police Nationale',
        number: '170',
        description: 'Police secours et interventions',
        category: EmergencyCategory.police,
        icon: '🚔',
      ),
      EmergencyNumber(
        id: '6',
        name: 'Gendarmerie',
        number: '+225 27 22 40 40 40',
        description: 'Forces de sécurité et maintien de l\'ordre',
        category: EmergencyCategory.police,
        icon: '👮',
      ),
      // Blood Bank
      EmergencyNumber(
        id: '7',
        name: 'Centre National de Transfusion Sanguine',
        number: '+225 27 22 44 44 44',
        description: 'Banque de sang et dons de sang',
        category: EmergencyCategory.bloodBank,
        icon: '🩸',
      ),
      EmergencyNumber(
        id: '8',
        name: 'Banque de Sang CHU de Cocody',
        number: '+225 27 22 44 44 44',
        description: 'Dons de sang et produits sanguins',
        category: EmergencyCategory.bloodBank,
        icon: '🩸',
      ),
      // Other
      EmergencyNumber(
        id: '9',
        name: 'SOS Enfants',
        number: '+225 27 22 44 44 44',
        description: 'Protection de l\'enfance en danger',
        category: EmergencyCategory.other,
        icon: '👶',
      ),
      EmergencyNumber(
        id: '10',
        name: 'Électricité (CIE)',
        number: '+225 27 22 44 44 44',
        description: 'Urgences électriques',
        category: EmergencyCategory.other,
        icon: '⚡',
      ),
      EmergencyNumber(
        id: '11',
        name: 'Eau (SODECI)',
        number: '+225 27 22 44 44 44',
        description: 'Urgences liées à l\'eau',
        category: EmergencyCategory.other,
        icon: '💧',
      ),
    ];
  }

  static List<EmergencyNumber> getByCategory(EmergencyCategory category) {
    return getEmergencyNumbers()
        .where((number) => number.category == category)
        .toList();
  }
}

