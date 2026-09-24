import 'package:civic_app/features/weather/domain/entities/weather.dart';
import 'package:flutter_test/flutter_test.dart';

import 'weather_fixtures.dart';

Weather _threeDayWeather() => weatherWith(
  temperature: 14,
  forecast: [
    for (final hour in [9, 12, 15, 18])
      slot(
        DateTime(2026, 10, 14, hour),
        temperature: 19.0 + hour / 3,
        rain: hour == 15 ? 40 : 0,
      ),
    for (var hour = 0; hour < 24; hour += 3)
      slot(DateTime(2026, 10, 15, hour), temperature: 10.0 + hour),
  ],
);

void main() {
  group('slotAt', () {
    test('returns the nearest slot within the gap, and null beyond it', () {
      final weather = _threeDayWeather();

      expect(weather.slotAt(DateTime(2026, 10, 14, 13, 10))?.time.hour, 12);
      expect(weather.slotAt(DateTime(2026, 10, 14, 4)), isNull);
      expect(weatherWith().slotAt(DateTime(2026, 10, 14, 12)), isNull);
    });
  });

  group('upcomingSlots', () {
    test(
      'starts at the current slot and covers the next 24 hours, dropping earlier slots',
      () {
        final slots = _threeDayWeather().upcomingSlots(
          DateTime(2026, 10, 14, 13, 10),
        );

        expect(slots.first.time, DateTime(2026, 10, 14, 12));
        expect(slots.last.time, DateTime(2026, 10, 15, 12));
        expect(slots, hasLength(8));
      },
    );

    test('starts from now when no slot is close enough', () {
      final slots = _threeDayWeather().upcomingSlots(DateTime(2026, 10, 14, 5));

      expect(slots.first.time, DateTime(2026, 10, 14, 9));
    });

    test('honours a custom horizon', () {
      final slots = _threeDayWeather().upcomingSlots(
        DateTime(2026, 10, 14, 12),
        horizon: const Duration(hours: 6),
      );

      expect(slots.map((slot) => slot.time.hour), [12, 15, 18]);
    });

    test('is empty without forecast', () {
      expect(weatherWith().upcomingSlots(DateTime(2026, 10, 14, 12)), isEmpty);
    });
  });

  group('nextDayRange', () {
    test(
      'spans the shown temperature and the slots of the next 24 hours, across midnight',
      () {
        final range = _threeDayWeather().nextDayRange(
          DateTime(2026, 10, 14, 13),
        );

        expect(range.min, 10);
        expect(range.max, 25);
      },
    );

    test('is the shown temperature alone without forecast', () {
      final range = weatherWith(
        temperature: 17,
      ).nextDayRange(DateTime(2026, 10, 14));

      expect(range.min, 17);
      expect(range.max, 17);
    });
  });

  group('rainChanceAt', () {
    test('uses the current slot', () {
      expect(
        _threeDayWeather().rainChanceAt(DateTime(2026, 10, 14, 15, 30)),
        40,
      );
    });

    test(
      'falls back to the first upcoming slot before the forecast starts',
      () {
        final weather = weatherWith(
          forecast: [slot(DateTime(2026, 10, 14, 12), rain: 65)],
        );

        expect(weather.rainChanceAt(DateTime(2026, 10, 14, 8)), 65);
      },
    );

    test('is unknown once the forecast is over or when there is none', () {
      expect(_threeDayWeather().rainChanceAt(DateTime(2026, 10, 18)), isNull);
      expect(weatherWith().rainChanceAt(DateTime(2026, 10, 14)), isNull);
    });
  });

  group('sun', () {
    final weather = weatherWith(
      sunrise: DateTime(2026, 10, 14, 7),
      sunset: DateTime(2026, 10, 14, 19),
    );

    test('progresses from sunrise to sunset and is clamped outside', () {
      expect(weather.sunProgress(DateTime(2026, 10, 14, 13)), 0.5);
      expect(weather.sunProgress(DateTime(2026, 10, 14, 5)), 0);
      expect(weather.sunProgress(DateTime(2026, 10, 14, 22)), 1);
    });

    test('is unknown without both sun times or with inverted ones', () {
      expect(weatherWith().sunProgress(DateTime(2026, 10, 14, 13)), isNull);
      expect(
        weatherWith(
          sunrise: DateTime(2026, 10, 14, 7),
        ).sunProgress(DateTime(2026, 10, 14, 13)),
        isNull,
      );
      expect(
        weatherWith(
          sunrise: DateTime(2026, 10, 14, 19),
          sunset: DateTime(2026, 10, 14, 7),
        ).sunProgress(DateTime(2026, 10, 14, 13)),
        isNull,
      );
    });

    test('tells daylight from night, sunset excluded', () {
      expect(weather.isDaylightAt(DateTime(2026, 10, 14, 7)), isTrue);
      expect(weather.isDaylightAt(DateTime(2026, 10, 14, 6, 59)), isFalse);
      expect(weather.isDaylightAt(DateTime(2026, 10, 14, 19)), isFalse);
      expect(weatherWith().isDaylightAt(DateTime(2026, 10, 14, 23)), isTrue);
    });
  });
}
