import 'dart:async';

import 'package:civic_app/features/weather/domain/entities/weather.dart';
import 'package:civic_app/features/weather/domain/entities/weather_forecast_entry.dart';
import 'package:civic_app/features/weather/presentation/controllers/weather_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

WeatherForecastEntry _entry(int hour, double temperature, String icon) =>
    WeatherForecastEntry(
      time: DateTime.utc(2026, 10, 14, hour),
      temperature: temperature,
      description: 'prévu à $hour h',
      iconCode: icon,
    );

Weather _weather() => Weather(
  cityName: 'Bessan',
  temperature: 14,
  description: 'relevé du matin',
  iconCode: '03d',
  humidity: 90,
  windSpeed: 1.5,
  forecast: [
    _entry(9, 19, '04d'),
    _entry(12, 22, '01d'),
    _entry(15, 24, '02d'),
    _entry(18, 20, '04n'),
  ],
);

void main() {
  group('Weather.atTime', () {
    test(
      'shows the forecast slot nearest to now, keeping humidity, wind and the timeline',
      () {
        final shown = _weather().atTime(DateTime.utc(2026, 10, 14, 13, 10));

        expect(shown.temperature, 22);
        expect(shown.iconCode, '01d');
        expect(shown.description, 'prévu à 12 h');
        expect(shown.humidity, 90);
        expect(shown.windSpeed, 1.5);
        expect(shown.forecast, _weather().forecast);
      },
    );

    test('moves to the next slot as the day goes on', () {
      final morning = _weather().atTime(DateTime.utc(2026, 10, 14, 9, 20));
      final afternoon = _weather().atTime(DateTime.utc(2026, 10, 14, 14, 40));

      expect(morning.temperature, 19);
      expect(afternoon.temperature, 24);
    });

    test(
      'keeps the observed values when no slot is close enough (before the first, after the last)',
      () {
        final observed = _weather();

        expect(observed.atTime(DateTime.utc(2026, 10, 14, 5)), observed);
        expect(observed.atTime(DateTime.utc(2026, 10, 14, 22)), observed);
      },
    );

    test('keeps the observed values when there is no forecast at all', () {
      const observed = Weather(
        cityName: 'Bessan',
        temperature: 14,
        description: 'relevé',
        iconCode: '03d',
        humidity: 90,
        windSpeed: 1.5,
      );

      expect(observed.atTime(DateTime.utc(2026, 10, 14, 12)), observed);
    });
  });

  group('currentWeatherProvider', () {
    ProviderContainer containerAt(DateTime now, Weather? weather) {
      final container = ProviderContainer(
        overrides: [
          weatherProvider.overrideWith((ref) async => weather),
          weatherClockProvider.overrideWith((ref) => Stream.value(now)),
        ],
      );
      addTearDown(container.dispose);
      return container;
    }

    test('derives the displayed weather from the clock', () async {
      final container = containerAt(
        DateTime.utc(2026, 10, 14, 15, 5),
        _weather(),
      );
      container.listen(currentWeatherProvider, (_, _) {});
      await container.read(weatherProvider.future);
      await container.read(weatherClockProvider.future);

      expect(container.read(currentWeatherProvider).value?.temperature, 24);
    });

    test(
      'keeps showing the previous weather while it is being refreshed, instead of a loading state',
      () async {
        var loads = 0;
        final secondLoad = Completer<Weather?>();
        final container = ProviderContainer(
          overrides: [
            weatherProvider.overrideWith(
              (ref) =>
                  ++loads == 1 ? Future.value(_weather()) : secondLoad.future,
            ),
            weatherClockProvider.overrideWith(
              (ref) => Stream.value(DateTime.utc(2026, 10, 14, 15)),
            ),
          ],
        );
        addTearDown(container.dispose);
        container.listen(currentWeatherProvider, (_, _) {});
        await container.read(weatherProvider.future);
        await container.read(weatherClockProvider.future);

        container.invalidate(weatherProvider);
        await Future<void>.delayed(Duration.zero);

        final during = container.read(currentWeatherProvider);
        expect(during.hasValue, isTrue);
        expect(during.value?.temperature, 24);
      },
    );

    test('stays null while the server has no weather yet', () async {
      final container = containerAt(DateTime.utc(2026, 10, 14, 15), null);
      container.listen(currentWeatherProvider, (_, _) {});
      await container.read(weatherProvider.future);
      await container.read(weatherClockProvider.future);

      expect(container.read(currentWeatherProvider).value, isNull);
    });
  });
}
