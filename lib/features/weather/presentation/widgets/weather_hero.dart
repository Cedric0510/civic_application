import 'package:civic_app/features/weather/domain/entities/weather.dart';
import 'package:civic_app/features/weather/presentation/utils/weather_formatters.dart';
import 'package:civic_app/features/weather/presentation/widgets/weather_icon.dart';
import 'package:flutter/material.dart';

class WeatherHero extends StatelessWidget {
  const WeatherHero({super.key, required this.weather, required this.now});

  final Weather weather;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final range = weather.nextDayRange(now);

    return Column(
      children: [
        Text(
          weather.cityName,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        WeatherIcon(iconCode: weather.iconCode, size: 84),
        Text(
          formatTemperature(weather.temperature),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 88,
            fontWeight: FontWeight.w300,
            height: 1.1,
          ),
        ),
        Text(
          capitalize(weather.description),
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white, fontSize: 20),
        ),
        const SizedBox(height: 8),
        Text(
          'Sur 24 h : max. ${formatTemperature(range.max)}  ·  '
          'min. ${formatTemperature(range.min)}',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white70, fontSize: 15),
        ),
      ],
    );
  }
}
