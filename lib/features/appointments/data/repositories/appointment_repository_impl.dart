import 'package:civic_app/features/appointments/data/datasources/appointment_api_datasource.dart';
import 'package:civic_app/features/appointments/data/models/appointment_model.dart';
import 'package:civic_app/features/appointments/domain/entities/appointment.dart';
import 'package:civic_app/features/appointments/domain/repositories/appointment_repository.dart';

class AppointmentRepositoryImpl implements AppointmentRepository {
  const AppointmentRepositoryImpl(this._datasource);

  final AppointmentApiDatasource _datasource;

  @override
  Future<void> createAppointment(Appointment appointment) {
    return _datasource.createAppointment(
      AppointmentModel(
        id: appointment.id,
        serviceId: appointment.serviceId,
        date: appointment.date,
        message: appointment.message,
      ),
    );
  }

  @override
  Future<List<Appointment>> getMyAppointments() =>
      _datasource.getMyAppointments();
}
