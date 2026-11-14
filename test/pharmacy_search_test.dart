import 'package:flutter_test/flutter_test.dart';
import 'package:pharmacie_de_garde/core/utils/pharmacy_search.dart';
import 'package:pharmacie_de_garde/features/pharmacy/data/models/pharmacy_model.dart';

PharmacyModel _p(String id, String name, {String? commune, String? city, String phone = ''}) =>
    PharmacyModel(
      id: id,
      name: name,
      phone1: phone,
      commune: commune,
      city: city,
      statut: 'ACTIF',
      latitude: null,
      longitude: null,
      isOpen: true,
      isOnDuty: false,
    );

void main() {
  // Noms réels de la base (import du 13/11).
  final pharmacies = [
    _p('1', 'PHCIE ST PAUL DIDIEVI', city: 'DIDIEVI'),
    _p('2', 'PHCIE SAINT-PAUL', commune: 'COCODY'),
    _p('3', 'PHARMACIE APPAUL', commune: 'YOPOUGON'),
    _p('4', 'PHARMACIE SAINTE PAULINE', commune: 'ABOBO'),
    _p('5', 'PHARMACIE BONNE SANTÉ', commune: 'COCODY'),
    _p('6', 'PHARMACIE MARTHE ROBIN', commune: 'COCODY', phone: '+225 27 22 49 00 00'),
    _p('7', 'PHARMACIE DU PLATEAU', commune: 'PLATEAU'),
  ];

  List<String> names(String q) =>
      PharmacySearch.filter(pharmacies, q).map((p) => p.name).toList();

  test('« paul » trouve les pharmacies St Paul (casse, mot partiel)', () {
    final r = names('paul');
    expect(r, contains('PHCIE ST PAUL DIDIEVI'));
    expect(r, contains('PHCIE SAINT-PAUL'));
    // Les mots exacts passent avant « APPAUL ».
    expect(r.indexOf('PHCIE SAINT-PAUL'), lessThan(r.indexOf('PHARMACIE APPAUL')));
  });

  test('ST, SAINT et le trait d\'union sont équivalents', () {
    expect(names('st paul'), containsAll(['PHCIE ST PAUL DIDIEVI', 'PHCIE SAINT-PAUL']));
    expect(names('saint paul'), containsAll(['PHCIE ST PAUL DIDIEVI', 'PHCIE SAINT-PAUL']));
    expect(names('pharmacie st paul'), containsAll(['PHCIE ST PAUL DIDIEVI', 'PHCIE SAINT-PAUL']));
    expect(names('pharmacie st paul'), isNot(contains('PHARMACIE DU PLATEAU')));
    expect(names('ste pauline'), ['PHARMACIE SAINTE PAULINE']);
  });

  test('insensible aux accents', () {
    expect(names('bonne sante'), ['PHARMACIE BONNE SANTÉ']);
    expect(names('SANTÉ'), ['PHARMACIE BONNE SANTÉ']);
  });

  test('recherche par commune et combinaison nom + commune', () {
    expect(names('cocody').length, 3);
    expect(names('paul cocody'), ['PHCIE SAINT-PAUL']);
  });

  test('recherche par numéro de téléphone', () {
    expect(names('27224900'), ['PHARMACIE MARTHE ROBIN']);
  });

  test('normalisation', () {
    expect(PharmacySearch.normalize("PHCIE ST-PAUL D'AKROMIABLA"),
        'pharmacie saint paul d akromiabla');
    expect(PharmacySearch.normalize('  Éléphant   '), 'elephant');
  });

  test('requête vide : liste inchangée', () {
    expect(PharmacySearch.filter(pharmacies, '   ').length, pharmacies.length);
  });
}
