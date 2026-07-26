import 'package:equatable/equatable.dart';

// name/email disparaissent : le citoyen est maintenant un compte
// authentifié (dérivé du JWT côté civic_api), plus un simple formulaire
// anonyme. service (texte libre) devient serviceId (vraie relation).
class Appointment extends Equatable {
  const Appointment({
    this.id,
    required this.serviceId,
    required this.date,
    this.message,
  });

  final String? id;
  final String serviceId;
  final DateTime date;
  final String? message;

  @override
  List<Object?> get props => [id, serviceId, date, message];
}
