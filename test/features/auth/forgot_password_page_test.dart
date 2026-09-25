import 'package:civic_app/core/errors/app_exception.dart';
import 'package:civic_app/core/auth/token_storage.dart';
import 'package:civic_app/core/network/api_client.dart';
import 'package:civic_app/features/auth/data/datasources/auth_api_datasource.dart';
import 'package:civic_app/features/auth/domain/entities/citizen_session.dart';
import 'package:civic_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:civic_app/features/auth/presentation/controllers/auth_providers.dart';
import 'package:civic_app/features/auth/presentation/pages/auth_page.dart';
import 'package:civic_app/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

class _ResetRepository implements AuthRepository {
  final List<String> requestedFor = [];
  final List<Map<String, String>> resets = [];
  Object? requestError;
  Object? resetError;

  @override
  Future<void> requestPasswordReset({required String email}) async {
    requestedFor.add(email);
    if (requestError != null) throw requestError!;
  }

  @override
  Future<void> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    resets.add({'email': email, 'code': code, 'newPassword': newPassword});
    if (resetError != null) throw resetError!;
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
    String? invitationCode,
  }) async {}

  @override
  Future<void> signOut() async {}

  @override
  Future<CitizenSession> changeCommune(String communeSlug) =>
      throw UnimplementedError();
}

class _SignedOutDatasource extends AuthApiDatasource {
  _SignedOutDatasource()
    : super(
        ApiClient(
          MockClient((_) async => http.Response('{}', 200)),
          TokenStorage(),
        ),
        TokenStorage(),
      );

  @override
  Future<CitizenSession?> fetchSession() async => null;
}

Future<_ResetRepository> _open(
  WidgetTester tester, {
  String location = '/forgot-password',
}) async {
  tester.view.physicalSize = const Size(800, 2000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  final repository = _ResetRepository();
  final router = GoRouter(
    initialLocation: location,
    routes: [
      GoRoute(path: '/auth', builder: (_, _) => const AuthPage()),
      GoRoute(
        path: '/forgot-password',
        builder: (_, state) => ForgotPasswordPage(
          initialEmail: state.uri.queryParameters['email'],
        ),
      ),
    ],
  );
  addTearDown(router.dispose);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(repository),
        authDatasourceProvider.overrideWithValue(_SignedOutDatasource()),
      ],
      child: MaterialApp.router(routerConfig: router),
    ),
  );
  await tester.pumpAndSettle();
  return repository;
}

Future<void> _requestCodeFor(WidgetTester tester, String email) async {
  await tester.enterText(
    find.widgetWithText(TextFormField, 'Adresse e-mail'),
    email,
  );
  await tester.tap(find.widgetWithText(FilledButton, 'Envoyer le code'));
  await tester.pumpAndSettle();
}

Future<void> _fillReset(
  WidgetTester tester, {
  String code = 'K7QM-2XPD',
  String password = 'nouveau-mot-de-passe',
  String? confirmation,
}) async {
  await tester.enterText(
    find.widgetWithText(TextFormField, 'Code reçu par e-mail'),
    code,
  );
  await tester.enterText(
    find.widgetWithText(TextFormField, 'Nouveau mot de passe'),
    password,
  );
  await tester.enterText(
    find.widgetWithText(TextFormField, 'Confirmer le mot de passe'),
    confirmation ?? password,
  );
}

