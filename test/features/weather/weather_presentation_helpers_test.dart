import 'package:civic_app/features/weather/domain/entities/weather_condition.dart';
import 'package:civic_app/features/weather/domain/weather_units.dart';
import 'package:civic_app/features/weather/presentation/utils/weather_formatters.dart';
import 'package:civic_app/features/weather/presentation/widgets/weather_icon.dart';
import 'package:civic_app/features/weather/presentation/widgets/weather_palette.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('WeatherCondition', () {
    test('classifies OpenWeatherMap icon codes', () {
      expect(WeatherCondition.fromIconCode('01d'), WeatherCondition.clear);
      expect(
        WeatherCondition.fromIconCode('02n'),
        WeatherCondition.partlyCloudy,
      );
      expect(
        WeatherCondition.fromIconCode('03d'),
        WeatherCondition.partlyCloudy,
      );
      expect(WeatherCondition.fromIconCode('04d'), WeatherCondition.cloudy);
      expect(WeatherCondition.fromIconCode('09d'), WeatherCondition.rain);
      expect(WeatherCondition.fromIconCode('10n'), WeatherCondition.rain);
      expect(WeatherCondition.fromIconCode('11d'), WeatherCondition.storm);
      expect(WeatherCondition.fromIconCode('13d'), WeatherCondition.snow);
      expect(WeatherCondition.fromIconCode('50d'), WeatherCondition.mist);
    });

    test('treats unknown or empty codes as mist', () {
      expect(WeatherCondition.fromIconCode(''), WeatherCondition.mist);
      expect(WeatherCondition.fromIconCode('x'), WeatherCondition.mist);
      expect(WeatherCondition.fromIconCode('99d'), WeatherCondition.mist);
    });

    test('tells night codes and rebuilds their daytime variant', () {
      expect(isNightIconCode('01n'), isTrue);
      expect(isNightIconCode('01d'), isFalse);
      expect(dayVariantOfIconCode('10n'), '10d');
      expect(dayVariantOfIconCode('10d'), '10d');
      expect(dayVariantOfIconCode(''), '');
    });
  });

  group('every condition, day and night, is drawable', () {
    const codes = ['01', '02', '03', '04', '09', '10', '11', '13', '50'];

    test('has a two-colour sky', () {
      for (final code in codes) {
        for (final suffix in ['d', 'n']) {
          expect(WeatherPalette.skyFor('$code$suffix'), hasLength(2));
        }
      }
      expect(WeatherPalette.skyFor(''), hasLength(2));
    });

    test('has an icon, distinct between clear day and clear night', () {
      for (final code in codes) {
        expect(WeatherIcon.iconFor('${code}d'), isNotNull);
      }
      expect(WeatherIcon.iconFor('01d'), isNot(WeatherIcon.iconFor('01n')));
    });

    test('uses a darker sky at night than during the day', () {
      final day = WeatherPalette.skyFor('01d').first.computeLuminance();
      final night = WeatherPalette.skyFor('01n').first.computeLuminance();

      expect(night, lessThan(day));
    });
  });

  group('formatters', () {
    test('rounds temperatures, without a minus sign on zero', () {
      expect(formatTemperature(21.5), '22°');
      expect(formatTemperature(-0.4), '0°');
      expect(formatTemperature(-3.6), '-4°');
    });

    test('formats hours and clock times', () {
      expect(formatHour(DateTime(2026, 10, 14, 9)), '9 h');
      expect(formatClock(DateTime(2026, 10, 14, 7, 5)), '07:05');
    });

    test('capitalises a description and tolerates an empty one', () {
      expect(capitalize('ciel dégagé'), 'Ciel dégagé');
      expect(capitalize(''), '');
    });

    test('labels tomorrow, then the weekday and date', () {
      final now = DateTime(2026, 10, 14, 13);

      expect(dayLabel(DateTime(2026, 10, 15), now), 'Demain');
      expect(dayLabel(DateTime(2026, 10, 16), now), 'Ven. 16');
      expect(dayLabel(DateTime(2026, 10, 19), now), 'Lun. 19');
    });

    test('still finds tomorrow across a month boundary', () {
      expect(
        dayLabel(DateTime(2026, 11), DateTime(2026, 10, 31, 22)),
        'Demain',
      );
    });
  });

  test('converts metres per second to whole km/h', () {
    expect(metersPerSecondToKmh(0), 0);
    expect(metersPerSecondToKmh(2.5), 9);
    expect(metersPerSecondToKmh(10), 36);
  });
}
