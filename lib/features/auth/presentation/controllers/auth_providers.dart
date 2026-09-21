import 'package:civic_app/core/providers/api_client_provider.dart';
import 'package:civic_app/core/providers/token_storage_provider.dart';
import 'package:civic_app/features/auth/data/datasources/auth_api_datasource.dart';
import 'package:civic_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:civic_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:civic_app/features/auth/domain/usecases/sign_in_usecase.dart';
import 'package:civic_app/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:civic_app/features/auth/domain/usecases/sign_up_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authDatasourceProvider = Provider<AuthApiDatasource>((ref) {
  return AuthApiDatasource(
    ref.watch(apiClientProvider),
    ref.watch(tokenStorageProvider),
  );
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

// Identité de session (remplace l'ancien authStateProvider basé sur
// Supabase.instance.client.auth.onAuthStateChange). Pas de flux temps réel
// équivalent côté civic_api : on revalide le token stocké à la création, et
// AuthController demande un refresh explicite après signIn/signUp/signOut.
class AuthStateNotifier extends StateNotifier<AsyncValue<bool>> {
  AuthStateNotifier(this._datasource) : super(const AsyncLoading()) {
    refresh();
  }

  final AuthApiDatasource _datasource;

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _datasource.hasValidSession());
  }
}

final authStateProvider =
    StateNotifierProvider<AuthStateNotifier, AsyncValue<bool>>((ref) {
      return AuthStateNotifier(ref.watch(authDatasourceProvider));
    });
