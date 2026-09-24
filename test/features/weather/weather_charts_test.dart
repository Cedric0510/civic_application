import 'package:civic_app/features/weather/domain/entities/daily_forecast.dart';
import 'package:civic_app/features/weather/presentation/widgets/daily_forecast_list.dart';
import 'package:civic_app/features/weather/presentation/widgets/hourly_forecast_chart.dart';
import 'package:civic_app/features/weather/presentation/widgets/sun_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'weather_fixtures.dart';

void main() {
  group('curvePoints', () {
    const size = Size(300, 64);

    test('spreads points evenly and puts the warmest at the top', () {
      final points = curvePoints(temperatures: [10, 20, 15], size: size);

      expect(points.map((point) => point.dx), [50, 150, 250]);
      expect(points[1].dy, 12);
      expect(points[0].dy, 52);
      expect(points[2].dy, 32);
    });

    test('draws a flat series in the middle instead of dividing by zero', () {
      final points = curvePoints(temperatures: [18, 18, 18], size: size);

      expect(points.map((point) => point.dy), everyElement(32));
    });

    test('handles a single point and no point', () {
      expect(
        curvePoints(temperatures: [12], size: size).single,
        const Offset(150, 32),
      );
      expect(curvePoints(temperatures: const [], size: size), isEmpty);
    });
  });

  group('TemperatureCurvePainter', () {
    test('repaints only when the series or the highlighted slot changes', () {
      const painter = TemperatureCurvePainter(
        temperatures: [10, 20],
        highlightedIndex: 0,
      );

      expect(
        painter.shouldRepaint(
          const TemperatureCurvePainter(
            temperatures: [10, 20],
            highlightedIndex: 0,
          ),
        ),
        isFalse,
      );
      expect(
        painter.shouldRepaint(
          const TemperatureCurvePainter(
            temperatures: [10, 21],
            highlightedIndex: 0,
          ),
        ),
        isTrue,
      );
      expect(
        painter.shouldRepaint(
          const TemperatureCurvePainter(
            temperatures: [10, 20],
            highlightedIndex: 1,
          ),
        ),
        isTrue,
      );
    });
  });

  group('HourlyForecastChart', () {
    final slots = [
      slot(DateTime(2026, 10, 14, 12), temperature: 22, rain: 0),
      slot(DateTime(2026, 10, 14, 15), temperature: 24, rain: 40),
      slot(DateTime(2026, 10, 14, 18), temperature: 20, rain: 10),
    ];

    Future<void> pump(WidgetTester tester, {required int current}) =>
        tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: HourlyForecastChart(slots: slots, current: slots[current]),
            ),
          ),
        );

    testWidgets('labels the current slot "Maint." and the others by hour', (
      tester,
    ) async {
      await pump(tester, current: 0);

      expect(find.text('Maint.'), findsOneWidget);
      expect(find.text('12 h'), findsNothing);
      expect(find.text('15 h'), findsOneWidget);
      expect(find.text('18 h'), findsOneWidget);
    });

    testWidgets(
      'shows each slot temperature and only the non-zero rain chances',
      (tester) async {
        await pump(tester, current: 1);

        expect(find.text('22°'), findsOneWidget);
        expect(find.text('24°'), findsOneWidget);
        expect(find.text('20°'), findsOneWidget);
        expect(find.text('40 %'), findsOneWidget);
        expect(find.text('10 %'), findsOneWidget);
        expect(find.byIcon(Icons.water_drop), findsNWidgets(2));
        expect(tester.takeException(), isNull);
      },
    );
  });

  group('DailyForecastList', () {
    testWidgets('lays out a full week on a narrow screen without overflow', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(320, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final days = [
        for (var i = 0; i < 5; i++)
          DailyForecast(
            day: DateTime(2026, 10, 15 + i),
            minTemperature: 4.0 + i,
            maxTemperature: 12.0 + i * 3,
            iconCode: '10d',
            description: 'pluie',
            precipitationProbability: i * 25,
          ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: DailyForecastList(days: days, now: DateTime(2026, 10, 14)),
            ),
          ),
        ),
      );

      expect(find.text('Demain'), findsOneWidget);
      expect(find.text('4°'), findsOneWidget);
      expect(find.text('24°'), findsOneWidget);
      expect(find.text('100 %'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('copes with days that all share the same temperatures', (
      tester,
    ) async {
      final days = [
        for (var i = 0; i < 2; i++)
          DailyForecast(
            day: DateTime(2026, 10, 15 + i),
            minTemperature: 10,
            maxTemperature: 10,
            iconCode: '01d',
            description: 'ciel dégagé',
            precipitationProbability: 0,
          ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DailyForecastList(days: days, now: DateTime(2026, 10, 14)),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
    });
  });

  group('SunArcPainter', () {
    const size = Size(300, 84);

    test(
      'places the sun on the horizon at sunrise and sunset, at the top at midday',
      () {
        final sunrise = SunArcPainter.sunPosition(size, 0);
        final midday = SunArcPainter.sunPosition(size, 0.5);
        final sunset = SunArcPainter.sunPosition(size, 1);

        expect(sunrise.dx, closeTo(12, 0.001));
        expect(sunrise.dy, closeTo(84, 0.001));
        expect(midday.dx, closeTo(150, 0.001));
        expect(midday.dy, closeTo(12, 0.001));
        expect(sunset.dx, closeTo(288, 0.001));
        expect(sunset.dy, closeTo(84, 0.001));
      },
    );

    test('repaints only when the progress or the visibility changes', () {
      const painter = SunArcPainter(progress: 0.5, sunVisible: true);

      expect(
        painter.shouldRepaint(
          const SunArcPainter(progress: 0.5, sunVisible: true),
        ),
        isFalse,
      );
      expect(
        painter.shouldRepaint(
          const SunArcPainter(progress: 0.6, sunVisible: true),
        ),
        isTrue,
      );
      expect(
        painter.shouldRepaint(
          const SunArcPainter(progress: 0.5, sunVisible: false),
        ),
        isTrue,
      );
    });

    testWidgets('paints during the day and at night without error', (
      tester,
    ) async {
      for (final visible in [true, false]) {
        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: SizedBox(
              width: 300,
              height: 84,
              child: CustomPaint(
                painter: SunArcPainter(progress: 0.4, sunVisible: visible),
              ),
            ),
          ),
        );
      }

      expect(tester.takeException(), isNull);
    });
  });
}
