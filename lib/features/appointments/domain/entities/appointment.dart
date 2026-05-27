import 'package:equatable/equatable.dart';

class Appointment extends Equatable {
  const Appointment({
    this.id,
    required this.name,
    required this.email,
    required this.service,
    required this.date,
    this.message,
  });

  final String? id;
  final String name;
  final String email;
  final String service;
  final DateTime date;
  final String? message;

  @override
  List<Object?> get props => [id, name, email, service, date, message];
}
