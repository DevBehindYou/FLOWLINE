import '../../domain/assistant/action_preview.dart';
import '../../domain/assistant/autonomy.dart';
import '../../domain/assistant/ledger.dart';
import '../../domain/assistant/tool.dart';
import '../../domain/entities/task.dart';
import 'args.dart';
import 'block_tools.dart' show notMovable;
import 'checks.dart';

// Destructive tools: the policy always asks first (a confirm that states
// what goes), and the undo recipe holds the deleted rows themselves.

final class DeleteTaskTool extends AssistantTool<TaskRef> {
  const DeleteTaskTool();

  @override
  String get name => 'delete_task';
  @override
  String get description =>
      'Deletes a task and its subtasks. Always confirmed by the user.';
  @override
  Map<String, Object?> get parameters => const {
        'type': 'object',
        'properties': taskRefProperties,
      };
  @override
  ActionRisk get risk => ActionRisk.destructive;

  @override
  TaskRef parse(Map<String, Object?> json) => TaskRef.parse(json);

  Future<Task> _task(TaskRef ref, ToolEnv env) async =>
      switch (await resolveTask(env, ref, includeDone: true)) {
        Found(:final value) => value,
        NotResolved(:final invalid) => throw StateError('$invalid'),
      };

  @override
  Future<ToolValidation> validate(TaskRef ref, ToolEnv env) async =>
      switch (await resolveTask(env, ref, includeDone: true)) {
        Found() => const Valid(),
        NotResolved(:final invalid) => invalid,
      };

  @override
  Future<ActionPreview> preview(TaskRef ref, ToolEnv env) async {
    final task = await _task(ref, env);
    final subtasks = await env.tasks.getSubtasks(task.id);
    return DeletePreview(
      kind: DeleteKind.task,
      titles: [task.title],
      subtaskCount: subtasks.length,
    );
  }

  @override
  Future<ToolOutcome> run(TaskRef ref, ToolEnv env) async {
    final task = await _task(ref, env);
    final taskRow = await mustRow(env, UndoTable.tasks, task.id);
    final subtaskRows =
        await env.storedRowsWhere(UndoTable.subtasks, 'task_id', task.id);
    // Focus history stays (its foreign keys are SET NULL); undo puts the
    // links back.
    final sessionRows = [
      ...await env.storedRowsWhere(UndoTable.focusSessions, 'task_id', task.id),
      for (final s in subtaskRows)
        ...await env.storedRowsWhere(
            UndoTable.focusSessions, 'subtask_id', s['id']! as int),
    ];
    final sessions = {for (final r in sessionRows) r['id']! as int: r};
    await env.tasks.deleteTask(task.id);
    return ToolOutcome(
      result: {'deleted_task_id': task.id},
      // Listed in the order of the change; undone in reverse: the task,
      // then its subtasks, then the session links.
      undo: UndoAll([
        for (final MapEntry(key: id, value: row) in sessions.entries)
          RestoreFields(
            UndoTable.focusSessions,
            id,
            before: {
              'task_id': row['task_id'],
              'subtask_id': row['subtask_id']
            },
            after: {
              'task_id': null,
              'subtask_id': null,
            },
          ),
        if (subtaskRows.isNotEmpty)
          RestoreRows(UndoTable.subtasks, subtaskRows),
        RestoreRows(UndoTable.tasks, [taskRow]),
      ]),
    );
  }
}

final class DeleteBlockTool extends AssistantTool<int> {
  const DeleteBlockTool();

  @override
  String get name => 'delete_block';
  @override
  String get description =>
      'Deletes a one-off block; its tasks become unscheduled. Always '
      'confirmed by the user. Repeating blocks are edited in the app.';
  @override
  Map<String, Object?> get parameters => const {
        'type': 'object',
        'properties': {
          'block_id': {'type': 'integer'},
        },
        'required': ['block_id'],
      };
  @override
  ActionRisk get risk => ActionRisk.destructive;

  @override
  int parse(Map<String, Object?> json) =>
      requireInt(json, 'block_id', min: -(1 << 52), max: 1 << 52);

  @override
  Future<ToolValidation> validate(int id, ToolEnv env) async {
    final block = await findBlock(env, id);
    final problem = notMovable(block, id);
    if (problem != null) return problem;
    // Deleting one day of a series writes an exception row; undoing that
    // is a later slice, so for now only one-off blocks.
    if (block!.isOccurrence || block.isComputedOccurrence) {
      return const Invalid(InvalidReason.notSupported, 'repeating');
    }
    return const Valid();
  }

  @override
  Future<ActionPreview> preview(int id, ToolEnv env) async {
    final block = (await findBlock(env, id))!;
    final tasks = await env.tasks.getTasksForBlock(id);
    return DeletePreview(
      kind: DeleteKind.block,
      titles: [block.title],
      unscheduledTaskCount: tasks.length,
    );
  }

  @override
  Future<ToolOutcome> run(int id, ToolEnv env) async {
    final blockRow = await mustRow(env, UndoTable.scheduleBlocks, id);
    final taskRows =
        await env.storedRowsWhere(UndoTable.tasks, 'schedule_block_id', id);
    await env.schedule.deleteBlock(id);
    return ToolOutcome(
      result: {'deleted_block_id': id},
      undo: UndoAll([
        for (final t in taskRows)
          RestoreFields(UndoTable.tasks, t['id']! as int,
              before: {'schedule_block_id': id},
              after: {'schedule_block_id': null}),
        RestoreRows(UndoTable.scheduleBlocks, [blockRow]),
      ]),
    );
  }
}
