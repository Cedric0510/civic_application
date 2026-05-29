import 'package:civic_app/core/providers/supabase_provider.dart';
import 'package:civic_app/features/auth/data/datasources/auth_supabase_datasource.dart';
import 'package:civic_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:civic_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:civic_app/features/auth/domain/usecases/sign_in_usecase.dart';
import 'package:civic_app/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:civic_app/features/auth/domain/usecases/sign_up_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authDatasourceProvider = Provider<AuthSupabaseDatasource>((ref) {
  return AuthSupabaseDatasource(ref.watch(supabaseClientProvider));
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(ref.watch(authDatasourceProvider));
});

final signInUseCaseProvider = Provider<SignInUseCase>((ref) {
  return SignInUseCase(ref.watch(authRepositoryProvider));
});

final signUpUseCaseProvider = Provider<SignUpUseCase>((ref) {
  return SignUpUseCase(ref.watch(authRepositoryProvider));
});

final signOutUseCaseProvider = Provider<SignOutUseCase>((ref) {
  return SignOutUseCase(ref.watch(authRepositoryProvider));
});
