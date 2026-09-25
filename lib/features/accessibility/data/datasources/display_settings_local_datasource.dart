import 'package:shared_preferences/shared_preferences.dart';

class DisplaySettingsLocalDatasource {
  const DisplaySettingsLocalDatasource(this._preferences);

  static const String comfortModeKey = 'display.comfort_mode';

  final SharedPreferences _preferences;

  bool readComfortMode() => _preferences.getBool(comfortModeKey) ?? false;

  Future<void> writeComfortMode(bool enabled) async {
    await _preferences.setBool(comfortModeKey, enabled);
  }
}
