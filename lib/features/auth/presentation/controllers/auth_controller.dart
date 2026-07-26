import 'package:civic_app/features/auth/domain/usecases/sign_in_usecase.dart';
import 'package:civic_app/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:civic_app/features/auth/domain/usecases/sign_up_usecase.dart';
import 'package:civic_app/features/auth/presentation/controllers/auth_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthController extends StateNotifier<AsyncValue<void>> {
  AuthController(this._ref, this._signIn, this._signUp, this._signOut)
    : super(const AsyncData(null));

  final Ref _ref;
  final SignInUseCase _signIn;
  final SignUpUseCase _signUp;
  final SignOutUseCase _signOut;

  Future<void> signIn({required String email, required String password}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => _signIn(email: email, password: password),
    );
    if (!state.hasError) {
      await _ref.read(authStateProvider.notifier).refresh();
    }
  }

  Future<void> signUp({required String email, required String password}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => _signUp(email: email, password: password),
    );
    if (!state.hasError) {
      await _ref.read(authStateProvider.notifier).refresh();
    }
  }

  Future<void> signOut() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _signOut());
    if (!state.hasError) {
      await _ref.read(authStateProvider.notifier).refresh();
    }
  }
}

final authControllerProvider =
    StateNotifierProvider.autoDispose<AuthController, AsyncValue<void>>((ref) {
      return AuthController(
        ref,
        ref.watch(signInUseCaseProvider),
        ref.watch(signUpUseCaseProvider),
        ref.watch(signOutUseCaseProvider),
      );
    });
