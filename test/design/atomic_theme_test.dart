import 'dart:io';

import 'package:atomic_assist/design/atomic.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// WCAG 2.2 contrast ratio.
double contrast(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  final hi = la > lb ? la : lb;
  final lo = la > lb ? lb : la;
  return (hi + 0.05) / (lo + 0.05);
}

void main() {
  const aaText = 4.5;

  for (final (name, palette) in [
    ('light', AtomicPalette.light),
    ('dark', AtomicPalette.dark),
  ]) {
    group('$name palette', () {
      // Every text role on every surface it can sit on.
      final surfaces = {
        'background': palette.background,
        'card': palette.card,
        'panel': palette.panel,
        'raised': palette.raised,
      };
      final texts = {
        'text': palette.text,
        'textMuted': palette.textMuted,
        'accentText': palette.accentText,
        'danger': palette.danger,
      };
      for (final s in surfaces.entries) {
        for (final t in texts.entries) {
          test('${t.key} on ${s.key} meets AA', () {
            expect(contrast(t.value, s.value), greaterThanOrEqualTo(aaText));
          });
        }
      }

      test('fills and the text on them meet AA', () {
        for (final (label, fg, bg) in [
          ('onAccent on accent', palette.onAccent, palette.accent),
          ('onInverse on inverse', palette.onInverse, palette.inverse),
          (
            'onDangerContainer on dangerContainer',
            palette.onDangerContainer,
            palette.dangerContainer
          ),
        ]) {
          expect(contrast(fg, bg), greaterThanOrEqualTo(aaText), reason: label);
        }
      });

      test('control borders reach 3:1 against the background', () {
        expect(contrast(palette.rule, palette.background),
            greaterThanOrEqualTo(3));
      });
    });
  }

  group('the system\'s traps (§3.6) are never a text role', () {
    test('Signal on ink fails, so dark text uses signal-light', () {
      expect(contrast(AtomicColors.signal, AtomicColors.ink), lessThan(aaText));
      expect(AtomicPalette.dark.accentText, AtomicColors.signalLight);
    });

    test('energy orange on paper fails, so it is no text role', () {
      expect(contrast(AtomicColors.energyHigh, AtomicColors.paper),
          lessThan(aaText));
      for (final p in [AtomicPalette.light, AtomicPalette.dark]) {
        expect([p.text, p.textMuted, p.accentText, p.danger],
            isNot(contains(AtomicColors.energyHigh)));
      }
    });
  });

  for (final (name, theme) in [
    ('light', AtomicTheme.light()),
    ('dark', AtomicTheme.dark()),
  ]) {
    group('$name theme', () {
      final scheme = theme.colorScheme;

      test('Material roles used as text meet AA', () {
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
          ('error on surface', scheme.error, scheme.surface),
          ('onError on error', scheme.onError, scheme.error),
        ]) {
          expect(contrast(fg, bg), greaterThanOrEqualTo(aaText), reason: label);
        }
      });

      test('uses the three Atomic families in their roles', () {
        final t = theme.textTheme;
        for (final s in [t.displayLarge, t.headlineSmall, t.titleLarge]) {
          expect(s?.fontFamily, AtomicFonts.display);
        }
        for (final s in [t.bodyLarge, t.bodyMedium, t.titleSmall]) {
          expect(s?.fontFamily, AtomicFonts.body);
        }
        for (final s in [t.labelLarge, t.labelMedium, t.labelSmall]) {
          expect(s?.fontFamily, AtomicFonts.mono);
          expect(s!.fontSize, greaterThanOrEqualTo(12),
              reason: 'mono labels are never below 12 sp (§4.4)');
        }
      });

      test('carries the Atomic extension with the matching palette', () {
        final ext = theme.extension<AtomicThemeData>()!;
        expect(ext.palette.background, theme.scaffoldBackgroundColor);
      });

      test('no soft shapes: cards and buttons use radius 4', () {
        final card = theme.cardTheme.shape! as RoundedRectangleBorder;
        expect(card.borderRadius, BorderRadius.circular(AtomicRadius.sm));
        final sheet = theme.bottomSheetTheme.shape! as RoundedRectangleBorder;
        expect(sheet.borderRadius,
            const BorderRadius.vertical(top: Radius.circular(28)));
      });
    });
  }

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
