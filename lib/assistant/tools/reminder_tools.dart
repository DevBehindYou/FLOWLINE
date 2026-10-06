import '../../domain/assistant/action_preview.dart';
import '../../domain/assistant/autonomy.dart';
import '../../domain/assistant/ledger.dart';
import '../../domain/assistant/tool.dart';
import '../../domain/entities/reminder.dart';
import 'args.dart';
import 'checks.dart';

// Reminders (docs/05 §13). Each change touches the notification only
// after the transaction commits (ReminderTouched), so a rolled-back
// action can't leave an alert behind.

/// A year ahead is the most a reminder may be set for.
const _maxDaysAhead = 366;

Future<Reminder?> _open(ToolEnv env, int id) async {
  final r = await env.reminders.get(id);
  return r == null || !r.isOpen ? null : r;
}

Invalid? _checkTime(DateTime at, DateTime now) {
  if (isPast(at, now)) return const Invalid(InvalidReason.inPast, 'at');
  if (at.isAfter(now.add(const Duration(hours: 24 * _maxDaysAhead)))) {
    return const Invalid(InvalidReason.outOfRange, 'at most a year ahead');
  }
  return null;
}

typedef CreateReminderArgs = ({String title, DateTime at, TaskRef? task});

final class CreateReminderTool extends AssistantTool<CreateReminderArgs> {
  const CreateReminderTool();

  @override
  String get name => 'create_reminder';
  @override
  String get description =>
      'Reminds the user of something at a time: a notification fires then.';
  @override
  Map<String, Object?> get parameters => const {
        'type': 'object',
        'properties': {
          'title': {'type': 'string', 'maxLength': 200},
          'at': {
            'type': 'string',
            'description': 'Local date-time, YYYY-MM-DDTHH:MM.',
          },
          ...taskRefProperties,
        },
        'required': ['title', 'at'],
      };
  @override
  ActionRisk get risk => ActionRisk.reversible;

  @override
  CreateReminderArgs parse(Map<String, Object?> json) => (
        title: requireString(json, 'title'),
        at: requireDateTime(json, 'at'),
        task: json['task_id'] == null && json['task'] == null
            ? null
            : TaskRef.parse(json),
      );

  @override
  Future<ToolValidation> validate(CreateReminderArgs a, ToolEnv env) async {
    final time = _checkTime(a.at, env.now);
    if (time != null) return time;
    if (a.task != null) {
      if (await resolveTask(env, a.task!) case NotResolved(:final invalid)) {
        return invalid;
      }
    }
    return const Valid();
  }

  @override
  Future<ActionPreview> preview(CreateReminderArgs a, ToolEnv env) async =>
      CreateReminderPreview(title: a.title, at: a.at);

  @override
  Future<ToolOutcome> run(CreateReminderArgs a, ToolEnv env) async {
    final taskId = a.task == null
        ? null
        : switch (await resolveTask(env, a.task!)) {
            Found(:final value) => value.id,
            NotResolved(:final invalid) => throw StateError('$invalid'),
          };
    final id = await env.reminders
        .create(title: a.title, fireAt: a.at, taskId: taskId);
    return ToolOutcome(
      result: {'reminder_id': id},
      undo: DeleteRows(UndoTable.reminders, [id]),
      afterCommit: [ReminderTouched(id)],
    );
  }
}

typedef SnoozeArgs = ({int id, DateTime until});

final class SnoozeReminderTool extends AssistantTool<SnoozeArgs> {
  const SnoozeReminderTool();

  @override
  String get name => 'snooze_reminder';
  @override
  String get description => 'Moves an open reminder to a later time.';
  @override
  Map<String, Object?> get parameters => const {
        'type': 'object',
        'properties': {
          'reminder_id': {'type': 'integer'},
          'until': {
            'type': 'string',
            'description': 'Local date-time, YYYY-MM-DDTHH:MM.',
          },
        },
        'required': ['reminder_id', 'until'],
      };
  @override
  ActionRisk get risk => ActionRisk.reversible;

  @override
  SnoozeArgs parse(Map<String, Object?> json) => (
        id: requireInt(json, 'reminder_id', min: 1, max: 1 << 52),
        until: requireDateTime(json, 'until'),
      );

  @override
  Future<ToolValidation> validate(SnoozeArgs a, ToolEnv env) async {
    if (await _open(env, a.id) == null) {
      return Invalid(InvalidReason.notFound, 'reminder_id ${a.id}');
    }
    return _checkTime(a.until, env.now) ?? const Valid();
  }

  @override
  Future<ActionPreview> preview(SnoozeArgs a, ToolEnv env) async =>
      SnoozeReminderPreview(
          title: (await _open(env, a.id))!.title, until: a.until);

  @override
  Future<ToolOutcome> run(SnoozeArgs a, ToolEnv env) async {
    final before = await mustRow(env, UndoTable.reminders, a.id);
    await env.reminders.snooze(a.id, a.until);
    final after = await mustRow(env, UndoTable.reminders, a.id);
    return ToolOutcome(
      result: {'reminder_id': a.id},
      undo: fieldsUndo(UndoTable.reminders, a.id, before, after),
      afterCommit: [ReminderTouched(a.id)],
    );
  }
}

final class CompleteReminderTool extends AssistantTool<int> {
  const CompleteReminderTool();

  @override
  String get name => 'complete_reminder';
  @override
  String get description => 'Marks an open reminder done.';
  @override
  Map<String, Object?> get parameters => const {
        'type': 'object',
        'properties': {
          'reminder_id': {'type': 'integer'},
        },
        'required': ['reminder_id'],
      };
  @override
  ActionRisk get risk => ActionRisk.reversible;

  @override
  int parse(Map<String, Object?> json) =>
      requireInt(json, 'reminder_id', min: 1, max: 1 << 52);

  @override
  Future<ToolValidation> validate(int id, ToolEnv env) async =>
      await _open(env, id) == null
          ? Invalid(InvalidReason.notFound, 'reminder_id $id')
          : const Valid();

  @override
  Future<ActionPreview> preview(int id, ToolEnv env) async =>
      CompleteReminderPreview((await _open(env, id))!.title);

  @override
  Future<ToolOutcome> run(int id, ToolEnv env) async {
    final before = await mustRow(env, UndoTable.reminders, id);
    await env.reminders.setStatus(id, ReminderStatus.done);
    final after = await mustRow(env, UndoTable.reminders, id);
    return ToolOutcome(
      result: {'reminder_id': id},
      undo: fieldsUndo(UndoTable.reminders, id, before, after),
      afterCommit: [ReminderTouched(id)],
    );
  }
}
