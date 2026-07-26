import 'package:civic_app/features/appointments/domain/entities/appointment.dart';
import 'package:intl/intl.dart';

class AppointmentModel extends Appointment {
  const AppointmentModel({
    super.id,
    required super.serviceId,
    required super.date,
    super.message,
  });

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    return AppointmentModel(
      id: json['id'] as String?,
      serviceId: json['serviceId'] as String,
      date: DateTime.parse(json['date'] as String),
      message: json['message'] as String?,
    );
  }

  // Seuls les champs attendus par POST /appointments : citizenId/communeId
  // sont dérivés du JWT côté civic_api.
  Map<String, dynamic> toJson() {
    return {
      'serviceId': serviceId,
      'date': DateFormat('yyyy-MM-dd').format(date),
      if (message != null && message!.isNotEmpty) 'message': message,
    };
  }
}
