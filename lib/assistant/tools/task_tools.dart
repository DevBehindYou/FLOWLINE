import '../../domain/assistant/action_preview.dart';
import '../../domain/assistant/autonomy.dart';
import '../../domain/assistant/ledger.dart';
import '../../domain/assistant/tool.dart';
import '../../domain/entities/task.dart';
import 'args.dart';
import 'checks.dart';

// Reversible task tools. Each run returns the exact undo: a created row
// is deleted, an update restores the columns it changed (and refuses if
// the user has edited them since).

Task _found(Resolved<Task> r) => switch (r) {
      Found(:final value) => value,
      // run() only follows a Valid validate() in the same transaction.
      NotResolved(:final invalid) => throw StateError('$invalid'),
    };

const _priority = {
  'type': 'string',
  'enum': ['low', 'medium', 'high'],
};

typedef CreateTaskArgs = ({
  String title,
  DateTime? due,
  TaskPriority priority,
  String notes,
});

final class CreateTaskTool extends AssistantTool<CreateTaskArgs> {
  const CreateTaskTool();

  @override
  String get name => 'create_task';
  @override
  String get description => 'Adds a task to the backlog.';
  @override
  Map<String, Object?> get parameters => const {
        'type': 'object',
        'properties': {
          'title': {'type': 'string', 'maxLength': 200},
          'due': {
            'type': 'string',
            'description': 'Local date-time, YYYY-MM-DDTHH:MM.',
          },
          'priority': _priority,
          'notes': {'type': 'string', 'maxLength': 2000},
        },
        'required': ['title'],
      };
  @override
  ActionRisk get risk => ActionRisk.reversible;

  @override
  CreateTaskArgs parse(Map<String, Object?> json) => (
        title: requireString(json, 'title'),
        due: optionalDateTime(json, 'due'),
        priority: optionalEnum(json, 'priority', TaskPriority.values) ??
            TaskPriority.medium,
        notes: optionalString(json, 'notes', maxLength: 2000) ?? '',
      );

  @override
  Future<ToolValidation> validate(CreateTaskArgs a, ToolEnv env) async {
    if (a.due != null && isPast(a.due!, env.now)) {
      return const Invalid(InvalidReason.inPast, 'due');
    }
    return const Valid();
  }

  @override
  Future<ActionPreview> preview(CreateTaskArgs a, ToolEnv env) async =>
      CreateTaskPreview(title: a.title, priority: a.priority, due: a.due);

  @override
  Future<ToolOutcome> run(CreateTaskArgs a, ToolEnv env) async {
    final id = await env.tasks.createTask(
        title: a.title, notes: a.notes, priority: a.priority, dueAt: a.due);
    return ToolOutcome(
      result: {'task_id': id},
      undo: DeleteRows(UndoTable.tasks, [id]),
    );
  }
}

typedef UpdateTaskArgs = ({
  TaskRef task,
  String? title,
  String? notes,
  TaskPriority? priority,
  DateTime? due,
  bool clearDue,
});

final class UpdateTaskTool extends AssistantTool<UpdateTaskArgs> {
  const UpdateTaskTool();

  @override
  String get name => 'update_task';
  @override
  String get description =>
      'Changes a task\'s title, notes, priority or due time. Send only '
      'the fields to change; clear_due removes the due time.';
  @override
  Map<String, Object?> get parameters => const {
        'type': 'object',
        'properties': {
          ...taskRefProperties,
          'title': {'type': 'string', 'maxLength': 200},
          'notes': {'type': 'string', 'maxLength': 2000},
          'priority': _priority,
          'due': {
            'type': 'string',
            'description': 'Local date-time, YYYY-MM-DDTHH:MM.',
          },
          'clear_due': {'type': 'boolean'},
        },
      };
  @override
  ActionRisk get risk => ActionRisk.reversible;

  @override
  UpdateTaskArgs parse(Map<String, Object?> json) {
    final clearDue = json['clear_due'];
    if (clearDue != null && clearDue is! bool) {
      throw const ToolArgumentError('clear_due', 'must be a boolean');
    }
    final notes = json['notes'];
    if (notes != null && notes is! String) {
      throw const ToolArgumentError('notes', 'must be a string');
    }
    if (notes is String && notes.length > 2000) {
      throw const ToolArgumentError('notes', 'at most 2000 characters');
    }
    return (
      task: TaskRef.parse(json),
      title: optionalString(json, 'title'),
      // Empty notes are a real value here ("clear the notes").
      notes: (notes as String?)?.trim(),
      priority: optionalEnum(json, 'priority', TaskPriority.values),
      due: optionalDateTime(json, 'due'),
      clearDue: clearDue == true,
    );
  }

