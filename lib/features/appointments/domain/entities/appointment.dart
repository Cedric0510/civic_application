import 'package:equatable/equatable.dart';

enum AppointmentStatus {
  demande('DEMANDE', 'Demandé'),
  confirme('CONFIRME', 'Confirmé'),
  annule('ANNULE', 'Annulé');

  const AppointmentStatus(this.apiValue, this.label);

  final String apiValue;
  final String label;

  static AppointmentStatus fromApiValue(String value) {
    return AppointmentStatus.values.firstWhere(
      (status) => status.apiValue == value,
      orElse: () => AppointmentStatus.demande,
    );
  }
}

class Appointment extends Equatable {
  const Appointment({
    required this.id,
    required this.serviceId,
    required this.serviceName,
    required this.startsAt,
    required this.endsAt,
    required this.status,
    this.message,
  });

  final String id;
  final String serviceId;
  final String serviceName;
  final DateTime startsAt;
  final DateTime endsAt;
  final AppointmentStatus status;
  final String? message;

  @override
  List<Object?> get props => [
    id,
    serviceId,
    serviceName,
    startsAt,
    endsAt,
    status,
    message,
  ];
}
