import 'package:civic_app/features/settings/domain/entities/city_settings.dart';
import 'package:civic_app/features/weather/domain/entities/weather.dart';

class CitySettingsModel extends CitySettings {
  const CitySettingsModel({required super.villageName, super.weather});

  // Reflète GET /communes/:slug (civic_api) — 'name', pas 'village_name'.
  // La météo est mise en cache côté serveur (un appel externe par commune
  // par jour) : weatherTemperature absent = pas encore rafraîchie.
  factory CitySettingsModel.fromJson(Map<String, dynamic> json) {
    final villageName = json['name'] as String;
    final temperature = json['weatherTemperature'] as num?;
    final weather = temperature == null
        ? null
        : Weather(
            cityName: villageName,
            temperature: temperature.toDouble(),
            description: json['weatherDescription'] as String? ?? '',
            iconCode: json['weatherIconCode'] as String? ?? '',
            humidity: json['weatherHumidity'] as int? ?? 0,
            windSpeed: (json['weatherWindSpeed'] as num?)?.toDouble() ?? 0,
          );
    return CitySettingsModel(villageName: villageName, weather: weather);
  }

  Map<String, dynamic> toJson() {
    return {'name': villageName};
  }
}
