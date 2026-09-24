import 'package:civic_app/features/home/presentation/widgets/navigation_tiles_grid.dart';
import 'package:civic_app/features/settings/domain/entities/app_module.dart';
import 'package:civic_app/features/settings/presentation/controllers/settings_providers.dart';
import 'package:civic_app/shared/widgets/module_gate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _pump(
  WidgetTester tester,
  Widget child, {
  Set<AppModule> disabled = const {},
}) async {
  tester.view.physicalSize = const Size(400, 1200);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [disabledModulesProvider.overrideWithValue(disabled)],
      child: MaterialApp(home: Scaffold(body: child)),
    ),
  );
}

void main() {
  group('NavigationTilesGrid', () {
    const labels = [
      'Actualités',
      'Rendez-vous',
      'Sondages',
      'Services',
      'Commerçants',
      'Signalements',
    ];

    testWidgets('shows a tile for every module when none is disabled', (
      tester,
    ) async {
      await _pump(tester, const NavigationTilesGrid());

      for (final label in labels) {
        expect(find.text(label), findsOneWidget);
      }
    });

    testWidgets('drops the tile of a disabled module and keeps the others', (
      tester,
    ) async {
      await _pump(
        tester,
        const NavigationTilesGrid(),
        disabled: {AppModule.polls, AppModule.reports},
      );

      expect(find.text('Sondages'), findsNothing);
      expect(find.text('Signalements'), findsNothing);
      expect(find.text('Actualités'), findsOneWidget);
      expect(find.text('Commerçants'), findsOneWidget);
    });

    testWidgets('weather has no tile, so disabling it changes nothing here', (
      tester,
    ) async {
      await _pump(
        tester,
        const NavigationTilesGrid(),
        disabled: {AppModule.weather},
      );

      for (final label in labels) {
        expect(find.text(label), findsOneWidget);
      }
    });

    testWidgets('renders nothing when every module is disabled', (
      tester,
    ) async {
      await _pump(
        tester,
        const NavigationTilesGrid(),
        disabled: AppModule.values.toSet(),
      );

      for (final label in labels) {
        expect(find.text(label), findsNothing);
      }
    });
  });

  group('ModuleGate', () {
    testWidgets('shows its child while the module is enabled', (tester) async {
      await _pump(
        tester,
        const ModuleGate(module: AppModule.weather, child: Text('Météo')),
      );

      expect(find.text('Météo'), findsOneWidget);
    });

    testWidgets('hides its child once the module is disabled', (tester) async {
      await _pump(
        tester,
        const ModuleGate(module: AppModule.weather, child: Text('Météo')),
        disabled: {AppModule.weather},
      );

      expect(find.text('Météo'), findsNothing);
    });

    testWidgets('is not affected by another module being disabled', (
      tester,
    ) async {
      await _pump(
        tester,
        const ModuleGate(module: AppModule.weather, child: Text('Météo')),
        disabled: {AppModule.polls},
      );

      expect(find.text('Météo'), findsOneWidget);
    });
  });
}
