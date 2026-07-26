import 'dart:convert';

import 'package:civic_app/core/constants/app_constants.dart';
import 'package:civic_app/core/errors/app_exception.dart';
import 'package:civic_app/features/settings/data/models/city_settings_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

// Contenu public côté civic_api (comme articles/services) — l'app mobile
// est dédiée à une seule commune, identifiée par son slug (AppConstants).
class SettingsApiDatasource {
  const SettingsApiDatasource(this._client);

  final http.Client _client;

  String get _baseUrl =>
      dotenv.get('API_BASE_URL', fallback: 'http://10.0.2.2:4000');

  Future<CitySettingsModel> getCitySettings() async {
    try {
      final uri = Uri.parse('$_baseUrl/communes/${AppConstants.communeSlug}');
      final response = await _client.get(uri);
      if (response.statusCode != 200) {
        throw const DatabaseException();
      }
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return CitySettingsModel.fromJson(json);
    } on AppException {
      rethrow;
    } catch (_) {
      throw const NetworkException();
    }
  }
}
