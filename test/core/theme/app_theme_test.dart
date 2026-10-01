import 'dart:io';

import 'package:flowline/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

double _contrast(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  final hi = la > lb ? la : lb;
  final lo = la > lb ? lb : la;
  return (hi + 0.05) / (lo + 0.05);
}

void main() {
  for (final (name, theme) in [
    ('light', AppTheme.light()),
    ('dark', AppTheme.dark()),
  ]) {
    group('$name theme', () {
      final scheme = theme.colorScheme;

      // WCAG AA for normal text is 4.5:1.
      test('text and primary pairs meet WCAG AA', () {
        for (final (label, fg, bg) in [
          ('onSurface on surface', scheme.onSurface, scheme.surface),
          (
            'onSurfaceVariant on surface',
            scheme.onSurfaceVariant,
            scheme.surface
          ),
          ('primary on surface', scheme.primary, scheme.surface),
          (
            'primary on container-high',
            scheme.primary,
            scheme.surfaceContainerHigh
          ),
          ('onPrimary on primary', scheme.onPrimary, scheme.primary),
          ('onError on error', scheme.onError, scheme.error),
        ]) {
          expect(_contrast(fg, bg), greaterThanOrEqualTo(4.5), reason: label);
        }
      });

      test('uses the bundled typefaces', () {
        final text = theme.textTheme;
        for (final style in [text.displayLarge, text.headlineSmall]) {
          expect(style?.fontFamily, FlowlineFonts.display);
        }
        for (final style in [text.titleMedium, text.bodyMedium]) {
          expect(style?.fontFamily, FlowlineFonts.text);
        }
      });
    });
  }

  test('the dark primary is the token value (docs/design-tokens/DECISIONS.md)',
      () {
    expect(AppTheme.dark().colorScheme.primary, const Color(0xFFC0C1FF));
  });

  test('every font asset in pubspec.yaml exists', () {
    final assets = RegExp(r'asset: (\S+)')
        .allMatches(File('pubspec.yaml').readAsStringSync())
        .map((m) => m.group(1)!)
        .toList();
    expect(assets, isNotEmpty);
    for (final path in assets) {
      expect(File(path).existsSync(), isTrue, reason: path);
    }
  });
}
