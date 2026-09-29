import 'package:equatable/equatable.dart';

class AppointmentRequest extends Equatable {
  const AppointmentRequest({
    required this.serviceId,
    required this.startsAt,
    required this.visitorName,
    this.message,
  });

  final String serviceId;
  final DateTime startsAt;
  final String visitorName;
  final String? message;

  @override
  List<Object?> get props => [serviceId, startsAt, visitorName, message];
}
