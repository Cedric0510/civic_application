import 'package:civic_app/core/providers/api_client_provider.dart';
import 'package:civic_app/core/providers/token_storage_provider.dart';
import 'package:civic_app/features/auth/data/datasources/auth_api_datasource.dart';
import 'package:civic_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:civic_app/features/auth/domain/entities/citizen_session.dart';
import 'package:civic_app/features/auth/domain/entities/commune_ref.dart';
import 'package:civic_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:civic_app/features/auth/domain/usecases/change_commune_usecase.dart';
import 'package:civic_app/features/auth/domain/usecases/request_password_reset_usecase.dart';
import 'package:civic_app/features/auth/domain/usecases/reset_password_usecase.dart';
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

final requestPasswordResetUseCaseProvider =
    Provider<RequestPasswordResetUseCase>((ref) {
      return RequestPasswordResetUseCase(ref.watch(authRepositoryProvider));
    });

final resetPasswordUseCaseProvider = Provider<ResetPasswordUseCase>((ref) {
  return ResetPasswordUseCase(ref.watch(authRepositoryProvider));
});

final signOutUseCaseProvider = Provider<SignOutUseCase>((ref) {
  return SignOutUseCase(ref.watch(authRepositoryProvider));
});

final changeCommuneUseCaseProvider = Provider<ChangeCommuneUseCase>((ref) {
  return ChangeCommuneUseCase(ref.watch(authRepositoryProvider));
});

// Communes partenaires de City-Co -- alimente le sélecteur affiché à
// l'inscription (endpoint public, appelable avant toute authentification).
final publicCommunesProvider = FutureProvider<List<CommuneRef>>((ref) {
  return ref.read(authDatasourceProvider).fetchPublicCommunes();
});

// Identité de session : une valeur non-nulle porte la commune du citoyen
// connecté (détermine le contenu affiché dans le reste de l'appli) et son
// rôle éventuel de commerçant. Pas de flux temps réel côté civic_api : on
// revalide le token stocké à la création, et AuthController demande un
// refresh explicite après signIn/signUp/signOut.
class AuthStateNotifier extends StateNotifier<AsyncValue<CitizenSession?>> {
  AuthStateNotifier(this._datasource) : super(const AsyncLoading()) {
    refresh();
  }

  final AuthApiDatasource _datasource;

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _datasource.fetchSession());
  }

  // Sans passage par AsyncLoading : un changement de commune ne doit pas
  // renvoyer le citoyen vers /auth le temps d'un refresh.
  void updateSession(CitizenSession session) {
    state = AsyncData(session);
  }
}

final authStateProvider =
    StateNotifierProvider<AuthStateNotifier, AsyncValue<CitizenSession?>>((
      ref,
    ) {
      return AuthStateNotifier(ref.watch(authDatasourceProvider));
    });
