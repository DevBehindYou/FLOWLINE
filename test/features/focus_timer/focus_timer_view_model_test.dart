import 'package:drift/drift.dart' show Value;
import 'package:atomic_assist/core/notifications/notification_service.dart';
import 'package:atomic_assist/core/providers.dart';
import 'package:atomic_assist/core/riverpod_config.dart';
import 'package:atomic_assist/data/local/drift/app_database.dart';
import 'package:atomic_assist/data/repositories/app_settings_repository_impl.dart';
import 'package:atomic_assist/domain/entities/app_settings.dart';
import 'package:atomic_assist/data/repositories/task_repository_impl.dart';
import 'package:atomic_assist/domain/entities/focus_session.dart';
import 'package:atomic_assist/domain/entities/task.dart';
import 'package:atomic_assist/features/focus_timer/viewmodel/focus_timer_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/test_database.dart';

class _FakeNotificationService implements NotificationService {
  // Reminder alerts (unused by these tests).
  @override
  Stream<({String action, int reminderId})> get reminderActions =>
      const Stream.empty();

  @override
  Future<void> scheduleReminder({
    required int notificationId,
    required int reminderId,
    required DateTime fireAt,
    required String title,
    required String channelName,
    required String channelDescription,
    required List<({String id, String label})> actions,
  }) async {}

  @override
  Future<void> cancel(int notificationId) async {}

  int cancels = 0;
  int schedules = 0;
  DateTime? lastFireAt;

  @override
  Future<void> init() async {}

  @override
  Future<void> scheduleSessionComplete({
    required DateTime fireAt,
    required String title,
    required String body,
  }) async {
    schedules++;
    lastFireAt = fireAt;
  }

  @override
  Future<void> requestPermission() async {}

  @override
  Future<bool> launchedFromNotification() async => false;

  @override
  Stream<void> get taps => const Stream.empty();

  @override
  Future<void> cancelSessionNotification() async => cancels++;
}

