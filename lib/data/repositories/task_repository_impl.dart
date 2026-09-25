import 'package:drift/drift.dart';

import '../../domain/entities/subtask.dart';
import '../../domain/entities/task.dart';
import '../../domain/repositories/task_repository.dart';
import '../local/drift/app_database.dart';

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
  Stream<List<Task>> watchUnscheduledTasks() {
    final query = _db.select(_db.tasks)
      ..where((t) => t.scheduleBlockId.isNull());
    return query.watch().map((rows) => rows.map(_mapTask).toList());
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
      ..orderBy([(s) => OrderingTerm.asc(s.orderIndex)]);
    return query.watch().map((rows) => rows.map(_mapSubtask).toList());
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
    return _db.into(_db.subtasks).insert(
          SubtasksCompanion.insert(
            taskId: taskId,
            title: title,
            status: SubtaskStatus.todo,
            plannedSprints: Value(plannedSprints),
          ),
        );
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
  Future<void> incrementSubtaskCompletedSprints(int subtaskId) async {
    final row = await (_db.select(_db.subtasks)
          ..where((s) => s.id.equals(subtaskId)))
        .getSingle();
    await (_db.update(_db.subtasks)..where((s) => s.id.equals(subtaskId)))
        .write(
      SubtasksCompanion(completedSprints: Value(row.completedSprints + 1)),
    );
  }

  Task _mapTask(TaskRow row) {
    return Task(
      id: row.id,
      title: row.title,
      notes: row.notes,
      priority: row.priority,
      status: row.status,
      scheduleBlockId: row.scheduleBlockId,
      dueAt: row.dueAt,
      createdAt: row.createdAt,
    );
  }

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
