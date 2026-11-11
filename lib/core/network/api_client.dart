import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants/api_constants.dart';
import '../errors/exceptions.dart';
import 'api_error_payload.dart';
import 'protected_endpoints.dart';

class ApiClient {
  final http.Client client;
  final String baseUrl;
  final Future<String?> Function()? readAccessToken;
  final Future<bool> Function()? onUnauthorized;

  ApiClient({
    http.Client? client,
    String? baseUrl,
    this.readAccessToken,
    this.onUnauthorized,
  }) : client = client ?? http.Client(),
       baseUrl = baseUrl ?? ApiConstants.baseUrl;

  Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
  }) async {
    final response = await _send(
      method: 'GET',
      endpoint: endpoint,
      headers: headers,
      queryParameters: queryParameters,
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> post(
    String endpoint, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    final response = await _send(
      method: 'POST',
      endpoint: endpoint,
      headers: headers,
      body: body,
      jsonBody: true,
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> put(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
    Object? body,
  }) async {
    final response = await _send(
      method: 'PUT',
      endpoint: endpoint,
      headers: headers,
      queryParameters: queryParameters,
      body: body,
      jsonBody: true,
    );
    return _handleResponse(response);
  }

  Future<void> delete(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
  }) async {
    final response = await _send(
      method: 'DELETE',
      endpoint: endpoint,
      headers: headers,
      queryParameters: queryParameters,
      jsonBody: true,
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw _exceptionFor(response);
    }
  }

  /// Récupère directement une liste JSON (sans pagination).
  Future<List<dynamic>> getList(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
  }) async {
    final response = await _send(
      method: 'GET',
      endpoint: endpoint,
      headers: headers,
      queryParameters: queryParameters,
    );
    return _handleListResponse(response);
  }

  Future<http.Response> _send({
    required String method,
    required String endpoint,
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
    Object? body,
    bool jsonBody = false,
  }) async {
    final uri = Uri.parse('$baseUrl$endpoint').replace(
      queryParameters: queryParameters?.map(
        (key, value) => MapEntry(key, value.toString()),
      ),
    );

    Future<http.Response> once() async {
      final built = await _headers(
        method,
        endpoint,
        headers,
        jsonBody: jsonBody,
      );
      final encoded = body == null ? null : jsonEncode(body);
      switch (method) {
        case 'GET':
          return client.get(uri, headers: built);
        case 'POST':
          return client.post(uri, headers: built, body: encoded);
        case 'PUT':
          return client.put(uri, headers: built, body: encoded);
        case 'DELETE':
          return client.delete(uri, headers: built);
        default:
          throw ArgumentError('Méthode HTTP non gérée: $method');
      }
    }

    try {
      var response = await once().timeout(ApiConstants.receiveTimeout);
      if (response.statusCode == 401 &&
          ProtectedEndpoints.requiresBearer(method, endpoint)) {
        final recovered = await _reconnect();
        if (recovered) {
          response = await once().timeout(ApiConstants.receiveTimeout);
        }
      }
      return response;
    } on http.ClientException {
      throw const NetworkException('Erreur de connexion réseau');
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException('Erreur inattendue: ${e.toString()}');
    }
  }

  Future<bool> _reconnect() async {
    final hook = onUnauthorized;
    if (hook == null) return false;
    try {
      return await hook();
    } catch (_) {
      return false;
    }
  }

  Future<Map<String, String>> _headers(
    String method,
    String endpoint,
    Map<String, String>? headers, {
    required bool jsonBody,
  }) async {
    final result = <String, String>{
      if (jsonBody) 'Content-Type': 'application/json',
      ...?headers,
    };
    if (ProtectedEndpoints.requiresBearer(method, endpoint) &&
        !result.containsKey('Authorization')) {
      final token = await readAccessToken?.call();
      if (token != null && token.isNotEmpty) {
        result['Authorization'] = 'Bearer $token';
      }
    }
    return result;
  }

  String _body(http.Response response) {
    final bytes = response.bodyBytes;
    try {
      return utf8.decode(bytes);
    } on FormatException {
      // Le filtre 429 du backend écrit le JSON sans charset (latin-1).
      return latin1.decode(bytes);
    }
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw _exceptionFor(response);
    }
    final body = _body(response);
    if (body.trim().isEmpty) {
      return <String, dynamic>{};
    }
    final decoded = jsonDecode(body);
    if (decoded is Map<String, dynamic>) return decoded;
    if (decoded is List) return {'data': decoded};
    throw const ServerException('Format de réponse inattendu');
  }

  List<dynamic> _handleListResponse(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw _exceptionFor(response);
    }
    final decoded = jsonDecode(_body(response));
    if (decoded is List) return decoded;
    throw const ServerException(
      'Format de réponse inattendu: une liste était attendue',
    );
  }

  AppException _exceptionFor(http.Response response) {
    final payload = ApiErrorPayload.tryParse(_body(response));
    final code = response.statusCode;

    if (code == 401) {
      final message =
          payload?.frenchMessage(ApiErrorMessages.unauthorized) ??
          ApiErrorMessages.unauthorized;
      if (message == 'Authentification requise') {
        return const UnauthorizedException(ApiErrorMessages.unauthorized);
      }
      return UnauthorizedException(message);
    }
    if (code == 429) {
      return RateLimitException(
        payload?.frenchMessage(ApiErrorMessages.rateLimit) ??
            ApiErrorMessages.rateLimit,
      );
    }
    if (code == 403) {
      return ForbiddenException(
        payload?.frenchMessage(ApiErrorMessages.forbidden) ??
            ApiErrorMessages.forbidden,
      );
    }
    if (code == 404 ||
        (code == 400 && payload?.indicatesMissingAccount == true)) {
      return NotFoundException(
        payload?.frenchMessage(ApiErrorMessages.notFound) ??
            ApiErrorMessages.notFound,
      );
    }
    if (code == 409) {
      return ConflictException(
        payload?.frenchMessage(ApiErrorMessages.alreadyRegistered) ??
            ApiErrorMessages.alreadyRegistered,
      );
    }
    if (code == 400) {
      return ValidationException(
        payload?.frenchMessage(ApiErrorMessages.invalidRequest) ??
            ApiErrorMessages.invalidRequest,
      );
    }
    if (code >= 500) {
      return ServerException(
        payload?.frenchMessage('Erreur serveur: $code') ??
            'Erreur serveur: $code',
      );
    }
    return ServerException(
      payload?.frenchMessage('Erreur: $code') ?? 'Erreur: $code',
    );
  }

  void dispose() {
    client.close();
  }
}
