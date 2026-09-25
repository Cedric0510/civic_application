import 'package:civic_app/features/weather/presentation/controllers/weather_providers.dart';
import 'package:civic_app/features/weather/presentation/widgets/current_weather_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class WeatherWidget extends ConsumerWidget {
  const WeatherWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(currentWeatherProvider);

    return state.when(
      loading: () => const _WeatherTileSkeleton(),
      error: (error, stackTrace) => const SizedBox.shrink(),
      data: (weather) => weather == null
          ? const SizedBox.shrink()
          : InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => context.go('/weather'),
              child: CurrentWeatherCard(weather: weather),
            ),
    );
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
      child: const Center(
        child: CircularProgressIndicator(semanticsLabel: 'Chargement en cours'),
      ),
    );
  }
}
