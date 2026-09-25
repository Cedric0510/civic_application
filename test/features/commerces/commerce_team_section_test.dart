import 'package:civic_app/core/errors/app_exception.dart';
import 'package:civic_app/features/commerces/domain/entities/commerce_team.dart';
import 'package:civic_app/features/commerces/domain/repositories/commerce_team_repository.dart';
import 'package:civic_app/features/commerces/presentation/controllers/commerce_team_providers.dart';
import 'package:civic_app/features/commerces/presentation/widgets/commerce_team_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/app_harness.dart';

class _FakeTeamRepository implements CommerceTeamRepository {
  _FakeTeamRepository({List<CommerceTeamMember>? members})
    : members =
          members ??
          const [
            CommerceTeamMember(
              id: 'chief-1',
              email: 'chef@boulangerie.fr',
              isChief: true,
            ),
            CommerceTeamMember(
              id: 'member-2',
              email: 'paul@boulangerie.fr',
              isChief: false,
            ),
          ];

  List<CommerceTeamMember> members;
  List<CommerceInvitation> invitations = [
    CommerceInvitation(
      id: 'inv-1',
      email: 'nouvelle@boulangerie.fr',
      expiresAt: DateTime(2026, 10, 8),
    ),
  ];
  TeamAddOutcome outcome = TeamAddOutcome.linked;
  Object? error;
  final List<String> added = [];
  final List<String> removed = [];
  final List<String> cancelled = [];

  @override
  Future<CommerceTeam> getTeam(String commerceId) async =>
      CommerceTeam(members: members, invitations: invitations);

  @override
  Future<TeamAddOutcome> addMember(String commerceId, String email) async {
    if (error != null) throw error!;
    added.add(email);
    return outcome;
  }

  @override
  Future<void> removeMember(String commerceId, String memberId) async {
    if (error != null) throw error!;
    removed.add(memberId);
    members = members.where((member) => member.id != memberId).toList();
  }

  @override
  Future<void> cancelInvitation(String commerceId, String invitationId) async {
    if (error != null) throw error!;
    cancelled.add(invitationId);
    invitations = invitations.where((i) => i.id != invitationId).toList();
  }
}

Future<void> _open(
  WidgetTester tester,
  _FakeTeamRepository repository, {
  bool comfort = false,
  double systemScale = 1.0,
}) {
  return pumpPage(
    tester,
    comfort: comfort,
    systemScale: systemScale,
    size: const Size(360, 900),
    page: const Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: CommerceTeamSection(commerceId: 'shop-1'),
      ),
    ),
    overrides: [commerceTeamRepositoryProvider.overrideWithValue(repository)],
  );
}

Future<void> _typeAndAdd(WidgetTester tester, String email) async {
  await tester.enterText(
    find.widgetWithText(TextFormField, 'Adresse e-mail du collaborateur'),
    email,
  );
  final addButton = find.widgetWithText(FilledButton, 'Ajouter à l\'équipe');
  await tester.ensureVisible(addButton);
  await tester.tap(addButton);
  await tester.pumpAndSettle();
}

void main() {
  group('CommerceTeamSection', () {
    testWidgets(
      'lists the chief, the collaborators and the pending invitations',
      (tester) async {
        await _open(tester, _FakeTeamRepository());

        expect(find.text('chef@boulangerie.fr'), findsOneWidget);
        expect(find.text('Chef du commerce'), findsOneWidget);
        expect(find.text('paul@boulangerie.fr'), findsOneWidget);
        expect(find.text('nouvelle@boulangerie.fr'), findsOneWidget);
        expect(find.textContaining('Invitation en attente'), findsOneWidget);
      },
    );

    testWidgets('offers to remove a collaborator, never the chief', (
      tester,
    ) async {
      await _open(tester, _FakeTeamRepository());

      expect(find.byTooltip('Retirer paul@boulangerie.fr'), findsOneWidget);
      expect(find.byTooltip('Retirer chef@boulangerie.fr'), findsNothing);
    });

    testWidgets('adds an existing account and says it now has access', (
      tester,
    ) async {
      final repository = _FakeTeamRepository();
      await _open(tester, repository);

      await _typeAndAdd(tester, '  Julie@Boulangerie.fr ');

      expect(repository.added, ['julie@boulangerie.fr']);
      expect(
        find.text('Julie@Boulangerie.fr a maintenant accès à votre commerce.'),
        findsOneWidget,
      );
      final field = tester.widget<TextFormField>(
        find.widgetWithText(TextFormField, 'Adresse e-mail du collaborateur'),
      );
      expect(field.controller!.text, isEmpty);
    });

    testWidgets('explains that an unknown address received a code by e-mail', (
      tester,
    ) async {
      final repository = _FakeTeamRepository()
        ..outcome = TeamAddOutcome.invited;
      await _open(tester, repository);

      await _typeAndAdd(tester, 'julie@boulangerie.fr');

      expect(
        find.textContaining('Invitation envoyée à julie@boulangerie.fr'),
        findsOneWidget,
      );
    });

    testWidgets('sends nothing for an address that is not an e-mail', (
      tester,
    ) async {
      final repository = _FakeTeamRepository();
      await _open(tester, repository);

      await _typeAndAdd(tester, 'pas-un-mail');

      expect(find.text('Entrez une adresse e-mail valide.'), findsOneWidget);
      expect(repository.added, isEmpty);
    });

    testWidgets('removes a collaborator only after a confirmation', (
      tester,
    ) async {
      final repository = _FakeTeamRepository();
      await _open(tester, repository);

      await tester.tap(find.byTooltip('Retirer paul@boulangerie.fr'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Annuler'));
      await tester.pumpAndSettle();
      expect(repository.removed, isEmpty);

      await tester.tap(find.byTooltip('Retirer paul@boulangerie.fr'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Retirer'));
      await tester.pumpAndSettle();

      expect(repository.removed, ['member-2']);
      expect(find.text('paul@boulangerie.fr'), findsNothing);
    });

    testWidgets('withdraws a pending invitation', (tester) async {
      final repository = _FakeTeamRepository();
      await _open(tester, repository);

      await tester.tap(
        find.byTooltip('Annuler l\'invitation à nouvelle@boulangerie.fr'),
      );
      await tester.pumpAndSettle();

      expect(repository.cancelled, ['inv-1']);
      expect(find.text('nouvelle@boulangerie.fr'), findsNothing);
    });

    testWidgets('shows the reason the server gave when it refuses', (
      tester,
    ) async {
      final repository = _FakeTeamRepository()
        ..error = const DatabaseException(
          'Ce compte gère déjà un autre commerce.',
        );
      await _open(tester, repository);

      await _typeAndAdd(tester, 'julie@boulangerie.fr');

      expect(
        find.text('Ce compte gère déjà un autre commerce.'),
        findsOneWidget,
      );
    });

    for (final comfort in [false, true]) {
      testWidgets(
        'stays readable and reachable at 200% text${comfort ? ' in comfort mode' : ''}',
        (tester) async {
          final handle = tester.ensureSemantics();
          await _open(
            tester,
            _FakeTeamRepository(),
            comfort: comfort,
            systemScale: 2.0,
          );

          expect(tester.takeException(), isNull);
          await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
          await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
          handle.dispose();
        },
      );
    }
  });
}
