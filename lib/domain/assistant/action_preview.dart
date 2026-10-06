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

final class CreateReminderPreview extends ActionPreview {
  const CreateReminderPreview({required this.title, required this.at});
  final String title;
  final DateTime at;
}

final class SnoozeReminderPreview extends ActionPreview {
  const SnoozeReminderPreview({required this.title, required this.until});
  final String title;
  final DateTime until;
}

final class CompleteReminderPreview extends ActionPreview {
  const CompleteReminderPreview(this.title);
  final String title;
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

// ---- Stored form ---------------------------------------------------------
// Previews are stored with each ledger row (schema v10), so Activity and
// the chat can word an action after the fact (a deleted task can't be
// previewed again). Enum *names* and epoch milliseconds, so the form
// survives enum growth and time zones; decoding never throws.

Map<String, Object?> previewToJson(ActionPreview p) {
  int ms(DateTime t) => t.millisecondsSinceEpoch;
  return switch (p) {
    ReadPreview(:final kind, :final day) => {
        'k': 'read',
        'kind': kind.name,
        if (day != null) 'day': ms(day),
      },
    CreateTaskPreview(:final title, :final priority, :final due) => {
        'k': 'createTask',
        'title': title,
        'priority': priority.name,
        if (due != null) 'due': ms(due),
      },
    UpdateTaskPreview(:final title, :final fields) => {
        'k': 'updateTask',
        'title': title,
        'fields': [for (final f in fields) f.name],
      },
    CompleteTaskPreview(:final title) => {'k': 'completeTask', 'title': title},
    ScheduleTaskPreview(:final title, :final start, :final end) => {
        'k': 'scheduleTask',
        'title': title,
        'start': ms(start),
        'end': ms(end),
      },
    CreateBlockPreview(:final title, :final start, :final end) => {
        'k': 'createBlock',
        'title': title,
        'start': ms(start),
        'end': ms(end),
      },
    MoveBlockPreview(
      :final title,
      :final fromStart,
      :final fromEnd,
      :final toStart,
      :final toEnd
    ) =>
      {
        'k': 'moveBlock',
        'title': title,
        'fromStart': ms(fromStart),
        'fromEnd': ms(fromEnd),
        'toStart': ms(toStart),
        'toEnd': ms(toEnd),
      },
    StartFocusPreview(:final minutes, :final taskTitle) => {
        'k': 'startFocus',
        'minutes': minutes,
        if (taskTitle != null) 'task': taskTitle,
      },
    BreakDownTaskPreview(:final title, :final steps) => {
        'k': 'breakDown',
        'title': title,
        'steps': steps,
      },
    CreateReminderPreview(:final title, :final at) => {
        'k': 'createReminder',
        'title': title,
        'at': ms(at),
      },
    SnoozeReminderPreview(:final title, :final until) => {
        'k': 'snoozeReminder',
        'title': title,
        'until': ms(until),
      },
    CompleteReminderPreview(:final title) => {
        'k': 'completeReminder',
        'title': title,
      },
    DeletePreview(
      :final kind,
      :final titles,
      :final subtaskCount,
      :final unscheduledTaskCount
    ) =>
      {
        'k': 'delete',
        'kind': kind.name,
        'titles': titles,
        'subtasks': subtaskCount,
        'unscheduled': unscheduledTaskCount,
      },
  };
}

/// The preview in [json], or null when it isn't one this version reads.
ActionPreview? previewFromJson(Object? json) {
  if (json is! Map) return null;
  try {
    return _decode(json);
  } on FormatException {
    return null;
  }
}

ActionPreview _decode(Map<Object?, Object?> j) {
  String str(String k) =>
      j[k] is String ? j[k]! as String : throw FormatException(k);
  int integer(String k) =>
      j[k] is int ? j[k]! as int : throw FormatException(k);
  DateTime time(String k) => DateTime.fromMillisecondsSinceEpoch(integer(k));
  DateTime? optTime(String k) => j[k] == null ? null : time(k);
  T byName<T extends Enum>(List<T> values, String k) {
    final n = str(k);
    for (final v in values) {
      if (v.name == n) return v;
    }
    throw FormatException('$k $n');
  }

  List<String> strings(String k) {
    final v = j[k];
    if (v is! List || v.any((e) => e is! String)) throw FormatException(k);
    return v.cast<String>();
  }

  return switch (j['k']) {
    'read' => ReadPreview(byName(ReadKind.values, 'kind'), day: optTime('day')),
    'createTask' => CreateTaskPreview(
        title: str('title'),
        priority: byName(TaskPriority.values, 'priority'),
        due: optTime('due')),
    'updateTask' => UpdateTaskPreview(title: str('title'), fields: {
        for (final f in strings('fields'))
          TaskField.values.firstWhere((v) => v.name == f,
              orElse: () => throw FormatException('field $f')),
      }),
    'completeTask' => CompleteTaskPreview(str('title')),
    'scheduleTask' => ScheduleTaskPreview(
        title: str('title'), start: time('start'), end: time('end')),
    'createBlock' => CreateBlockPreview(
        title: str('title'), start: time('start'), end: time('end')),
    'moveBlock' => MoveBlockPreview(
        title: str('title'),
        fromStart: time('fromStart'),
        fromEnd: time('fromEnd'),
        toStart: time('toStart'),
        toEnd: time('toEnd')),
    'startFocus' => StartFocusPreview(
        minutes: integer('minutes'),
        taskTitle: j['task'] == null ? null : str('task')),
    'breakDown' =>
      BreakDownTaskPreview(title: str('title'), steps: strings('steps')),
    'createReminder' =>
      CreateReminderPreview(title: str('title'), at: time('at')),
    'snoozeReminder' =>
      SnoozeReminderPreview(title: str('title'), until: time('until')),
    'completeReminder' => CompleteReminderPreview(str('title')),
    'delete' => DeletePreview(
        kind: byName(DeleteKind.values, 'kind'),
        titles: strings('titles'),
        subtaskCount: integer('subtasks'),
        unscheduledTaskCount: integer('unscheduled')),
    _ => throw FormatException('kind ${j['k']}'),
  };
}
