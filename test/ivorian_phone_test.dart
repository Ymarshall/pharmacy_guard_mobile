import 'package:flutter_test/flutter_test.dart';
import 'package:pharmacie_de_garde/core/utils/ivorian_phone.dart';

void main() {
  test('accepte les numéros ivoiriens avec indicatif, espaces ou tirets', () {
    expect(IvorianPhone.isValid('+225 07 12 34 56 78'), isTrue);
    expect(IvorianPhone.isValid('07-12-34-56-78'), isTrue);
    expect(IvorianPhone.isValid('00225 05 12 34 56 78'), isTrue);
    expect(IvorianPhone.isValid('225 21 12 34 56 78'), isTrue);
    expect(IvorianPhone.isValid('27 12 34 56 78'), isTrue);
    expect(IvorianPhone.isValid('01.12.34.56.78'), isTrue);
    expect(IvorianPhone.nationalNumber('+225 07 12 34 56 78'), '0712345678');
  });

  test('refuse un numéro vide, étranger ou un mauvais préfixe', () {
    expect(
      IvorianPhone.validationMessage(''),
      IvorianPhone.requiredMessage,
    );
    expect(
      IvorianPhone.validationMessage('+33 6 12 34 56 78'),
      IvorianPhone.invalidMessage,
    );
    expect(
      IvorianPhone.validationMessage('0812345678'),
      IvorianPhone.invalidMessage,
    );
    expect(IvorianPhone.validationMessage('+225 07 12 34 56 78'), isNull);
  });
}
