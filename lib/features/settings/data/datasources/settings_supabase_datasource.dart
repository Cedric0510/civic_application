import 'package:civic_app/core/constants/supabase_constants.dart';
import 'package:civic_app/core/errors/app_exception.dart';
import 'package:civic_app/features/settings/data/models/city_settings_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SettingsSupabaseDatasource {
  const SettingsSupabaseDatasource(this._client);

  final SupabaseClient _client;

  Future<CitySettingsModel> getCitySettings() async {
    try {
      final response = await _client
          .from(SupabaseConstants.settingsTable)
          .select()
          .single();
      return CitySettingsModel.fromJson(response);
    } catch (_) {
      throw const DatabaseException();
    }
  }
}
