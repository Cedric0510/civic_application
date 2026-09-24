import 'package:equatable/equatable.dart';

class WeatherForecastEntry extends Equatable {
  const WeatherForecastEntry({
    required this.time,
    required this.temperature,
    required this.description,
    required this.iconCode,
  });

  final DateTime time;
  final double temperature;
  final String description;
  final String iconCode;

  @override
  List<Object?> get props => [time, temperature, description, iconCode];
}
