import 'dart:convert';

import 'package:civic_app/core/network/api_client.dart';
import 'package:civic_app/features/legal/data/datasources/legal_api_datasource.dart';
import 'package:civic_app/features/legal/domain/entities/legal_texts.dart';
import 'package:civic_app/features/legal/presentation/controllers/legal_providers.dart';
import 'package:civic_app/features/legal/presentation/pages/legal_page.dart';
import '../../support/no_token_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

const _texts = LegalTexts(
  communeName: 'Bessan',
  legalNotice: '## Éditeur\n\nLa commune de Bessan.',
  privacyPolicy:
      '## Vos droits\n\n- Accès et portabilité\n- Effacement\n\nContactez la mairie.',
);

Future<void> _open(
  WidgetTester tester,
  LegalDocument document, {
  Future<LegalTexts> Function()? load,
}) async {
  tester.view.physicalSize = const Size(800, 1600);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        legalTextsProvider.overrideWith(
          (ref, slug) => (load ?? () async => _texts)(),
        ),
      ],
      child: MaterialApp(
        home: LegalPage(document: document, communeSlug: 'bessan'),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() {
    dotenv.testLoad(fileInput: 'API_BASE_URL=http://test.local');
  });

  testWidgets('shows the mentions légales of the commune', (tester) async {
    await _open(tester, LegalDocument.notice);

    expect(find.text('Mentions légales'), findsOneWidget);
    expect(find.text('Bessan'), findsOneWidget);
    expect(find.text('Éditeur'), findsOneWidget);
    expect(find.text('La commune de Bessan.'), findsOneWidget);
    expect(find.text('Vos droits'), findsNothing);
  });

  testWidgets('shows the privacy policy, with its list', (tester) async {
    await _open(tester, LegalDocument.privacy);

    expect(find.text('Politique de confidentialité'), findsOneWidget);
    expect(find.text('Vos droits'), findsOneWidget);
    expect(find.text('Accès et portabilité'), findsOneWidget);
    expect(find.text('Effacement'), findsOneWidget);
    expect(find.text('Contactez la mairie.'), findsOneWidget);
  });

  testWidgets('marks each title as a heading for screen readers', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await _open(tester, LegalDocument.privacy);

    expect(
      tester.getSemantics(find.text('Vos droits')),
      matchesSemantics(label: 'Vos droits', isHeader: true),
    );
    handle.dispose();
  });

  testWidgets('offers to retry when the document cannot be loaded', (
    tester,
  ) async {
    await _open(
      tester,
      LegalDocument.notice,
      load: () async => throw Exception('hors ligne'),
    );

    expect(find.text('Impossible de charger ce document.'), findsOneWidget);
  });

  group('LegalApiDatasource', () {
    test('reads the texts of the commune from the public endpoint', () async {
      late Uri seen;
      final datasource = LegalApiDatasource(
        ApiClient(
          MockClient((request) async {
            seen = request.url;
            return http.Response(
              jsonEncode({
                'communeName': 'Bessan',
                'legalNotice': 'Mentions',
                'privacyPolicy': 'Politique',
                'legalNoticeIsCustom': false,
                'privacyPolicyIsCustom': true,
              }),
              200,
            );
          }),
          NoTokenStorage(),
        ),
      );

      final texts = await datasource.getLegalTexts('bessan');

      expect(seen.path, '/communes/bessan/legal');
      expect(texts.communeName, 'Bessan');
      expect(texts.textOf(LegalDocument.notice), 'Mentions');
      expect(texts.textOf(LegalDocument.privacy), 'Politique');
    });
  });

  group('LegalDocument.fromRouteSegment', () {
    test('finds a document by its route, and nothing for an unknown one', () {
      expect(LegalDocument.fromRouteSegment('notice'), LegalDocument.notice);
      expect(LegalDocument.fromRouteSegment('privacy'), LegalDocument.privacy);
      expect(LegalDocument.fromRouteSegment('cgv'), isNull);
    });
  });
}
