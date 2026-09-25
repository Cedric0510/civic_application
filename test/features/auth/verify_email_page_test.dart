import 'package:civic_app/core/auth/token_storage.dart';
import 'package:civic_app/core/errors/app_exception.dart';
import 'package:civic_app/core/network/api_client.dart';
import 'package:civic_app/features/auth/data/datasources/auth_api_datasource.dart';
import 'package:civic_app/features/auth/domain/entities/citizen_session.dart';
import 'package:civic_app/features/auth/domain/entities/sign_up_outcome.dart';
import 'package:civic_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:civic_app/features/auth/presentation/controllers/auth_providers.dart';
import 'package:civic_app/features/auth/presentation/pages/verify_email_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import '../../support/app_harness.dart';

const _email = 'martine@boulangerie.fr';

class _VerificationRepository implements AuthRepository {
  final List<({String email, String code})> verified = [];
  int resendCalls = 0;
  Object? verifyError;
  Object? resendError;

  @override
  Future<void> verifySignUp({
    required String email,
    required String code,
  }) async {
    if (verifyError != null) throw verifyError!;
    verified.add((email: email, code: code));
  }

  @override
  Future<SignUpNeedsVerification> resendSignUpCode({
    required String email,
  }) async {
    if (resendError != null) throw resendError!;
    resendCalls++;
    return SignUpNeedsVerification(
      email: email,
      expiresAt: DateTime.now().add(const Duration(minutes: 30)),
      resendAvailableAt: DateTime.now().add(const Duration(seconds: 60)),
    );
  }

  @override
  Future<SignUpOutcome> signUp({
    required String email,
    required String password,
    required String communeSlug,
    required bool acceptedTerms,
    String? invitationCode,
  }) => throw UnimplementedError();

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

Future<_VerificationRepository> _open(
  WidgetTester tester, {
  DateTime? resendAvailableAt,
  bool comfort = false,
  double systemScale = 1.0,
}) async {
  final repository = _VerificationRepository();
  await pumpPage(
    tester,
    comfort: comfort,
    systemScale: systemScale,
    page: VerifyEmailPage(email: _email, resendAvailableAt: resendAvailableAt),
    overrides: [
      authRepositoryProvider.overrideWithValue(repository),
      authDatasourceProvider.overrideWithValue(_SignedOutDatasource()),
    ],
  );
  return repository;
}

Future<void> _typeCode(WidgetTester tester, String code) async {
  await tester.enterText(
    find.widgetWithText(TextFormField, 'Code de vérification'),
    code,
  );
}

Future<void> _validate(WidgetTester tester) async {
  await tester.tap(find.widgetWithText(FilledButton, 'Valider mon adresse'));
  await tester.pumpAndSettle();
}

void main() {
  group('VerifyEmailPage', () {
    testWidgets('says where the code was sent', (tester) async {
      await _open(tester);

      expect(find.text('Nous avons envoyé un code à'), findsOneWidget);
      expect(find.text(_email), findsOneWidget);
    });

    testWidgets('asks for the code, and checks nothing, when it is empty', (
      tester,
    ) async {
      final repository = await _open(tester);

      await _validate(tester);

      expect(find.text('Saisissez le code reçu par e-mail.'), findsOneWidget);
      expect(repository.verified, isEmpty);
    });

    testWidgets('refuses a code that is too short before asking the server', (
      tester,
    ) async {
      final repository = await _open(tester);

      await _typeCode(tester, 'K7QM');
      await _validate(tester);

      expect(find.text('Le code contient 8 caractères.'), findsOneWidget);
      expect(repository.verified, isEmpty);
    });

    testWidgets('sends the address and the code, whatever the separators', (
      tester,
    ) async {
      final repository = await _open(tester);

      await _typeCode(tester, '  K7QM-2XPD ');
      await _validate(tester);

      expect(repository.verified, [(email: _email, code: 'K7QM-2XPD')]);
    });

    testWidgets('shows the reason when the server refuses the code', (
      tester,
    ) async {
      final repository = await _open(tester);
      repository.verifyError = const DatabaseException(
        'Ce code est invalide ou a expiré.',
      );

      await _typeCode(tester, 'K7QM-2XPD');
      await _validate(tester);

      expect(find.text('Ce code est invalide ou a expiré.'), findsOneWidget);
    });

    testWidgets('lets the person ask for a new code once the wait is over', (
      tester,
    ) async {
      final repository = await _open(tester);

      await tester.tap(find.widgetWithText(TextButton, 'Renvoyer le code'));
      await tester.pumpAndSettle();

      expect(repository.resendCalls, 1);
      expect(
        find.text('Un nouveau code vient d\'être envoyé à $_email.'),
        findsOneWidget,
      );
      expect(
        find.textContaining(RegExp(r'Renvoyer le code \(dans \d+ s\)')),
        findsOneWidget,
      );
    });

    testWidgets('makes the person wait before asking for another code', (
      tester,
    ) async {
      final repository = await _open(
        tester,
        resendAvailableAt: DateTime.now().add(const Duration(seconds: 45)),
      );

      expect(
        find.textContaining(RegExp(r'Renvoyer le code \(dans \d+ s\)')),
        findsOneWidget,
      );
      final button = tester.widget<TextButton>(
        find.ancestor(
          of: find.textContaining('Renvoyer le code'),
          matching: find.byType(TextButton),
        ),
      );
      expect(button.onPressed, isNull);
      expect(repository.resendCalls, 0);
    });

    testWidgets('shows the reason when a new code cannot be sent', (
      tester,
    ) async {
      final repository = await _open(tester);
      repository.resendError = const RateLimitException(
        'Un code vient d\'être envoyé.',
      );

      await tester.tap(find.widgetWithText(TextButton, 'Renvoyer le code'));
      await tester.pumpAndSettle();

      expect(find.text('Un code vient d\'être envoyé.'), findsOneWidget);
    });

    for (final comfort in [false, true]) {
      testWidgets(
        'stays readable and reachable at 200% text${comfort ? ' in comfort mode' : ''}',
        (tester) async {
          final handle = tester.ensureSemantics();
          await _open(tester, comfort: comfort, systemScale: 2.0);

          expect(tester.takeException(), isNull);
          await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
          await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
          handle.dispose();
        },
      );
    }
  });
}
