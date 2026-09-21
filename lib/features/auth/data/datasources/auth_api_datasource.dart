import 'package:civic_app/core/auth/token_storage.dart';
import 'package:civic_app/core/constants/app_constants.dart';
import 'package:civic_app/core/errors/app_exception.dart';
import 'package:civic_app/core/network/api_client.dart';

class AuthApiDatasource {
  const AuthApiDatasource(this._api, this._tokenStorage);

  final ApiClient _api;
  final TokenStorage _tokenStorage;

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
      await _api.get('/citizens/me');
      return true;
    } on NetworkException {
      return true;
    } catch (_) {
      await _tokenStorage.clear();
      return false;
    }
  }

  Future<String> _authenticate(String path, Map<String, dynamic> body) async {
    final json = await _api.post(path, body) as Map<String, dynamic>;
    return json['accessToken'] as String;
  }
}
