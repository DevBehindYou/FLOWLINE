import '../entities/focus_session.dart';

/// What to suggest after a session ends: a break after focus (a long one
/// after every [longBreakEvery]-th completed focus session today), and
/// focus after any break. Pure so the Pomodoro rhythm is unit-tested.
FocusSessionType suggestNextSession({
  required FocusSessionType finished,
  required int focusSessionsCompletedToday,
  required int longBreakEvery,
}) {
  if (finished != FocusSessionType.focus) return FocusSessionType.focus;
  final every = longBreakEvery < 1 ? 1 : longBreakEvery;
  final isLongBreakDue = focusSessionsCompletedToday > 0 &&
      focusSessionsCompletedToday % every == 0;
  return isLongBreakDue
      ? FocusSessionType.longBreak
      : FocusSessionType.shortBreak;
}
