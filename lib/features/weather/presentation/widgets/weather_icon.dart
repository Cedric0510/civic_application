import 'package:civic_app/features/weather/domain/entities/weather_condition.dart';
import 'package:flutter/material.dart';

class WeatherIcon extends StatelessWidget {
  const WeatherIcon({
    super.key,
    required this.iconCode,
    this.size = 64,
    this.color = Colors.white,
  });

  final String iconCode;
  final double size;
  final Color color;

  static IconData iconFor(String code) {
    final night = isNightIconCode(code);
    return switch (WeatherCondition.fromIconCode(code)) {
      WeatherCondition.clear => night ? Icons.nightlight_round : Icons.wb_sunny,
      WeatherCondition.partlyCloudy =>
        night ? Icons.nights_stay : Icons.cloud_queue,
      WeatherCondition.cloudy => Icons.cloud,
      WeatherCondition.rain => Icons.umbrella,
      WeatherCondition.storm => Icons.thunderstorm,
      WeatherCondition.snow => Icons.ac_unit,
      WeatherCondition.mist => Icons.foggy,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Icon(iconFor(iconCode), size: size, color: color);
  }
}
