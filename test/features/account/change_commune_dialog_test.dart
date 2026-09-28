import 'package:civic_app/features/account/presentation/widgets/change_commune_dialog.dart';
import 'package:civic_app/features/auth/domain/entities/commune_ref.dart';
import 'package:civic_app/features/auth/presentation/controllers/auth_providers.dart';
import 'package:civic_app/features/auth/presentation/widgets/unknown_commune_notice.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

const _current = CommuneRef(
  id: 'c0',
  name: 'Bessan',
  slug: 'bessan',
  postalCode: '34550',
);
const _villeneuve = CommuneRef(
  id: 'c1',
  name: 'Villeneuve',
  slug: 'villeneuve',
  postalCode: '12260',
);

CommuneRef? _result;

Future<void> _open(
  WidgetTester tester, {
  List<CommuneRef> communes = const [_current, _villeneuve],
  Object? communesError,
}) async {
  _result = null;
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        publicCommunesProvider.overrideWith((ref) async {
          if (communesError != null) throw communesError;
          return communes;
        }),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                _result = await showChangeCommuneDialog(
                  context,
                  current: _current,
                );
              },
              child: const Text('Ouvrir'),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Ouvrir'));
  await tester.pumpAndSettle();
}

Future<void> _typePostalCode(WidgetTester tester, String value) {
  return tester.enterText(
    find.widgetWithText(TextFormField, 'Code postal'),
    value,
  );
}

Future<void> _confirm(WidgetTester tester) async {
  await tester.tap(find.widgetWithText(FilledButton, 'Confirmer'));
  await tester.pumpAndSettle();
}

void main() {
  group('showChangeCommuneDialog', () {
    testWidgets('asks for a postal code, not a dropdown of communes', (
      tester,
    ) async {
      await _open(tester);

      expect(find.text('Code postal'), findsOneWidget);
      expect(find.byType(DropdownButtonFormField<CommuneRef>), findsNothing);
    });

    testWidgets(
      'resolves the commune matching the postal code, unknown to the user, and returns it',
      (tester) async {
        await _open(tester);
        await _typePostalCode(tester, '12260');

        await _confirm(tester);

        expect(_result, _villeneuve);
        expect(find.byType(AlertDialog), findsNothing);
      },
    );

    testWidgets(
      'explains that the commune is not a partner yet, returns nothing and keeps the dialog open',
      (tester) async {
        await _open(tester);
        await _typePostalCode(tester, '99999');

        await _confirm(tester);

        expect(find.byType(UnknownCommuneNotice), findsOneWidget);
        expect(_result, isNull);
        expect(find.byType(AlertDialog), findsOneWidget);
      },
    );

    testWidgets('refuses to "change" to the commune already in place', (
      tester,
    ) async {
      await _open(tester);
      await _typePostalCode(tester, '34550');

      await _confirm(tester);

      expect(
        find.text('Vous êtes déjà rattaché à cette commune.'),
        findsOneWidget,
      );
      expect(_result, isNull);
    });

    testWidgets('refuses a postal code that is not five digits', (
      tester,
    ) async {
      await _open(tester);
      await _typePostalCode(tester, '345');

      await _confirm(tester);

      expect(
        find.text('Saisissez d\'abord votre code postal.'),
        findsOneWidget,
      );
      expect(_result, isNull);
    });

    testWidgets('cancels without returning anything', (tester) async {
      await _open(tester);

      await tester.tap(find.widgetWithText(TextButton, 'Annuler'));
      await tester.pumpAndSettle();

      expect(_result, isNull);
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('drops the notice as soon as the postal code is edited', (
      tester,
    ) async {
      await _open(tester);
      await _typePostalCode(tester, '99999');
      await _confirm(tester);
      expect(find.byType(UnknownCommuneNotice), findsOneWidget);

      await _typePostalCode(tester, '12260');
      await tester.pump();

      expect(find.byType(UnknownCommuneNotice), findsNothing);
    });

    testWidgets('reports a failure to reach the server while matching', (
      tester,
    ) async {
      await _open(tester, communesError: Exception('panne'));
      await _typePostalCode(tester, '12260');

      await _confirm(tester);

      expect(find.byType(SnackBar), findsOneWidget);
      expect(_result, isNull);
    });
  });
}
