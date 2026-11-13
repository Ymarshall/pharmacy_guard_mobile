import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pharmacie_de_garde/features/pharmacy/presentation/widgets/pharmacy_card.dart';

void main() {
  const style = TextStyle(fontSize: 12, height: 1.2, fontFamily: 'Roboto');

  test(
    'garde la distance et le temps voiture quand la ligne est assez large',
    () {
      final label = fitDistanceDrivingLabel(
        distance: '485 m',
        drivingTime: '1 min',
        walkingTime: '6 min',
        maxWidth: 400,
        style: style,
      );
      expect(label, '485 m · 1 min');
    },
  );

  test('abandonne le temps voiture si la ligne est trop étroite', () {
    final label = fitDistanceDrivingLabel(
      distance: '485 m',
      drivingTime: '1 min',
      walkingTime: '6 min',
      maxWidth: 90,
      style: style,
    );
    expect(label, '485 m');
    expect(label.contains('·'), isFalse);
  });
}
