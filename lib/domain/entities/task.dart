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

  Task copyWith({
    String? title,
    String? notes,
    TaskPriority? priority,
    TaskStatus? status,
    int? scheduleBlockId,
    DateTime? dueAt,
  }) {
    return Task(
      id: id,
      title: title ?? this.title,
      notes: notes ?? this.notes,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      scheduleBlockId: scheduleBlockId ?? this.scheduleBlockId,
      dueAt: dueAt ?? this.dueAt,
      createdAt: createdAt,
    );
  }
}
