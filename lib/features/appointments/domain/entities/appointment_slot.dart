import 'package:equatable/equatable.dart';

class AppointmentSlot extends Equatable {
  const AppointmentSlot({required this.startsAt, required this.endsAt});

  final DateTime startsAt;
  final DateTime endsAt;

  @override
  List<Object?> get props => [startsAt, endsAt];
}

Map<DateTime, List<AppointmentSlot>> groupSlotsByDay(
  List<AppointmentSlot> slots,
) {
  final days = <DateTime, List<AppointmentSlot>>{};
  for (final slot in slots) {
    final local = slot.startsAt.toLocal();
    final day = DateTime(local.year, local.month, local.day);
    days.putIfAbsent(day, () => []).add(slot);
  }
  return days;
}
