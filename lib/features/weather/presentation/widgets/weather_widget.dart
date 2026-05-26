import 'package:civic_app/features/weather/presentation/controllers/weather_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WeatherWidget extends ConsumerWidget {
  const WeatherWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(weatherProvider);
    return state.when(
      loading: () => const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (error, stackTrace) => const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.cloud_off_outlined, size: 40),
              SizedBox(width: 16),
              Text('Météo indisponible'),
            ],
          ),
        ),
      ),
      data: (weather) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              _WeatherIcon(iconCode: weather.iconCode),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${weather.temperature.round()}°C',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      weather.description,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.water_drop_outlined, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          '${weather.humidity}%',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(width: 12),
                        const Icon(Icons.air, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          '${weather.windSpeed.toStringAsFixed(1)} m/s',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
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
    return Icon(
      _iconFromCode(iconCode),
      size: 48,
      color: Theme.of(context).colorScheme.primary,
    );
  }
}
