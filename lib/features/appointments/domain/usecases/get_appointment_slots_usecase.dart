import 'package:civic_app/features/appointments/domain/entities/appointment_slot.dart';
import 'package:civic_app/features/appointments/domain/entities/slots_query.dart';
import 'package:civic_app/features/appointments/domain/repositories/appointment_repository.dart';

class GetAppointmentSlotsUseCase {
  const GetAppointmentSlotsUseCase(this._repository);

  final AppointmentRepository _repository;

  Future<List<AppointmentSlot>> call(SlotsQuery query) =>
      _repository.getSlots(query);
}
