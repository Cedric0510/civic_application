import 'package:civic_app/features/settings/presentation/controllers/settings_providers.dart';
import 'package:civic_app/features/weather/domain/entities/weather.dart';
import 'package:civic_app/features/weather/presentation/controllers/weather_providers.dart';
import 'package:civic_app/features/weather/presentation/utils/weather_formatters.dart';
import 'package:civic_app/features/weather/presentation/widgets/daily_forecast_list.dart';
import 'package:civic_app/features/weather/presentation/widgets/hourly_forecast_chart.dart';
import 'package:civic_app/features/weather/presentation/widgets/sun_card.dart';
import 'package:civic_app/features/weather/presentation/widgets/weather_glass_card.dart';
import 'package:civic_app/features/weather/presentation/widgets/weather_hero.dart';
import 'package:civic_app/features/weather/presentation/widgets/weather_metrics_grid.dart';
import 'package:civic_app/features/weather/presentation/widgets/weather_palette.dart';
import 'package:civic_app/shared/widgets/error_retry_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class WeatherDetailPage extends ConsumerWidget {
  const WeatherDetailPage({super.key});

  static const _contentMaxWidth = 600.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(currentWeatherProvider);
    final now = ref.watch(weatherClockProvider).valueOrNull ?? DateTime.now();

    return state.when(
      loading: () => const _PlainScaffold(
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stackTrace) => _PlainScaffold(
        child: ErrorRetryWidget(
          message: 'Impossible de charger la météo.',
          onRetry: () => ref.invalidate(citySettingsProvider),
        ),
      ),
      data: (weather) => weather == null
          ? const _PlainScaffold(
              child: Center(
                child: Text('Météo pas encore disponible pour votre commune.'),
              ),
            )
          : _WeatherView(weather: weather, now: now),
    );
  }
}

class _PlainScaffold extends StatelessWidget {
  const _PlainScaffold({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Météo'), leading: const _BackButton()),
      body: child,
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton();

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => context.go('/home'),
    );
  }
}

class _WeatherView extends StatelessWidget {
  const _WeatherView({required this.weather, required this.now});

  final Weather weather;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final slots = weather.upcomingSlots(now);
    final days = weather.dailyForecasts(now);
    final updatedAt = weather.updatedAt;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        scrolledUnderElevation: 0,
        title: const Text('Météo'),
        leading: const _BackButton(),
      ),
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: WeatherPalette.skyFor(weather.iconCode),
          ),
        ),
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: WeatherDetailPage._contentMaxWidth,
            ),
            child: ListView(
              padding: EdgeInsets.fromLTRB(
                16,
                media.padding.top + kToolbarHeight + 8,
                16,
                media.padding.bottom + 24,
              ),
              children: [
                WeatherHero(weather: weather, now: now),
                const SizedBox(height: 24),
                if (slots.isNotEmpty) ...[
                  WeatherGlassCard(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: WeatherSectionTitle(
                            icon: Icons.schedule,
                            label: 'Prochaines heures',
                          ),
                        ),
                        const SizedBox(height: 8),
                        HourlyForecastChart(
                          slots: slots,
                          current: weather.slotAt(now),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                WeatherMetricsGrid(weather: weather, now: now),
                const SizedBox(height: 12),
                SunCard(weather: weather, now: now),
                if (days.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  WeatherGlassCard(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const WeatherSectionTitle(
                          icon: Icons.calendar_month_outlined,
                          label: 'Prochains jours',
                        ),
                        const SizedBox(height: 4),
                        DailyForecastList(days: days, now: now),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                Text(
                  updatedAt == null
                      ? 'Données OpenWeatherMap'
                      : 'Prévisions actualisées à ${formatClock(updatedAt)}'
                            '  ·  Données OpenWeatherMap',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white60, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
