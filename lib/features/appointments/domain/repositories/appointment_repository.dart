import 'package:civic_app/features/appointments/domain/entities/appointment.dart';

abstract class AppointmentRepository {
  Future<void> createAppointment(Appointment appointment);
}
