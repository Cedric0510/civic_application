import 'package:flutter/material.dart';

abstract final class FeatureColors {
  static const Color articles = Color(0xFF1565C0);
  static const Color appointments = Color(0xFFC62828);
  static const Color polls = Color(0xFF2E7D32);
  static const Color services = Color(0xFFC2410C);
  static const Color commerces = Color(0xFF00796B);
  static const Color reports = Color(0xFF6D4C41);
  static const Color account = Color(0xFF5E35B1);

  static const List<Color> all = [
    articles,
    appointments,
    polls,
    services,
    commerces,
    reports,
    account,
  ];
}
