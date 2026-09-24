import 'package:civic_app/features/appointments/domain/entities/appointment.dart';

class AppointmentModel extends Appointment {
  const AppointmentModel({
    required super.id,
    required super.serviceId,
    required super.serviceName,
    required super.startsAt,
    required super.endsAt,
    required super.status,
    super.message,
  });

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    return AppointmentModel(
      id: json['id'] as String,
      serviceId: json['serviceId'] as String,
      serviceName: (json['service'] as Map<String, dynamic>)['name'] as String,
      startsAt: DateTime.parse(json['startsAt'] as String),
      endsAt: DateTime.parse(json['endsAt'] as String),
      status: AppointmentStatus.fromApiValue(json['status'] as String),
      message: json['message'] as String?,
    );
  }
}
