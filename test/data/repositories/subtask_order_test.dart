import 'package:drift/drift.dart' show Value;
import 'package:flowline/data/local/drift/app_database.dart';
import 'package:flowline/data/repositories/task_repository_impl.dart';
import 'package:flowline/domain/entities/subtask.dart';
import 'package:flowline/domain/entities/task.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/test_database.dart';

void main() {
  late AppDatabase db;
  late TaskRepositoryImpl tasks;
  setUp(() {
    db = createTestDatabase();
    tasks = TaskRepositoryImpl(db);
  });
  tearDown(() => db.close());

  Future<List<String>> titles(int taskId) async =>
      (await tasks.watchSubtasks(taskId).first).map((s) => s.title).toList();

  test('new subtasks are appended in order', () async {
    final task = await tasks.createTask(title: 'T', priority: TaskPriority.low);
    for (final t in ['a', 'b', 'c']) {
      await tasks.createSubtask(taskId: task, title: t);
    }
    final subtasks = await tasks.watchSubtasks(task).first;
    expect(subtasks.map((s) => s.title), ['a', 'b', 'c']);
    expect(subtasks.map((s) => s.orderIndex), [0, 1, 2]);
  });

  test('reorder stores the new order', () async {
    final task = await tasks.createTask(title: 'T', priority: TaskPriority.low);
    final ids = [
      for (final t in ['a', 'b', 'c'])
        await tasks.createSubtask(taskId: task, title: t),
    ];
    await tasks.reorderSubtasks(task, [ids[2], ids[0], ids[1]]);
    expect(await titles(task), ['c', 'a', 'b']);

    // A subtask added afterwards still goes last.
    await tasks.createSubtask(taskId: task, title: 'd');
    expect(await titles(task), ['c', 'a', 'b', 'd']);
  });

  test("reorder can't move another task's subtask", () async {
    final mine = await tasks.createTask(title: 'A', priority: TaskPriority.low);
    final other =
        await tasks.createTask(title: 'B', priority: TaskPriority.low);
    final a = await tasks.createSubtask(taskId: mine, title: 'a');
    final foreign = await tasks.createSubtask(taskId: other, title: 'x');
    await tasks.createSubtask(taskId: other, title: 'y');

    await tasks.reorderSubtasks(mine, [foreign, a]);
    expect(await titles(other), ['x', 'y']);
  });

  test('subtasks from before ordering keep their creation order', () async {
    final task = await tasks.createTask(title: 'T', priority: TaskPriority.low);
    for (final t in ['first', 'second']) {
      // As written before this fix: every orderIndex 0.
      await db.into(db.subtasks).insert(SubtasksCompanion.insert(
            taskId: task,
            title: t,
            status: SubtaskStatus.todo,
            orderIndex: const Value(0),
          ));
    }
    expect(await titles(task), ['first', 'second']);
  });
}
