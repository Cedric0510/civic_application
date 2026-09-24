import 'dart:math' as math;

import 'package:civic_app/features/weather/domain/entities/daily_forecast.dart';
import 'package:civic_app/features/weather/presentation/utils/weather_formatters.dart';
import 'package:civic_app/features/weather/presentation/widgets/weather_icon.dart';
import 'package:flutter/material.dart';

class DailyForecastList extends StatelessWidget {
  const DailyForecastList({super.key, required this.days, required this.now});

  final List<DailyForecast> days;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final lowest = days
        .map((day) => day.minTemperature)
        .reduce((a, b) => a < b ? a : b);
    final highest = days
        .map((day) => day.maxTemperature)
        .reduce((a, b) => a > b ? a : b);

    return Column(
      children: [
        for (var i = 0; i < days.length; i++) ...[
          if (i > 0)
            Divider(height: 1, color: Colors.white.withValues(alpha: 0.12)),
          _DayRow(day: days[i], now: now, lowest: lowest, highest: highest),
        ],
      ],
    );
  }
}

class _DayRow extends StatelessWidget {
  const _DayRow({
    required this.day,
    required this.now,
    required this.lowest,
    required this.highest,
  });

  final DailyForecast day;
  final DateTime now;
  final double lowest;
  final double highest;

  static const _rainColor = Color(0xFF9BD4FF);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          SizedBox(
            width: 70,
            child: Text(
              dayLabel(day.day, now),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          WeatherIcon(iconCode: day.iconCode, size: 26),
          SizedBox(
            width: 44,
            child: day.precipitationProbability == 0
                ? null
                : Text(
                    '${day.precipitationProbability} %',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: _rainColor, fontSize: 12),
                  ),
          ),
          SizedBox(
            width: 32,
            child: Text(
              formatTemperature(day.minTemperature),
              textAlign: TextAlign.right,
              style: const TextStyle(color: Colors.white70, fontSize: 15),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _RangeBar(
              min: day.minTemperature,
              max: day.maxTemperature,
              lowest: lowest,
              highest: highest,
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 32,
            child: Text(
              formatTemperature(day.maxTemperature),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RangeBar extends StatelessWidget {
  const _RangeBar({
    required this.min,
    required this.max,
    required this.lowest,
    required this.highest,
  });

  final double min;
  final double max;
  final double lowest;
  final double highest;

  static const _height = 5.0;
  static const _minimumSegment = 6.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final spread = highest - lowest;
        final width = constraints.maxWidth;
        final segment = spread == 0
            ? width
            : math.min(
                width,
                math.max(_minimumSegment, (max - min) / spread * width),
              );
        final left = spread == 0
            ? 0.0
            : math.min(width - segment, (min - lowest) / spread * width);

        return SizedBox(
          height: _height,
          child: Stack(
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(_height),
                ),
                child: const SizedBox.expand(),
              ),
              Positioned(
                left: left,
                width: segment,
                top: 0,
                bottom: 0,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF7FD1FF), Color(0xFFFFC857)],
                    ),
                    borderRadius: BorderRadius.circular(_height),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
