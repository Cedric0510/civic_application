import 'dart:convert';

import 'package:civic_app/core/errors/app_exception.dart';
import 'package:civic_app/core/network/api_client.dart';
import 'package:civic_app/features/feedback/data/datasources/feedback_api_datasource.dart';
import 'package:civic_app/features/feedback/domain/entities/feedback_kind.dart';
import 'package:civic_app/features/feedback/domain/repositories/feedback_repository.dart';
import 'package:civic_app/features/feedback/presentation/controllers/feedback_providers.dart';
import 'package:civic_app/features/feedback/presentation/pages/feedback_page.dart';
import '../../support/no_token_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

class _RecordingRepository implements FeedbackRepository {
  final List<Map<String, Object?>> sent = [];
  Object? error;

  @override
  Future<void> send({
    required int rating,
    required FeedbackKind kind,
    required String message,
    required bool contactAllowed,
  }) async {
    if (error != null) throw error!;
    sent.add({
      'rating': rating,
      'kind': kind,
      'message': message,
      'contactAllowed': contactAllowed,
    });
  }
}

Future<_RecordingRepository> _open(WidgetTester tester) async {
  tester.view.physicalSize = const Size(800, 2200);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  final repository = _RecordingRepository();
  final router = GoRouter(
    initialLocation: '/feedback',
    routes: [
      GoRoute(path: '/feedback', builder: (_, _) => const FeedbackPage()),
      GoRoute(path: '/home', builder: (_, _) => const Text('Accueil')),
    ],
  );
  addTearDown(router.dispose);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [feedbackRepositoryProvider.overrideWithValue(repository)],
      child: MaterialApp.router(routerConfig: router),
    ),
  );
  await tester.pumpAndSettle();
  return repository;
}

Future<void> _rate(WidgetTester tester, int stars) async {
  await tester.tap(
    find.bySemanticsLabel(
      stars == 1 ? '1 étoile sur 5' : '$stars étoiles sur 5',
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _write(WidgetTester tester, String message) async {
  await tester.enterText(
    find.widgetWithText(TextFormField, 'Votre message'),
    message,
  );
}

Future<void> _send(WidgetTester tester) async {
  await tester.tap(find.widgetWithText(FilledButton, 'Envoyer mon avis'));
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() {
    dotenv.testLoad(fileInput: 'API_BASE_URL=http://test.local');
  });

  group('FeedbackPage', () {
    testWidgets('asks for a note and a message before sending anything', (
      tester,
    ) async {
      final repository = await _open(tester);

      await _send(tester);

      expect(
        find.text('Choisissez une note de 1 à 5 étoiles.'),
        findsOneWidget,
      );
      expect(
        find.text('Écrivez quelques mots pour nous aider.'),
        findsOneWidget,
      );
      expect(repository.sent, isEmpty);
    });

    testWidgets(
      'sends the note, the kind, the message and the contact choice',
      (tester) async {
        final repository = await _open(tester);

        await _rate(tester, 4);
        await tester.tap(find.text('Un problème'));
        await _write(tester, '  Le vote plante parfois  ');
        await tester.tap(find.byType(SwitchListTile));
        await tester.pumpAndSettle();
        await _send(tester);

        expect(repository.sent, [
          {
            'rating': 4,
            'kind': FeedbackKind.problem,
            'message': 'Le vote plante parfois',
            'contactAllowed': true,
          },
        ]);
      },
    );

    testWidgets(
      'does not share the address unless asked, and suggests an idea by default',
      (tester) async {
        final repository = await _open(tester);

        await _rate(tester, 5);
        await _write(tester, 'Très pratique');
        await _send(tester);

        expect(repository.sent.single['contactAllowed'], isFalse);
        expect(repository.sent.single['kind'], FeedbackKind.idea);
      },
    );

    testWidgets('thanks the resident, then goes back home', (tester) async {
      await _open(tester);

      await _rate(tester, 3);
      await _write(tester, 'Correct');
      await _send(tester);

      expect(find.text('Merci pour votre avis !'), findsOneWidget);
      await tester.tap(find.text('Retour à l\'accueil'));
      await tester.pumpAndSettle();
      expect(find.text('Accueil'), findsOneWidget);
    });

    testWidgets('keeps the form and says why when sending fails', (
      tester,
    ) async {
      final repository = await _open(tester);
      repository.error = const RateLimitException();

      await _rate(tester, 3);
      await _write(tester, 'Correct');
      await _send(tester);

      expect(
        find.text(
          'Trop de tentatives. Patientez un moment avant de réessayer.',
        ),
        findsOneWidget,
      );
      expect(find.text('Merci pour votre avis !'), findsNothing);
      expect(find.text('Votre message'), findsOneWidget);
    });

    testWidgets(
      'exposes each star as a button with its value for screen readers',
      (tester) async {
        final handle = tester.ensureSemantics();
        await _open(tester);

        expect(find.bySemanticsLabel('1 étoile sur 5'), findsOneWidget);
        expect(find.bySemanticsLabel('5 étoiles sur 5'), findsOneWidget);
        handle.dispose();
      },
    );
  });

  group('FeedbackApiDatasource', () {
    test('posts the feedback with the API vocabulary', () async {
      late http.Request seen;
      final datasource = FeedbackApiDatasource(
        ApiClient(
          MockClient((request) async {
            seen = request;
            return http.Response(jsonEncode({'id': 'f1'}), 201);
          }),
          NoTokenStorage(),
        ),
      );

      await datasource.send(
        rating: 2,
        kind: FeedbackKind.problem,
        message: 'Bug',
        contactAllowed: true,
      );

      expect(seen.method, 'POST');
      expect(seen.url.path, '/feedback');
      expect(jsonDecode(seen.body), {
        'rating': 2,
        'kind': 'PROBLEME',
        'message': 'Bug',
        'contactAllowed': true,
      });
    });
  });
}
