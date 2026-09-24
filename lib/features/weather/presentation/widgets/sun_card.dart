import 'dart:math' as math;

import 'package:civic_app/features/weather/domain/entities/weather.dart';
import 'package:civic_app/features/weather/presentation/utils/weather_formatters.dart';
import 'package:civic_app/features/weather/presentation/widgets/weather_glass_card.dart';
import 'package:flutter/material.dart';

class SunCard extends StatelessWidget {
  const SunCard({super.key, required this.weather, required this.now});

  final Weather weather;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final sunrise = weather.sunrise;
    final sunset = weather.sunset;
    final progress = weather.sunProgress(now);
    if (sunrise == null || sunset == null || progress == null) {
      return const SizedBox.shrink();
    }

    return WeatherGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const WeatherSectionTitle(
            icon: Icons.wb_twilight,
            label: 'Lever et coucher du soleil',
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 84,
            width: double.infinity,
            child: CustomPaint(
              painter: SunArcPainter(
                progress: progress,
                sunVisible: weather.isDaylightAt(now),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _SunTime(label: 'Lever', time: sunrise),
              _SunTime(label: 'Coucher', time: sunset, alignEnd: true),
            ],
          ),
        ],
      ),
    );
  }
}

class _SunTime extends StatelessWidget {
  const _SunTime({
    required this.label,
    required this.time,
    this.alignEnd = false,
  });

  final String label;
  final DateTime time;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignEnd
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
        Text(
          formatClock(time),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class SunArcPainter extends CustomPainter {
  const SunArcPainter({required this.progress, required this.sunVisible});

  final double progress;
  final bool sunVisible;

  static const _sunColor = Color(0xFFFFD54F);

  static const _inset = 12.0;

  static Rect arcBounds(Size size) => Rect.fromLTRB(
    _inset,
    _inset,
    size.width - _inset,
    2 * size.height - _inset,
  );

  static Offset sunPosition(Size size, double progress) {
    final bounds = arcBounds(size);
    final angle = progress * math.pi;
    return Offset(
      bounds.center.dx - bounds.width / 2 * math.cos(angle),
      bounds.center.dy - bounds.height / 2 * math.sin(angle),
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    final arcBounds = SunArcPainter.arcBounds(size);

    final horizon = Paint()
      ..color = Colors.white.withValues(alpha: 0.35)
      ..strokeWidth = 1;
    canvas.drawLine(
      Offset(0, size.height),
      Offset(size.width, size.height),
      horizon,
    );

    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = Colors.white.withValues(alpha: 0.30);
    canvas.drawArc(arcBounds, math.pi, math.pi, false, track);

    final elapsed = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..color = _sunColor.withValues(alpha: sunVisible ? 0.9 : 0.35);
    canvas.drawArc(arcBounds, math.pi, math.pi * progress, false, elapsed);

    if (!sunVisible) return;

    final position = sunPosition(size, progress);
    canvas.drawCircle(
      position,
      12,
      Paint()..color = _sunColor.withValues(alpha: 0.30),
    );
    canvas.drawCircle(position, 7, Paint()..color = _sunColor);
  }

  @override
  bool shouldRepaint(SunArcPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.sunVisible != sunVisible;
}
