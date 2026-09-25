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

    final unscheduled = await tasks.watchUnscheduledTasks().first;
    expect(unscheduled.map((t) => t.id), contains(taskId));
  });

  test('starting a session while one is active closes the old one first',
      () async {
    final first = await sessions.startSession(
      sessionType: FocusSessionType.focus,
      plannedDurationSec: 1500,
    );
    final second = await sessions.startSession(
      sessionType: FocusSessionType.shortBreak,
      plannedDurationSec: 300,
    );

    final active = await sessions.watchActiveSession().first;
    expect(active?.id, second);

    final old = await (db.select(db.focusSessions)
          ..where((s) => s.id.equals(first)))
        .getSingle();
    expect(old.completedAt, isNotNull);
    expect(old.endedEarly, isTrue);
  });
}
