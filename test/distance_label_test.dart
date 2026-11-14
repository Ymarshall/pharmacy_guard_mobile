import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pharmacie_de_garde/features/pharmacy/presentation/widgets/pharmacy_card.dart';

void main() {
  const style = TextStyle(fontSize: 12, height: 1.2, fontFamily: 'Roboto');

  test('affiche aussi le temps à pied quand la ligne est assez large', () {
    expect(
      fitsWalkingTime(
        driving: '485 m · ≈ 4 min',
        walkingTime: '≈ 9 min',
        maxWidth: 400,
        style: style,
      ),
      isTrue,
    );
  });

  test('abandonne le temps à pied (pas le temps voiture) si la ligne est étroite', () {
    expect(
      fitsWalkingTime(
        driving: '485 m · ≈ 4 min',
        walkingTime: '≈ 9 min',
        maxWidth: 120,
        style: style,
      ),
      isFalse,
    );
  });
}
