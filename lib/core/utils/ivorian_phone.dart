/// Même règle que le backend (`IvorianPhoneValidator`).
///
/// 10 chiffres nationaux, préfixes 01, 05, 07, 21, 25 ou 27.
/// Indicatif +225, 00225 ou 225 facultatif. Espaces, points, tirets et
/// parenthèses sont ignorés.
class IvorianPhone {
  static final RegExp _compact = RegExp(
    r'^(?:\+225|00225|225)?((?:01|05|07|21|25|27)\d{8})$',
  );

  static const String requiredMessage =
      'Le numéro de téléphone est obligatoire';
  static const String invalidMessage =
      'Le numéro de téléphone doit être un numéro ivoirien valide';

  static String? nationalNumber(String? raw) {
    if (raw == null) return null;
    final compact = raw.trim().replaceAll(RegExp(r'[\s.\-()/]'), '');
    final match = _compact.firstMatch(compact);
    if (match == null) return null;
    return match.group(1);
  }

  static bool isValid(String? raw) => nationalNumber(raw) != null;

  /// Message à afficher sous le champ, ou null si le numéro est accepté.
  static String? validationMessage(String? raw) {
    if (raw == null || raw.trim().isEmpty) return requiredMessage;
    if (!isValid(raw)) return invalidMessage;
    return null;
  }
}
