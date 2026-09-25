import 'package:civic_app/core/errors/app_exception.dart';
import 'package:civic_app/core/auth/token_storage.dart';
import 'package:civic_app/core/network/api_client.dart';
import 'package:civic_app/features/auth/data/datasources/auth_api_datasource.dart';
import 'package:civic_app/features/auth/domain/entities/citizen_session.dart';
import 'package:civic_app/features/auth/domain/entities/commune_ref.dart';
import 'package:civic_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:civic_app/features/auth/presentation/controllers/auth_controller.dart';
import 'package:civic_app/features/auth/presentation/controllers/auth_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

const _testCommune = CommuneRef(
  id: 'commune-1',
  name: 'Saint-Martin-de-Belleville',
  slug: 'saint-martin-de-belleville',
);
const _testSession = CitizenSession(
  commune: _testCommune,
  role: CitizenRole.user,
);

class _FakeAuthRepository implements AuthRepository {
  int signInCalls = 0;
  int signUpCalls = 0;
  int signOutCalls = 0;
  String? lastEmail;
  String? lastPassword;
  String? lastCommuneSlug;
  String? lastInvitationCode;
  bool? lastAcceptedTerms;

  Object? signInError;
  Object? signUpError;
  Object? signOutError;
  Duration? signOutDelay;

  @override
  Future<void> signIn({required String email, required String password}) async {
    signInCalls++;
    lastEmail = email;
    lastPassword = password;
    if (signInError != null) throw signInError!;
  }

  @override
  Future<void> signUp({
    required String email,
    required String password,
    required String communeSlug,
    required bool acceptedTerms,
    String? invitationCode,
  }) async {
    signUpCalls++;
    lastEmail = email;
    lastPassword = password;
    lastCommuneSlug = communeSlug;
    lastInvitationCode = invitationCode;
    lastAcceptedTerms = acceptedTerms;
    if (signUpError != null) throw signUpError!;
  }

  @override
  Future<void> requestPasswordReset({required String email}) async {}

  @override
  Future<void> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {}

  @override
  Future<void> signOut() async {
    if (signOutDelay != null) await Future<void>.delayed(signOutDelay!);
    signOutCalls++;
    if (signOutError != null) throw signOutError!;
  }

  @override
  Future<CitizenSession> changeCommune(String communeSlug) async =>
      _testSession;
}

// fetchSession() is overridden below, so the ApiClient/TokenStorage passed
// to super() are never actually exercised -- placeholders only.
class _FakeAuthDatasource extends AuthApiDatasource {
  _FakeAuthDatasource(this.session)
    : super(
        ApiClient(
          MockClient((_) async => http.Response('{}', 200)),
          TokenStorage(),
        ),
        TokenStorage(),
      );

  CitizenSession? session;
  CitizenSession? liveSession;
  Object? liveError;
  int fetchSessionCalls = 0;

  @override
  Future<CitizenSession> fetchLiveSession() async {
    if (liveError != null) throw liveError!;
    return liveSession!;
  }

  @override
  Future<CitizenSession?> fetchSession() async {
    fetchSessionCalls++;
    return session;
  }
}

