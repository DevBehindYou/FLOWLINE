import '../entities/task.dart';

// Typed descriptions of what a tool call does (docs/05 §9.1). The single
// source for every sentence AA says about an action: the chat, the Inbox,
// confirm sheets, the ledger and the spoken reply all word these with
// l10n, so they never disagree. Pure Dart, no English.

sealed class ActionPreview {
  const ActionPreview();
}

enum ReadKind { agenda, freeTime, searchTasks, task }

/// A read tool: nothing changes.
final class ReadPreview extends ActionPreview {
  const ReadPreview(this.kind, {this.day});
  final ReadKind kind;
  final DateTime? day;
}

final class CreateTaskPreview extends ActionPreview {
  const CreateTaskPreview({
    required this.title,
    required this.priority,
    this.due,
  });
  final String title;
  final TaskPriority priority;
  final DateTime? due;
}

enum TaskField { title, notes, priority, due }

final class UpdateTaskPreview extends ActionPreview {
  const UpdateTaskPreview({required this.title, required this.fields});

  /// The title before the change.
  final String title;
  final Set<TaskField> fields;
}

final class CompleteTaskPreview extends ActionPreview {
  const CompleteTaskPreview(this.title);
  final String title;
}

final class ScheduleTaskPreview extends ActionPreview {
  const ScheduleTaskPreview({
    required this.title,
    required this.start,
    required this.end,
  });
  final String title;
  final DateTime start;
  final DateTime end;
}

final class CreateBlockPreview extends ActionPreview {
  const CreateBlockPreview({
    required this.title,
    required this.start,
    required this.end,
  });
  final String title;
  final DateTime start;
  final DateTime end;
}

final class MoveBlockPreview extends ActionPreview {
  const MoveBlockPreview({
    required this.title,
    required this.fromStart,
    required this.fromEnd,
    required this.toStart,
    required this.toEnd,
  });
  final String title;
  final DateTime fromStart;
  final DateTime fromEnd;
  final DateTime toStart;
  final DateTime toEnd;
}

final class StartFocusPreview extends ActionPreview {
  const StartFocusPreview({required this.minutes, this.taskTitle});
  final int minutes;
  final String? taskTitle;
}

final class BreakDownTaskPreview extends ActionPreview {
  const BreakDownTaskPreview({required this.title, required this.steps});
  final String title;
  final List<String> steps;
}

enum DeleteKind { task, block }

/// States exactly what goes (design system §9.9): the confirm sheet lists
/// [titles] and says how many dependent rows go with them.
final class DeletePreview extends ActionPreview {
  const DeletePreview({
    required this.kind,
    required this.titles,
    this.subtaskCount = 0,
    this.unscheduledTaskCount = 0,
  });
  final DeleteKind kind;
  final List<String> titles;

  /// Subtasks deleted with a task.
  final int subtaskCount;

  /// Tasks a deleted block leaves unscheduled (they are kept).
  final int unscheduledTaskCount;
}
