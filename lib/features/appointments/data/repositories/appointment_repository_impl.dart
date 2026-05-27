import 'package:civic_app/features/appointments/data/datasources/appointment_supabase_datasource.dart';
import 'package:civic_app/features/appointments/data/models/appointment_model.dart';
import 'package:civic_app/features/appointments/domain/entities/appointment.dart';
import 'package:civic_app/features/appointments/domain/repositories/appointment_repository.dart';

class AppointmentRepositoryImpl implements AppointmentRepository {
  const AppointmentRepositoryImpl(this._datasource);

  final AppointmentSupabaseDatasource _datasource;

  @override
  Future<void> createAppointment(Appointment appointment) {
    return _datasource.createAppointment(
      AppointmentModel(
        id: appointment.id,
        name: appointment.name,
        email: appointment.email,
        service: appointment.service,
        date: appointment.date,
        message: appointment.message,
      ),
    );
  }
}
