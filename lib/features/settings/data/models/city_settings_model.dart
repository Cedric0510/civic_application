import 'package:civic_app/features/settings/domain/entities/city_settings.dart';
import 'package:civic_app/features/weather/domain/entities/weather.dart';
import 'package:civic_app/features/weather/domain/entities/weather_forecast_entry.dart';

class CitySettingsModel extends CitySettings {
  const CitySettingsModel({required super.villageName, super.weather});

  // Reflète GET /communes/:slug (civic_api) — 'name', pas 'village_name'.
  // La météo (et son prévisionnel, forecastEntries) est mise en cache côté
  // serveur : weatherTemperature absent = pas encore rafraîchie.
  factory CitySettingsModel.fromJson(Map<String, dynamic> json) {
    final villageName = json['name'] as String;
    final temperature = json['weatherTemperature'] as num?;
    final weather = temperature == null
        ? null
        : Weather(
            cityName: villageName,
            temperature: temperature.toDouble(),
            feelsLike:
                (json['weatherFeelsLike'] as num?)?.toDouble() ??
                temperature.toDouble(),
            description: json['weatherDescription'] as String? ?? '',
            iconCode: json['weatherIconCode'] as String? ?? '',
            humidity: json['weatherHumidity'] as int? ?? 0,
            windSpeed: (json['weatherWindSpeed'] as num?)?.toDouble() ?? 0,
            sunrise: _parseLocalDate(json['weatherSunrise']),
            sunset: _parseLocalDate(json['weatherSunset']),
            updatedAt: _parseLocalDate(json['weatherUpdatedAt']),
            forecast: _parseForecast(json['forecastEntries']),
          );
    return CitySettingsModel(villageName: villageName, weather: weather);
  }

  static DateTime? _parseLocalDate(dynamic raw) =>
      raw is String ? DateTime.parse(raw).toLocal() : null;

  static List<WeatherForecastEntry> _parseForecast(dynamic raw) {
    if (raw is! List) return const [];
    return raw
        .cast<Map<String, dynamic>>()
        .map(
          (entry) => WeatherForecastEntry(
            time: DateTime.parse(entry['forecastAt'] as String).toLocal(),
            temperature: (entry['temperature'] as num).toDouble(),
            feelsLike: (entry['feelsLike'] as num).toDouble(),
            description: entry['description'] as String,
            iconCode: entry['iconCode'] as String,
            humidity: entry['humidity'] as int,
            windSpeed: (entry['windSpeed'] as num).toDouble(),
            precipitationProbability: entry['precipitationProbability'] as int,
          ),
        )
        .toList();
  }

  Map<String, dynamic> toJson() {
    return {'name': villageName};
  }
}
