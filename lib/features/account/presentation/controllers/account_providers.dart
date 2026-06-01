import 'package:civic_app/core/providers/auth_provider.dart';
import 'package:civic_app/core/providers/supabase_provider.dart';
import 'package:civic_app/features/account/data/datasources/account_supabase_datasource.dart';
import 'package:civic_app/features/account/data/repositories/account_repository_impl.dart';
import 'package:civic_app/features/account/domain/entities/user_profile.dart';
import 'package:civic_app/features/account/domain/repositories/account_repository.dart';
import 'package:civic_app/features/account/domain/usecases/delete_account_usecase.dart';
import 'package:civic_app/features/account/domain/usecases/get_user_appointments_usecase.dart';
import 'package:civic_app/features/account/domain/usecases/get_user_profile_usecase.dart';
import 'package:civic_app/features/account/domain/usecases/update_city_usecase.dart';
import 'package:civic_app/features/appointments/domain/entities/appointment.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final accountDatasourceProvider = Provider<AccountSupabaseDatasource>((ref) {
  return AccountSupabaseDatasource(ref.watch(supabaseClientProvider));
});

final accountRepositoryProvider = Provider<AccountRepository>((ref) {
  return AccountRepositoryImpl(ref.watch(accountDatasourceProvider));
});

final getUserProfileUseCaseProvider = Provider<GetUserProfileUseCase>((ref) {
  return GetUserProfileUseCase(ref.watch(accountRepositoryProvider));
});

final updateCityUseCaseProvider = Provider<UpdateCityUseCase>((ref) {
  return UpdateCityUseCase(ref.watch(accountRepositoryProvider));
});

final deleteAccountUseCaseProvider = Provider<DeleteAccountUseCase>((ref) {
  return DeleteAccountUseCase(ref.watch(accountRepositoryProvider));
});

final getUserAppointmentsUseCaseProvider =
    Provider<GetUserAppointmentsUseCase>((ref) {
      return GetUserAppointmentsUseCase(ref.watch(accountRepositoryProvider));
    });

final userProfileProvider = FutureProvider.autoDispose<UserProfile?>((ref) {
  return ref.watch(getUserProfileUseCaseProvider).call();
});

final userAppointmentsProvider =
    FutureProvider.autoDispose<List<Appointment>>((ref) async {
      final auth = ref.watch(authStateProvider);
      final email = auth.valueOrNull?.email;
      if (email == null) return [];
      return ref.watch(getUserAppointmentsUseCaseProvider).call(email);
    });
