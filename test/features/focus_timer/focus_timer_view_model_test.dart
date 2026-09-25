import 'package:drift/drift.dart' show Value;
import 'package:flowline/core/notifications/notification_service.dart';
import 'package:flowline/core/providers.dart';
import 'package:flowline/data/local/drift/app_database.dart';
import 'package:flowline/data/repositories/task_repository_impl.dart';
import 'package:flowline/domain/entities/focus_session.dart';
import 'package:flowline/domain/entities/task.dart';
import 'package:flowline/features/focus_timer/viewmodel/focus_timer_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/test_database.dart';

class _FakeNotificationService implements NotificationService {
  int cancels = 0;

  @override
  Future<void> init() async {}

  @override
  Future<void> scheduleSessionComplete({
    required DateTime fireAt,
    required String title,
    required String body,
  }) async {}

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
    container = ProviderContainer(overrides: [
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
    final id = await insertSession(anchor: DateTime(2026, 1, 1, 9), paused: true);

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
}
