import '../../features/pharmacy/domain/entities/pharmacy.dart';
import '../../features/pharmacy/domain/entities/insurance.dart';

class MockPharmacies {
  static List<Pharmacy> getPharmacies({
    double? userLatitude,
    double? userLongitude,
  }) {
    // Coordonnées de référence (Abidjan, Côte d'Ivoire)
    final baseLat = userLatitude ?? 5.3600;
    final baseLng = userLongitude ?? -4.0083;

    return [
      Pharmacy(
        id: '1',
        name: 'Pharmacie Grande Plateau',
        phone1: '+225 20 21 22 23',
        phone2: '+225 20 21 22 24',
        email: 'contact@grandeplateau-pharma.ci',
        horaires: 'Lundi-Vendredi: 8h-18h, Samedi: 8h-12h',
        city: 'Abidjan',
        commune: 'Plateau',
        district: 'Abidjan',
        description: 'Pharmacie de garde ouverte 24h/24 et 7j/7. Services de livraison disponibles.',
        pharmacistName: 'Dr. Jean Dupont',
        photo: 'https://via.placeholder.com/400x300?text=Pharmacie+Grande+Plateau',
        statut: 'ACTIF',
        location: '${baseLat + 0.01},${baseLng + 0.01}',
        latitude: baseLat + 0.01,
        longitude: baseLng + 0.01,
        assurances: [
          Insurance(id: 1, name: 'MCI', description: 'Mci'),
          Insurance(id: 2, name: 'NSIA', description: 'Nsia'),
        ],
        distance: 0.5,
        isOpen: true,
        isOnDuty: true,
      ),
      Pharmacy(
        id: '2',
        name: 'Pharmacie St Jean',
        phone1: '+225 20 24 25 26',
        email: 'info@stjean-pharma.ci',
        horaires: 'Lundi-Vendredi: 8h-18h, Samedi: 8h-12h',
        city: 'Abidjan',
        commune: 'Cocody',
        district: 'Abidjan',
        description: 'Pharmacie moderne avec un large choix de médicaments et produits pharmaceutiques.',
        pharmacistName: 'Dr. Marie Kouassi',
        photo: 'https://via.placeholder.com/400x300?text=Pharmacie+St+Jean',
        statut: 'ACTIF',
        location: '${baseLat + 0.015},${baseLng - 0.01}',
        latitude: baseLat + 0.015,
        longitude: baseLng - 0.01,
        assurances: [
          Insurance(id: 1, name: 'MCI', description: 'Mci'),
          Insurance(id: 3, name: 'CNPS', description: 'Cnps'),
        ],
        distance: 0.8,
        isOpen: true,
        isOnDuty: true,
      ),
      Pharmacy(
        id: '3',
        name: 'Pharmacie Grand Plateau',
        phone1: '+225 20 27 28 29',
        email: 'contact@grandplateau-pharma.ci',
        horaires: 'Lun-Sam: 8h-20h, Dim: 9h-18h',
        city: 'Abidjan',
        commune: 'Plateau',
        district: 'Abidjan',
        description: 'Votre pharmacie de confiance au cœur du Plateau.',
        pharmacistName: 'Dr. Paul Kouamé',
        photo: 'https://via.placeholder.com/400x300?text=Pharmacie+Grand+Plateau',
        statut: 'ACTIF',
        location: '${baseLat - 0.01},${baseLng + 0.015}',
        latitude: baseLat - 0.01,
        longitude: baseLng + 0.015,
        assurances: [
          Insurance(id: 2, name: 'NSIA', description: 'Nsia'),
        ],
        distance: 1.2,
        isOpen: true,
        isOnDuty: false,
      ),
    ];
  }
}
