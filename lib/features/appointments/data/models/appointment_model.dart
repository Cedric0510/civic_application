import 'package:civic_app/features/appointments/domain/entities/appointment.dart';
import 'package:intl/intl.dart';

class AppointmentModel extends Appointment {
  const AppointmentModel({
    super.id,
    required super.name,
    required super.email,
    required super.service,
    required super.date,
    super.message,
  });

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    return AppointmentModel(
      id: json['id'] as String?,
      name: json['name'] as String,
      email: json['email'] as String,
      service: json['service'] as String,
      date: DateTime.parse(json['date'] as String),
      message: json['message'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'service': service,
      'date': DateFormat('yyyy-MM-dd').format(date),
      if (message != null && message!.isNotEmpty) 'message': message,
    };
  }
}
