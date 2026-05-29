import 'package:civic_app/features/weather/presentation/controllers/weather_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WeatherWidget extends ConsumerWidget {
  const WeatherWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(weatherProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return state.when(
      loading: () => const _WeatherTileSkeleton(),
      error: (error, stackTrace) => const SizedBox.shrink(),
      data: (weather) => Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [colorScheme.primary, colorScheme.tertiary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    weather.cityName,
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${weather.temperature.round()}°',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    weather.description,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.water_drop_outlined,
                        color: Colors.white70,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${weather.humidity}%',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Icon(Icons.air, color: Colors.white70, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        '${weather.windSpeed.toStringAsFixed(1)} m/s',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            _WeatherIcon(iconCode: weather.iconCode),
          ],
        ),
      ),
    );
  }
}

class _WeatherIcon extends StatelessWidget {
  const _WeatherIcon({required this.iconCode});

  final String iconCode;

  IconData _iconFromCode(String code) {
    final prefix = code.length >= 2 ? code.substring(0, 2) : '';
    return switch (prefix) {
      '01' => Icons.wb_sunny,
      '02' || '03' || '04' => Icons.cloud,
      '09' || '10' => Icons.umbrella,
      '11' => Icons.bolt,
      '13' => Icons.ac_unit,
      _ => Icons.blur_on,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Icon(_iconFromCode(iconCode), size: 64, color: Colors.white);
  }
}

class _WeatherTileSkeleton extends StatelessWidget {
  const _WeatherTileSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 110,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(child: CircularProgressIndicator()),
    );
  }
}
