import 'package:civic_app/features/weather/domain/entities/weather_condition.dart';
import 'package:civic_app/features/weather/domain/entities/weather_forecast_entry.dart';
import 'package:equatable/equatable.dart';

class DailyForecast extends Equatable {
  const DailyForecast({
    required this.day,
    required this.minTemperature,
    required this.maxTemperature,
    required this.iconCode,
    required this.description,
    required this.precipitationProbability,
  });

  final DateTime day;
  final double minTemperature;
  final double maxTemperature;
  final String iconCode;
  final String description;
  final int precipitationProbability;

  static const minSlotsForFullDay = 4;
  static const _representativeMinuteOfDay = 13 * 60;

  static List<DailyForecast> fromEntries(
    List<WeatherForecastEntry> entries, {
    required DateTime after,
  }) {
    final today = dateOnly(after);
    final byDay = <DateTime, List<WeatherForecastEntry>>{};
    for (final entry in entries) {
      final day = dateOnly(entry.time);
      if (day.isAfter(today)) byDay.putIfAbsent(day, () => []).add(entry);
    }

    final days = byDay.entries
        .where((day) => day.value.length >= minSlotsForFullDay)
        .map((day) => _summarize(day.key, day.value))
        .toList();
    days.sort((a, b) => a.day.compareTo(b.day));
    return days;
  }

  static DailyForecast _summarize(
    DateTime day,
    List<WeatherForecastEntry> slots,
  ) {
    final temperatures = slots.map((slot) => slot.temperature);
    final representative = slots.reduce(
      (best, slot) =>
          _distanceToMidday(slot) < _distanceToMidday(best) ? slot : best,
    );
    return DailyForecast(
      day: day,
      minTemperature: temperatures.reduce((a, b) => a < b ? a : b),
      maxTemperature: temperatures.reduce((a, b) => a > b ? a : b),
      iconCode: dayVariantOfIconCode(representative.iconCode),
      description: representative.description,
      precipitationProbability: slots
          .map((slot) => slot.precipitationProbability)
          .reduce((a, b) => a > b ? a : b),
    );
  }

  static int _distanceToMidday(WeatherForecastEntry slot) =>
      (slot.time.hour * 60 + slot.time.minute - _representativeMinuteOfDay)
          .abs();

  @override
  List<Object?> get props => [
    day,
    minTemperature,
    maxTemperature,
    iconCode,
    description,
    precipitationProbability,
  ];
}

DateTime dateOnly(DateTime moment) =>
    DateTime(moment.year, moment.month, moment.day);
