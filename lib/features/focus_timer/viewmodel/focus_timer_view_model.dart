import 'package:clock/clock.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/notifications/notification_service.dart';
import '../../../core/providers.dart';
import '../../../core/time/current_day.dart';
import '../../../domain/entities/focus_session.dart';
import '../../../domain/services/session_planner.dart';
import '../../../domain/time/calendar_day.dart';
import '../../../l10n/l10n.dart';

part 'focus_timer_view_model.g.dart';

@riverpod
Stream<FocusSession?> activeFocusSession(Ref ref) {
  return ref.watch(focusSessionRepositoryProvider).watchActiveSession();
}

@riverpod
Stream<({int totalSeconds, int sessionCount})> todaysFocusSummary(Ref ref) {
  final day = dayRange(ref.watch(currentDayProvider));
  return ref
      .watch(focusSessionRepositoryProvider)
      .watchCompletedSessionsInRange(day.start, day.end)
      .map((sessions) {
    final completedFocusSessions = sessions.where(
      (s) => s.sessionType == FocusSessionType.focus,
    );
    final total = completedFocusSessions.fold<int>(
      0,
      (sum, s) => sum + (s.actualDurationSec ?? 0),
    );
    return (totalSeconds: total, sessionCount: completedFocusSessions.length);
  });
}

/// How a session that just ended went, and what to do next. Published by
/// [FocusTimerViewModel.complete] only for the call that actually
/// completed the session; the Focus screen shows it as the Session
/// Summary sheet and then clears it.
class SessionOutcome {
  const SessionOutcome({
    required this.session,
    required this.actualSec,
    required this.endedEarly,
    required this.next,
    required this.focusSessionsToday,
  });

  final FocusSession session;
  final int actualSec;
  final bool endedEarly;
  final FocusSessionType next;
  final int focusSessionsToday;
}

// keepAlive: written by the view model when nothing may be watching (the
// session can end while another tab is open) and read when Focus shows.
@Riverpod(keepAlive: true)
class LastSessionOutcome extends _$LastSessionOutcome {
  @override
  SessionOutcome? build() => null;

  void publish(SessionOutcome outcome) => state = outcome;
  void clear() => state = null;
}

@riverpod
class SelectedSessionType extends _$SelectedSessionType {
  @override
  FocusSessionType build() => FocusSessionType.focus;

  void set(FocusSessionType type) => state = type;
}

/// Staged task/subtask to attach to the *next* session that gets started —
/// set from the Today or Task Detail screens before jumping to the Focus
/// tab, consumed (and cleared) once a session actually starts.
///
/// keepAlive because it's a hand-off: it's written while nothing watches
/// it (the Focus tab may never have been built yet), and an auto-dispose
/// provider could drop the link before the Focus screen reads it (B9).
@Riverpod(keepAlive: true)
class PendingFocusLink extends _$PendingFocusLink {
  @override
  ({int taskId, int? subtaskId, String label})? build() => null;

  void set({required int taskId, int? subtaskId, required String label}) {
    state = (taskId: taskId, subtaskId: subtaskId, label: label);
  }

  void clear() => state = null;
}

// keepAlive (rule R11): an action surface whose methods use `ref` after
// an `await`. Auto-dispose would let it be disposed mid-action (the sheet
// or screen that called it closes), and Riverpod 3 throws on any use of a
// disposed Ref.
@Riverpod(keepAlive: true)
class FocusTimerViewModel extends _$FocusTimerViewModel {
  @override
  void build() {}

  Future<void> startSession({
    required FocusSessionType type,
    int? taskId,
    int? subtaskId,
  }) async {
    // Read fresh rather than from the stream provider, so a session started
    // right after changing a duration in Settings uses the new value.
    final settings = await ref.read(appSettingsRepositoryProvider).get();
    final plannedSec = settings.minutesFor(type) * 60;
    await ref.read(focusSessionRepositoryProvider).startSession(
          sessionType: type,
          plannedDurationSec: plannedSec,
          taskId: taskId,
          subtaskId: subtaskId,
        );
    ref.read(pendingFocusLinkProvider.notifier).clear();
    await _scheduleNotification(type, plannedSec);
  }

