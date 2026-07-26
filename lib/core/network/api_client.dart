import 'dart:convert';

import 'package:civic_app/core/auth/token_storage.dart';
import 'package:civic_app/core/errors/app_exception.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

// Client HTTP partagé pour tous les appels civic_api. Attache le JWT stocké
// s'il existe — inoffensif pour les routes publiques (Articles, Services),
// nécessaire pour les routes citoyennes protégées (Appointments, Polls,
// Account).
class ApiClient {
  const ApiClient(this._client, this._tokenStorage);

  final http.Client _client;
  final TokenStorage _tokenStorage;

  String get baseUrl =>
      dotenv.get('API_BASE_URL', fallback: 'http://10.0.2.2:4000');

  Future<dynamic> get(String path) async {
    return _send(
      () async => _client.get(_uri(path), headers: await _headers()),
    );
  }

  Future<dynamic> post(String path, [Map<String, dynamic>? body]) async {
    return _send(
      () async => _client.post(
        _uri(path),
        headers: await _headers(),
        body: body != null ? jsonEncode(body) : null,
      ),
    );
  }

  Future<dynamic> delete(String path) async {
    return _send(
      () async => _client.delete(_uri(path), headers: await _headers()),
    );
  }

  Uri _uri(String path) => Uri.parse('$baseUrl$path');

  Future<Map<String, String>> _headers() async {
    final token = await _tokenStorage.read();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<dynamic> _send(Future<http.Response> Function() request) async {
    http.Response response;
    try {
      response = await request();
    } catch (_) {
      throw const NetworkException();
    }

    if (response.statusCode == 401 || response.statusCode == 403) {
      throw AuthException(_extractMessage(response.body));
    }
    if (response.statusCode == 404) {
      throw NotFoundException(_extractMessage(response.body));
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw DatabaseException(_extractMessage(response.body));
    }
    if (response.body.isEmpty) return null;
    return jsonDecode(response.body);
  }

  String _extractMessage(String body) {
    try {
      final json = jsonDecode(body) as Map<String, dynamic>;
      final message = json['message'];
      if (message is List) return message.join(', ');
      if (message is String) return message;
    } catch (_) {
      // corps non-JSON ou inattendu : message générique du constructeur
      // par défaut de l'AppException concernée.
    }
    return 'Une erreur est survenue.';
  }
}
