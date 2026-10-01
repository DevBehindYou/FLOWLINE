import 'package:flowline/core/riverpod_config.dart';
import 'package:flowline/core/time/current_day.dart';
import 'package:flowline/domain/time/calendar_day.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // testWidgets runs in FakeAsync, which also drives package:clock, so
  // pumping time moves both the rollover timer and clock.now() together.
  // Each test disposes its container at the end of the body: the
  // framework's "no pending timers" check runs before tear-downs, so it
  // also proves dispose cancels the rollover timer.

  testWidgets('rolls over to the next day at midnight without a rebuild (K7)',
      (tester) async {
    final container = ProviderContainer(retry: noAutomaticRetry);
    final seen = <DateTime>[];
    container.listen(currentDayProvider, (_, next) => seen.add(next),
        fireImmediately: true);
    final first = seen.single;
    expect(first, today());

    await tester.pump(const Duration(hours: 24));

    expect(container.read(currentDayProvider), addDays(first, 1));
    expect(seen.last, addDays(first, 1));
    expect(seen.every((d) => d.hour == 0 && d.minute == 0), isTrue);
    container.dispose();
  });

  testWidgets('keeps rolling over on later days', (tester) async {
    final container = ProviderContainer(retry: noAutomaticRetry);
    final first = container.read(currentDayProvider);
    for (var i = 1; i <= 3; i++) {
      await tester.pump(const Duration(hours: 24));
      expect(container.read(currentDayProvider), addDays(first, i));
    }
    container.dispose();
  });

  testWidgets('refresh() is a no-op for listeners on the same day',
      (tester) async {
    final container = ProviderContainer(retry: noAutomaticRetry);
    var notifications = 0;
    container.listen(currentDayProvider, (_, __) => notifications++);

    container.read(currentDayProvider.notifier).refresh();
    container.read(currentDayProvider.notifier).refresh();

    expect(notifications, 0);
    container.dispose();
  });
}
