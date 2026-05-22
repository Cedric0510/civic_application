import 'package:civic_app/features/settings/domain/entities/city_settings.dart';

abstract class SettingsRepository {
  Future<CitySettings> getCitySettings();
}
