import 'package:civic_app/core/auth/token_storage.dart';
import 'package:civic_app/core/errors/app_exception.dart';
import 'package:civic_app/core/network/api_client.dart';
import 'package:civic_app/features/auth/domain/entities/commune_ref.dart';

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

  Future<void> signUp({
    required String email,
    required String password,
    required String communeSlug,
  }) async {
    final token = await _authenticate('/citizens/signup', {
      'email': email,
      'password': password,
      'communeSlug': communeSlug,
    });
    await _tokenStorage.save(token);
  }

  Future<void> signOut() => _tokenStorage.clear();

  // Commune du citoyen si un token stocké existe et est encore accepté par
  // civic_api, sinon null. En cas d'erreur réseau (pas de connexion), on ne
  // déconnecte pas l'utilisateur pour un problème de connectivité ponctuel :
  // on retombe sur la dernière commune connue (mise en cache à chaque succès)
  // plutôt que de renvoyer null, qui le déconnecterait visuellement à tort.
  Future<CommuneRef?> fetchSessionCommune() async {
    final token = await _tokenStorage.read();
    if (token == null) return null;
    try {
      final json = await _api.get('/citizens/me') as Map<String, dynamic>;
      final commune = CommuneRef.fromJson(
        json['commune'] as Map<String, dynamic>,
      );
      await _tokenStorage.saveCommune({
        'id': commune.id,
        'name': commune.name,
        'slug': commune.slug,
      });
      return commune;
    } on NetworkException {
      final cached = await _tokenStorage.readCommune();
      if (cached != null) return CommuneRef.fromJson(cached);
      rethrow;
    } catch (_) {
      await _tokenStorage.clear();
      return null;
    }
  }

  // Liste des communes partenaires -- alimente le sélecteur affiché à
  // l'inscription (endpoint public, pas besoin d'être connecté).
  Future<List<CommuneRef>> fetchPublicCommunes() async {
    final json = await _api.get('/communes/public') as List<dynamic>;
    return json
        .map((item) => CommuneRef.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<String> _authenticate(String path, Map<String, dynamic> body) async {
    final json = await _api.post(path, body) as Map<String, dynamic>;
    return json['accessToken'] as String;
  }
}
