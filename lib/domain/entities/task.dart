enum TaskPriority { low, medium, high }

enum TaskStatus { todo, inProgress, done }

class Task {
  const Task({
    required this.id,
    required this.title,
    this.notes = '',
    required this.priority,
    required this.status,
    this.scheduleBlockId,
    this.dueAt,
    required this.createdAt,
  });

  final int id;
  final String title;
  final String notes;
  final TaskPriority priority;
  final TaskStatus status;
  final int? scheduleBlockId;
  final DateTime? dueAt;
  final DateTime createdAt;

  /// Nullable fields take a function so they can be cleared, not only
  /// changed: `copyWith(scheduleBlockId: () => null)` unschedules a task,
  /// while omitting the argument keeps the current value. (A plain
  /// `int? scheduleBlockId` can't tell "set to null" from "not given".)
  Task copyWith({
    String? title,
    String? notes,
    TaskPriority? priority,
    TaskStatus? status,
    int? Function()? scheduleBlockId,
    DateTime? Function()? dueAt,
  }) {
    return Task(
      id: id,
      title: title ?? this.title,
      notes: notes ?? this.notes,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      scheduleBlockId:
          scheduleBlockId != null ? scheduleBlockId() : this.scheduleBlockId,
      dueAt: dueAt != null ? dueAt() : this.dueAt,
      createdAt: createdAt,
    );
  }
}
