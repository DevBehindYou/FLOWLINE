import 'package:flutter_riverpod/flutter_riverpod.dart' show Ref;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/providers.dart';
import '../../../domain/entities/focus_session.dart';

part 'focus_timer_view_model.g.dart';

const _durationBySessionType = {
  FocusSessionType.focus: 1500, // 25 min
  FocusSessionType.shortBreak: 300, // 5 min
  FocusSessionType.longBreak: 900, // 15 min
};

@riverpod
Stream<FocusSession?> activeFocusSession(Ref ref) {
  return ref.watch(focusSessionRepositoryProvider).watchActiveSession();
}

@riverpod
Stream<({int totalSeconds, int sessionCount})> todaysFocusSummary(Ref ref) {
  return ref.watch(focusSessionRepositoryProvider).watchTodaysSessions().map((sessions) {
    final completedFocusSessions = sessions.where(
      (s) => s.sessionType == FocusSessionType.focus && s.completedAt != null,
    );
    final total = completedFocusSessions.fold<int>(
      0,
      (sum, s) => sum + (s.actualDurationSec ?? 0),
    );
    return (totalSeconds: total, sessionCount: completedFocusSessions.length);
  });
}

/// Ticks once a second. Watched only while a session is actually running,
/// purely to force the countdown display to rebuild — the countdown
/// value itself always comes from `FocusSession.remainingSec`, which is
/// wall-clock derived, never from counting these ticks.
@riverpod
Stream<int> secondsTicker(Ref ref) {
  return Stream.periodic(const Duration(seconds: 1), (tick) => tick);
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
@riverpod
class PendingFocusLink extends _$PendingFocusLink {
  @override
  ({int taskId, int? subtaskId, String label})? build() => null;

  void set({required int taskId, int? subtaskId, required String label}) {
    state = (taskId: taskId, subtaskId: subtaskId, label: label);
  }

  void clear() => state = null;
}

@riverpod
class FocusTimerViewModel extends _$FocusTimerViewModel {
  @override
  void build() {}

  Future<void> startSession({
    required FocusSessionType type,
    int? taskId,
    int? subtaskId,
  }) async {
    await ref.read(focusSessionRepositoryProvider).startSession(
          sessionType: type,
          plannedDurationSec: _durationBySessionType[type]!,
          taskId: taskId,
          subtaskId: subtaskId,
        );
    ref.read(pendingFocusLinkProvider.notifier).clear();
    await _scheduleNotification(type, _durationBySessionType[type]!);
  }

  Future<void> pause(FocusSession session) async {
    await ref.read(focusSessionRepositoryProvider).pauseSession(session.id);
    final notifier = await ref.read(notificationServiceProvider.future);
    await notifier.cancelSessionNotification();
  }

  Future<void> resume(FocusSession session) async {
    await ref.read(focusSessionRepositoryProvider).resumeSession(session.id);
    await _scheduleNotification(session.sessionType, session.remainingSec);
  }

  Future<void> extend(FocusSession session, {int addSeconds = 300}) async {
    await ref.read(focusSessionRepositoryProvider).extendSession(session.id, addSeconds);
    if (session.isRunning) {
      await _scheduleNotification(session.sessionType, session.remainingSec + addSeconds);
    }
  }

  Future<void> complete(FocusSession session, {required bool endedEarly}) async {
    await ref
        .read(focusSessionRepositoryProvider)
        .completeSession(session.id, endedEarly: endedEarly);

    final notifier = await ref.read(notificationServiceProvider.future);
    await notifier.cancelSessionNotification();

    final shouldCountSprint = !endedEarly &&
        session.sessionType == FocusSessionType.focus &&
        session.subtaskId != null;
    if (shouldCountSprint) {
      await ref.read(taskRepositoryProvider).incrementSubtaskCompletedSprints(session.subtaskId!);
    }
  }

  Future<void> _scheduleNotification(FocusSessionType type, int inSeconds) async {
    final notifier = await ref.read(notificationServiceProvider.future);
    await notifier.scheduleSessionComplete(
      fireAt: DateTime.now().add(Duration(seconds: inSeconds)),
      title: switch (type) {
        FocusSessionType.focus => 'Focus session complete',
        FocusSessionType.shortBreak => 'Short break over',
        FocusSessionType.longBreak => 'Long break over',
      },
      body: 'Tap to see what\'s next.',
    );
  }
}
