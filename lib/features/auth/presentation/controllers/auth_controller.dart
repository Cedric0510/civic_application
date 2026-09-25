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

  Future<void> signIn({required String email, required String password}) {
    return _run(() => _signIn(email: email, password: password));
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String communeSlug,
    required bool acceptedTerms,
    String? invitationCode,
  }) {
    return _run(
      () => _signUp(
        email: email,
        password: password,
        communeSlug: communeSlug,
        acceptedTerms: acceptedTerms,
        invitationCode: invitationCode,
      ),
    );
  }

  Future<void> signOut() => _run(() => _signOut());

  Future<void> _run(Future<void> Function() action) async {
    final keepAlive = _ref.keepAlive();
    try {
      state = const AsyncLoading();
      state = await AsyncValue.guard(action);
      if (!state.hasError) {
        await _ref.read(authStateProvider.notifier).refresh();
      }
    } finally {
      keepAlive.close();
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
