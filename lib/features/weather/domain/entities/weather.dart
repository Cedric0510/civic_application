import 'package:civic_app/features/weather/domain/entities/daily_forecast.dart';
import 'package:civic_app/features/weather/domain/entities/weather_forecast_entry.dart';
import 'package:equatable/equatable.dart';

class Weather extends Equatable {
  const Weather({
    required this.cityName,
    required this.temperature,
    required this.feelsLike,
    required this.description,
    required this.iconCode,
    required this.humidity,
    required this.windSpeed,
    this.sunrise,
    this.sunset,
    this.updatedAt,
    this.forecast = const [],
  });

  final String cityName;
  final double temperature;
  final double feelsLike;
  final String description;
  final String iconCode;
  final int humidity;
  final double windSpeed;
  final DateTime? sunrise;
  final DateTime? sunset;
  final DateTime? updatedAt;
  final List<WeatherForecastEntry> forecast;

  static const maxForecastGap = Duration(minutes: 90);

  WeatherForecastEntry? slotAt(DateTime now) {
    WeatherForecastEntry? nearest;
    for (final entry in forecast) {
      if (nearest == null || _gap(entry, now) < _gap(nearest, now)) {
        nearest = entry;
      }
    }
    if (nearest == null || _gap(nearest, now) > maxForecastGap) return null;
    return nearest;
  }

  Weather atTime(DateTime now) {
    final slot = slotAt(now);
    if (slot == null) return this;

    return Weather(
      cityName: cityName,
      temperature: slot.temperature,
      feelsLike: slot.feelsLike,
      description: slot.description,
      iconCode: slot.iconCode,
      humidity: slot.humidity,
      windSpeed: slot.windSpeed,
      sunrise: sunrise,
      sunset: sunset,
      updatedAt: updatedAt,
      forecast: forecast,
    );
  }

  List<WeatherForecastEntry> upcomingSlots(
    DateTime now, {
    Duration horizon = const Duration(hours: 24),
  }) {
    final from = slotAt(now)?.time ?? now;
    final until = now.add(horizon);
    return forecast
        .where(
          (entry) => !entry.time.isBefore(from) && !entry.time.isAfter(until),
        )
        .toList();
  }

  List<DailyForecast> dailyForecasts(DateTime now) =>
      DailyForecast.fromEntries(forecast, after: now);

  ({double min, double max}) nextDayRange(DateTime now) {
    final temperatures = [
      temperature,
      ...upcomingSlots(now).map((entry) => entry.temperature),
    ];
    return (
      min: temperatures.reduce((a, b) => a < b ? a : b),
      max: temperatures.reduce((a, b) => a > b ? a : b),
    );
  }

  int? rainChanceAt(DateTime now) {
    final slot =
        slotAt(now) ??
        forecast.where((entry) => !entry.time.isBefore(now)).firstOrNull;
    return slot?.precipitationProbability;
  }

  double? sunProgress(DateTime now) {
    final rise = sunrise;
    final set = sunset;
    if (rise == null || set == null || !set.isAfter(rise)) return null;
    final elapsed = now.difference(rise).inSeconds;
    final daylight = set.difference(rise).inSeconds;
    return (elapsed / daylight).clamp(0.0, 1.0);
  }

  bool isDaylightAt(DateTime now) {
    final rise = sunrise;
    final set = sunset;
    if (rise == null || set == null) return true;
    return !now.isBefore(rise) && now.isBefore(set);
  }

  static Duration _gap(WeatherForecastEntry entry, DateTime now) =>
      entry.time.difference(now).abs();

  @override
  List<Object?> get props => [
    cityName,
    temperature,
    feelsLike,
    description,
    iconCode,
    humidity,
    windSpeed,
    sunrise,
    sunset,
    updatedAt,
    forecast,
  ];
}
