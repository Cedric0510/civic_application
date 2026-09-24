import 'package:civic_app/features/settings/domain/entities/city_settings.dart';
import 'package:civic_app/features/weather/domain/entities/weather.dart';
import 'package:civic_app/features/weather/domain/entities/weather_forecast_entry.dart';

class CitySettingsModel extends CitySettings {
  const CitySettingsModel({required super.villageName, super.weather});

  // Reflète GET /communes/:slug (civic_api) — 'name', pas 'village_name'.
  // La météo (et son prévisionnel du jour, forecastEntries) est mise en
  // cache côté serveur : weatherTemperature absent = pas encore rafraîchie.
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
            forecast: _parseForecast(json['forecastEntries']),
          );
    return CitySettingsModel(villageName: villageName, weather: weather);
  }

  static List<WeatherForecastEntry> _parseForecast(dynamic raw) {
    if (raw is! List) return const [];
    return raw
        .cast<Map<String, dynamic>>()
        .map(
          (entry) => WeatherForecastEntry(
            time: DateTime.parse(entry['forecastAt'] as String),
            temperature: (entry['temperature'] as num).toDouble(),
            description: entry['description'] as String,
            iconCode: entry['iconCode'] as String,
          ),
        )
        .toList();
  }

  Map<String, dynamic> toJson() {
    return {'name': villageName};
  }
}
