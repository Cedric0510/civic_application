import 'package:civic_app/features/auth/domain/entities/sign_up_outcome.dart';
import 'package:civic_app/features/auth/domain/usecases/resend_sign_up_code_usecase.dart';
import 'package:civic_app/features/auth/domain/usecases/sign_in_usecase.dart';
import 'package:civic_app/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:civic_app/features/auth/domain/usecases/sign_up_usecase.dart';
import 'package:civic_app/features/auth/domain/usecases/verify_sign_up_usecase.dart';
import 'package:civic_app/features/auth/presentation/controllers/auth_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthController extends StateNotifier<AsyncValue<void>> {
  AuthController(
    this._ref,
    this._signIn,
    this._signUp,
    this._verifySignUp,
    this._resendSignUpCode,
    this._signOut,
  ) : super(const AsyncData(null));

  final Ref _ref;
  final SignInUseCase _signIn;
  final SignUpUseCase _signUp;
  final VerifySignUpUseCase _verifySignUp;
  final ResendSignUpCodeUseCase _resendSignUpCode;
  final SignOutUseCase _signOut;

  Future<void> signIn({required String email, required String password}) {
    return _run(() => _signIn(email: email, password: password));
  }

  Future<SignUpNeedsVerification?> signUp({
    required String email,
    required String password,
    required String communeSlug,
    required bool acceptedTerms,
    String? invitationCode,
  }) async {
    SignUpOutcome? outcome;
    await _run(() async {
      outcome = await _signUp(
        email: email,
        password: password,
        communeSlug: communeSlug,
        acceptedTerms: acceptedTerms,
        invitationCode: invitationCode,
      );
    }, startsSession: () => outcome is SignUpCompleted);
    final result = outcome;
    return result is SignUpNeedsVerification && !state.hasError ? result : null;
  }

  Future<void> verifySignUp({required String email, required String code}) {
    return _run(() => _verifySignUp(email: email, code: code));
  }

  Future<SignUpNeedsVerification?> resendSignUpCode({
    required String email,
  }) async {
    SignUpNeedsVerification? sent;
    await _run(() async {
      sent = await _resendSignUpCode(email: email);
    }, startsSession: () => false);
    return state.hasError ? null : sent;
  }

  Future<void> signOut() => _run(() => _signOut());

  Future<void> _run(
    Future<void> Function() action, {
    bool Function()? startsSession,
  }) async {
    final keepAlive = _ref.keepAlive();
    try {
      state = const AsyncLoading();
      state = await AsyncValue.guard(action);
      if (!state.hasError && (startsSession?.call() ?? true)) {
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
        ref.watch(verifySignUpUseCaseProvider),
        ref.watch(resendSignUpCodeUseCaseProvider),
        ref.watch(signOutUseCaseProvider),
      );
    });
