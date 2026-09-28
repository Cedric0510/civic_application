import 'package:civic_app/core/errors/app_exception.dart';
import 'package:civic_app/features/auth/domain/entities/sign_up_outcome.dart';
import 'package:civic_app/core/auth/token_storage.dart';
import 'package:civic_app/core/network/api_client.dart';
import 'package:civic_app/features/auth/data/datasources/auth_api_datasource.dart';
import 'package:civic_app/features/auth/domain/entities/citizen_session.dart';
import 'package:civic_app/features/auth/domain/entities/commune_ref.dart';
import 'package:civic_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:civic_app/features/auth/presentation/controllers/auth_providers.dart';
import 'package:civic_app/features/auth/presentation/pages/auth_page.dart';
import 'package:civic_app/features/auth/presentation/widgets/unknown_commune_notice.dart';
import '../../support/preferences_override.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

const _bessan = CommuneRef(
  id: 'c1',
  name: 'Bessan',
  slug: 'bessan',
  postalCode: '34550',
);

class _RecordingAuthRepository implements AuthRepository {
  int signUpCalls = 0;
  String? lastCommuneSlug;
  String? lastInvitationCode;
  bool? lastAcceptedTerms;

  @override
  Future<SignUpOutcome> signUp({
    required String email,
    required String password,
    required String communeSlug,
    required bool acceptedTerms,
    String? invitationCode,
  }) async {
    signUpCalls++;
    lastCommuneSlug = communeSlug;
    lastInvitationCode = invitationCode;
    lastAcceptedTerms = acceptedTerms;
    return const SignUpCompleted();
  }

  @override
  Future<void> verifySignUp({
    required String email,
    required String code,
  }) async {}

  @override
  Future<SignUpNeedsVerification> resendSignUpCode({
    required String email,
  }) async => SignUpNeedsVerification(
    email: email,
    expiresAt: DateTime(2100),
    resendAvailableAt: DateTime(2100),
  );

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

  final List<String> reportedProspects = [];

  @override
  Future<void> recordCommuneProspect(String postalCode) async {
    reportedProspects.add(postalCode);
  }
}

_SignedOutDatasource? _lastDatasource;

Future<_RecordingAuthRepository> _openSignUp(
  WidgetTester tester, {
  List<CommuneRef> communes = const [_bessan],
  Object? communesError,
}) async {
  tester.view.physicalSize = const Size(800, 2200);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  final repository = _RecordingAuthRepository();
  final datasource = _SignedOutDatasource();
  _lastDatasource = datasource;
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(repository),
        authDatasourceProvider.overrideWithValue(datasource),
        publicCommunesProvider.overrideWith((ref) async {
          if (communesError != null) throw communesError;
          return communes;
        }),
        await preferencesOverride(),
      ],
      child: const MaterialApp(home: AuthPage()),
    ),
  );
  await tester.pumpAndSettle();
  await tester.tap(find.text('Pas encore de compte ? S\'inscrire'));
  await tester.pumpAndSettle();
  return repository;
}

