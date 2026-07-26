import 'package:civic_app/core/providers/api_client_provider.dart';
import 'package:civic_app/features/appointments/data/datasources/appointment_api_datasource.dart';
import 'package:civic_app/features/appointments/data/repositories/appointment_repository_impl.dart';
import 'package:civic_app/features/appointments/domain/repositories/appointment_repository.dart';
import 'package:civic_app/features/appointments/domain/usecases/create_appointment_usecase.dart';
import 'package:civic_app/features/appointments/domain/usecases/get_my_appointments_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final appointmentDatasourceProvider = Provider<AppointmentApiDatasource>((
  ref,
) {
  return AppointmentApiDatasource(ref.watch(apiClientProvider));
});

final appointmentRepositoryProvider = Provider<AppointmentRepository>((ref) {
  return AppointmentRepositoryImpl(ref.watch(appointmentDatasourceProvider));
});

final createAppointmentUseCaseProvider = Provider<CreateAppointmentUseCase>((
  ref,
) {
  return CreateAppointmentUseCase(ref.watch(appointmentRepositoryProvider));
});

final getMyAppointmentsUseCaseProvider = Provider<GetMyAppointmentsUseCase>((
  ref,
) {
  return GetMyAppointmentsUseCase(ref.watch(appointmentRepositoryProvider));
});
