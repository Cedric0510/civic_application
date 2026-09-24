import 'package:civic_app/features/weather/domain/entities/daily_forecast.dart';
import 'package:intl/intl.dart';

const _weekdayLabels = ['Lun.', 'Mar.', 'Mer.', 'Jeu.', 'Ven.', 'Sam.', 'Dim.'];

String formatTemperature(double value) => '${value.round()}°';

String formatClock(DateTime time) => DateFormat('HH:mm').format(time);

String formatHour(DateTime time) => '${time.hour} h';

String capitalize(String text) => toBeginningOfSentenceCase(text) ?? text;

String dayLabel(DateTime day, DateTime now) {
  final tomorrow = DateTime(now.year, now.month, now.day + 1);
  if (dateOnly(day) == tomorrow) return 'Demain';
  return '${_weekdayLabels[day.weekday - 1]} ${day.day}';
}
