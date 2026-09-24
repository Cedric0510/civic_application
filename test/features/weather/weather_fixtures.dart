import 'package:civic_app/features/weather/domain/entities/weather.dart';
import 'package:civic_app/features/weather/domain/entities/weather_forecast_entry.dart';

WeatherForecastEntry slot(
  DateTime time, {
  double temperature = 20,
  double? feelsLike,
  String description = 'ciel dégagé',
  String iconCode = '01d',
  int humidity = 50,
  double windSpeed = 2,
  int rain = 0,
}) => WeatherForecastEntry(
  time: time,
  temperature: temperature,
  feelsLike: feelsLike ?? temperature - 1,
  description: description,
  iconCode: iconCode,
  humidity: humidity,
  windSpeed: windSpeed,
  precipitationProbability: rain,
);

Weather weatherWith({
  double temperature = 14,
  double feelsLike = 13,
  String description = 'relevé du matin',
  String iconCode = '03d',
  int humidity = 90,
  double windSpeed = 1.5,
  DateTime? sunrise,
  DateTime? sunset,
  DateTime? updatedAt,
  List<WeatherForecastEntry> forecast = const [],
}) => Weather(
  cityName: 'Bessan',
  temperature: temperature,
  feelsLike: feelsLike,
  description: description,
  iconCode: iconCode,
  humidity: humidity,
  windSpeed: windSpeed,
  sunrise: sunrise,
  sunset: sunset,
  updatedAt: updatedAt,
  forecast: forecast,
);
