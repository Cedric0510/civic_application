import 'package:civic_app/features/settings/presentation/controllers/settings_providers.dart';
import 'package:civic_app/features/weather/presentation/controllers/weather_providers.dart';
import 'package:civic_app/features/weather/presentation/widgets/current_weather_card.dart';
import 'package:civic_app/features/weather/presentation/widgets/forecast_timeline.dart';
import 'package:civic_app/shared/widgets/error_retry_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class WeatherDetailPage extends ConsumerWidget {
  const WeatherDetailPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(currentWeatherProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 80,
            pinned: true,
            backgroundColor: colorScheme.primary,
            foregroundColor: Colors.white,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.go('/home'),
            ),
            flexibleSpace: const FlexibleSpaceBar(
              title: Text(
                'Météo du jour',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
              titlePadding: EdgeInsets.only(left: 56, bottom: 12),
            ),
          ),
          state.when(
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, stackTrace) => SliverFillRemaining(
              child: ErrorRetryWidget(
                message: 'Impossible de charger la météo.',
                onRetry: () => ref.invalidate(citySettingsProvider),
              ),
            ),
            data: (weather) => weather == null
                ? const SliverFillRemaining(
                    child: Center(
                      child: Text(
                        "Météo pas encore disponible pour votre commune.",
                      ),
                    ),
                  )
                : SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: SliverList.list(
                      children: [
                        CurrentWeatherCard(weather: weather),
                        const SizedBox(height: 24),
                        Text(
                          "Aujourd'hui, heure par heure",
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        if (weather.forecast.isEmpty)
                          Text(
                            'Prévisionnel pas encore disponible.',
                            style: TextStyle(color: Colors.grey.shade500),
                          )
                        else
                          ForecastTimeline(entries: weather.forecast),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
