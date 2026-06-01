import 'package:civic_app/features/account/domain/repositories/account_repository.dart';
import 'package:civic_app/features/appointments/domain/entities/appointment.dart';

class GetUserAppointmentsUseCase {
  const GetUserAppointmentsUseCase(this._repository);

  final AccountRepository _repository;

  Future<List<Appointment>> call(String email) =>
      _repository.getUserAppointments(email);
}