  Future<void> pause(FocusSession session) async {
    await ref.read(focusSessionRepositoryProvider).pauseSession(session.id);
    await _notify((service) => service.cancelSessionNotification());
  }

  Future<void> resume(FocusSession session) async {
    await ref.read(focusSessionRepositoryProvider).resumeSession(session.id);
    await _scheduleNotification(session.sessionType, session.remainingSec);
  }

  Future<void> extend(FocusSession session, {int addSeconds = 300}) async {
    await ref
        .read(focusSessionRepositoryProvider)
        .extendSession(session.id, addSeconds);
    if (session.isRunning) {
      await _scheduleNotification(
          session.sessionType, session.remainingSec + addSeconds);
    }
  }

  Future<void> complete(FocusSession session,
      {required bool endedEarly}) async {
    final completedNow = await ref
        .read(focusSessionRepositoryProvider)
        .completeSession(session.id, endedEarly: endedEarly);
    // Already completed by an earlier call (the Focus screen can ask more
    // than once around zero): crediting again would double-count sprints.
    if (!completedNow) return;

    // Data first: completeSession already returned true, so this is the
    // only chance to credit the sprint. A notification failure below must
    // not be able to skip it.
    final shouldCountSprint = !endedEarly &&
        session.sessionType == FocusSessionType.focus &&
        session.subtaskId != null;
    if (shouldCountSprint) {
      await ref
          .read(taskRepositoryProvider)
          .incrementSubtaskCompletedSprints(session.subtaskId!);
    }

    await _notify((service) => service.cancelSessionNotification());
    await _publishOutcome(session, endedEarly: endedEarly);
  }

  Future<void> _publishOutcome(FocusSession session,
      {required bool endedEarly}) async {
    final sessions = ref.read(focusSessionRepositoryProvider);
    final today = dayRange(clock.now());
    final completed =
        await sessions.getCompletedSessionsInRange(today.start, today.end);
    // By id: a session that ran out overnight was completed yesterday.
    final finished = await sessions.getSession(session.id);
    final focusToday =
        completed.where((s) => s.sessionType == FocusSessionType.focus).length;
    final settings = await ref.read(appSettingsRepositoryProvider).get();
    ref.read(lastSessionOutcomeProvider.notifier).publish(SessionOutcome(
          session: finished ?? session,
          actualSec: finished?.actualDurationSec ?? 0,
          endedEarly: endedEarly,
          focusSessionsToday: focusToday,
          next: suggestNextSession(
            finished: session.sessionType,
            focusSessionsCompletedToday: focusToday,
            longBreakEvery: settings.longBreakEvery,
          ),
        ));
  }

  /// Completes the active session if its time already ran out while
  /// nothing was watching it: app backgrounded, Focus tab not yet built,
  /// or process killed. Safe to call at any time.
  Future<void> completeIfElapsed() async {
    final session =
        await ref.read(focusSessionRepositoryProvider).getActiveSession();
    if (session == null || !session.isRunning || session.remainingSec > 0) {
      return;
    }
    await complete(session, endedEarly: false);
  }

  Future<void> _scheduleNotification(
      FocusSessionType type, int inSeconds) async {
    final settings = await ref.read(appSettingsRepositoryProvider).get();
    if (!settings.sessionAlerts) return;
    await _notify((service) => service.requestPermission());
    final l10n = deviceLocalizations();
    return _notify(
      (service) => service.scheduleSessionComplete(
        fireAt: clock.now().add(Duration(seconds: inSeconds)),
        title: switch (type) {
          FocusSessionType.focus => l10n.notifyFocusComplete,
          FocusSessionType.shortBreak => l10n.notifyShortBreakOver,
          FocusSessionType.longBreak => l10n.notifyLongBreakOver,
        },
        body: l10n.notifyBody,
      ),
    );
  }

  /// Notifications are a convenience on top of the timer, never part of
  /// its correctness: the session state is already persisted by the time
  /// this runs. A failing plugin (permission revoked, unknown timezone,
  /// OEM quirk) must not turn a successful start/pause/complete into an
  /// error, so failures are swallowed here.
  Future<void> _notify(
    Future<void> Function(NotificationService service) action,
  ) async {
    try {
      final service = await ref.read(notificationServiceProvider.future);
      await action(service);
    } catch (_) {
      // Deliberately ignored; see above.
    }
  }
}
