import 'package:flutter/material.dart';

class WeatherIcon extends StatelessWidget {
  const WeatherIcon({
    super.key,
    required this.iconCode,
    this.size = 64,
    this.color = Colors.white,
  });

  final String iconCode;
  final double size;
  final Color color;

  static IconData _iconFromCode(String code) {
    final prefix = code.length >= 2 ? code.substring(0, 2) : '';
    return switch (prefix) {
      '01' => Icons.wb_sunny,
      '02' || '03' || '04' => Icons.cloud,
      '09' || '10' => Icons.umbrella,
      '11' => Icons.bolt,
      '13' => Icons.ac_unit,
      _ => Icons.blur_on,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Icon(_iconFromCode(iconCode), size: size, color: color);
  }
}
