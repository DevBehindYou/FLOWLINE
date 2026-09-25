enum SubtaskStatus { todo, done }

class Subtask {
  const Subtask({
    required this.id,
    required this.taskId,
    required this.title,
    required this.status,
    this.plannedSprints = 1,
    this.completedSprints = 0,
    this.orderIndex = 0,
  });

  final int id;
  final int taskId;
  final String title;
  final SubtaskStatus status;
  final int plannedSprints;
  final int completedSprints;
  final int orderIndex;

  Subtask copyWith({
    String? title,
    SubtaskStatus? status,
    int? plannedSprints,
    int? completedSprints,
  }) {
    return Subtask(
      id: id,
      taskId: taskId,
      title: title ?? this.title,
      status: status ?? this.status,
      plannedSprints: plannedSprints ?? this.plannedSprints,
      completedSprints: completedSprints ?? this.completedSprints,
      orderIndex: orderIndex,
    );
  }
}
