import 'package:drift/drift.dart';

import '../../domain/entities/subtask.dart';
import '../../domain/entities/task.dart';
import '../../domain/repositories/task_repository.dart';
import '../local/drift/app_database.dart';
import 'row_mappers.dart';

class TaskRepositoryImpl implements TaskRepository {
  TaskRepositoryImpl(this._db);

  final AppDatabase _db;

  @override
  Stream<List<Task>> watchTasksForBlock(int scheduleBlockId) {
    final query = _db.select(_db.tasks)
      ..where((t) => t.scheduleBlockId.equals(scheduleBlockId));
    return query.watch().map((rows) => rows.map(_mapTask).toList());
  }

  @override
  Stream<List<Task>> watchUnscheduledTasks({
    required bool done,
    required int limit,
  }) {
    final query = _db.select(_db.tasks)
      ..where((t) {
        final isDone = t.status.equalsValue(TaskStatus.done);
        return t.scheduleBlockId.isNull() & (done ? isDone : isDone.not());
      })
      ..orderBy(
          [(t) => done ? OrderingTerm.desc(t.id) : OrderingTerm.asc(t.id)])
      ..limit(limit);
    return query.watch().map((rows) => rows.map(_mapTask).toList());
  }

  @override
  Stream<int> watchUnscheduledDoneCount() {
    final count = _db.tasks.id.count();
    final query = _db.selectOnly(_db.tasks)
      ..addColumns([count])
      ..where(_db.tasks.scheduleBlockId.isNull() &
          _db.tasks.status.equalsValue(TaskStatus.done));
    return query.watchSingle().map((row) => row.read(count) ?? 0);
  }

  @override
  Stream<Task?> watchTask(int id) {
    final query = _db.select(_db.tasks)..where((t) => t.id.equals(id));
    return query
        .watchSingleOrNull()
        .map((row) => row == null ? null : _mapTask(row));
  }

  @override
  Stream<List<Subtask>> watchSubtasks(int taskId) {
    final query = _db.select(_db.subtasks)
      ..where((s) => s.taskId.equals(taskId))
      // id breaks ties: subtasks created before ordering existed all
      // have orderIndex 0, and keep their creation order.
      ..orderBy([
        (s) => OrderingTerm.asc(s.orderIndex),
        (s) => OrderingTerm.asc(s.id),
      ]);
    return query.watch().map((rows) => rows.map(_mapSubtask).toList());
  }

