import 'package:civic_app/features/auth/domain/usecases/request_password_reset_usecase.dart';
import 'package:civic_app/features/auth/domain/usecases/reset_password_usecase.dart';
import 'package:civic_app/features/auth/presentation/controllers/auth_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PasswordResetController extends StateNotifier<AsyncValue<void>> {
  PasswordResetController(this._requestReset, this._reset)
    : super(const AsyncData(null));

  final RequestPasswordResetUseCase _requestReset;
  final ResetPasswordUseCase _reset;

  Future<bool> requestCode({required String email}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _requestReset(email: email));
    return !state.hasError;
  }

  Future<bool> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => _reset(email: email, code: code, newPassword: newPassword),
    );
    return !state.hasError;
  }
}

final passwordResetControllerProvider =
    StateNotifierProvider.autoDispose<
      PasswordResetController,
      AsyncValue<void>
    >((ref) {
      return PasswordResetController(
        ref.watch(requestPasswordResetUseCaseProvider),
        ref.watch(resetPasswordUseCaseProvider),
      );
    });
