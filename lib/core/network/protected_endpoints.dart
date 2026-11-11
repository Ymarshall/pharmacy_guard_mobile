/// Routes qui exigent le jeton client (`Authorization: Bearer`).
///
/// Restent publiques : lecture des pharmacies, proximité, urgences, zones,
/// période courante, recherche client et consultation des avis.
class ProtectedEndpoints {
  static final RegExp _createReview = RegExp(
    r'^/client/pharmacies/[^/]+/reviews$',
  );

  static bool requiresBearer(String method, String endpoint) {
    final path = _normalize(endpoint);
    final verb = method.toUpperCase();

    if (verb == 'POST' && _createReview.hasMatch(path)) return true;
    if ((verb == 'PUT' || verb == 'DELETE') &&
        path.startsWith('/client/pharmacies/reviews/')) {
      return true;
    }
    if (verb == 'POST' && path == '/client/pharmacies/duty/report') return true;
    // Compte client (profil, position). La création anonyme POST /clients
    // n'a pas encore de jeton.
    if (path.startsWith('/clients/')) return true;
    return false;
  }

  static String _normalize(String endpoint) {
    var path = endpoint.split('?').first;
    if (path.length > 1 && path.endsWith('/')) {
      path = path.substring(0, path.length - 1);
    }
    return path;
  }
}
