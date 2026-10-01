import 'package:flowline/domain/entities/focus_session.dart';
import 'package:flowline/domain/services/session_planner.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  FocusSessionType next(FocusSessionType finished, int done, {int every = 4}) =>
      suggestNextSession(
          finished: finished,
          focusSessionsCompletedToday: done,
          longBreakEvery: every);

  test('a short break after focus, a long one every fourth', () {
    expect(next(FocusSessionType.focus, 1), FocusSessionType.shortBreak);
    expect(next(FocusSessionType.focus, 3), FocusSessionType.shortBreak);
    expect(next(FocusSessionType.focus, 4), FocusSessionType.longBreak);
    expect(next(FocusSessionType.focus, 8), FocusSessionType.longBreak);
  });

  test('respects the configured rhythm', () {
    expect(
        next(FocusSessionType.focus, 2, every: 2), FocusSessionType.longBreak);
  });

  test('focus after any break', () {
    expect(next(FocusSessionType.shortBreak, 4), FocusSessionType.focus);
    expect(next(FocusSessionType.longBreak, 4), FocusSessionType.focus);
  });

  test('never a long break when nothing is done yet', () {
    expect(next(FocusSessionType.focus, 0), FocusSessionType.shortBreak);
  });
}
