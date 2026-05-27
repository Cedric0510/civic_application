import 'package:civic_app/features/appointments/domain/entities/appointment.dart';
import 'package:civic_app/features/appointments/domain/repositories/appointment_repository.dart';

class CreateAppointmentUseCase {
  const CreateAppointmentUseCase(this._repository);

  final AppointmentRepository _repository;

  Future<void> call(Appointment appointment) =>
      _repository.createAppointment(appointment);
}
