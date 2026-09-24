import 'package:civic_app/features/appointments/domain/entities/appointment_request.dart';
import 'package:civic_app/features/appointments/domain/repositories/appointment_repository.dart';

class CreateAppointmentUseCase {
  const CreateAppointmentUseCase(this._repository);

  final AppointmentRepository _repository;

  Future<void> call(AppointmentRequest request) =>
      _repository.createAppointment(request);
}
