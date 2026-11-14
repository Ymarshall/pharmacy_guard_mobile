import 'package:flutter_test/flutter_test.dart';
import 'package:pharmacie_de_garde/core/utils/distance_utils.dart';

void main() {
  group('Temps de trajet estimé', () {
    test('une pharmacie à 485 m ne donne plus « 1 min » en voiture', () {
      // Avant : 485 m à vol d'oiseau à 30 km/h = 1 min.
      expect(DistanceUtils.calculateDrivingTime(0.485), greaterThanOrEqualTo(3));
      expect(DistanceUtils.formatDrivingTime(0.485), '≈ 4 min');
    });

    test('tient compte des détours et de la circulation en ville', () {
      // 2 km à vol d'oiseau ≈ 2,8 km de route à 22 km/h + 2 min.
      expect(DistanceUtils.calculateDrivingTime(2.0), 10);
      // 5 km ≈ 7 km de route ≈ 21 min.
      expect(DistanceUtils.calculateDrivingTime(5.0), 21);
    });

    test('jamais moins de 3 min en voiture, jamais 0 min à pied', () {
      expect(DistanceUtils.calculateDrivingTime(0.0), 3);
      expect(DistanceUtils.calculateWalkingTime(0.0), 1);
    });

    test('marche : distance routière à 4,5 km/h', () {
      expect(DistanceUtils.calculateWalkingTime(1.0), 19);
      expect(DistanceUtils.formatWalkingTime(1.0), '≈ 19 min');
    });

    test('les longs trajets sont affichés en heures', () {
      expect(DistanceUtils.formatDrivingTime(20), '≈ 1 h 18');
    });

    test('distance réelle Guiraud → Riviera Palmeraie (vol d\'oiseau)', () {
      final km = DistanceUtils.calculateDistance(
        5.372438, -3.959563, 5.3665, -3.9595,
      );
      expect(km, closeTo(0.66, 0.05));
    });
  });
}
