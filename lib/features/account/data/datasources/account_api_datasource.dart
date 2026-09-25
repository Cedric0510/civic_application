import 'package:civic_app/core/errors/app_exception.dart';
import 'package:civic_app/core/network/api_client.dart';
import 'package:civic_app/features/account/data/models/user_profile_model.dart';

class AccountApiDatasource {
  const AccountApiDatasource(this._api);

  final ApiClient _api;

  Future<UserProfileModel?> getProfile() async {
    try {
      final json = await _api.get('/citizens/me') as Map<String, dynamic>;
      return UserProfileModel.fromJson(json);
    } on AuthException {
      return null;
    } on NotFoundException {
      // Le token stocké reste valide (signature/expiration) mais le compte
      // n'existe plus côté civic_api (suppression) — même absence de profil
      // du point de vue de l'utilisateur.
      return null;
    }
  }

  Future<void> requestDataExport() async {
    await _api.post('/citizens/me/export/email');
  }

  // Ne gère pas la déconnexion locale (token) : c'est la responsabilité du
  // contrôleur, via le SignOutUseCase de la feature auth — une seule source
  // de vérité pour "effacer la session".
  Future<void> deleteAccount() async {
    await _api.delete('/citizens/me');
  }
}
