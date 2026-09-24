import 'package:civic_app/features/weather/domain/entities/weather_forecast_entry.dart';
import 'package:civic_app/features/weather/presentation/widgets/weather_icon.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ForecastTimeline extends StatelessWidget {
  const ForecastTimeline({super.key, required this.entries});

  final List<WeatherForecastEntry> entries;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: 130,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: entries.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final entry = entries[index];
          return Container(
            width: 76,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('HH:mm').format(entry.time),
                  style: Theme.of(context).textTheme.labelMedium,
                ),
                WeatherIcon(
                  iconCode: entry.iconCode,
                  size: 28,
                  color: colorScheme.primary,
                ),
                Text(
                  '${entry.temperature.round()}°',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
