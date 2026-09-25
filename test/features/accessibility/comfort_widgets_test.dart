import 'package:civic_app/core/routing/app_router.dart';
import 'package:civic_app/features/accessibility/data/datasources/display_settings_local_datasource.dart';
import 'package:civic_app/features/accessibility/presentation/widgets/comfort_mode_button.dart';
import 'package:civic_app/features/accessibility/presentation/widgets/comfort_mode_tile.dart';
import 'package:civic_app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../support/preferences_override.dart';

Future<void> _pump(
  WidgetTester tester,
  Widget child, {
  Map<String, Object> stored = const {},
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [await preferencesOverride(stored)],
      child: MaterialApp(
        home: Scaffold(body: Center(child: child)),
      ),
    ),
  );
}

void main() {
  group('ComfortModeTile', () {
    testWidgets('names the mode and says what it does', (tester) async {
      await _pump(tester, const ComfortModeTile());

      expect(find.text('Mode Confort'), findsOneWidget);
      expect(find.textContaining('plus grands'), findsOneWidget);
      expect(tester.widget<Switch>(find.byType(Switch)).value, isFalse);
    });

    testWidgets('turns the mode on and remembers it', (tester) async {
      await _pump(tester, const ComfortModeTile());

      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();

      expect(tester.widget<Switch>(find.byType(Switch)).value, isTrue);
      final preferences = await SharedPreferences.getInstance();
      expect(
        preferences.getBool(DisplaySettingsLocalDatasource.comfortModeKey),
        isTrue,
      );
    });

    testWidgets('shows the mode as on when it was left on', (tester) async {
      await _pump(
        tester,
        const ComfortModeTile(),
        stored: {DisplaySettingsLocalDatasource.comfortModeKey: true},
      );

      expect(tester.widget<Switch>(find.byType(Switch)).value, isTrue);
    });
  });

  group('ComfortModeButton', () {
    testWidgets('is a labelled toggle that says what tapping it will do', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await _pump(tester, const ComfortModeButton());

      expect(
        find.byTooltip('Mode Confort : agrandir les textes'),
        findsOneWidget,
      );

      await tester.tap(find.byType(IconButton));
      await tester.pumpAndSettle();

      expect(
        find.byTooltip('Mode Confort activé : toucher pour le désactiver'),
        findsOneWidget,
      );
      handle.dispose();
    });
  });

  group('CivicApp', () {
    Future<GoRouter> open(
      WidgetTester tester, {
      Map<String, Object> stored = const {},
    }) async {
      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, _) => Scaffold(
              body: Column(
                children: [
                  Text(
                    MaterialLocalizations.of(context).backButtonTooltip,
                    key: const Key('back'),
                  ),
                  Text(
                    '${MediaQuery.textScalerOf(context).scale(10) / 10}',
                    key: const Key('scale'),
                  ),
                  const ComfortModeButton(),
                ],
              ),
            ),
          ),
        ],
      );
      addTearDown(router.dispose);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            await preferencesOverride(stored),
            appRouterProvider.overrideWithValue(router),
          ],
          child: const CivicApp(),
        ),
      );
      await tester.pumpAndSettle();
      return router;
    }

    testWidgets('speaks French to the system: back button and other labels', (
      tester,
    ) async {
      await open(tester);

      expect(tester.widget<Text>(find.byKey(const Key('back'))).data, 'Retour');
    });

    testWidgets('enlarges every text at once when the mode is switched on', (
      tester,
    ) async {
      await open(tester);
      expect(tester.widget<Text>(find.byKey(const Key('scale'))).data, '1.0');

      await tester.tap(find.byType(IconButton));
      await tester.pumpAndSettle();

      expect(tester.widget<Text>(find.byKey(const Key('scale'))).data, '1.3');
    });

    testWidgets('starts enlarged when the previous session left the mode on', (
      tester,
    ) async {
      await open(
        tester,
        stored: {DisplaySettingsLocalDatasource.comfortModeKey: true},
      );

      expect(tester.widget<Text>(find.byKey(const Key('scale'))).data, '1.3');
    });
  });
}
