import 'package:civic_app/core/theme/app_theme.dart';
import 'package:civic_app/features/weather/domain/entities/weather.dart';
import 'package:civic_app/features/weather/presentation/controllers/weather_providers.dart';
import 'package:civic_app/features/weather/presentation/pages/weather_detail_page.dart';
import 'package:civic_app/features/weather/presentation/widgets/weather_palette.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'weather_fixtures.dart';

final _now = DateTime(2026, 10, 14, 13, 10);

Weather _fullWeather({String iconCode = '01d'}) => weatherWith(
  temperature: 22,
  feelsLike: 21,
  description: 'ciel dégagé',
  iconCode: iconCode,
  humidity: 55,
  windSpeed: 3,
  sunrise: DateTime(2026, 10, 14, 7, 40),
  sunset: DateTime(2026, 10, 14, 19, 5),
  updatedAt: DateTime(2026, 10, 14, 12),
  forecast: [
    for (var day = 14; day <= 18; day++)
      for (var hour = day == 14 ? 12 : 0; hour < 24; hour += 3)
        slot(
          DateTime(2026, 10, day, hour),
          temperature: 12.0 + hour / 2 + day - 14,
          iconCode: hour >= 21 || hour < 6 ? '02n' : '01d',
          rain: hour == 15 ? 40 : 0,
        ),
  ],
);

Future<void> _pumpPage(
  WidgetTester tester,
  AsyncValue<Weather?> state, {
  Size size = const Size(360, 2400),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        currentWeatherProvider.overrideWithValue(state),
        weatherClockProvider.overrideWith((ref) => Stream.value(_now)),
      ],
      child: MaterialApp(
        theme: AppTheme.light,
        home: const WeatherDetailPage(),
      ),
    ),
  );
  await tester.pump();
}

Finder _skyGradient(List<Color> colors) => find.byWidgetPredicate((widget) {
  if (widget is! DecoratedBox) return false;
  final decoration = widget.decoration;
  if (decoration is! BoxDecoration) return false;
  final gradient = decoration.gradient;
  return gradient is LinearGradient && listEquals(gradient.colors, colors);
});

void main() {
  group('WeatherDetailPage', () {
    testWidgets(
      'shows the hero, the hourly timeline, the metrics, the sun and the coming days',
      (tester) async {
        await _pumpPage(tester, AsyncData(_fullWeather().atTime(_now)));

        expect(find.text('Bessan'), findsOneWidget);
        expect(find.text('Ciel dégagé'), findsOneWidget);
        expect(find.textContaining('Sur 24 h : max. '), findsOneWidget);
        expect(find.text('PROCHAINES HEURES'), findsOneWidget);
        expect(find.text('Maint.'), findsOneWidget);
        expect(find.text('RESSENTI'), findsOneWidget);
        expect(find.text('HUMIDITÉ'), findsOneWidget);
        expect(find.text('50 %'), findsOneWidget);
        expect(find.text('VENT'), findsOneWidget);
        expect(find.text('7 km/h'), findsOneWidget);
        expect(find.text('PLUIE'), findsOneWidget);
        expect(find.text('LEVER ET COUCHER DU SOLEIL'), findsOneWidget);
        expect(find.text('07:40'), findsOneWidget);
        expect(find.text('19:05'), findsOneWidget);
        expect(find.text('PROCHAINS JOURS'), findsOneWidget);
        expect(find.text('Demain'), findsOneWidget);
        expect(find.text('Ven. 16'), findsOneWidget);
        expect(
          find.text(
            'Prévisions actualisées à 12:00  ·  Données OpenWeatherMap',
          ),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
      },
    );

    for (final width in [360.0, 320.0]) {
      testWidgets(
        'lays out without overflow on a ${width.toInt()} px wide screen',
        (tester) async {
          await _pumpPage(
            tester,
            AsyncData(_fullWeather().atTime(_now)),
            size: Size(width, 2400),
          );

          expect(tester.takeException(), isNull);
        },
      );
    }

    testWidgets('scrolls on a phone-sized screen down to the last section', (
      tester,
    ) async {
      await _pumpPage(
        tester,
        AsyncData(_fullWeather().atTime(_now)),
        size: const Size(360, 640),
      );

      await tester.dragUntilVisible(
        find.text('PROCHAINS JOURS'),
        find.byType(ListView),
        const Offset(0, -200),
      );

      expect(find.text('PROCHAINS JOURS'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('leaves out the sections it has no data for', (tester) async {
      await _pumpPage(tester, AsyncData(weatherWith()));

      expect(find.text('RESSENTI'), findsOneWidget);
      expect(find.text('HUMIDITÉ'), findsOneWidget);
      expect(find.text('VENT'), findsOneWidget);
      expect(find.text('PLUIE'), findsNothing);
      expect(find.text('PROCHAINES HEURES'), findsNothing);
      expect(find.text('PROCHAINS JOURS'), findsNothing);
      expect(find.text('LEVER ET COUCHER DU SOLEIL'), findsNothing);
      expect(find.text('Données OpenWeatherMap'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('paints a night sky after dark and a day sky otherwise', (
      tester,
    ) async {
      await _pumpPage(tester, AsyncData(weatherWith(iconCode: '01n')));
      expect(_skyGradient(WeatherPalette.skyFor('01n')), findsOneWidget);

      await _pumpPage(tester, AsyncData(weatherWith(iconCode: '01d')));
      expect(_skyGradient(WeatherPalette.skyFor('01d')), findsOneWidget);
    });

    testWidgets('shows a spinner while loading', (tester) async {
      await _pumpPage(tester, const AsyncLoading());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('offers a retry when the weather cannot be loaded', (
      tester,
    ) async {
      await _pumpPage(tester, AsyncError('boom', StackTrace.empty));

      expect(find.text('Impossible de charger la météo.'), findsOneWidget);
    });

    testWidgets('says so when the commune has no weather yet', (tester) async {
      await _pumpPage(tester, const AsyncData(null));

      expect(
        find.text('Météo pas encore disponible pour votre commune.'),
        findsOneWidget,
      );
    });
  });
}
