import 'package:civic_app/core/providers/api_client_provider.dart';
import 'package:civic_app/features/account/data/datasources/account_api_datasource.dart';
import 'package:civic_app/features/account/data/repositories/account_repository_impl.dart';
import 'package:civic_app/features/account/domain/entities/user_profile.dart';
import 'package:civic_app/features/account/domain/repositories/account_repository.dart';
import 'package:civic_app/features/account/domain/usecases/delete_account_usecase.dart';
import 'package:civic_app/features/account/domain/usecases/get_user_profile_usecase.dart';
import 'package:civic_app/features/appointments/domain/entities/appointment.dart';
import 'package:civic_app/features/appointments/presentation/controllers/appointment_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final accountDatasourceProvider = Provider<AccountApiDatasource>((ref) {
  return AccountApiDatasource(ref.watch(apiClientProvider));
});

final accountRepositoryProvider = Provider<AccountRepository>((ref) {
  return AccountRepositoryImpl(ref.watch(accountDatasourceProvider));
});

final getUserProfileUseCaseProvider = Provider<GetUserProfileUseCase>((ref) {
  return GetUserProfileUseCase(ref.watch(accountRepositoryProvider));
});

final deleteAccountUseCaseProvider = Provider<DeleteAccountUseCase>((ref) {
  return DeleteAccountUseCase(ref.watch(accountRepositoryProvider));
});

final userProfileProvider = FutureProvider.autoDispose<UserProfile?>((ref) {
  return ref.watch(getUserProfileUseCaseProvider).call();
});

final userAppointmentsProvider = FutureProvider.autoDispose<List<Appointment>>(
  (ref) {
    return ref.watch(getMyAppointmentsUseCaseProvider).call();
  },
);
