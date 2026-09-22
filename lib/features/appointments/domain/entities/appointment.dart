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

// name/email disparaissent : le citoyen est maintenant un compte
// authentifié (dérivé du JWT côté civic_api), plus un simple formulaire
// anonyme. service (texte libre) devient serviceId (vraie relation).
// status est nul avant l'envoi -- civic_api le détermine (DEMANDE par défaut).
class Appointment extends Equatable {
  const Appointment({
    this.id,
    required this.serviceId,
    required this.date,
    this.message,
    this.status,
  });

  final String? id;
  final String serviceId;
  final DateTime date;
  final String? message;
  final AppointmentStatus? status;

  @override
  List<Object?> get props => [id, serviceId, date, message, status];
}
