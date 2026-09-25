import 'package:civic_app/core/errors/app_exception.dart';
import 'package:civic_app/features/auth/domain/entities/citizen_session.dart';
import 'package:civic_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:civic_app/features/auth/presentation/controllers/auth_providers.dart';
import 'package:civic_app/features/auth/presentation/controllers/password_reset_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _Repository implements AuthRepository {
  int requests = 0;
  int resets = 0;
  Object? error;

  @override
  Future<void> requestPasswordReset({required String email}) async {
    requests++;
    if (error != null) throw error!;
  }

  @override
  Future<void> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    resets++;
    if (error != null) throw error!;
  }

  @override
  Future<void> signIn({
    required String email,
    required String password,
  }) async {}

  @override
  Future<void> signUp({
    required String email,
    required String password,
    required String communeSlug,
    required bool acceptedTerms,
    String? invitationCode,
  }) async {}

  @override
  Future<void> signOut() async {}

  @override
  Future<CitizenSession> changeCommune(String communeSlug) =>
      throw UnimplementedError();
}

void main() {
  late _Repository repository;
  late ProviderContainer container;

  setUp(() {
    repository = _Repository();
    container = ProviderContainer(
      overrides: [authRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);
    container.listen(passwordResetControllerProvider, (_, _) {});
  });

  PasswordResetController controller() =>
      container.read(passwordResetControllerProvider.notifier);

  test('requestCode reports success and leaves no error', () async {
    final sent = await controller().requestCode(email: 'martine@example.fr');

    expect(sent, isTrue);
    expect(repository.requests, 1);
    expect(container.read(passwordResetControllerProvider).hasError, isFalse);
  });

  test(
    'requestCode reports failure and keeps the error for the page to show',
    () async {
      repository.error = const RateLimitException();

      final sent = await controller().requestCode(email: 'martine@example.fr');

      expect(sent, isFalse);
      expect(container.read(passwordResetControllerProvider).hasError, isTrue);
    },
  );

  test('resetPassword reports success', () async {
    final done = await controller().resetPassword(
      email: 'martine@example.fr',
      code: 'K7QM-2XPD',
      newPassword: 'nouveau-mot-de-passe',
    );

    expect(done, isTrue);
    expect(repository.resets, 1);
  });

  test('resetPassword reports a refused code as a failure', () async {
    repository.error = const DatabaseException(
      'Ce code est invalide ou a expiré.',
    );

    final done = await controller().resetPassword(
      email: 'martine@example.fr',
      code: 'WRONG',
      newPassword: 'nouveau-mot-de-passe',
    );

    expect(done, isFalse);
    expect(
      (container.read(passwordResetControllerProvider).error as AppException)
          .message,
      'Ce code est invalide ou a expiré.',
    );
  });
}
