import 'package:civic_app/features/appointments/domain/entities/appointment_slot.dart';

class AppointmentSlotModel extends AppointmentSlot {
  const AppointmentSlotModel({required super.startsAt, required super.endsAt});

  factory AppointmentSlotModel.fromJson(Map<String, dynamic> json) {
    return AppointmentSlotModel(
      startsAt: DateTime.parse(json['startsAt'] as String),
      endsAt: DateTime.parse(json['endsAt'] as String),
    );
  }
}
