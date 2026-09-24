import 'dart:async';

import 'package:civic_app/features/weather/domain/entities/weather.dart';
import 'package:civic_app/features/weather/presentation/controllers/weather_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'weather_fixtures.dart';

Weather _weather() => weatherWith(
  forecast: [
    slot(
      DateTime(2026, 10, 14, 9),
      temperature: 19,
      feelsLike: 18,
      description: 'prévu à 9 h',
      iconCode: '04d',
      humidity: 70,
      windSpeed: 2.5,
    ),
    slot(
      DateTime(2026, 10, 14, 12),
      temperature: 22,
      feelsLike: 21,
      description: 'prévu à 12 h',
      iconCode: '01d',
      humidity: 55,
      windSpeed: 3,
    ),
    slot(
      DateTime(2026, 10, 14, 15),
      temperature: 24,
      feelsLike: 24.5,
      description: 'prévu à 15 h',
      iconCode: '02d',
      humidity: 45,
      windSpeed: 4,
    ),
    slot(DateTime(2026, 10, 14, 18), temperature: 20, iconCode: '04n'),
  ],
);

void main() {
  group('Weather.atTime', () {
    test(
      'shows every value of the forecast slot nearest to now, keeping the timeline and the sun times',
      () {
        final sunrise = DateTime(2026, 10, 14, 7, 40);
        final observed = weatherWith(
          sunrise: sunrise,
          forecast: _weather().forecast,
        );

        final shown = observed.atTime(DateTime(2026, 10, 14, 13, 10));

        expect(shown.temperature, 22);
        expect(shown.feelsLike, 21);
        expect(shown.iconCode, '01d');
        expect(shown.description, 'prévu à 12 h');
        expect(shown.humidity, 55);
        expect(shown.windSpeed, 3);
        expect(shown.sunrise, sunrise);
        expect(shown.forecast, observed.forecast);
      },
    );

    test('moves to the next slot as the day goes on', () {
      final morning = _weather().atTime(DateTime(2026, 10, 14, 9, 20));
      final afternoon = _weather().atTime(DateTime(2026, 10, 14, 14, 40));

      expect(morning.temperature, 19);
      expect(afternoon.temperature, 24);
    });

    test(
      'keeps the observed values when no slot is close enough (before the first, after the last)',
      () {
        final observed = _weather();

        expect(observed.atTime(DateTime(2026, 10, 14, 5)), observed);
        expect(observed.atTime(DateTime(2026, 10, 14, 22)), observed);
      },
    );

    test('keeps the observed values when there is no forecast at all', () {
      final observed = weatherWith();

      expect(observed.atTime(DateTime(2026, 10, 14, 12)), observed);
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
      final container = containerAt(DateTime(2026, 10, 14, 15, 5), _weather());
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
              (ref) => Stream.value(DateTime(2026, 10, 14, 15)),
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
      final container = containerAt(DateTime(2026, 10, 14, 15), null);
      container.listen(currentWeatherProvider, (_, _) {});
      await container.read(weatherProvider.future);
      await container.read(weatherClockProvider.future);

      expect(container.read(currentWeatherProvider).value, isNull);
    });
  });
}
