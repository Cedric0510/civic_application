import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Le JWT civic_api doit survivre au redémarrage de l'app.
class TokenStorage {
  const TokenStorage([FlutterSecureStorage? storage])
    : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  static const _tokenKey = 'civic_access_token';
  static const _communeKey = 'civic_session_commune';

  Future<String?> read() => _storage.read(key: _tokenKey);

  Future<void> save(String token) =>
      _storage.write(key: _tokenKey, value: token);

  Future<void> clear() => Future.wait([
    _storage.delete(key: _tokenKey),
    _storage.delete(key: _communeKey),
  ]);

  // Dernière commune du citoyen résolue avec succès -- repli si une coupure
  // réseau empêche de la re-résoudre (cf. AuthApiDatasource.fetchSession),
  // pour ne pas déconnecter visuellement quelqu'un dont le token reste valide.
  Future<void> saveCommune(Map<String, String> commune) =>
      _storage.write(key: _communeKey, value: jsonEncode(commune));

  Future<Map<String, dynamic>?> readCommune() async {
    final raw = await _storage.read(key: _communeKey);
    if (raw == null) return null;
    return jsonDecode(raw) as Map<String, dynamic>;
  }
}
