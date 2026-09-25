import 'package:civic_app/core/errors/app_exception.dart';
import 'package:civic_app/features/account/domain/entities/user_profile.dart';
import 'package:civic_app/features/account/domain/repositories/account_repository.dart';
import 'package:civic_app/features/account/presentation/controllers/account_providers.dart';
import 'package:civic_app/features/account/presentation/widgets/account_privacy_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

class _Repository implements AccountRepository {
  int exports = 0;
  Object? exportError;

  @override
  Future<void> requestDataExport() async {
    exports++;
    if (exportError != null) throw exportError!;
  }

  @override
  Future<UserProfile?> getProfile() async => null;

  @override
  Future<void> deleteAccount() async {}
}

Future<_Repository> _open(WidgetTester tester) async {
  tester.view.physicalSize = const Size(800, 1600);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  final repository = _Repository();
  final router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (_, _) => const Scaffold(
          body: SingleChildScrollView(
            child: AccountPrivacySection(communeSlug: 'bessan'),
          ),
        ),
      ),
      GoRoute(path: '/feedback', builder: (_, _) => const Text('Page avis')),
      GoRoute(
        path: '/legal/:kind',
        builder: (_, state) => Text(
          'Texte ${state.pathParameters['kind']} de ${state.uri.queryParameters['commune']}',
        ),
      ),
    ],
  );
  addTearDown(router.dispose);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [accountRepositoryProvider.overrideWithValue(repository)],
      child: MaterialApp.router(routerConfig: router),
    ),
  );
  await tester.pumpAndSettle();
  return repository;
}

void main() {
  testWidgets('offers the feedback form and both legal texts of the commune', (
    tester,
  ) async {
    await _open(tester);

    expect(find.text('Donner mon avis'), findsOneWidget);
    expect(find.text('Mentions légales'), findsOneWidget);
    expect(find.text('Politique de confidentialité'), findsOneWidget);

    await tester.tap(find.text('Politique de confidentialité'));
    await tester.pumpAndSettle();
    expect(find.text('Texte privacy de bessan'), findsOneWidget);
  });

  testWidgets('opens the feedback page', (tester) async {
    await _open(tester);

    await tester.tap(find.text('Donner mon avis'));
    await tester.pumpAndSettle();

    expect(find.text('Page avis'), findsOneWidget);
  });

  testWidgets('asks before e-mailing the data, then confirms once it is sent', (
    tester,
  ) async {
    final repository = await _open(tester);

    await tester.tap(find.text('Recevoir mes données par e-mail'));
    await tester.pumpAndSettle();
    expect(find.text('Recevoir mes données'), findsOneWidget);
    expect(repository.exports, 0);

    await tester.tap(find.text('Envoyer'));
    await tester.pumpAndSettle();

    expect(repository.exports, 1);
    expect(
      find.text('Un e-mail avec vos données vient de vous être envoyé.'),
      findsOneWidget,
    );
  });

  testWidgets('sends nothing when the confirmation is cancelled', (
    tester,
  ) async {
    final repository = await _open(tester);

    await tester.tap(find.text('Recevoir mes données par e-mail'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Annuler'));
    await tester.pumpAndSettle();

    expect(repository.exports, 0);
  });

  testWidgets('does not claim success when the e-mail could not be sent', (
    tester,
  ) async {
    final repository = await _open(tester);
    repository.exportError = const DatabaseException(
      'L\'envoi d\'e-mails n\'est pas disponible pour le moment.',
    );

    await tester.tap(find.text('Recevoir mes données par e-mail'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Envoyer'));
    await tester.pumpAndSettle();

    expect(
      find.text('Un e-mail avec vos données vient de vous être envoyé.'),
      findsNothing,
    );
  });
}
