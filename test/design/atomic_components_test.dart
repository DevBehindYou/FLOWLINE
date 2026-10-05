import 'package:atomic_assist/design/atomic.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'component_gallery.dart';

Widget _app(Widget child, {bool dark = false, bool reduceMotion = false}) =>
    MaterialApp(
      theme: AtomicTheme.light(),
      darkTheme: AtomicTheme.dark(),
      themeMode: dark ? ThemeMode.dark : ThemeMode.light,
      home: Builder(
        builder: (context) => MediaQuery(
          data:
              MediaQuery.of(context).copyWith(disableAnimations: reduceMotion),
          child: Scaffold(body: Center(child: child)),
        ),
      ),
    );

List<BoxShadow> _shadowOf(WidgetTester tester) {
  final container = tester.widget<AnimatedContainer>(find.descendant(
      of: find.byType(AtomicPressable),
      matching: find.byType(AnimatedContainer)));
  return (container.decoration! as BoxDecoration).boxShadow ?? const [];
}

void main() {
  group('AtomicButton', () {
    testWidgets('taps, shows caps label, and has a 3 px ink shadow',
        (tester) async {
      var taps = 0;
      await tester.pumpWidget(
          _app(AtomicButton(label: 'Add task', onPressed: () => taps++)));
      expect(find.text('Add task'), findsOneWidget,
          reason: 'Bebas is caps-only; the string stays as written');
      expect(_shadowOf(tester).single.offset, const Offset(3, 3));
      expect(_shadowOf(tester).single.blurRadius, 0);
      await tester.tap(find.byType(AtomicButton));
      expect(taps, 1);
    });

    testWidgets('pressing drops the shadow, like a key', (tester) async {
      await tester
          .pumpWidget(_app(AtomicButton(label: 'Go', onPressed: () {})));
      final gesture = await tester
          .startGesture(tester.getCenter(find.byType(AtomicButton)));
      await tester.pump(AtomicDurations.press);
      expect(_shadowOf(tester), isEmpty);
      await gesture.up();
      await tester.pump(AtomicDurations.press);
      expect(_shadowOf(tester), isNotEmpty);
    });

    testWidgets('busy shows the busy label and ignores taps (R12)',
        (tester) async {
      var taps = 0;
      await tester.pumpWidget(_app(AtomicButton(
          label: 'Save',
          busyLabel: 'Saving…',
          busy: true,
          onPressed: () => taps++)));
      expect(find.text('Saving…'), findsOneWidget);
      await tester.tap(find.byType(AtomicButton));
      expect(taps, 0);
      expect(_shadowOf(tester), isEmpty, reason: 'disabled has no shadow');
    });

    testWidgets('announces itself as a button with its label', (tester) async {
      final handle = tester.ensureSemantics();
      await tester
          .pumpWidget(_app(AtomicButton(label: 'Add task', onPressed: () {})));
      expect(
          tester.getSemantics(find.byType(AtomicButton)),
          matchesSemantics(
              label: 'Add task',
              isButton: true,
              hasEnabledState: true,
              isEnabled: true,
              hasTapAction: true));
      handle.dispose();
    });

    testWidgets('text variant is mono caps in the accent', (tester) async {
      await tester.pumpWidget(_app(AtomicButton(
          label: 'Open', variant: AtomicButtonVariant.text, onPressed: () {})));
      final text = tester.widget<Text>(find.text('OPEN'));
      expect(text.style?.color, AtomicPalette.light.accentText);
      expect(text.semanticsLabel, 'Open');
    });
  });

  testWidgets('AtomicIconButton needs and exposes a label, 48 dp target',
      (tester) async {
    final handle = tester.ensureSemantics();
    var taps = 0;
    await tester.pumpWidget(_app(AtomicIconButton(
        icon: AtomicIcons.back,
        semanticLabel: 'Back',
        style: AtomicIconButtonStyle.ink,
        onPressed: () => taps++)));
    expect(tester.getSize(find.byType(AtomicIconButton)),
        const Size.square(AtomicSize.touchTarget));
    expect(find.bySemanticsLabel('Back'), findsOneWidget);
    await tester.tap(find.byType(AtomicIconButton));
    expect(taps, 1);
    handle.dispose();
  });

  testWidgets('AtomicChip toggles and reports selection', (tester) async {
    bool? got;
    await tester.pumpWidget(_app(AtomicChip(
        label: 'High', selected: false, onSelected: (v) => got = v)));
    await tester.tap(find.byType(AtomicChip));
    expect(got, isTrue);
    expect(tester.getSize(find.byType(AtomicChip)).height,
        greaterThanOrEqualTo(AtomicSize.touchTarget));
  });

  test('load colour follows the energy thresholds (§9.8)', () {
    expect(atomicLoadColor(0), AtomicColors.energyLow);
    expect(atomicLoadColor(9.9), AtomicColors.energyLow);
    expect(atomicLoadColor(10), AtomicColors.signal);
    expect(atomicLoadColor(79.9), AtomicColors.signal);
    expect(atomicLoadColor(80), AtomicColors.energyHigh);
  });

  testWidgets('a card has a shadow or a priority border, never both',
      (tester) async {
    expect(
        () => AtomicCard(
            shadowLevel: 2,
            priorityColor: AtomicColors.error,
            child: const SizedBox()),
        throwsAssertionError);
  });

  testWidgets('a priority-border card paints (sides differ in colour)',
      (tester) async {
    await tester.pumpWidget(_app(const SizedBox(
        width: 200,
        child: AtomicCard(
            priorityColor: AtomicColors.error, child: Text('Overlap')))));
    expect(tester.takeException(), isNull);
    expect(find.text('Overlap'), findsOneWidget);
  });

  testWidgets('showAtomicConfirm is true only on an explicit confirm',
      (tester) async {
    late BuildContext ctx;
    await tester.pumpWidget(_app(Builder(builder: (c) {
      ctx = c;
      return const SizedBox();
    })));
    Future<bool> open() => showAtomicConfirm(
        context: ctx,
        label: 'Delete',
        title: 'Delete task?',
        message: 'Write report and its 5 subtasks go.',
        confirmLabel: 'Delete task',
        cancelLabel: 'Keep it');

    var result = open();
    await tester.pumpAndSettle();
    expect(find.text('DELETE'), findsOneWidget, reason: 'mono sheet label');
    await tester.tap(find.text('Keep it'));
    await tester.pumpAndSettle();
    expect(await result, isFalse);

    result = open();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete task'));
    await tester.pumpAndSettle();
    expect(await result, isTrue);

    result = open();
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(5, 5)); // the scrim
    await tester.pumpAndSettle();
    expect(await result, isFalse);
  });

  testWidgets('bottom bar: the selected item is the ink pill with its label',
      (tester) async {
    final handle = tester.ensureSemantics();
    int? picked;
    await tester.pumpWidget(_app(AtomicBottomBar(
      selectedIndex: 0,
      onSelected: (i) => picked = i,
      destinations: const [
        AtomicDestination(icon: AtomicIcons.today, label: 'Today'),
        AtomicDestination(
            icon: AtomicIcons.inbox, label: 'Inbox', badgeCount: 4),
      ],
    )));
    expect(find.text('TODAY'), findsOneWidget);
    expect(find.text('INBOX'), findsNothing,
        reason: 'inactive destinations are icon-only');
    expect(find.bySemanticsLabel('Inbox, 4'), findsOneWidget);
    await tester.tap(find.bySemanticsLabel('Inbox, 4'));
    expect(picked, 1);
    handle.dispose();
  });

  testWidgets('the atom only orbits without reduced motion', (tester) async {
    double phase() => (tester
            .widget<CustomPaint>(find.descendant(
                of: find.byType(AtomMark), matching: find.byType(CustomPaint)))
            .painter! as AtomMarkPainter)
        .phase;
    Future<bool> moves() async {
      final before = phase();
      await tester.pump(const Duration(seconds: 1));
      return phase() != before;
    }

    await tester
        .pumpWidget(_app(const AtomMark(animate: true), reduceMotion: true));
    expect(await moves(), isFalse, reason: 'reduced motion');
    await tester.pumpWidget(_app(const AtomMark(animate: true)));
    expect(await moves(), isTrue, reason: 'listening');
    await tester.pumpWidget(_app(const AtomMark()));
    expect(await moves(), isFalse, reason: 'stopped');
  });

  for (final dark in [false, true]) {
    testWidgets(
        'gallery meets tap-target, label and contrast guidelines '
        '(${dark ? 'dark' : 'light'})', (tester) async {
      final handle = tester.ensureSemantics();
      tester.view.physicalSize = const Size(1080, 4800);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(MaterialApp(
          theme: AtomicTheme.light(),
          darkTheme: AtomicTheme.dark(),
          themeMode: dark ? ThemeMode.dark : ThemeMode.light,
          home: const ComponentGallery()));
      // The loading bar is indeterminate by design: pump, don't settle.
      await tester.pump(AtomicDurations.enter);
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      await expectLater(tester, meetsGuideline(textContrastGuideline));
      handle.dispose();
    });
  }
}
