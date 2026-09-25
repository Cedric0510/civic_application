import 'package:civic_app/core/auth/token_storage.dart';
import 'package:civic_app/core/network/api_client.dart';
import 'package:civic_app/features/auth/data/datasources/auth_api_datasource.dart';
import 'package:civic_app/features/auth/domain/entities/citizen_session.dart';
import 'package:civic_app/features/auth/domain/entities/commune_ref.dart';
import 'package:civic_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:civic_app/features/auth/presentation/controllers/auth_providers.dart';
import 'package:civic_app/features/auth/presentation/pages/auth_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

const _bessan = CommuneRef(id: 'c1', name: 'Bessan', slug: 'bessan');

class _RecordingAuthRepository implements AuthRepository {
  int signUpCalls = 0;
  String? lastCommuneSlug;
  String? lastInvitationCode;

  @override
  Future<void> signUp({
    required String email,
    required String password,
    required String communeSlug,
    String? invitationCode,
  }) async {
    signUpCalls++;
    lastCommuneSlug = communeSlug;
    lastInvitationCode = invitationCode;
  }

  @override
  Future<void> signIn({
    required String email,
    required String password,
  }) async {}

  @override
  Future<void> requestPasswordReset({required String email}) async {}

  @override
  Future<void> resetPassword({
    required String email,
    required String code,
    required String newPassword,
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

Future<_RecordingAuthRepository> _openSignUp(WidgetTester tester) async {
  tester.view.physicalSize = const Size(800, 2200);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  final repository = _RecordingAuthRepository();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(repository),
        authDatasourceProvider.overrideWithValue(_SignedOutDatasource()),
        publicCommunesProvider.overrideWith((ref) async => [_bessan]),
      ],
      child: const MaterialApp(home: AuthPage()),
    ),
  );
  await tester.pumpAndSettle();
  await tester.tap(find.text('Pas encore de compte ? S\'inscrire'));
  await tester.pumpAndSettle();
  return repository;
}

Future<void> _fillIdentity(WidgetTester tester) async {
  await tester.enterText(
    find.widgetWithText(TextFormField, 'Adresse e-mail'),
    'martine@boulangerie.fr',
  );
  await tester.enterText(
    find.widgetWithText(TextFormField, 'Mot de passe'),
    'motdepasse1',
  );
  await tester.tap(find.byType(DropdownButtonFormField<CommuneRef>));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Bessan').last);
  await tester.pumpAndSettle();
}

Future<void> _submit(WidgetTester tester) async {
  await tester.tap(find.widgetWithText(FilledButton, 'Créer un compte'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('keeps the invitation code out of the way until asked for', (
    tester,
  ) async {
    await _openSignUp(tester);

    expect(find.text('Code d\'invitation'), findsNothing);
    expect(find.text('J\'ai un code d\'invitation commerçant'), findsOneWidget);

    await tester.tap(find.text('J\'ai un code d\'invitation commerçant'));
    await tester.pumpAndSettle();

    expect(find.text('Code d\'invitation'), findsOneWidget);
    expect(find.text('Je n\'ai pas de code d\'invitation'), findsOneWidget);
  });

  testWidgets('sends the typed code with the sign-up', (tester) async {
    final repository = await _openSignUp(tester);
    await _fillIdentity(tester);

    await tester.tap(find.text('J\'ai un code d\'invitation commerçant'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Code d\'invitation'),
      'K7QM-2XPD',
    );
    await _submit(tester);

    expect(repository.signUpCalls, 1);
    expect(repository.lastCommuneSlug, 'bessan');
    expect(repository.lastInvitationCode, 'K7QM-2XPD');
  });

  testWidgets(
    'asks for the code, and signs nobody up, when the field is left empty',
    (tester) async {
      final repository = await _openSignUp(tester);
      await _fillIdentity(tester);

      await tester.tap(find.text('J\'ai un code d\'invitation commerçant'));
      await tester.pumpAndSettle();
      await _submit(tester);

      expect(find.text('Saisissez le code reçu par e-mail.'), findsOneWidget);
      expect(repository.signUpCalls, 0);
    },
  );

  testWidgets('sends no code once the field has been dismissed', (
    tester,
  ) async {
    final repository = await _openSignUp(tester);
    await _fillIdentity(tester);

    await tester.tap(find.text('J\'ai un code d\'invitation commerçant'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Code d\'invitation'),
      'K7QM-2XPD',
    );
    await tester.tap(find.text('Je n\'ai pas de code d\'invitation'));
    await tester.pumpAndSettle();
    await _submit(tester);

    expect(repository.signUpCalls, 1);
    expect(repository.lastInvitationCode, isNull);
  });

  testWidgets('a plain sign-up carries no code', (tester) async {
    final repository = await _openSignUp(tester);
    await _fillIdentity(tester);
    await _submit(tester);

    expect(repository.signUpCalls, 1);
    expect(repository.lastInvitationCode, isNull);
  });
}
