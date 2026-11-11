import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pharmacie_de_garde/core/theme/app_theme.dart';
import 'package:pharmacie_de_garde/core/utils/distance_utils.dart';
import 'package:pharmacie_de_garde/features/pharmacy/data/models/pharmacy_model.dart';
import 'package:pharmacie_de_garde/features/pharmacy/presentation/widgets/pharmacy_card.dart';

void main() {
  const longName = 'NVLLE PHARMACIE SAINTE MARIE DE LA RIVIERA PALMERAIE';

  PharmacyModel withoutGps() {
    return PharmacyModel.fromJson({
      'id': 12,
      'name': longName,
      'phone1': '+2250700000099',
      'city': 'Abidjan',
      'commune': 'Cocody',
      'statut': 'ACTIF',
      'location': null,
      'latitude': null,
      'longitude': null,
      'distanceInKm': 3.4,
      'isOpen': false,
      'isOnDuty': false,
    });
  }

  test('une pharmacie sans location ne plante pas et n\'a pas de distance', () {
    final pharmacy = withoutGps();

    expect(pharmacy.location, isNull);
    expect(pharmacy.latitude, isNull);
    expect(pharmacy.longitude, isNull);
    expect(pharmacy.hasGps, isFalse);
    expect(pharmacy.distance, isNull);
    expect(
      DistanceUtils.distanceIfPossible(
        5.36,
        -4.01,
        pharmacy.latitude,
        pharmacy.longitude,
      ),
      isNull,
    );
  });

  test(
    'les coordonnées explicites restent utilisables si location est absent',
    () {
      final pharmacy = PharmacyModel.fromJson({
        'id': '3',
        'name': 'Pharmacie du Plateau',
        'phone1': '+22527220001',
        'statut': 'ACTIF',
        'location': '5.320000,-4.020000',
        'isOpen': true,
        'isOnDuty': true,
      });

      expect(pharmacy.hasGps, isTrue);
      expect(pharmacy.latitude, closeTo(5.32, 0.0001));
      expect(pharmacy.longitude, closeTo(-4.02, 0.0001));
      expect(
        DistanceUtils.distanceIfPossible(
          5.32,
          -4.02,
          pharmacy.latitude,
          pharmacy.longitude,
        ),
        isNotNull,
      );
    },
  );

  testWidgets('la carte n\'affiche pas de distance et ne tronque pas le nom', (
    tester,
  ) async {
    final pharmacy = withoutGps();

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(body: PharmacyCard(pharmacy: pharmacy)),
      ),
    );
    await tester.pump();

    final name = tester.widget<Text>(find.text(longName));
    expect(name.maxLines, isNull);
    expect(name.overflow, TextOverflow.visible);
    expect(name.softWrap, isTrue);
    expect(find.textContaining('km'), findsNothing);
    expect(find.text('Localisation indisponible'), findsOneWidget);
  });
}
