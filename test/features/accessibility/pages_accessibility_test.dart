import 'package:civic_app/features/account/domain/entities/user_profile.dart';
import 'package:civic_app/features/account/domain/repositories/account_repository.dart';
import 'package:civic_app/features/account/presentation/controllers/account_providers.dart';
import 'package:civic_app/features/account/presentation/widgets/account_privacy_section.dart';
import 'package:civic_app/features/auth/domain/entities/commune_ref.dart';
import 'package:civic_app/features/auth/presentation/controllers/auth_providers.dart';
import 'package:civic_app/features/auth/presentation/pages/auth_page.dart';
import 'package:civic_app/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:civic_app/features/feedback/presentation/pages/feedback_page.dart';
import 'package:civic_app/features/home/presentation/widgets/navigation_tiles_grid.dart';
import 'package:civic_app/features/legal/domain/entities/legal_texts.dart';
import 'package:civic_app/features/legal/presentation/controllers/legal_providers.dart';
import 'package:civic_app/features/legal/presentation/pages/legal_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/app_harness.dart';
import '../../support/fake_auth_repository.dart';

class _FakeAccountRepository implements AccountRepository {
  @override
  Future<UserProfile?> getProfile() async => null;
  @override
  Future<void> deleteAccount() async {}
  @override
  Future<void> requestDataExport() async {}
}

const _texts = LegalTexts(
  communeName: 'Bessan',
  legalNotice:
      '## Éditeur\n\nLa commune de Bessan met cette application à disposition des habitants pour les informer et faciliter leurs démarches.\n\n## Contact\n\nContactez la mairie de Bessan pour toute question.',
  privacyPolicy:
      '## Vos droits\n\n- Accès et portabilité de vos données\n- Effacement de votre compte\n- Réclamation auprès de la CNIL\n\nContactez la mairie.',
);

typedef _PageBuilder = Widget Function();

final _pages = <String, ({_PageBuilder page, List<Override> overrides})>{
  'connexion': (page: () => const AuthPage(), overrides: _authOverrides()),
  'mot de passe oublié': (
    page: () => const ForgotPasswordPage(initialEmail: 'martine@example.fr'),
    overrides: _authOverrides(),
  ),
  'avis': (page: () => const FeedbackPage(), overrides: const []),
  'mentions légales': (
    page: () =>
        const LegalPage(document: LegalDocument.privacy, communeSlug: 'bessan'),
    overrides: [legalTextsProvider.overrideWith((ref, slug) async => _texts)],
  ),
  'accueil (tuiles)': (
    page: () => const Scaffold(
      body: SingleChildScrollView(child: NavigationTilesGrid()),
    ),
    overrides: const [],
  ),
  'compte (données et textes)': (
    page: () => const Scaffold(
      body: SingleChildScrollView(
        child: AccountPrivacySection(communeSlug: 'bessan'),
      ),
    ),
    overrides: [
      accountRepositoryProvider.overrideWithValue(_FakeAccountRepository()),
    ],
  ),
};

List<Override> _authOverrides() => [
  authRepositoryProvider.overrideWithValue(FakeAuthRepository()),
  publicCommunesProvider.overrideWith(
    (ref) async => [const CommuneRef(id: 'c1', name: 'Bessan', slug: 'bessan')],
  ),
];

void main() {
  for (final comfort in [false, true]) {
    for (final systemScale in [1.0, 2.0]) {
      final mode = comfort ? 'Mode Confort' : 'affichage normal';
      group('$mode, texte du téléphone à ${(systemScale * 100).round()} %', () {
        for (final entry in _pages.entries) {
          testWidgets('${entry.key} : rien ne déborde ni ne se chevauche', (
            tester,
          ) async {
            await pumpPage(
              tester,
              page: entry.value.page(),
              comfort: comfort,
              systemScale: systemScale,
              overrides: entry.value.overrides,
            );

            expect(tester.takeException(), isNull);
          });
        }
      });
    }
  }

  group('cibles tactiles et libellés (lecteur d\'écran)', () {
    for (final comfort in [false, true]) {
      for (final entry in _pages.entries) {
        final mode = comfort ? 'Mode Confort' : 'affichage normal';
        testWidgets(
          '${entry.key}, $mode : chaque commande est nommée et assez grande',
          (tester) async {
            final handle = tester.ensureSemantics();
            await pumpPage(
              tester,
              page: entry.value.page(),
              comfort: comfort,
              overrides: entry.value.overrides,
            );

            await expectLater(
              tester,
              meetsGuideline(labeledTapTargetGuideline),
            );
            await expectLater(
              tester,
              meetsGuideline(androidTapTargetGuideline),
            );
            handle.dispose();
          },
        );
      }
    }
  });

  group('accueil en grand texte', () {
    testWidgets(
      'passe les tuiles sur une seule colonne quand le texte est grand',
      (tester) async {
        await pumpPage(
          tester,
          page: const Scaffold(
            body: SingleChildScrollView(child: NavigationTilesGrid()),
          ),
          systemScale: 1.5,
        );

        final first = tester.getTopLeft(find.text('Actualités'));
        final second = tester.getTopLeft(find.text('Rendez-vous'));
        expect(second.dx, first.dx);
        expect(second.dy, greaterThan(first.dy));
      },
    );

    testWidgets('garde deux colonnes en affichage normal', (tester) async {
      await pumpPage(
        tester,
        page: const Scaffold(
          body: SingleChildScrollView(child: NavigationTilesGrid()),
        ),
      );

      final first = tester.getTopLeft(find.text('Actualités'));
      final second = tester.getTopLeft(find.text('Rendez-vous'));
      expect(second.dy, first.dy);
      expect(second.dx, greaterThan(first.dx));
    });

    testWidgets('donne à chaque tuile la hauteur d\'un doigt en Mode Confort', (
      tester,
    ) async {
      await pumpPage(
        tester,
        page: const Scaffold(
          body: SingleChildScrollView(child: NavigationTilesGrid()),
        ),
        comfort: true,
      );

      final tile = tester.getSize(
        find.ancestor(
          of: find.text('Actualités'),
          matching: find.byType(InkWell),
        ),
      );
      expect(tile.height, greaterThanOrEqualTo(84));
    });
  });
}
