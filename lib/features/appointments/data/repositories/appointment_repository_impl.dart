import 'package:civic_app/features/appointments/data/datasources/appointment_api_datasource.dart';
import 'package:civic_app/features/appointments/data/models/appointment_request_model.dart';
import 'package:civic_app/features/appointments/domain/entities/appointment.dart';
import 'package:civic_app/features/appointments/domain/entities/appointment_request.dart';
import 'package:civic_app/features/appointments/domain/entities/appointment_slot.dart';
import 'package:civic_app/features/appointments/domain/entities/slots_query.dart';
import 'package:civic_app/features/appointments/domain/repositories/appointment_repository.dart';

class AppointmentRepositoryImpl implements AppointmentRepository {
  const AppointmentRepositoryImpl(this._datasource);

  final AppointmentApiDatasource _datasource;

  @override
  Future<void> createAppointment(AppointmentRequest request) {
    return _datasource.createAppointment(
      AppointmentRequestModel.fromEntity(request),
    );
  }

  @override
  Future<List<Appointment>> getMyAppointments() =>
      _datasource.getMyAppointments();

  @override
  Future<List<AppointmentSlot>> getSlots(SlotsQuery query) =>
      _datasource.getSlots(query);
}