Future<void> _fillIdentity(
  WidgetTester tester, {
  String emailConfirmation = 'martine@boulangerie.fr',
  String passwordConfirmation = 'motdepasse1',
  String postalCode = '34550',
}) async {
  await tester.enterText(
    find.widgetWithText(TextFormField, 'Adresse e-mail'),
    'martine@boulangerie.fr',
  );
  await tester.enterText(
    find.widgetWithText(TextFormField, 'Confirmer l\'adresse e-mail'),
    emailConfirmation,
  );
  await tester.enterText(
    find.widgetWithText(TextFormField, 'Mot de passe'),
    'motdepasse1',
  );
  await tester.enterText(
    find.widgetWithText(TextFormField, 'Confirmer le mot de passe'),
    passwordConfirmation,
  );
  await tester.enterText(
    find.widgetWithText(TextFormField, 'Code postal'),
    postalCode,
  );
  await tester.tap(find.byType(CheckboxListTile));
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

  testWidgets('does not create the account until the terms are accepted', (
    tester,
  ) async {
    final repository = await _openSignUp(tester);
    await _fillIdentity(tester);
    await tester.tap(find.byType(CheckboxListTile));
    await tester.pumpAndSettle();

    await _submit(tester);

    expect(
      find.text('Vous devez accepter pour créer un compte.'),
      findsOneWidget,
    );
    expect(repository.signUpCalls, 0);
  });

  testWidgets('sends the acceptance of the terms with the sign-up', (
    tester,
  ) async {
    final repository = await _openSignUp(tester);
    await _fillIdentity(tester);

    await _submit(tester);

    expect(repository.lastAcceptedTerms, isTrue);
  });

  group('confirmations', () {
    testWidgets('asks for the e-mail and the password twice, only to sign up', (
      tester,
    ) async {
      await _openSignUp(tester);

      expect(find.text('Confirmer l\'adresse e-mail'), findsOneWidget);
      expect(find.text('Confirmer le mot de passe'), findsOneWidget);

      await tester.tap(find.text('Déjà un compte ? Se connecter'));
      await tester.pumpAndSettle();

      expect(find.text('Confirmer l\'adresse e-mail'), findsNothing);
      expect(find.text('Confirmer le mot de passe'), findsNothing);
    });

    testWidgets('creates no account when the two e-mail addresses differ', (
      tester,
    ) async {
      final repository = await _openSignUp(tester);
      await _fillIdentity(tester, emailConfirmation: 'martine@boulangeri.fr');

      await _submit(tester);

      expect(
        find.text('Les deux adresses e-mail ne sont pas identiques.'),
        findsOneWidget,
      );
      expect(repository.signUpCalls, 0);
    });

    testWidgets('creates no account when the two passwords differ', (
      tester,
    ) async {
      final repository = await _openSignUp(tester);
      await _fillIdentity(tester, passwordConfirmation: 'motdepasse2');

      await _submit(tester);

      expect(
        find.text('Les deux mots de passe ne sont pas identiques.'),
        findsOneWidget,
      );
      expect(repository.signUpCalls, 0);
    });

    testWidgets('asks to confirm rather than accepting an empty confirmation', (
      tester,
    ) async {
      final repository = await _openSignUp(tester);
      await _fillIdentity(
        tester,
        emailConfirmation: '',
        passwordConfirmation: '',
      );

      await _submit(tester);

      expect(find.text('Confirmez l\'adresse e-mail.'), findsOneWidget);
      expect(find.text('Confirmez le mot de passe.'), findsOneWidget);
      expect(repository.signUpCalls, 0);
    });

    testWidgets('does not mind capitals or spaces around the e-mail address', (
      tester,
    ) async {
      final repository = await _openSignUp(tester);
      await _fillIdentity(
        tester,
        emailConfirmation: ' Martine@Boulangerie.fr ',
      );

      await _submit(tester);

      expect(repository.signUpCalls, 1);
    });

    testWidgets('does not ask for the confirmations again after a round trip', (
      tester,
    ) async {
      await _openSignUp(tester);
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Confirmer le mot de passe'),
        'brouillon',
      );

      await tester.tap(find.text('Déjà un compte ? Se connecter'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Pas encore de compte ? S\'inscrire'));
      await tester.pumpAndSettle();

      final field = tester.widget<TextFormField>(
        find.widgetWithText(TextFormField, 'Confirmer le mot de passe'),
      );
      expect(field.controller!.text, isEmpty);
    });
  });

  group('rattachement par code postal', () {
    testWidgets('asks for a postal code, no more a list of communes', (
      tester,
    ) async {
      await _openSignUp(tester);

      expect(find.text('Code postal'), findsOneWidget);
      expect(find.byType(DropdownButtonFormField<CommuneRef>), findsNothing);
    });

    testWidgets('refuses a postal code that is not five digits', (
      tester,
    ) async {
      final repository = await _openSignUp(tester);
      await _fillIdentity(tester, postalCode: '345');

      await _submit(tester);

      expect(find.text('Entrez un code postal à 5 chiffres.'), findsOneWidget);
      expect(repository.signUpCalls, 0);
    });

    testWidgets(
      'signs up with the commune matching the postal code, unknown to the user',
      (tester) async {
        final repository = await _openSignUp(
          tester,
          communes: const [
            _bessan,
            CommuneRef(
              id: 'c2',
              name: 'Villeneuve',
              slug: 'villeneuve',
              postalCode: '12260',
            ),
          ],
        );
        await _fillIdentity(tester, postalCode: '12260');

        await _submit(tester);

        expect(repository.signUpCalls, 1);
        expect(repository.lastCommuneSlug, 'villeneuve');
      },
    );

    testWidgets(
      'explains that the commune is not a partner yet, and creates no account',
      (tester) async {
        final repository = await _openSignUp(tester);
        await _fillIdentity(tester, postalCode: '99999');

        await _submit(tester);

        expect(find.byType(UnknownCommuneNotice), findsOneWidget);
        expect(
          find.textContaining('n\'est pas encore inscrite à City-Co'),
          findsOneWidget,
        );
        expect(find.textContaining(supportEmail), findsOneWidget);
        expect(repository.signUpCalls, 0);
        expect(_lastDatasource!.reportedProspects, ['99999']);
      },
    );

    testWidgets('never reports a postal code that does match a commune', (
      tester,
    ) async {
      await _openSignUp(tester);
      await _fillIdentity(tester, postalCode: '34550');

      await _submit(tester);

      expect(_lastDatasource!.reportedProspects, isEmpty);
    });

    testWidgets('drops the notice as soon as the postal code is edited', (
      tester,
    ) async {
      await _openSignUp(tester);
      await _fillIdentity(tester, postalCode: '99999');
      await _submit(tester);
      expect(find.byType(UnknownCommuneNotice), findsOneWidget);

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Code postal'),
        '34550',
      );
      await tester.pumpAndSettle();

      expect(find.byType(UnknownCommuneNotice), findsNothing);
    });

    testWidgets('reports a failure to reach the server while matching', (
      tester,
    ) async {
      final repository = await _openSignUp(
        tester,
        communesError: const NetworkException(),
      );
      await _fillIdentity(tester);

      await _submit(tester);

      expect(find.byType(SnackBar), findsOneWidget);
      expect(repository.signUpCalls, 0);
    });
  });

  testWidgets('asks for the postal code before reading a legal text', (
    tester,
  ) async {
    await _openSignUp(tester);

    await tester.tap(find.text('Lire : Mentions légales'));
    await tester.pumpAndSettle();

    expect(find.text('Saisissez d\'abord votre code postal.'), findsOneWidget);
  });

  testWidgets(
    'shows the unknown-commune notice when the postal code of a legal text request matches nobody',
    (tester) async {
      await _openSignUp(tester);
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Code postal'),
        '99999',
      );

      await tester.tap(find.text('Lire : Mentions légales'));
      await tester.pumpAndSettle();

      expect(find.byType(UnknownCommuneNotice), findsOneWidget);
    },
  );
}
