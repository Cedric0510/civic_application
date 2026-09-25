import 'package:civic_app/core/auth/token_storage.dart';
import 'package:civic_app/core/network/api_client.dart';
import 'package:civic_app/features/auth/data/datasources/auth_api_datasource.dart';
import 'package:civic_app/features/auth/domain/entities/citizen_session.dart';
import 'package:civic_app/features/auth/domain/entities/commune_ref.dart';
import 'package:civic_app/features/auth/domain/entities/sign_up_outcome.dart';
import 'package:civic_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:civic_app/features/auth/presentation/controllers/auth_providers.dart';
import 'package:civic_app/features/auth/presentation/pages/auth_page.dart';
import 'package:civic_app/features/auth/presentation/pages/verify_email_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import '../../support/preferences_override.dart';

const _bessan = CommuneRef(id: 'c1', name: 'Bessan', slug: 'bessan');
const _email = 'martine@boulangerie.fr';

class _Repository implements AuthRepository {
  SignUpOutcome outcome = SignUpNeedsVerification(
    email: _email,
    expiresAt: DateTime(2100),
    resendAvailableAt: DateTime(2100),
  );
  int signUpCalls = 0;
  final List<String> verifiedCodes = [];

  @override
  Future<SignUpOutcome> signUp({
    required String email,
    required String password,
    required String communeSlug,
    required bool acceptedTerms,
    String? invitationCode,
  }) async {
    signUpCalls++;
    return outcome;
  }

  @override
  Future<void> verifySignUp({
    required String email,
    required String code,
  }) async {
    verifiedCodes.add(code);
  }

  @override
  Future<SignUpNeedsVerification> resendSignUpCode({required String email}) =>
      throw UnimplementedError();

  @override
  Future<void> signIn({required String email, required String password}) =>
      throw UnimplementedError();

  @override
  Future<void> requestPasswordReset({required String email}) =>
      throw UnimplementedError();

  @override
  Future<void> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) => throw UnimplementedError();

  @override
  Future<void> signOut() => throw UnimplementedError();

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

Future<_Repository> _open(WidgetTester tester) async {
  tester.view.physicalSize = const Size(800, 2600);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  final repository = _Repository();
  final router = GoRouter(
    initialLocation: '/auth',
    routes: [
      GoRoute(path: '/auth', builder: (_, _) => const AuthPage()),
      GoRoute(
        path: '/verify-email',
        builder: (_, state) => VerifyEmailPage(
          email: state.uri.queryParameters['email']!,
          resendAvailableAt: state.extra as DateTime?,
        ),
      ),
      GoRoute(path: '/home', builder: (_, _) => const Text('Accueil')),
    ],
  );
  addTearDown(router.dispose);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(repository),
        authDatasourceProvider.overrideWithValue(_SignedOutDatasource()),
        publicCommunesProvider.overrideWith((ref) async => [_bessan]),
        await preferencesOverride(),
      ],
      child: MaterialApp.router(routerConfig: router),
    ),
  );
  await tester.pumpAndSettle();
  await tester.tap(find.text('Pas encore de compte ? S\'inscrire'));
  await tester.pumpAndSettle();
  return repository;
}

Future<void> _fillSignUp(WidgetTester tester) async {
  await tester.enterText(
    find.widgetWithText(TextFormField, 'Adresse e-mail'),
    _email,
  );
  await tester.enterText(
    find.widgetWithText(TextFormField, 'Confirmer l\'adresse e-mail'),
    _email,
  );
  await tester.enterText(
    find.widgetWithText(TextFormField, 'Mot de passe'),
    'motdepasse1',
  );
  await tester.enterText(
    find.widgetWithText(TextFormField, 'Confirmer le mot de passe'),
    'motdepasse1',
  );
  await tester.tap(find.byType(DropdownButtonFormField<CommuneRef>));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Bessan').last);
  await tester.pumpAndSettle();
  await tester.tap(find.byType(CheckboxListTile));
  await tester.pumpAndSettle();
}

Future<void> _submit(WidgetTester tester) async {
  await tester.tap(find.widgetWithText(FilledButton, 'Créer un compte'));
  await tester.pumpAndSettle();
}

void main() {
  group('sign-up with an e-mail code', () {
    testWidgets('leads to the code page instead of opening the account', (
      tester,
    ) async {
      final repository = await _open(tester);
      await _fillSignUp(tester);

      await _submit(tester);

      expect(repository.signUpCalls, 1);
      expect(find.text('Vérification de l\'adresse'), findsOneWidget);
      expect(find.text(_email), findsOneWidget);
      expect(find.text('Accueil'), findsNothing);
    });

    testWidgets('finishes with the code received by e-mail', (tester) async {
      final repository = await _open(tester);
      await _fillSignUp(tester);
      await _submit(tester);

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Code de vérification'),
        'K7QM-2XPD',
      );
      await tester.tap(
        find.widgetWithText(FilledButton, 'Valider mon adresse'),
      );
      await tester.pumpAndSettle();

      expect(repository.verifiedCodes, ['K7QM-2XPD']);
    });

    testWidgets('lets the person go back and fix the sign-up form', (
      tester,
    ) async {
      await _open(tester);
      await _fillSignUp(tester);
      await _submit(tester);

      await tester.tap(find.byTooltip('Modifier mon inscription'));
      await tester.pumpAndSettle();

      expect(find.text('Connexion'), findsOneWidget);
    });

    testWidgets(
      'skips the code page when an invitation already proved the address',
      (tester) async {
        final repository = await _open(tester);
        repository.outcome = const SignUpCompleted();
        await _fillSignUp(tester);

        await _submit(tester);

        expect(repository.signUpCalls, 1);
        expect(find.text('Vérification de l\'adresse'), findsNothing);
      },
    );

    testWidgets('opens the code page for someone who already has a code', (
      tester,
    ) async {
      await _open(tester);
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Adresse e-mail'),
        _email,
      );

      await tester.tap(find.text('J\'ai déjà reçu mon code par e-mail'));
      await tester.pumpAndSettle();

      expect(find.text('Vérification de l\'adresse'), findsOneWidget);
      expect(find.text(_email), findsOneWidget);
      final resend = tester.widget<TextButton>(
        find.ancestor(
          of: find.text('Renvoyer le code'),
          matching: find.byType(TextButton),
        ),
      );
      expect(resend.onPressed, isNotNull);
    });

    testWidgets('asks for the address first when the field is empty', (
      tester,
    ) async {
      await _open(tester);

      await tester.tap(find.text('J\'ai déjà reçu mon code par e-mail'));
      await tester.pumpAndSettle();

      expect(
        find.text('Saisissez d\'abord votre adresse e-mail.'),
        findsOneWidget,
      );
      expect(find.text('Vérification de l\'adresse'), findsNothing);
    });
  });
}
