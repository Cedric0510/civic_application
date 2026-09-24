import 'package:civic_app/features/weather/domain/entities/daily_forecast.dart';
import 'package:flutter_test/flutter_test.dart';

import 'weather_fixtures.dart';

void main() {
  final now = DateTime(2026, 10, 14, 13);

  group('DailyForecast.fromEntries', () {
    test('summarises each following day, leaving today out', () {
      final days = DailyForecast.fromEntries([
        slot(DateTime(2026, 10, 14, 15), temperature: 30),
        for (var hour = 0; hour < 24; hour += 3)
          slot(
            DateTime(2026, 10, 15, hour),
            temperature: 10.0 + hour,
            rain: hour == 6 ? 70 : 20,
          ),
      ], after: now);

      expect(days, hasLength(1));
      final day = days.single;
      expect(day.day, DateTime(2026, 10, 15));
      expect(day.minTemperature, 10);
      expect(day.maxTemperature, 31);
      expect(day.precipitationProbability, 70);
    });

    test(
      'represents the day by the slot closest to 13h, always in its daytime variant',
      () {
        final days = DailyForecast.fromEntries([
          slot(DateTime(2026, 10, 15, 3), iconCode: '01n', description: 'nuit'),
          slot(
            DateTime(2026, 10, 15, 9),
            iconCode: '04d',
            description: 'matin',
          ),
          slot(
            DateTime(2026, 10, 15, 12),
            iconCode: '10n',
            description: 'midi',
          ),
          slot(
            DateTime(2026, 10, 15, 21),
            iconCode: '01n',
            description: 'soir',
          ),
        ], after: now);

        expect(days.single.iconCode, '10d');
        expect(days.single.description, 'midi');
      },
    );

    test('drops trailing days covered by too few slots to be summarised', () {
      final days = DailyForecast.fromEntries([
        for (var hour = 0; hour < 24; hour += 3)
          slot(DateTime(2026, 10, 15, hour)),
        slot(DateTime(2026, 10, 16, 0)),
        slot(DateTime(2026, 10, 16, 3)),
      ], after: now);

      expect(days.map((day) => day.day), [DateTime(2026, 10, 15)]);
    });

    test('lists days in chronological order whatever the input order', () {
      final days = DailyForecast.fromEntries([
        for (final date in [17, 15, 16])
          for (var hour = 0; hour < 12; hour += 3)
            slot(DateTime(2026, 10, date, hour)),
      ], after: now);

      expect(days.map((day) => day.day.day), [15, 16, 17]);
    });

    test('is empty without forecast', () {
      expect(DailyForecast.fromEntries(const [], after: now), isEmpty);
    });
  });
}