  Task _apply(Task t, UpdateTaskArgs a) => t.copyWith(
        title: a.title,
        notes: a.notes,
        priority: a.priority,
        dueAt: a.clearDue ? () => null : (a.due == null ? null : () => a.due),
      );

  Set<TaskField> _changed(Task before, Task after) => {
        if (before.title != after.title) TaskField.title,
        if (before.notes != after.notes) TaskField.notes,
        if (before.priority != after.priority) TaskField.priority,
        if (before.dueAt != after.dueAt) TaskField.due,
      };

  @override
  Future<ToolValidation> validate(UpdateTaskArgs a, ToolEnv env) async {
    final resolved = await resolveTask(env, a.task, includeDone: true);
    if (resolved case NotResolved(:final invalid)) return invalid;
    final task = _found(resolved);
    if (a.due != null && a.clearDue) {
      return const Invalid(InvalidReason.outOfRange, 'due and clear_due');
    }
    if (a.due != null && isPast(a.due!, env.now)) {
      return const Invalid(InvalidReason.inPast, 'due');
    }
    if (_changed(task, _apply(task, a)).isEmpty) {
      return const Invalid(InvalidReason.nothingToChange);
    }
    return const Valid();
  }

  @override
  Future<ActionPreview> preview(UpdateTaskArgs a, ToolEnv env) async {
    final task = _found(await resolveTask(env, a.task, includeDone: true));
    return UpdateTaskPreview(
        title: task.title, fields: _changed(task, _apply(task, a)));
  }

  @override
  Future<ToolOutcome> run(UpdateTaskArgs a, ToolEnv env) async {
    final task = _found(await resolveTask(env, a.task, includeDone: true));
    final before = await mustRow(env, UndoTable.tasks, task.id);
    await env.tasks.updateTask(_apply(task, a));
    final after = await mustRow(env, UndoTable.tasks, task.id);
    return ToolOutcome(
      result: {'task_id': task.id},
      undo: fieldsUndo(UndoTable.tasks, task.id, before, after),
    );
  }
}

final class CompleteTaskTool extends AssistantTool<TaskRef> {
  const CompleteTaskTool();

  @override
  String get name => 'complete_task';
  @override
  String get description => 'Marks an open task done.';
  @override
  Map<String, Object?> get parameters => const {
        'type': 'object',
        'properties': taskRefProperties,
      };
  @override
  ActionRisk get risk => ActionRisk.reversible;

  @override
  TaskRef parse(Map<String, Object?> json) => TaskRef.parse(json);

  @override
  Future<ToolValidation> validate(TaskRef ref, ToolEnv env) async {
    // By title, only open tasks are candidates: "mark report done" means
    // the open one, not last month's finished one.
    final resolved = await resolveTask(env, ref);
    if (resolved case NotResolved(:final invalid)) return invalid;
    if (_found(resolved).status == TaskStatus.done) {
      return const Invalid(InvalidReason.alreadyDone);
    }
    return const Valid();
  }

  @override
  Future<ActionPreview> preview(TaskRef ref, ToolEnv env) async =>
      CompleteTaskPreview(_found(await resolveTask(env, ref)).title);

  @override
  Future<ToolOutcome> run(TaskRef ref, ToolEnv env) async {
    final task = _found(await resolveTask(env, ref));
    final before = await mustRow(env, UndoTable.tasks, task.id);
    await env.tasks.setTaskStatus(task.id, TaskStatus.done);
    final after = await mustRow(env, UndoTable.tasks, task.id);
    return ToolOutcome(
      result: {'task_id': task.id},
      undo: fieldsUndo(UndoTable.tasks, task.id, before, after),
    );
  }
}

typedef ScheduleTaskArgs = ({TaskRef task, DateTime start, int minutes});

final class ScheduleTaskTool extends AssistantTool<ScheduleTaskArgs> {
  const ScheduleTaskTool();

