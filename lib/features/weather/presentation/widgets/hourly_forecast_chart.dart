import 'package:civic_app/features/weather/domain/entities/weather_forecast_entry.dart';
import 'package:civic_app/features/weather/presentation/utils/weather_formatters.dart';
import 'package:civic_app/features/weather/presentation/widgets/weather_icon.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

const _slotWidth = 68.0;
const _headerHeight = 104.0;
const _curveHeight = 64.0;
const _footerHeight = 22.0;

class HourlyForecastChart extends StatelessWidget {
  const HourlyForecastChart({
    super.key,
    required this.slots,
    required this.current,
  });

  final List<WeatherForecastEntry> slots;
  final WeatherForecastEntry? current;

  @override
  Widget build(BuildContext context) {
    final currentIndex = current == null ? -1 : slots.indexOf(current!);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: SizedBox(
        width: slots.length * _slotWidth,
        child: Column(
          children: [
            Row(
              children: [
                for (var i = 0; i < slots.length; i++)
                  _SlotHeader(slot: slots[i], isCurrent: i == currentIndex),
              ],
            ),
            SizedBox(
              height: _curveHeight,
              width: double.infinity,
              child: CustomPaint(
                painter: TemperatureCurvePainter(
                  temperatures: [for (final slot in slots) slot.temperature],
                  highlightedIndex: currentIndex,
                ),
              ),
            ),
            Row(children: [for (final slot in slots) _SlotFooter(slot: slot)]),
          ],
        ),
      ),
    );
  }
}

class _SlotHeader extends StatelessWidget {
  const _SlotHeader({required this.slot, required this.isCurrent});

  final WeatherForecastEntry slot;
  final bool isCurrent;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _slotWidth,
      height: _headerHeight,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: isCurrent
                ? Colors.white.withValues(alpha: 0.18)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                isCurrent ? 'Maint.' : formatHour(slot.time),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
                ),
              ),
              WeatherIcon(iconCode: slot.iconCode, size: 28),
              Text(
                formatTemperature(slot.temperature),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SlotFooter extends StatelessWidget {
  const _SlotFooter({required this.slot});

  final WeatherForecastEntry slot;

  static const _rainColor = Color(0xFF9BD4FF);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _slotWidth,
      height: _footerHeight,
      child: slot.precipitationProbability == 0
          ? null
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.water_drop, size: 11, color: _rainColor),
                const SizedBox(width: 2),
                Text(
                  '${slot.precipitationProbability} %',
                  style: const TextStyle(color: _rainColor, fontSize: 11),
                ),
              ],
            ),
    );
  }
}

@visibleForTesting
List<Offset> curvePoints({
  required List<double> temperatures,
  required Size size,
  double verticalPadding = 12,
}) {
  if (temperatures.isEmpty) return const [];
  final lowest = temperatures.reduce((a, b) => a < b ? a : b);
  final highest = temperatures.reduce((a, b) => a > b ? a : b);
  final spread = highest - lowest;
  final slotWidth = size.width / temperatures.length;
  final usableHeight = size.height - 2 * verticalPadding;

  return [
    for (var i = 0; i < temperatures.length; i++)
      Offset(
        (i + 0.5) * slotWidth,
        spread == 0
            ? size.height / 2
            : verticalPadding +
                  (highest - temperatures[i]) / spread * usableHeight,
      ),
  ];
}

class TemperatureCurvePainter extends CustomPainter {
  const TemperatureCurvePainter({
    required this.temperatures,
    required this.highlightedIndex,
  });

  final List<double> temperatures;
  final int highlightedIndex;

  @override
  void paint(Canvas canvas, Size size) {
    final points = curvePoints(temperatures: temperatures, size: size);
    if (points.isEmpty) return;

    final line = _smoothPath(points);
    final area = Path.from(line)
      ..lineTo(points.last.dx, size.height)
      ..lineTo(points.first.dx, size.height)
      ..close();

    canvas.drawPath(
      area,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withValues(alpha: 0.28),
            Colors.white.withValues(alpha: 0),
          ],
        ).createShader(Offset.zero & size),
    );
    canvas.drawPath(
      line,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round
        ..color = Colors.white,
    );

    for (var i = 0; i < points.length; i++) {
      final highlighted = i == highlightedIndex;
      if (highlighted) {
        canvas.drawCircle(
          points[i],
          9,
          Paint()..color = Colors.white.withValues(alpha: 0.28),
        );
      }
      canvas.drawCircle(
        points[i],
        highlighted ? 5.5 : 3.5,
        Paint()..color = Colors.white,
      );
    }
  }

  Path _smoothPath(List<Offset> points) {
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 1; i < points.length; i++) {
      final previous = points[i - 1];
      final point = points[i];
      final middle = (previous.dx + point.dx) / 2;
      path.cubicTo(middle, previous.dy, middle, point.dy, point.dx, point.dy);
    }
    return path;
  }

  @override
  bool shouldRepaint(TemperatureCurvePainter oldDelegate) =>
      !listEquals(oldDelegate.temperatures, temperatures) ||
      oldDelegate.highlightedIndex != highlightedIndex;
}
