import 'dart:convert';

import 'package:civic_app/core/auth/token_storage.dart';
import 'package:civic_app/core/constants/app_constants.dart';
import 'package:civic_app/core/errors/app_exception.dart' as app_errors;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class AuthApiDatasource {
  const AuthApiDatasource(this._client, this._tokenStorage);

  final http.Client _client;
  final TokenStorage _tokenStorage;

  String get _baseUrl =>
      dotenv.get('API_BASE_URL', fallback: 'http://10.0.2.2:4000');

  Future<void> signIn({required String email, required String password}) async {
    final token = await _authenticate('/citizens/login', {
      'email': email,
      'password': password,
    });
    await _tokenStorage.save(token);
  }

  Future<void> signUp({required String email, required String password}) async {
    final token = await _authenticate('/citizens/signup', {
      'email': email,
      'password': password,
      'communeSlug': AppConstants.communeSlug,
    });
    await _tokenStorage.save(token);
  }

  Future<void> signOut() => _tokenStorage.clear();

  // Vrai si un token stocké existe et est encore accepté par civic_api. En
  // cas d'erreur réseau (pas de connexion), on ne déconnecte pas l'utilisateur
  // pour un problème de connectivité ponctuel : le token stocké reste
  // considéré valide jusqu'à preuve du contraire par le serveur.
  Future<bool> hasValidSession() async {
    final token = await _tokenStorage.read();
    if (token == null) return false;
    try {
      final response = await _client.get(
        Uri.parse('$_baseUrl/citizens/me'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) return true;
      await _tokenStorage.clear();
      return false;
    } catch (_) {
      return true;
    }
  }

  Future<String> _authenticate(String path, Map<String, dynamic> body) async {
    try {
      final response = await _client.post(
        Uri.parse('$_baseUrl$path'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
      if (response.statusCode == 401) {
        throw const app_errors.AuthException('Identifiants invalides.');
      }
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw app_errors.AuthException(_extractMessage(response.body));
      }
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return json['accessToken'] as String;
    } on app_errors.AuthException {
      rethrow;
    } catch (_) {
      throw const app_errors.NetworkException(
        'Impossible de contacter le serveur.',
      );
    }
  }

  String _extractMessage(String body) {
    try {
      final json = jsonDecode(body) as Map<String, dynamic>;
      final message = json['message'];
      if (message is List) return message.join(', ');
      if (message is String) return message;
    } catch (_) {
      // corps non-JSON ou inattendu : message générique ci-dessous
    }
    return 'Une erreur est survenue.';
  }
}