  @override
  String get name => 'schedule_task';
  @override
  String get description =>
      'Gives a task its own time block. The time must be free: use '
      'find_free_time first when unsure.';
  @override
  Map<String, Object?> get parameters => const {
        'type': 'object',
        'properties': {
          ...taskRefProperties,
          'start': {
            'type': 'string',
            'description': 'Local date-time, YYYY-MM-DDTHH:MM.',
          },
          'minutes': {'type': 'integer', 'minimum': 5, 'maximum': 720},
        },
        'required': ['start', 'minutes'],
      };
  @override
  ActionRisk get risk => ActionRisk.reversible;

  @override
  ScheduleTaskArgs parse(Map<String, Object?> json) => (
        task: TaskRef.parse(json),
        start: requireDateTime(json, 'start'),
        minutes: requireInt(json, 'minutes', min: 5, max: 720),
      );

  DateTime _end(ScheduleTaskArgs a) =>
      a.start.add(Duration(minutes: a.minutes));

  @override
  Future<ToolValidation> validate(ScheduleTaskArgs a, ToolEnv env) async {
    final resolved = await resolveTask(env, a.task);
    if (resolved case NotResolved(:final invalid)) return invalid;
    if (_found(resolved).status == TaskStatus.done) {
      return const Invalid(InvalidReason.alreadyDone);
    }
    return await checkTimeRange(env, a.start, _end(a)) ?? const Valid();
  }

  @override
  Future<ActionPreview> preview(ScheduleTaskArgs a, ToolEnv env) async =>
      ScheduleTaskPreview(
        title: _found(await resolveTask(env, a.task)).title,
        start: a.start,
        end: _end(a),
      );

  @override
  Future<ToolOutcome> run(ScheduleTaskArgs a, ToolEnv env) async {
    final task = _found(await resolveTask(env, a.task));
    final blockId = await env.schedule
        .createBlock(title: task.title, startTime: a.start, endTime: _end(a));
    final before = await mustRow(env, UndoTable.tasks, task.id);
    await env.tasks.updateTask(task.copyWith(scheduleBlockId: () => blockId));
    final after = await mustRow(env, UndoTable.tasks, task.id);
    return ToolOutcome(
      result: {'task_id': task.id, 'block_id': blockId},
      // Undone in reverse: the task goes back first, then the block goes.
      undo: UndoAll([
        DeleteRows(UndoTable.scheduleBlocks, [blockId]),
        fieldsUndo(UndoTable.tasks, task.id, before, after)!,
      ]),
    );
  }
}

typedef BreakDownArgs = ({TaskRef task, List<String> steps});

final class BreakDownTaskTool extends AssistantTool<BreakDownArgs> {
  const BreakDownTaskTool();

  @override
  String get name => 'break_down_task';
  @override
  String get description =>
      'Adds 2 to 10 concrete steps to a task as subtasks, after any it '
      'already has.';
  @override
  Map<String, Object?> get parameters => const {
        'type': 'object',
        'properties': {
          ...taskRefProperties,
          'steps': {
            'type': 'array',
            'items': {'type': 'string', 'maxLength': 200},
            'minItems': 2,
            'maxItems': 10,
          },
        },
        'required': ['steps'],
      };
  @override
  ActionRisk get risk => ActionRisk.reversible;

  @override
  BreakDownArgs parse(Map<String, Object?> json) => (
        task: TaskRef.parse(json),
        steps: requireStringList(json, 'steps', minItems: 2, maxItems: 10),
      );

  @override
  Future<ToolValidation> validate(BreakDownArgs a, ToolEnv env) async {
    final resolved = await resolveTask(env, a.task);
    if (resolved case NotResolved(:final invalid)) return invalid;
    if (_found(resolved).status == TaskStatus.done) {
      return const Invalid(InvalidReason.alreadyDone);
    }
    return const Valid();
  }

  @override
  Future<ActionPreview> preview(BreakDownArgs a, ToolEnv env) async =>
      BreakDownTaskPreview(
          title: _found(await resolveTask(env, a.task)).title, steps: a.steps);

  @override
  Future<ToolOutcome> run(BreakDownArgs a, ToolEnv env) async {
    final task = _found(await resolveTask(env, a.task));
    final ids = [
      for (final step in a.steps)
        await env.tasks.createSubtask(taskId: task.id, title: step),
    ];
    return ToolOutcome(
      result: {'task_id': task.id, 'subtask_ids': ids},
      undo: DeleteRows(UndoTable.subtasks, ids),
    );
  }
}