void main() {
  late AppDatabase db;
  late ProviderContainer container;
  late _FakeNotificationService notifications;

  setUp(() {
    db = createTestDatabase();
    notifications = _FakeNotificationService();
    container = ProviderContainer(retry: noAutomaticRetry, overrides: [
      appDatabaseProvider.overrideWith((ref) => db),
      notificationServiceProvider.overrideWith((ref) async => notifications),
    ]);
  });
  tearDown(() async {
    container.dispose();
    await db.close();
  });

  FocusTimerViewModel viewModel() =>
      container.read(focusTimerViewModelProvider.notifier);

  Future<int> insertSession({
    required DateTime anchor,
    int? subtaskId,
    bool paused = false,
  }) {
    return db.into(db.focusSessions).insert(
          FocusSessionsCompanion.insert(
            subtaskId: Value(subtaskId),
            sessionType: FocusSessionType.focus,
            plannedDurationSec: 1500,
            startedAt: anchor,
            segmentStartedAt: Value(paused ? null : anchor),
            remainingSecAtSegmentStart: 1500,
            isPaused: Value(paused),
          ),
        );
  }

  Future<FocusSessionRow> sessionRow(int id) =>
      (db.select(db.focusSessions)..where((s) => s.id.equals(id))).getSingle();

  test('completeIfElapsed records an expired session at its natural end',
      () async {
    final id = await insertSession(anchor: DateTime(2026, 1, 1, 9));

    await viewModel().completeIfElapsed();

    final done = await sessionRow(id);
    expect(done.completedAt, DateTime(2026, 1, 1, 9, 25));
    expect(done.endedEarly, isFalse);
    expect(notifications.cancels, 1);
  });

  test('completeIfElapsed leaves a session with time left alone', () async {
    final id = await insertSession(
      anchor: DateTime.now().subtract(const Duration(minutes: 1)),
    );

    await viewModel().completeIfElapsed();

    expect((await sessionRow(id)).completedAt, isNull);
    expect(notifications.cancels, 0);
  });

  test('completeIfElapsed leaves a paused session alone', () async {
    final id =
        await insertSession(anchor: DateTime(2026, 1, 1, 9), paused: true);

    await viewModel().completeIfElapsed();

    expect((await sessionRow(id)).completedAt, isNull);
  });

  test('racing completions credit the linked subtask exactly once', () async {
    final tasks = TaskRepositoryImpl(db);
    final taskId =
        await tasks.createTask(title: 'Write', priority: TaskPriority.high);
    final subtaskId = await tasks.createSubtask(taskId: taskId, title: 'Draft');
    await insertSession(anchor: DateTime(2026, 1, 1, 9), subtaskId: subtaskId);

    // The Focus screen and the app-resume check can both fire at zero.
    await Future.wait([
      viewModel().completeIfElapsed(),
      viewModel().completeIfElapsed(),
    ]);

    final subtask = await (db.select(db.subtasks)
          ..where((s) => s.id.equals(subtaskId)))
        .getSingle();
    expect(subtask.completedSprints, 1);
    expect(notifications.cancels, 1);
  });

  test('a failing notification service never costs the sprint credit (B4)',
      () async {
    // Notification init can fail on a real device (unknown timezone id,
    // revoked permission). The session is completed in the database
    // before notifications run, so the credit must not depend on them.
    final failing = ProviderContainer(retry: noAutomaticRetry, overrides: [
      appDatabaseProvider.overrideWith((ref) => db),
      notificationServiceProvider
          .overrideWith((ref) async => throw StateError('plugin failed')),
    ]);
    addTearDown(failing.dispose);

    final tasks = TaskRepositoryImpl(db);
    final taskId =
        await tasks.createTask(title: 'Write', priority: TaskPriority.high);
    final subtaskId = await tasks.createSubtask(taskId: taskId, title: 'Draft');
    final id = await insertSession(
        anchor: DateTime(2026, 1, 1, 9), subtaskId: subtaskId);

    await failing
        .read(focusTimerViewModelProvider.notifier)
        .completeIfElapsed();

    expect((await sessionRow(id)).completedAt, isNotNull);
    final subtask = await (db.select(db.subtasks)
          ..where((s) => s.id.equals(subtaskId)))
        .getSingle();
    expect(subtask.completedSprints, 1);
  });

  test('a session uses the focus length from settings', () async {
    await AppSettingsRepositoryImpl(db)
        .save(const AppSettings(focusMinutes: 50));
    await viewModel().startSession(type: FocusSessionType.focus);
    final row = await db.select(db.focusSessions).getSingle();
    expect(row.plannedDurationSec, 50 * 60);
    expect(notifications.schedules, 1);
  });

  test('no alert is scheduled when session alerts are off', () async {
    await AppSettingsRepositoryImpl(db)
        .save(const AppSettings(sessionAlerts: false));
    await viewModel().startSession(type: FocusSessionType.shortBreak);
    final row = await db.select(db.focusSessions).getSingle();
    expect(row.plannedDurationSec, 5 * 60);
    expect(notifications.schedules, 0);
  });

  test('completing publishes an outcome that suggests the next session',
      () async {
    await viewModel().startSession(type: FocusSessionType.focus);
    final active = (await container
        .read(focusSessionRepositoryProvider)
        .getActiveSession())!;
    await viewModel().complete(active, endedEarly: true);

    final outcome = container.read(lastSessionOutcomeProvider)!;
    expect(outcome.session.id, active.id);
    expect(outcome.endedEarly, isTrue);
    expect(outcome.focusSessionsToday, 1);
    expect(outcome.next, FocusSessionType.shortBreak);
  });

  test('a repeated completion publishes nothing new', () async {
    final id = await insertSession(anchor: DateTime(2026, 1, 1, 9));
    await viewModel().completeIfElapsed();
    container.read(lastSessionOutcomeProvider.notifier).clear();
    final row = await sessionRow(id);
    expect(row.completedAt, isNotNull);
    await viewModel().completeIfElapsed();
    expect(container.read(lastSessionOutcomeProvider), isNull);
  });
}
