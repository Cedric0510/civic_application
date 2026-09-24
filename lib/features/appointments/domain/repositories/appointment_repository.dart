import 'package:civic_app/features/appointments/domain/entities/appointment.dart';
import 'package:civic_app/features/appointments/domain/entities/appointment_request.dart';
import 'package:civic_app/features/appointments/domain/entities/appointment_slot.dart';
import 'package:civic_app/features/appointments/domain/entities/slots_query.dart';

abstract class AppointmentRepository {
  Future<void> createAppointment(AppointmentRequest request);
  Future<List<Appointment>> getMyAppointments();
  Future<List<AppointmentSlot>> getSlots(SlotsQuery query);
}
