import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../errors/exceptions.dart';

class ApiClient {
  final http.Client client;
  final String baseUrl;

  ApiClient({
    http.Client? client,
    String? baseUrl,
  })  : client = client ?? http.Client(),
        baseUrl = baseUrl ?? ApiConstants.baseUrl;

  Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint').replace(
        queryParameters: queryParameters?.map(
          (key, value) => MapEntry(key, value.toString()),
        ),
      );

      final response = await client
          .get(uri, headers: headers)
          .timeout(ApiConstants.receiveTimeout);

      return _handleResponse(response);
    } on http.ClientException {
      throw const NetworkException('Erreur de connexion réseau');
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException('Erreur inattendue: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> post(
    String endpoint, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      final defaultHeaders = {
        'Content-Type': 'application/json',
        ...?headers,
      };
      final response = await client
          .post(
            uri,
            headers: defaultHeaders,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(ApiConstants.receiveTimeout);

      return _handleResponse(response);
    } on http.ClientException {
      throw const NetworkException('Erreur de connexion réseau');
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException('Erreur inattendue: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> put(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
    Object? body,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint').replace(
        queryParameters: queryParameters?.map(
          (key, value) => MapEntry(key, value.toString()),
        ),
      );
      final defaultHeaders = {
        'Content-Type': 'application/json',
        ...?headers,
      };
      final response = await client
          .put(
            uri,
            headers: defaultHeaders,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(ApiConstants.receiveTimeout);

      return _handleResponse(response);
    } on http.ClientException {
      throw const NetworkException('Erreur de connexion réseau');
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException('Erreur inattendue: ${e.toString()}');
    }
  }

  Future<void> delete(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint').replace(
        queryParameters: queryParameters?.map(
          (key, value) => MapEntry(key, value.toString()),
        ),
      );
      final defaultHeaders = {
        'Content-Type': 'application/json',
        ...?headers,
      };
      final response = await client
          .delete(uri, headers: defaultHeaders)
          .timeout(ApiConstants.receiveTimeout);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        if (response.statusCode == 404) {
          throw const NotFoundException('Ressource non trouvée');
        } else if (response.statusCode >= 500) {
          throw ServerException('Erreur serveur: ${response.statusCode}');
        } else {
          throw ServerException('Erreur: ${response.statusCode}');
        }
      }
    } on http.ClientException {
      throw const NetworkException('Erreur de connexion réseau');
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException('Erreur inattendue: ${e.toString()}');
    }
  }

  /// Méthode pour récupérer directement une liste JSON
  Future<List<dynamic>> getList(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint').replace(
        queryParameters: queryParameters?.map(
          (key, value) => MapEntry(key, value.toString()),
        ),
      );

      final response = await client
          .get(uri, headers: headers)
          .timeout(ApiConstants.receiveTimeout);

      return _handleListResponse(response);
    } on http.ClientException {
      throw const NetworkException('Erreur de connexion réseau');
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException('Erreur inattendue: ${e.toString()}');
    }
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final decoded = jsonDecode(response.body);
      // Si c'est déjà un Map, le retourner tel quel
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      // Si c'est une liste, la wrapper dans un objet avec la clé 'data'
      if (decoded is List) {
        return {'data': decoded};
      }
      throw const ServerException('Format de réponse inattendu');
    } else if (response.statusCode == 404 || response.statusCode == 400) {
      // 400 ou 404 = client non trouvé (pour l'endpoint de login)
      throw const NotFoundException('Client non trouvé');
    } else if (response.statusCode >= 500) {
      throw ServerException('Erreur serveur: ${response.statusCode}');
    } else {
      throw ServerException('Erreur: ${response.statusCode}');
    }
  }

  List<dynamic> _handleListResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final decoded = jsonDecode(response.body);
      if (decoded is List) {
        return decoded;
      }
      throw const ServerException('Format de réponse inattendu: une liste était attendue');
    } else if (response.statusCode == 404 || response.statusCode == 400) {
      // 400 ou 404 = ressource non trouvée
      throw const NotFoundException('Ressource non trouvée');
    } else if (response.statusCode >= 500) {
      throw ServerException('Erreur serveur: ${response.statusCode}');
    } else {
      throw ServerException('Erreur: ${response.statusCode}');
    }
  }

  void dispose() {
    client.close();
  }
}