void main() {
  late _FakeAuthRepository fakeRepo;
  late _FakeAuthDatasource fakeDatasource;
  late ProviderContainer container;

  setUp(() {
    fakeRepo = _FakeAuthRepository();
    fakeDatasource = _FakeAuthDatasource(null);
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
    'authStateProvider resolves to the session returned by the datasource',
    () async {
      fakeDatasource.session = _testSession;

      await container.read(authStateProvider.notifier).refresh();

      expect(container.read(authStateProvider).value, _testSession);
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
    final callsBefore = fakeDatasource.fetchSessionCalls;

    await container
        .read(authControllerProvider.notifier)
        .signIn(email: 'a@b.com', password: 'secret123');

    expect(fakeDatasource.fetchSessionCalls, greaterThan(callsBefore));
  });

  test(
    'a failed signIn surfaces the error and does not refresh session state',
    () async {
      fakeRepo.signInError = Exception('Identifiants invalides.');
      final callsBefore = fakeDatasource.fetchSessionCalls;

      await container
          .read(authControllerProvider.notifier)
          .signIn(email: 'a@b.com', password: 'wrong');

      expect(container.read(authControllerProvider).hasError, isTrue);
      expect(fakeDatasource.fetchSessionCalls, callsBefore);
    },
  );

  test(
    'signUp forwards credentials and the chosen commune, leaves state error-free on success',
    () async {
      await container
          .read(authControllerProvider.notifier)
          .signUp(
            email: 'new@b.com',
            password: 'secret123',
            communeSlug: 'bessan',
            acceptedTerms: true,
          );

      expect(fakeRepo.signUpCalls, 1);
      expect(fakeRepo.lastEmail, 'new@b.com');
      expect(fakeRepo.lastCommuneSlug, 'bessan');
      expect(container.read(authControllerProvider).hasError, isFalse);
    },
  );

  test('signUp forwards the invitation code of a future commerçant', () async {
    await container
        .read(authControllerProvider.notifier)
        .signUp(
          email: 'martine@boulangerie.fr',
          password: 'secret123',
          communeSlug: 'bessan',
          acceptedTerms: true,
          invitationCode: 'K7QM-2XPD',
        );

    expect(fakeRepo.lastInvitationCode, 'K7QM-2XPD');
  });

  test('signUp forwards the consent given on the form', () async {
    await container
        .read(authControllerProvider.notifier)
        .signUp(
          email: 'new@b.com',
          password: 'secret123',
          communeSlug: 'bessan',
          acceptedTerms: true,
        );

    expect(fakeRepo.lastAcceptedTerms, isTrue);
  });

  test('signUp sends no invitation code by default', () async {
    await container
        .read(authControllerProvider.notifier)
        .signUp(
          email: 'new@b.com',
          password: 'secret123',
          communeSlug: 'bessan',
          acceptedTerms: true,
        );

    expect(fakeRepo.lastInvitationCode, isNull);
  });

  test(
    'a failed signUp surfaces the error and does not refresh session state',
    () async {
      fakeRepo.signUpError = Exception('Email déjà utilisé.');
      final callsBefore = fakeDatasource.fetchSessionCalls;

      await container
          .read(authControllerProvider.notifier)
          .signUp(
            email: 'dup@b.com',
            password: 'secret123',
            communeSlug: 'bessan',
            acceptedTerms: true,
          );

      expect(container.read(authControllerProvider).hasError, isTrue);
      expect(fakeDatasource.fetchSessionCalls, callsBefore);
    },
  );

  test(
    'signOut clears state and triggers an authStateProvider refresh on success',
    () async {
      final callsBefore = fakeDatasource.fetchSessionCalls;

      await container.read(authControllerProvider.notifier).signOut();

      expect(fakeRepo.signOutCalls, 1);
      expect(container.read(authControllerProvider).hasError, isFalse);
      expect(fakeDatasource.fetchSessionCalls, greaterThan(callsBefore));
    },
  );

  test(
    'signOut finishes, and refreshes the session, even when nothing listens to the controller any more',
    () async {
      final quietRepo = _FakeAuthRepository()
        ..signOutDelay = const Duration(milliseconds: 20);
      final datasource = _FakeAuthDatasource(null);
      final quiet = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(quietRepo),
          authDatasourceProvider.overrideWithValue(datasource),
        ],
      );
      addTearDown(quiet.dispose);
      quiet.read(authStateProvider);
      await pumpEventQueue();
      final before = datasource.fetchSessionCalls;

      await quiet.read(authControllerProvider.notifier).signOut();

      expect(quietRepo.signOutCalls, 1);
      expect(datasource.fetchSessionCalls, greaterThan(before));
    },
  );

  group('refreshQuietly', () {
    const commerce = ManagedCommerceRef(id: 'shop-1', name: 'Boulangerie');
    final promoted = CitizenSession(
      commune: _testCommune,
      role: CitizenRole.commercant,
      managedCommerce: commerce,
    );

    Future<void> signedIn() async {
      fakeDatasource.session = _testSession;
      await container.read(authStateProvider.notifier).refresh();
    }

    test(
      'picks up a role granted by the town hall, without ever showing a loading state',
      () async {
        await signedIn();
        fakeDatasource.liveSession = promoted;
        final seen = <AsyncValue<CitizenSession?>>[];
        container.listen(authStateProvider, (_, next) => seen.add(next));

        await container.read(authStateProvider.notifier).refreshQuietly();

        expect(container.read(authStateProvider).value, promoted);
        expect(container.read(authStateProvider).value!.isCommercant, isTrue);
        expect(seen.any((state) => state.isLoading), isFalse);
      },
    );

    test('keeps the current session when the phone is offline', () async {
      await signedIn();
      fakeDatasource.liveError = const NetworkException();

      await container.read(authStateProvider.notifier).refreshQuietly();

      expect(container.read(authStateProvider).value, _testSession);
    });

    test('does nothing while nobody is signed in', () async {
      fakeDatasource.session = null;
      await container.read(authStateProvider.notifier).refresh();
      fakeDatasource.liveSession = promoted;

      await container.read(authStateProvider.notifier).refreshQuietly();

      expect(container.read(authStateProvider).value, isNull);
    });

    test(
      'signs the person out when the server no longer accepts the session',
      () async {
        await signedIn();
        fakeDatasource.liveError = const AuthException('Session expirée.');
        fakeDatasource.session = null;

        await container.read(authStateProvider.notifier).refreshQuietly();

        expect(container.read(authStateProvider).value, isNull);
      },
    );
  });
}
