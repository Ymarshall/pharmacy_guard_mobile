import 'dart:convert';

/// Corps d'erreur renvoyé par le backend (`ApiError`).
class ApiErrorPayload {
  final int? statusCode;
  final String? status;
  final String? message;
  final Map<String, String> fieldErrors;

  const ApiErrorPayload({
    this.statusCode,
    this.status,
    this.message,
    this.fieldErrors = const {},
  });

  static ApiErrorPayload? tryParse(String body) {
    final trimmed = body.trim();
    if (trimmed.isEmpty) return null;
    try {
      final decoded = jsonDecode(trimmed);
      if (decoded is! Map) return null;
      final errors = <String, String>{};
      final rawErrors = decoded['errors'];
      if (rawErrors is Map) {
        rawErrors.forEach((key, value) {
          if (value != null) {
            final text = value.toString().trim();
            if (text.isNotEmpty) errors[key.toString()] = text;
          }
        });
      }
      return ApiErrorPayload(
        statusCode: (decoded['statusCode'] as num?)?.toInt(),
        status: decoded['status'] as String?,
        message: decoded['message'] as String?,
        fieldErrors: errors,
      );
    } catch (_) {
      return null;
    }
  }

  /// Message affichable. Les erreurs de champ priment sur le message générique.
  String frenchMessage(String fallback) {
    final details = fieldErrors.values.toList();
    final base = message?.trim();
    if (details.isNotEmpty) {
      final joined = details.join('\n');
      if (base != null &&
          base.isNotEmpty &&
          base != 'Erreurs de validation' &&
          !joined.contains(base)) {
        return '$base\n$joined';
      }
      return joined;
    }
    if (base != null && base.isNotEmpty) return base;
    return fallback;
  }

  bool get indicatesMissingAccount {
    final text = frenchMessage('').toLowerCase();
    return text.contains('non trouvé') ||
        text.contains('non trouve') ||
        text.contains('introuvable');
  }
}

class ApiErrorMessages {
  static const rateLimit =
      'Trop de tentatives de connexion. Réessayez dans une minute.';
  static const unauthorized =
      'Authentification requise. Reconnectez-vous pour continuer.';
  static const forbidden = 'Accès refusé';
  static const notFound = 'Ressource non trouvée';
  static const invalidRequest = 'Requête invalide';
}
