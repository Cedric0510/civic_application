import 'package:civic_app/core/auth/token_storage.dart';
import 'package:civic_app/core/errors/app_exception.dart';
import 'package:civic_app/core/network/api_client.dart';
import 'package:civic_app/features/auth/domain/entities/citizen_session.dart';
import 'package:civic_app/features/auth/domain/entities/commune_ref.dart';
import 'package:civic_app/features/auth/domain/entities/sign_up_outcome.dart';

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

  Future<SignUpOutcome> signUp({
    required String email,
    required String password,
    required String communeSlug,
    required bool acceptedTerms,
    String? invitationCode,
  }) async {
    final code = invitationCode?.trim();
    final json =
        await _api.post('/citizens/signup', {
              'email': email,
              'password': password,
              'communeSlug': communeSlug,
              'acceptTerms': acceptedTerms,
              if (code != null && code.isNotEmpty) 'invitationCode': code,
            })
            as Map<String, dynamic>;
    if (json['status'] == 'verification_required') {
      return _pendingVerification(json);
    }
    await _tokenStorage.save(json['accessToken'] as String);
    return const SignUpCompleted();
  }

  Future<void> verifySignUp({
    required String email,
    required String code,
  }) async {
    final token = await _authenticate('/citizens/signup/verify', {
      'email': email,
      'code': code,
    });
    await _tokenStorage.save(token);
  }

  Future<SignUpNeedsVerification> resendSignUpCode({
    required String email,
  }) async {
    final json =
        await _api.post('/citizens/signup/resend', {'email': email})
            as Map<String, dynamic>;
    return _pendingVerification(json);
  }

  SignUpNeedsVerification _pendingVerification(Map<String, dynamic> json) {
    return SignUpNeedsVerification(
      email: json['email'] as String,
      expiresAt: DateTime.parse(json['expiresAt'] as String),
      resendAvailableAt: DateTime.parse(json['resendAvailableAt'] as String),
    );
  }

  Future<void> requestPasswordReset({required String email}) async {
    await _api.post('/citizens/forgot-password', {'email': email});
  }

  Future<void> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    await _api.post('/citizens/reset-password', {
      'email': email,
      'code': code,
      'newPassword': newPassword,
    });
  }

  Future<void> signOut() => _tokenStorage.clear();

  // Session du citoyen (commune + rôle + commerce géré le cas échéant) si un
  // token stocké existe et est encore accepté par civic_api, sinon null. En
  // cas d'erreur réseau (pas de connexion), on ne déconnecte pas l'utilisateur
  // pour un problème de connectivité ponctuel : on retombe sur la dernière
  // commune connue (mise en cache à chaque succès), en USER par défaut --
  // un commerçant perd temporairement l'accès à "Gérer mon commerce" le
  // temps de retrouver la connexion, mais reste connecté.
  Future<CitizenSession?> fetchSession() async {
    final token = await _tokenStorage.read();
    if (token == null) return null;
    try {
      final json = await _api.get('/citizens/me') as Map<String, dynamic>;
      return await _sessionFromJson(json);
    } on NetworkException {
      final cached = await _tokenStorage.readCommune();
      if (cached != null) {
        return CitizenSession(
          commune: CommuneRef.fromJson(cached),
          role: CitizenRole.user,
        );
      }
      rethrow;
    } catch (_) {
      await _tokenStorage.clear();
      return null;
    }
  }

  Future<CitizenSession> fetchLiveSession() async {
    final json = await _api.get('/citizens/me') as Map<String, dynamic>;
    return _sessionFromJson(json);
  }

  Future<CitizenSession> changeCommune(String communeSlug) async {
    final json =
        await _api.patch('/citizens/me/commune', {'communeSlug': communeSlug})
            as Map<String, dynamic>;
    return _sessionFromJson(json);
  }

  Future<CitizenSession> _sessionFromJson(Map<String, dynamic> json) async {
    final commune = CommuneRef.fromJson(
      json['commune'] as Map<String, dynamic>,
    );
    await _tokenStorage.saveCommune({
      'id': commune.id,
      'name': commune.name,
      'slug': commune.slug,
    });
    final managedCommerceJson =
        json['managedCommerce'] as Map<String, dynamic>?;
    final voteEligibleAt = json['voteEligibleAt'] as String?;
    return CitizenSession(
      commune: commune,
      role: CitizenRole.fromApiValue(json['role'] as String),
      managedCommerce: managedCommerceJson != null
          ? ManagedCommerceRef.fromJson(managedCommerceJson)
          : null,
      voteEligibleAt: voteEligibleAt != null
          ? DateTime.parse(voteEligibleAt)
          : null,
    );
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
