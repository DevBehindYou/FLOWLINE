import 'package:atomic_assist/features/focus_timer/widgets/timer_ring.dart';
import 'package:atomic_assist/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('diameterFor', () {
    test('uses most of a phone\'s width', () {
      expect(
        TimerRing.diameterFor(availableWidth: 360, screenHeight: 740),
        closeTo(259.2, 0.01),
      );
    });

    test('is capped by the height in landscape, but never below 160', () {
      expect(
          TimerRing.diameterFor(availableWidth: 740, screenHeight: 360), 160);
    });

    test('stops growing on a tablet', () {
      expect(
          TimerRing.diameterFor(availableWidth: 1200, screenHeight: 1600), 360);
    });
  });

  testWidgets('the ring takes the size it computes', (tester) async {
    tester.view.physicalSize = const Size(720, 1480); // 360 x 740 dp
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: Scaffold(
        body: Center(
          child: TimerRing(
              remainingSec: 600, plannedSec: 1500, color: Colors.indigo),
        ),
      ),
    ));
    final ring = tester.getSize(find.byType(TimerRing));
    expect(ring.width, closeTo(259.2, 0.01));
    expect(ring.height, ring.width);
  });
}
