import 'package:civic_app/features/appointments/domain/entities/appointment.dart';
import 'package:civic_app/features/appointments/domain/repositories/appointment_repository.dart';

class GetMyAppointmentsUseCase {
  const GetMyAppointmentsUseCase(this._repository);

  final AppointmentRepository _repository;

  Future<List<Appointment>> call() => _repository.getMyAppointments();
}
