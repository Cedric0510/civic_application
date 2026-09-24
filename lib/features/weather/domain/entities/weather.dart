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
