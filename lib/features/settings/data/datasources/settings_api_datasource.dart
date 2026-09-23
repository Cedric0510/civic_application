import 'package:civic_app/core/network/api_client.dart';
import 'package:civic_app/features/settings/data/models/city_settings_model.dart';

// Contenu public côté civic_api (comme articles/services) -- la commune est
// celle du citoyen connecté, résolue dynamiquement.
class SettingsApiDatasource {
  const SettingsApiDatasource(this._api, this._communeSlug);

  final ApiClient _api;
  final String _communeSlug;

  Future<CitySettingsModel> getCitySettings() async {
    final json =
        await _api.get('/communes/$_communeSlug') as Map<String, dynamic>;
    return CitySettingsModel.fromJson(json);
  }
}
