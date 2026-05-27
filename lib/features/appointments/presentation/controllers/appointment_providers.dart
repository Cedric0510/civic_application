import 'package:civic_app/core/providers/supabase_provider.dart';
import 'package:civic_app/features/appointments/data/datasources/appointment_supabase_datasource.dart';
import 'package:civic_app/features/appointments/data/repositories/appointment_repository_impl.dart';
import 'package:civic_app/features/appointments/domain/repositories/appointment_repository.dart';
import 'package:civic_app/features/appointments/domain/usecases/create_appointment_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final appointmentDatasourceProvider = Provider<AppointmentSupabaseDatasource>((
  ref,
) {
  return AppointmentSupabaseDatasource(ref.watch(supabaseClientProvider));
});

final appointmentRepositoryProvider = Provider<AppointmentRepository>((ref) {
  return AppointmentRepositoryImpl(ref.watch(appointmentDatasourceProvider));
});

final createAppointmentUseCaseProvider = Provider<CreateAppointmentUseCase>((
  ref,
) {
  return CreateAppointmentUseCase(ref.watch(appointmentRepositoryProvider));
});
