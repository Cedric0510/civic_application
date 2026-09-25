import 'package:civic_app/shared/widgets/feature_app_bar.dart';
import 'package:civic_app/shared/widgets/section_title.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('a section title is announced as a heading', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: SectionTitle('Mes rendez-vous'))),
    );

    expect(
      tester.getSemantics(find.text('Mes rendez-vous')),
      matchesSemantics(label: 'Mes rendez-vous', isHeader: true),
    );
    handle.dispose();
  });

  testWidgets(
    'a feature header names its page as a heading and offers a labelled way back',
    (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CustomScrollView(
              slivers: [
                FeatureAppBar(title: 'Signalements', color: Color(0xFF6D4C41)),
              ],
            ),
          ),
        ),
      );

      expect(find.byTooltip('Retour'), findsOneWidget);
      expect(
        tester.getSemantics(find.text('Signalements').first),
        containsSemantics(label: 'Signalements', isHeader: true),
      );
      handle.dispose();
    },
  );

  testWidgets(
    'a feature header grows with the text so the title is never cut',
    (tester) async {
      tester.platformDispatcher.textScaleFactorTestValue = 1.6;
      addTearDown(tester.platformDispatcher.clearAllTestValues);
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CustomScrollView(
              slivers: [
                FeatureAppBar(title: 'Signalements', color: Color(0xFF6D4C41)),
              ],
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      final bar = tester.getSize(find.byType(FlexibleSpaceBar));
      expect(bar.height, greaterThan(80));
    },
  );
}
