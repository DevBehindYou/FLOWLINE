import 'package:flowline/data/local/drift/app_database.dart';
import 'package:flowline/data/repositories/focus_session_repository_impl.dart';
import 'package:flowline/data/repositories/schedule_repository_impl.dart';
import 'package:flowline/data/repositories/task_repository_impl.dart';
import 'package:flowline/domain/entities/focus_session.dart';
import 'package:flowline/domain/entities/task.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/test_database.dart';

void main() {
  late AppDatabase db;
  late TaskRepositoryImpl tasks;
  late ScheduleRepositoryImpl schedule;
  late FocusSessionRepositoryImpl sessions;

  setUp(() {
    db = createTestDatabase();
    tasks = TaskRepositoryImpl(db);
    schedule = ScheduleRepositoryImpl(db);
    sessions = FocusSessionRepositoryImpl(db);
  });
  tearDown(() => db.close());

  test('foreign keys are enforced on every connection', () async {
    final row = await db.customSelect('PRAGMA foreign_keys').getSingle();
    expect(row.data.values.single, 1);
  });

  test('deleting a task deletes its subtasks instead of orphaning them',
      () async {
    final taskId =
        await tasks.createTask(title: 'Parent', priority: TaskPriority.low);
    await tasks.createSubtask(taskId: taskId, title: 'Child A');
    await tasks.createSubtask(taskId: taskId, title: 'Child B');

    await tasks.deleteTask(taskId);

    final remaining = await db.select(db.subtasks).get();
    expect(remaining, isEmpty);
  });

  test('deleting a task keeps its focus-session history but unlinks it',
      () async {
    final taskId =
        await tasks.createTask(title: 'Linked', priority: TaskPriority.low);
    final sessionId = await sessions.startSession(
      sessionType: FocusSessionType.focus,
      plannedDurationSec: 1500,
      taskId: taskId,
    );
    await sessions.completeSession(sessionId, endedEarly: false);

    await tasks.deleteTask(taskId);

    final row = await (db.select(db.focusSessions)
          ..where((s) => s.id.equals(sessionId)))
        .getSingle();
    expect(row.taskId, isNull);
    expect(row.completedAt, isNotNull,
        reason: 'history must survive the task delete');
  });

  test('deleting a schedule block moves its tasks to Unscheduled', () async {
    final blockId = await schedule.createBlock(
      title: 'Morning',
      startTime: DateTime(2026, 1, 1, 9),
      endTime: DateTime(2026, 1, 1, 10),
    );
    final taskId = await tasks.createTask(
      title: 'In the block',
      priority: TaskPriority.medium,
      scheduleBlockId: blockId,
    );

    await schedule.deleteBlock(blockId);

    final unscheduled =
        await tasks.watchUnscheduledTasks(done: false, limit: 50).first;
    expect(unscheduled.map((t) => t.id), contains(taskId));
  });

  test('starting while a session is active returns it unchanged (B6)',
      () async {
    final first = await sessions.startSession(
      sessionType: FocusSessionType.focus,
      plannedDurationSec: 1500,
    );
    // A duplicate start (double tap racing the rebuild) must neither close
    // the running session as "ended early" nor create a second one.
    final second = await sessions.startSession(
      sessionType: FocusSessionType.shortBreak,
      plannedDurationSec: 300,
    );

    expect(second, first);
    final rows = await db.select(db.focusSessions).get();
    expect(rows, hasLength(1));
    expect(rows.single.completedAt, isNull);
    expect(rows.single.endedEarly, isFalse);
    final active = await sessions.watchActiveSession().first;
    expect(active?.id, first);
  });

  test('a paused session is also kept when start is called again', () async {
    final first = await sessions.startSession(
      sessionType: FocusSessionType.focus,
      plannedDurationSec: 1500,
    );
    await sessions.pauseSession(first);

    expect(
      await sessions.startSession(
          sessionType: FocusSessionType.focus, plannedDurationSec: 1500),
      first,
    );
    expect(await db.select(db.focusSessions).get(), hasLength(1));
  });
}
