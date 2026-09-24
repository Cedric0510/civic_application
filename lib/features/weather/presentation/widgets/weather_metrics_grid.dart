import 'package:civic_app/features/weather/domain/entities/weather.dart';
import 'package:civic_app/features/weather/domain/weather_units.dart';
import 'package:civic_app/features/weather/presentation/utils/weather_formatters.dart';
import 'package:civic_app/features/weather/presentation/widgets/weather_glass_card.dart';
import 'package:flutter/material.dart';

class WeatherMetricsGrid extends StatelessWidget {
  const WeatherMetricsGrid({
    super.key,
    required this.weather,
    required this.now,
  });

  final Weather weather;
  final DateTime now;

  static const _spacing = 12.0;

  @override
  Widget build(BuildContext context) {
    final rainChance = weather.rainChanceAt(now);
    final metrics = [
      _Metric(
        Icons.thermostat,
        'Ressenti',
        formatTemperature(weather.feelsLike),
      ),
      _Metric(Icons.water_drop_outlined, 'Humidité', '${weather.humidity} %'),
      _Metric(
        Icons.air,
        'Vent',
        '${metersPerSecondToKmh(weather.windSpeed)} km/h',
      ),
      if (rainChance != null)
        _Metric(Icons.umbrella_outlined, 'Pluie', '$rainChance %'),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final tileWidth = (constraints.maxWidth - _spacing) / 2;
        return Wrap(
          spacing: _spacing,
          runSpacing: _spacing,
          children: [
            for (final metric in metrics)
              SizedBox(
                width: tileWidth,
                child: _MetricTile(metric: metric),
              ),
          ],
        );
      },
    );
  }
}

class _Metric {
  const _Metric(this.icon, this.label, this.value);

  final IconData icon;
  final String label;
  final String value;
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({required this.metric});

  final _Metric metric;

  @override
  Widget build(BuildContext context) {
    return WeatherGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          WeatherSectionTitle(icon: metric.icon, label: metric.label),
          const SizedBox(height: 10),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              metric.value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
