import 'package:civic_app/core/constants/app_constants.dart';
import 'package:civic_app/core/network/api_client.dart';
import 'package:civic_app/features/settings/data/models/city_settings_model.dart';

// Contenu public côté civic_api (comme articles/services) — l'app mobile
// est dédiée à une seule commune, identifiée par son slug (AppConstants).
class SettingsApiDatasource {
  const SettingsApiDatasource(this._api);

  final ApiClient _api;

  Future<CitySettingsModel> getCitySettings() async {
    final json =
        await _api.get('/communes/${AppConstants.communeSlug}')
            as Map<String, dynamic>;
    return CitySettingsModel.fromJson(json);
  }
}
