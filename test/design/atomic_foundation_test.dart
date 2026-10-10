import 'package:atomic_assist/design/atomic.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _app(Widget child, {bool reduceMotion = false, bool dark = false}) =>
    MaterialApp(
      theme: AtomicTheme.light(),
      darkTheme: AtomicTheme.dark(),
      themeMode: dark ? ThemeMode.dark : ThemeMode.light,
      home: MediaQuery(
        data: MediaQueryData(disableAnimations: reduceMotion),
        child: Scaffold(body: child),
      ),
    );

void main() {
  group('AtomicText', () {
    testWidgets('mono shows capitals and keeps the words for screen readers',
        (tester) async {
      await tester.pumpWidget(_app(const AtomicText.mono('Due today')));
      final text = tester.widget<Text>(find.byType(Text));
      expect(text.data, 'DUE TODAY');
      expect(text.semanticsLabel, 'Due today');
      expect(text.style?.fontFamily, AtomicFonts.mono);
    });

    testWidgets('display keeps the string (Bebas Neue is caps-only)',
        (tester) async {
      await tester.pumpWidget(_app(const AtomicText.display('Today')));
      final text = tester.widget<Text>(find.byType(Text));
      expect(text.data, 'Today');
      expect(text.semanticsLabel, isNull);
      expect(text.style?.fontFamily, AtomicFonts.display);
      expect(text.style?.height, lessThanOrEqualTo(1.05),
          reason: 'display line-height stays 0.95–1.05 (§4.4)');
    });

    testWidgets('body is as written, in the theme text colour', (tester) async {
      await tester.pumpWidget(_app(const AtomicText.body('hello'), dark: true));
      final text = tester.widget<Text>(find.byType(Text));
      expect(text.data, 'hello');
      expect(text.style?.color, AtomicPalette.dark.text);
    });

    testWidgets('maxLines ellipsizes', (tester) async {
      await tester.pumpWidget(_app(const AtomicText.body('x', maxLines: 1)));
      expect(tester.widget<Text>(find.byType(Text)).overflow,
          TextOverflow.ellipsis);
    });
  });

  group('AtomicMotion', () {
    test('full motion uses the system durations', () {
      const m = AtomicMotion(reduced: false);
      expect(m.press, AtomicDurations.press);
      expect(m.toggle, AtomicDurations.toggle);
      expect(m.enter, AtomicDurations.enter);
      expect(m.slide, AtomicSpace.m);
      expect(m.ambient, isTrue);
    });

    test('reduced motion drops transforms and keeps short fades', () {
      const m = AtomicMotion(reduced: true);
      expect(m.press, Duration.zero);
      expect(m.toggle, Duration.zero);
      expect(m.enter, AtomicDurations.reducedFade);
      expect(m.slide, 0);
      expect(m.ambient, isFalse);
    });

    testWidgets('reads the OS setting from the context', (tester) async {
      late AtomicMotion motion;
      await tester.pumpWidget(_app(
        Builder(builder: (context) {
          motion = context.atomicMotion;
          return const SizedBox();
        }),
        reduceMotion: true,
      ));
      expect(motion.reduced, isTrue);
    });
  });

  group('AtomicTag', () {
    testWidgets('accent tone is a Signal fill with white text', (tester) async {
      await tester
          .pumpWidget(_app(const AtomicTag('Now', tone: AtomicTagTone.accent)));
      final box = tester.widget<Container>(find.byType(Container));
      final decoration = box.decoration! as BoxDecoration;
      expect(decoration.color, AtomicColors.signal);
      expect(tester.widget<Text>(find.byType(Text)).style?.color,
          AtomicColors.white);
    });

    testWidgets('quiet tone has no fill and muted text', (tester) async {
      await tester.pumpWidget(_app(const AtomicTag('Low')));
      final decoration = tester
          .widget<Container>(find.byType(Container))
          .decoration! as BoxDecoration;
      expect(decoration.color, isNull);
      expect(tester.widget<Text>(find.byType(Text)).style?.color,
          AtomicPalette.light.textMuted);
    });
  });
}