void main() {
  group('ForgotPasswordPage', () {
    testWidgets('starts by asking for the address, prefilled when known', (
      tester,
    ) async {
      await _open(
        tester,
        location: '/forgot-password?email=martine@example.fr',
      );

      expect(find.text('Envoyer le code'), findsOneWidget);
      expect(find.text('martine@example.fr'), findsOneWidget);
      expect(find.text('Code reçu par e-mail'), findsNothing);
    });

    testWidgets(
      'refuses an empty or malformed address without calling the server',
      (tester) async {
        final repository = await _open(tester);

        await tester.tap(find.widgetWithText(FilledButton, 'Envoyer le code'));
        await tester.pumpAndSettle();
        expect(find.text('L\'adresse e-mail est requise.'), findsOneWidget);

        await _requestCodeFor(tester, 'pas-une-adresse');
        expect(find.text('Entrez une adresse e-mail valide.'), findsOneWidget);
        expect(repository.requestedFor, isEmpty);
      },
    );

    testWidgets(
      'asks for the code, then moves on to choosing the new password',
      (tester) async {
        final repository = await _open(tester);

        await _requestCodeFor(tester, 'martine@example.fr');

        expect(repository.requestedFor, ['martine@example.fr']);
        expect(
          find.textContaining('Si un compte existe pour martine@example.fr'),
          findsOneWidget,
        );
        expect(find.text('Code reçu par e-mail'), findsOneWidget);
        expect(find.text('Changer le mot de passe'), findsOneWidget);
      },
    );

    testWidgets(
      'stays on the first step, and says why, when the code cannot be requested',
      (tester) async {
        final repository = await _open(tester);
        repository.requestError = const NetworkException();

        await _requestCodeFor(tester, 'martine@example.fr');

        expect(find.text('Code reçu par e-mail'), findsNothing);
        expect(find.text('Envoyer le code'), findsOneWidget);
      },
    );

    testWidgets(
      'resets the password with the code and goes back to the sign-in page',
      (tester) async {
        final repository = await _open(tester);
        await _requestCodeFor(tester, 'martine@example.fr');

        await _fillReset(tester, code: ' k7qm-2xpd ');
        await tester.tap(
          find.widgetWithText(FilledButton, 'Changer le mot de passe'),
        );
        await tester.pumpAndSettle();

        expect(repository.resets, [
          {
            'email': 'martine@example.fr',
            'code': 'k7qm-2xpd',
            'newPassword': 'nouveau-mot-de-passe',
          },
        ]);
        expect(find.text('Connexion'), findsOneWidget);
        expect(
          find.text('Mot de passe modifié. Connectez-vous avec le nouveau.'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'does not submit a short password, a missing code or two different passwords',
      (tester) async {
        final repository = await _open(tester);
        await _requestCodeFor(tester, 'martine@example.fr');

        await tester.tap(
          find.widgetWithText(FilledButton, 'Changer le mot de passe'),
        );
        await tester.pumpAndSettle();
        expect(find.text('Saisissez le code reçu par e-mail.'), findsOneWidget);
        expect(
          find.text('Le mot de passe doit contenir au moins 8 caractères.'),
          findsOneWidget,
        );

        await _fillReset(tester, password: 'court');
        await tester.tap(
          find.widgetWithText(FilledButton, 'Changer le mot de passe'),
        );
        await tester.pumpAndSettle();
        expect(
          find.text('Le mot de passe doit contenir au moins 8 caractères.'),
          findsOneWidget,
        );

        await _fillReset(tester, confirmation: 'autre-mot-de-passe');
        await tester.tap(
          find.widgetWithText(FilledButton, 'Changer le mot de passe'),
        );
        await tester.pumpAndSettle();
        expect(
          find.text('Les deux mots de passe ne correspondent pas.'),
          findsOneWidget,
        );
        expect(repository.resets, isEmpty);
      },
    );

    testWidgets(
      'keeps the form and shows the reason when the code is refused',
      (tester) async {
        final repository = await _open(tester);
        await _requestCodeFor(tester, 'martine@example.fr');
        repository.resetError = const DatabaseException(
          'Ce code est invalide ou a expiré.',
        );

        await _fillReset(tester);
        await tester.tap(
          find.widgetWithText(FilledButton, 'Changer le mot de passe'),
        );
        await tester.pumpAndSettle();

        expect(find.text('Ce code est invalide ou a expiré.'), findsOneWidget);
        expect(find.text('Code reçu par e-mail'), findsOneWidget);
        expect(find.text('Connexion'), findsNothing);
      },
    );

    testWidgets('can ask for the code again, or change the address', (
      tester,
    ) async {
      final repository = await _open(tester);
      await _requestCodeFor(tester, 'martine@example.fr');

      await tester.tap(find.text('Renvoyer un code'));
      await tester.pumpAndSettle();
      expect(repository.requestedFor, [
        'martine@example.fr',
        'martine@example.fr',
      ]);

      await tester.tap(find.text('Changer d\'adresse e-mail'));
      await tester.pumpAndSettle();
      expect(find.text('Envoyer le code'), findsOneWidget);
      expect(find.text('Code reçu par e-mail'), findsNothing);
    });
  });

  group('sign-in page link', () {
    testWidgets(
      'offers the forgotten-password page, carrying the typed address',
      (tester) async {
        await _open(tester, location: '/auth');

        expect(find.text('Mot de passe oublié ?'), findsOneWidget);
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Adresse e-mail'),
          'martine@example.fr',
        );
        await tester.tap(find.text('Mot de passe oublié ?'));
        await tester.pumpAndSettle();

        expect(find.text('Envoyer le code'), findsOneWidget);
        expect(find.text('martine@example.fr'), findsOneWidget);
      },
    );

    testWidgets('is not offered while creating an account', (tester) async {
      await _open(tester, location: '/auth');

      await tester.tap(find.text('Pas encore de compte ? S\'inscrire'));
      await tester.pumpAndSettle();

      expect(find.text('Mot de passe oublié ?'), findsNothing);
    });
  });
}
