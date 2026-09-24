import 'package:equatable/equatable.dart';

class WeatherForecastEntry extends Equatable {
  const WeatherForecastEntry({
    required this.time,
    required this.temperature,
    required this.feelsLike,
    required this.description,
    required this.iconCode,
    required this.humidity,
    required this.windSpeed,
    required this.precipitationProbability,
  });

  final DateTime time;
  final double temperature;
  final double feelsLike;
  final String description;
  final String iconCode;
  final int humidity;
  final double windSpeed;
  final int precipitationProbability;

  @override
  List<Object?> get props => [
    time,
    temperature,
    feelsLike,
    description,
    iconCode,
    humidity,
    windSpeed,
    precipitationProbability,
  ];
}
