import 'package:civic_app/features/appointments/domain/entities/appointment_request.dart';

class AppointmentRequestModel extends AppointmentRequest {
  const AppointmentRequestModel({
    required super.serviceId,
    required super.startsAt,
    required super.visitorName,
    super.message,
  });

  factory AppointmentRequestModel.fromEntity(AppointmentRequest request) {
    return AppointmentRequestModel(
      serviceId: request.serviceId,
      startsAt: request.startsAt,
      visitorName: request.visitorName,
      message: request.message,
    );
  }

  // citizenId/communeId sont dérivés du JWT côté civic_api.
  Map<String, dynamic> toJson() {
    return {
      'serviceId': serviceId,
      'startsAt': startsAt.toUtc().toIso8601String(),
      'visitorName': visitorName,
      if (message != null && message!.isNotEmpty) 'message': message,
    };
  }
}
