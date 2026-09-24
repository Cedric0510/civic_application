import 'package:civic_app/core/providers/api_client_provider.dart';
import 'package:civic_app/features/appointments/data/datasources/appointment_api_datasource.dart';
import 'package:civic_app/features/appointments/data/repositories/appointment_repository_impl.dart';
import 'package:civic_app/features/appointments/domain/entities/appointment_slot.dart';
import 'package:civic_app/features/appointments/domain/entities/slots_query.dart';
import 'package:civic_app/features/appointments/domain/repositories/appointment_repository.dart';
import 'package:civic_app/features/appointments/domain/usecases/create_appointment_usecase.dart';
import 'package:civic_app/features/appointments/domain/usecases/get_appointment_slots_usecase.dart';
import 'package:civic_app/features/appointments/domain/usecases/get_my_appointments_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const slotsHorizonDays = 30;

final appointmentDatasourceProvider = Provider<AppointmentApiDatasource>((ref) {
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

final getAppointmentSlotsUseCaseProvider = Provider<GetAppointmentSlotsUseCase>(
  (ref) {
    return GetAppointmentSlotsUseCase(ref.watch(appointmentRepositoryProvider));
  },
);

final appointmentSlotsProvider = FutureProvider.autoDispose
    .family<List<AppointmentSlot>, String>((ref, serviceId) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      return ref.watch(getAppointmentSlotsUseCaseProvider)(
        SlotsQuery(
          serviceId: serviceId,
          from: today,
          to: today.add(const Duration(days: slotsHorizonDays)),
        ),
      );
    });
