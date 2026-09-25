import 'dart:math' as math;

import 'package:civic_app/core/theme/feature_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

double contrastRatio(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  final lighter = math.max(la, lb);
  final darker = math.min(la, lb);
  return (lighter + 0.05) / (darker + 0.05);
}

void main() {
  test(
    'every feature colour carries white text at the AA level for normal text (4.5:1)',
    () {
      for (final color in FeatureColors.all) {
        expect(
          contrastRatio(color, Colors.white),
          greaterThanOrEqualTo(4.5),
          reason:
              '#${color.toARGB32().toRadixString(16)} is too light for white text',
        );
      }
    },
  );

  test('the contrast helper agrees with the WCAG reference values', () {
    expect(contrastRatio(Colors.black, Colors.white), closeTo(21, 0.01));
    expect(contrastRatio(Colors.white, Colors.white), closeTo(1, 0.01));
  });
}
