import 'package:civic_app/core/auth/token_storage.dart';
import 'package:civic_app/core/network/api_client.dart';
import 'package:civic_app/features/auth/data/datasources/auth_api_datasource.dart';
import 'package:civic_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:civic_app/features/auth/presentation/controllers/auth_controller.dart';
import 'package:civic_app/features/auth/presentation/controllers/auth_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

class _FakeAuthRepository implements AuthRepository {
  int signInCalls = 0;
  int signUpCalls = 0;
  int signOutCalls = 0;
  String? lastEmail;
  String? lastPassword;

  Object? signInError;
  Object? signUpError;
  Object? signOutError;

  @override
  Future<void> signIn({required String email, required String password}) async {
    signInCalls++;
    lastEmail = email;
    lastPassword = password;
    if (signInError != null) throw signInError!;
  }

  @override
  Future<void> signUp({required String email, required String password}) async {
    signUpCalls++;
    lastEmail = email;
    lastPassword = password;
    if (signUpError != null) throw signUpError!;
  }

  @override
  Future<void> signOut() async {
    signOutCalls++;
    if (signOutError != null) throw signOutError!;
  }
}

// hasValidSession() is overridden below, so the ApiClient/TokenStorage
// passed to super() are never actually exercised -- placeholders only.
class _FakeAuthDatasource extends AuthApiDatasource {
  _FakeAuthDatasource(this.sessionValid)
    : super(
        ApiClient(
          MockClient((_) async => http.Response('{}', 200)),
          TokenStorage(),
        ),
        TokenStorage(),
      );

  bool sessionValid;
  int hasValidSessionCalls = 0;

  @override
  Future<bool> hasValidSession() async {
    hasValidSessionCalls++;
    return sessionValid;
  }
}

void main() {
  late _FakeAuthRepository fakeRepo;
  late _FakeAuthDatasource fakeDatasource;
  late ProviderContainer container;

  setUp(() {
    fakeRepo = _FakeAuthRepository();
    fakeDatasource = _FakeAuthDatasource(false);
    container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(fakeRepo),
        authDatasourceProvider.overrideWithValue(fakeDatasource),
      ],
    );
    addTearDown(container.dispose);
    // Keeps the autoDispose authControllerProvider alive for the test.
    container.listen(authControllerProvider, (_, _) {});
  });

  test(
    'authStateProvider resolves to the datasource session validity',
    () async {
      fakeDatasource.sessionValid = true;

      await container.read(authStateProvider.notifier).refresh();

      expect(container.read(authStateProvider).value, isTrue);
    },
  );

  test(
    'signIn forwards credentials and leaves state error-free on success',
    () async {
      await container
          .read(authControllerProvider.notifier)
          .signIn(email: 'a@b.com', password: 'secret123');

      expect(fakeRepo.signInCalls, 1);
      expect(fakeRepo.lastEmail, 'a@b.com');
      expect(fakeRepo.lastPassword, 'secret123');
      expect(container.read(authControllerProvider).hasError, isFalse);
    },
  );

  test('a successful signIn triggers an authStateProvider refresh', () async {
    final callsBefore = fakeDatasource.hasValidSessionCalls;

    await container
        .read(authControllerProvider.notifier)
        .signIn(email: 'a@b.com', password: 'secret123');

    expect(fakeDatasource.hasValidSessionCalls, greaterThan(callsBefore));
  });

  test(
    'a failed signIn surfaces the error and does not refresh session state',
    () async {
      fakeRepo.signInError = Exception('Identifiants invalides.');
      final callsBefore = fakeDatasource.hasValidSessionCalls;

      await container
          .read(authControllerProvider.notifier)
          .signIn(email: 'a@b.com', password: 'wrong');

      expect(container.read(authControllerProvider).hasError, isTrue);
      expect(fakeDatasource.hasValidSessionCalls, callsBefore);
    },
  );

  test(
    'signUp forwards credentials and leaves state error-free on success',
    () async {
      await container
          .read(authControllerProvider.notifier)
          .signUp(email: 'new@b.com', password: 'secret123');

      expect(fakeRepo.signUpCalls, 1);
      expect(fakeRepo.lastEmail, 'new@b.com');
      expect(container.read(authControllerProvider).hasError, isFalse);
    },
  );

  test(
    'a failed signUp surfaces the error and does not refresh session state',
    () async {
      fakeRepo.signUpError = Exception('Email déjà utilisé.');
      final callsBefore = fakeDatasource.hasValidSessionCalls;

      await container
          .read(authControllerProvider.notifier)
          .signUp(email: 'dup@b.com', password: 'secret123');

      expect(container.read(authControllerProvider).hasError, isTrue);
      expect(fakeDatasource.hasValidSessionCalls, callsBefore);
    },
  );

  test(
    'signOut clears state and triggers an authStateProvider refresh on success',
    () async {
      final callsBefore = fakeDatasource.hasValidSessionCalls;

      await container.read(authControllerProvider.notifier).signOut();

      expect(fakeRepo.signOutCalls, 1);
      expect(container.read(authControllerProvider).hasError, isFalse);
      expect(fakeDatasource.hasValidSessionCalls, greaterThan(callsBefore));
    },
  );
}
