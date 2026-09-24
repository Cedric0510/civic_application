import 'package:civic_app/features/weather/domain/entities/weather_forecast_entry.dart';
import 'package:equatable/equatable.dart';

class Weather extends Equatable {
  const Weather({
    required this.cityName,
    required this.temperature,
    required this.description,
    required this.iconCode,
    required this.humidity,
    required this.windSpeed,
    this.forecast = const [],
  });

  final String cityName;
  final double temperature;
  final String description;
  final String iconCode;
  final int humidity;
  final double windSpeed;
  final List<WeatherForecastEntry> forecast;

  static const maxForecastGap = Duration(minutes: 90);

  Weather atTime(DateTime now) {
    WeatherForecastEntry? nearest;
    for (final entry in forecast) {
      if (nearest == null || _gap(entry, now) < _gap(nearest, now)) {
        nearest = entry;
      }
    }
    if (nearest == null || _gap(nearest, now) > maxForecastGap) return this;

    return Weather(
      cityName: cityName,
      temperature: nearest.temperature,
      description: nearest.description,
      iconCode: nearest.iconCode,
      humidity: humidity,
      windSpeed: windSpeed,
      forecast: forecast,
    );
  }

  static Duration _gap(WeatherForecastEntry entry, DateTime now) =>
      entry.time.difference(now).abs();

  @override
  List<Object?> get props => [
    cityName,
    temperature,
    description,
    iconCode,
    humidity,
    windSpeed,
    forecast,
  ];
}
