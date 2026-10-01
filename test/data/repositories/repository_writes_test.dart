import 'package:flowline/data/local/drift/app_database.dart';
import 'package:flowline/data/repositories/schedule_repository_impl.dart';
import 'package:flowline/data/repositories/task_repository_impl.dart';
import 'package:flowline/domain/entities/schedule_block.dart';
import 'package:flowline/domain/entities/subtask.dart';
import 'package:flowline/domain/entities/task.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/test_database.dart';

void main() {
  late AppDatabase db;
  late TaskRepositoryImpl tasks;
  late ScheduleRepositoryImpl schedule;

  setUp(() {
    db = createTestDatabase();
    tasks = TaskRepositoryImpl(db);
    schedule = ScheduleRepositoryImpl(db);
  });
  tearDown(() => db.close());

  test('updateTask writes every editable field, including clearing', () async {
    final blockId = await schedule.createBlock(
        title: 'B',
        startTime: DateTime(2026, 3, 10, 9),
        endTime: DateTime(2026, 3, 10, 10));
    final id = await tasks.createTask(
      title: 'Old',
      priority: TaskPriority.low,
      scheduleBlockId: blockId,
      dueAt: DateTime(2026, 3, 12),
    );
    final task = (await tasks.watchTask(id).first)!;

    await tasks.updateTask(task.copyWith(
      title: 'New',
      notes: 'n',
      priority: TaskPriority.high,
      status: TaskStatus.inProgress,
      scheduleBlockId: () => null,
      dueAt: () => null,
    ));

    final updated = (await tasks.watchTask(id).first)!;
    expect(updated.title, 'New');
    expect(updated.notes, 'n');
    expect(updated.priority, TaskPriority.high);
    expect(updated.status, TaskStatus.inProgress);
    expect(updated.scheduleBlockId, isNull);
    expect(updated.dueAt, isNull);
    expect(await tasks.watchUnscheduledTasks(done: false, limit: 50).first,
        hasLength(1));
  });

  test('task status, subtask status and subtask delete', () async {
    final id = await tasks.createTask(title: 'T', priority: TaskPriority.low);
    await tasks.setTaskStatus(id, TaskStatus.done);
    expect((await tasks.watchTask(id).first)!.status, TaskStatus.done);

    final subId =
        await tasks.createSubtask(taskId: id, title: 'S', plannedSprints: 3);
    await tasks.setSubtaskStatus(subId, SubtaskStatus.done);
    final sub = (await tasks.watchSubtasks(id).first).single;
    expect(sub.status, SubtaskStatus.done);
    expect(sub.plannedSprints, 3);

    await tasks.deleteSubtask(subId);
    expect(await tasks.watchSubtasks(id).first, isEmpty);
  });

  test('watchTask emits null once the task is deleted', () async {
    final id = await tasks.createTask(title: 'T', priority: TaskPriority.low);
    await tasks.deleteTask(id);
    expect(await tasks.watchTask(id).first, isNull);
  });

  test('tasks are listed per block', () async {
    final a = await schedule.createBlock(
        title: 'A',
        startTime: DateTime(2026, 3, 10, 9),
        endTime: DateTime(2026, 3, 10, 10));
    await tasks.createTask(
        title: 'in A', priority: TaskPriority.low, scheduleBlockId: a);
    await tasks.createTask(title: 'loose', priority: TaskPriority.low);
    expect((await tasks.watchTasksForBlock(a).first).single.title, 'in A');
  });

  test('updateBlock moves a block between days', () async {
    final id = await schedule.createBlock(
        title: 'Move me',
        startTime: DateTime(2026, 3, 10, 9),
        endTime: DateTime(2026, 3, 10, 10));
    final block =
        (await schedule.watchBlocksForDay(DateTime(2026, 3, 10)).first).single;

    await schedule.updateBlock(block.copyWith(
      title: 'Moved',
      startTime: DateTime(2026, 3, 11, 14),
      endTime: DateTime(2026, 3, 11, 15),
    ));

    expect(
        await schedule.watchBlocksForDay(DateTime(2026, 3, 10)).first, isEmpty);
    final moved =
        (await schedule.watchBlocksForDay(DateTime(2026, 3, 11)).first).single;
    expect(moved.id, id);
    expect(moved.title, 'Moved');
    expect(moved.source, ScheduleBlockSource.local);
  });

  test('a block can not end before it starts (schema CHECK)', () async {
    await expectLater(
      schedule.createBlock(
          title: 'Bad',
          startTime: DateTime(2026, 3, 10, 10),
          endTime: DateTime(2026, 3, 10, 9)),
      throwsA(anything),
    );
  });

  test('Subtask.copyWith keeps identity and changes fields', () {
    const subtask =
        Subtask(id: 1, taskId: 2, title: 'a', status: SubtaskStatus.todo);
    final copy = subtask.copyWith(
        title: 'b',
        status: SubtaskStatus.done,
        plannedSprints: 4,
        completedSprints: 2);
    expect([copy.id, copy.taskId, copy.orderIndex], [1, 2, 0]);
    expect(copy.title, 'b');
    expect(copy.status, SubtaskStatus.done);
    expect([copy.plannedSprints, copy.completedSprints], [4, 2]);
    expect(subtask.copyWith().title, 'a');
  });
}