  @override
  Future<Task?> getTask(int id) async {
    final row = await (_db.select(_db.tasks)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    return row == null ? null : _mapTask(row);
  }

  @override
  Future<List<Subtask>> getSubtasks(int taskId) async {
    final rows = await (_db.select(_db.subtasks)
          ..where((s) => s.taskId.equals(taskId))
          ..orderBy([
            (s) => OrderingTerm.asc(s.orderIndex),
            (s) => OrderingTerm.asc(s.id),
          ]))
        .get();
    return rows.map(_mapSubtask).toList();
  }

  @override
  Future<List<Task>> getTasksForBlock(int scheduleBlockId) async {
    final rows = await (_db.select(_db.tasks)
          ..where((t) => t.scheduleBlockId.equals(scheduleBlockId))
          ..orderBy([(t) => OrderingTerm.asc(t.id)]))
        .get();
    return rows.map(_mapTask).toList();
  }

  @override
  Future<List<Task>> findTasks(String query,
      {bool includeDone = false, int limit = 20}) async {
    // instr(lower(...)) rather than LIKE, so % and _ in the query are
    // plain characters, not wildcards.
    final needle = query.trim().toLowerCase();
    final rows = await (_db.select(_db.tasks)
          ..where((t) {
            final notDone = t.status.equalsValue(TaskStatus.done).not();
            final matches = needle.isEmpty
                ? const Constant(true)
                : FunctionCallExpression<int>(
                        'instr', [t.title.lower(), Variable(needle)])
                    .isBiggerThanValue(0);
            return includeDone ? matches : matches & notDone;
          })
          ..orderBy([(t) => OrderingTerm.asc(t.id)])
          ..limit(limit))
        .get();
    return rows.map(_mapTask).toList();
  }

  @override
  Future<int> createTask({
    required String title,
    String notes = '',
    required TaskPriority priority,
    int? scheduleBlockId,
    DateTime? dueAt,
  }) {
    return _db.into(_db.tasks).insert(
          TasksCompanion.insert(
            title: title,
            notes: Value(notes),
            priority: priority,
            status: TaskStatus.todo,
            scheduleBlockId: Value(scheduleBlockId),
            dueAt: Value(dueAt),
          ),
        );
  }

  @override
  Future<void> updateTask(Task task) {
    return (_db.update(_db.tasks)..where((t) => t.id.equals(task.id))).write(
      TasksCompanion(
        title: Value(task.title),
        notes: Value(task.notes),
        priority: Value(task.priority),
        status: Value(task.status),
        scheduleBlockId: Value(task.scheduleBlockId),
        dueAt: Value(task.dueAt),
      ),
    );
  }

  @override
  Future<void> deleteTask(int id) {
    return (_db.delete(_db.tasks)..where((t) => t.id.equals(id))).go();
  }

  @override
  Future<void> setTaskStatus(int id, TaskStatus status) {
    return (_db.update(_db.tasks)..where((t) => t.id.equals(id)))
        .write(TasksCompanion(status: Value(status)));
  }

  @override
  Future<int> createSubtask({
    required int taskId,
    required String title,
    int plannedSprints = 1,
  }) {
    // Appended after the task's last subtask, in the same transaction as
    // the read, so two quick adds can't take the same position.
    return _db.transaction(() async {
      final last = _db.subtasks.orderIndex.max();
      final row = await (_db.selectOnly(_db.subtasks)
            ..addColumns([last])
            ..where(_db.subtasks.taskId.equals(taskId)))
          .getSingle();
      final next = (row.read(last) ?? -1) + 1;
      return _db.into(_db.subtasks).insert(
            SubtasksCompanion.insert(
              taskId: taskId,
              title: title,
              status: SubtaskStatus.todo,
              plannedSprints: Value(plannedSprints),
              orderIndex: Value(next),
            ),
          );
    });
  }

  @override
  Future<void> reorderSubtasks(int taskId, List<int> subtaskIds) {
    return _db.transaction(() async {
      for (final (index, id) in subtaskIds.indexed) {
        // Scoped to the task, so a stray id can't move another task's
        // subtask.
        await (_db.update(_db.subtasks)
              ..where((s) => s.id.equals(id) & s.taskId.equals(taskId)))
            .write(SubtasksCompanion(orderIndex: Value(index)));
      }
    });
  }

  @override
  Future<void> setSubtaskStatus(int id, SubtaskStatus status) {
    return (_db.update(_db.subtasks)..where((s) => s.id.equals(id)))
        .write(SubtasksCompanion(status: Value(status)));
  }

  @override
  Future<void> deleteSubtask(int id) {
    return (_db.delete(_db.subtasks)..where((s) => s.id.equals(id))).go();
  }

  @override
  Future<void> incrementSubtaskCompletedSprints(int subtaskId) {
    // One statement, so two concurrent increments can't both read the old
    // value and lose one (a read-then-write would). `updates` keeps
    // Drift's watch() streams on subtasks refreshing.
    return _db.customUpdate(
      'UPDATE subtasks SET completed_sprints = completed_sprints + 1 '
      'WHERE id = ?',
      variables: [Variable.withInt(subtaskId)],
      updates: {_db.subtasks},
    );
  }

  Task _mapTask(TaskRow row) => taskFromRow(row);

  Subtask _mapSubtask(SubtaskRow row) {
    return Subtask(
      id: row.id,
      taskId: row.taskId,
      title: row.title,
      status: row.status,
      plannedSprints: row.plannedSprints,
      completedSprints: row.completedSprints,
      orderIndex: row.orderIndex,
    );
  }
}
