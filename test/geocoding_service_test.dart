import 'package:flutter_test/flutter_test.dart';
import 'package:pharmacie_de_garde/core/services/geocoding_service.dart';

void main() {
  test('Riviera Palmeraie Guiraud résout le quartier, pas Plateau', () {
    final info = resolveLocationInfo(5.372438, -3.959563);
    expect(info.commune, 'Riviera Palmeraie');
    expect(info.city, 'Abidjan');
    expect(info.displayLabel, 'Riviera Palmeraie, Abidjan');
  });

  test('le centre du Plateau reste Plateau', () {
    final info = resolveLocationInfo(5.3239, -4.0199);
    expect(info.commune, 'Plateau');
    expect(info.displayLabel, 'Plateau, Abidjan');
  });

  test("Yopougon n'est pas remplacé par Plateau", () {
    final info = resolveLocationInfo(5.3369, -4.0897);
    expect(info.commune, 'Yopougon');
  });

  test("hors d'Abidjan : libellé générique, jamais un lieu inventé", () {
    final info = resolveLocationInfo(48.8566, 2.3522);
    expect(info.commune, isEmpty);
    expect(info.city, isEmpty);
    expect(info.displayLabel, 'Position actuelle');
  });
}
