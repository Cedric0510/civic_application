import 'package:civic_app/core/theme/app_theme.dart';
import 'package:civic_app/features/accessibility/data/datasources/display_settings_local_datasource.dart';
import 'package:civic_app/features/accessibility/domain/entities/display_settings.dart';
import 'package:civic_app/features/accessibility/presentation/comfort_text_scale.dart';
import 'package:civic_app/features/accessibility/presentation/controllers/display_settings_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/theme/feature_colors_test.dart' show contrastRatio;
import '../../support/preferences_override.dart';

Future<ProviderContainer> _container([
  Map<String, Object> stored = const {},
]) async {
  final container = ProviderContainer(
    overrides: [await preferencesOverride(stored)],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  group('comfort mode setting', () {
    test('is off until someone turns it on', () async {
      final container = await _container();

      expect(container.read(displaySettingsProvider).comfortMode, isFalse);
    });

    test('turns on and off, and is remembered for the next launch', () async {
      final container = await _container();

      await container
          .read(displaySettingsProvider.notifier)
          .setComfortMode(true);
      expect(container.read(displaySettingsProvider).comfortMode, isTrue);
      final preferences = await SharedPreferences.getInstance();
      expect(
        preferences.getBool(DisplaySettingsLocalDatasource.comfortModeKey),
        isTrue,
      );

      await container
          .read(displaySettingsProvider.notifier)
          .toggleComfortMode();
      expect(container.read(displaySettingsProvider).comfortMode, isFalse);
      expect(
        preferences.getBool(DisplaySettingsLocalDatasource.comfortModeKey),
        isFalse,
      );
    });

    test('starts on when the previous session left it on', () async {
      final container = await _container({
        DisplaySettingsLocalDatasource.comfortModeKey: true,
      });

      expect(container.read(displaySettingsProvider).comfortMode, isTrue);
    });

    test('has a name the interface can show, and a plain description', () {
      expect(comfortModeName, 'Mode Confort');
      expect(comfortModeDescription, contains('plus grands'));
    });
  });

  group('comfortTextScale', () {
    test('makes text at least 30 % larger than the normal size', () {
      expect(comfortTextScale(1.0), closeTo(1.3, 0.001));
    });

    test('builds on a larger system setting instead of replacing it', () {
      expect(comfortTextScale(1.15), closeTo(1.495, 0.001));
    });

    test('never goes beyond twice the normal size, so layouts stay usable', () {
      expect(comfortTextScale(1.8), 2.0);
      expect(comfortTextScale(3.0), 2.0);
    });

    test(
      'never shrinks below the comfort size when the phone is set small',
      () {
        expect(comfortTextScale(0.8), closeTo(1.3, 0.001));
      },
    );
  });

  group('ComfortTextScale widget', () {
    Future<double> scaleSeenBy(
      WidgetTester tester, {
      required bool comfort,
      double systemScale = 1.0,
    }) async {
      late double seen;
      tester.platformDispatcher.textScaleFactorTestValue = systemScale;
      addTearDown(tester.platformDispatcher.clearAllTestValues);
      await tester.pumpWidget(
        MaterialApp(
          home: ComfortTextScale(
            comfort: comfort,
            child: Builder(
              builder: (context) {
                seen = MediaQuery.textScalerOf(context).scale(10) / 10;
                return const SizedBox();
              },
            ),
          ),
        ),
      );
      return seen;
    }

    testWidgets('leaves the phone setting alone when the mode is off', (
      tester,
    ) async {
      expect(await scaleSeenBy(tester, comfort: false, systemScale: 1.2), 1.2);
    });

    testWidgets('enlarges the text for everything below it when on', (
      tester,
    ) async {
      expect(await scaleSeenBy(tester, comfort: true), closeTo(1.3, 0.001));
    });

    testWidgets('stacks on the phone setting, up to twice the normal size', (
      tester,
    ) async {
      expect(await scaleSeenBy(tester, comfort: true, systemScale: 1.6), 2.0);
    });
  });

  group('comfort theme', () {
    test('asks for bigger touch targets than the normal theme', () {
      final comfort = AppTheme.comfort;
      final normal = AppTheme.light;

      final comfortButton = comfort.filledButtonTheme.style!.minimumSize!
          .resolve({})!;
      expect(comfortButton.height, greaterThanOrEqualTo(56));
      expect(normal.filledButtonTheme.style, isNull);
      expect(
        comfort.iconButtonTheme.style!.minimumSize!.resolve({})!.width,
        greaterThanOrEqualTo(56),
      );
      expect(
        comfort.textButtonTheme.style!.minimumSize!.resolve({})!.height,
        greaterThanOrEqualTo(48),
      );
    });

    test('draws thick field borders, thicker still on focus', () {
      final decoration = AppTheme.comfort.inputDecorationTheme;

      expect(
        (decoration.enabledBorder! as OutlineInputBorder).borderSide.width,
        greaterThanOrEqualTo(2),
      );
      expect(
        (decoration.focusedBorder! as OutlineInputBorder).borderSide.width,
        greaterThanOrEqualTo(3),
      );
    });

    test('reads at the AAA level (7:1) for its main text and buttons', () {
      final scheme = AppTheme.comfort.colorScheme;

      expect(
        contrastRatio(scheme.onSurface, scheme.surface),
        greaterThanOrEqualTo(7),
      );
      expect(
        contrastRatio(scheme.onPrimary, scheme.primary),
        greaterThanOrEqualTo(7),
      );
    });

    test('the normal theme already reaches the AA level (4.5:1)', () {
      final scheme = AppTheme.light.colorScheme;

      expect(
        contrastRatio(scheme.onSurface, scheme.surface),
        greaterThanOrEqualTo(4.5),
      );
      expect(
        contrastRatio(scheme.onPrimary, scheme.primary),
        greaterThanOrEqualTo(4.5),
      );
    });
  });
}
