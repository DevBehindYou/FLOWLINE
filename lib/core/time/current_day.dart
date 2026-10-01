import 'dart:async';

import 'package:clock/clock.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/time/calendar_day.dart';

part 'current_day.g.dart';

/// Local midnight of the current day, and the one thing every "today"
/// window in the app watches (rule R9).
///
/// Tabs stay mounted in the shell, so a value computed once when a
/// provider was first built would keep showing yesterday after midnight
/// for as long as the app stays open (K7). This rolls over on its own at
/// the next local midnight, and [refresh] is called on app resume because
/// a suspended app's timers don't fire on time.
@Riverpod(keepAlive: true)
class CurrentDay extends _$CurrentDay {
  Timer? _rollover;

  @override
  DateTime build() {
    ref.onDispose(() => _rollover?.cancel());
    _scheduleRollover();
    return today();
  }

  /// Re-reads the clock; a no-op for listeners when the day hasn't changed.
  void refresh() {
    final now = today();
    if (now != state) state = now;
    _scheduleRollover();
  }

  void _scheduleRollover() {
    _rollover?.cancel();
    final now = clock.now();
    // A second past midnight, so the re-read can't land on 23:59:59.
    final wait = addDays(now, 1).difference(now) + const Duration(seconds: 1);
    _rollover = Timer(wait, refresh);
  }
}
