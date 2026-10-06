import '../../domain/assistant/action_preview.dart';
import '../../domain/assistant/autonomy.dart';
import '../../domain/assistant/quick_parse.dart' show isoLocal;
import '../../domain/assistant/tool.dart';
import '../../domain/entities/task.dart';
import '../../domain/services/free_time.dart';
import '../../domain/time/calendar_day.dart';
import 'args.dart';

// Read tools: they change nothing (risk `read`), so they run without a
// ledger row. Results are capped (docs/05 §9.3: 20 rows) before they go
// back to the model.

const _maxRows = 20;

final class GetAgendaTool extends AssistantTool<DateTime> {
  const GetAgendaTool();

  @override
  String get name => 'get_agenda';
  @override
  String get description =>
      'The time blocks on a day, with the tasks in each block. Use the '
      'ids it returns for move_block, schedule_task and complete_task.';
  @override
  Map<String, Object?> get parameters => const {
        'type': 'object',
        'properties': {
          'day': {
            'type': 'string',
            'description': 'Local date, YYYY-MM-DD.',
          },
        },
        'required': ['day'],
      };
  @override
  ActionRisk get risk => ActionRisk.read;

  @override
  DateTime parse(Map<String, Object?> json) => requireDay(json, 'day');

  @override
  Future<ToolValidation> validate(DateTime day, ToolEnv env) async =>
      const Valid();

  @override
  Future<ActionPreview> preview(DateTime day, ToolEnv env) async =>
      ReadPreview(ReadKind.agenda, day: day);

  @override
  Future<ToolOutcome> run(DateTime day, ToolEnv env) async {
    final blocks = await env.schedule.getBlocksForDay(day);
    final out = <Map<String, Object?>>[];
    for (final b in blocks.take(_maxRows)) {
      // Computed occurrences have no tasks until they are stored.
      final tasks = b.isComputedOccurrence
          ? const <Task>[]
          : await env.tasks.getTasksForBlock(b.id);
      out.add({
        ...blockJson(b),
        if (tasks.isNotEmpty)
          'tasks': [for (final t in tasks.take(_maxRows)) taskJson(t)],
      });
    }
    return ToolOutcome(result: {
      'day': dayJson(day),
      'blocks': out,
      if (blocks.length > _maxRows) 'more_blocks': blocks.length - _maxRows,
    });
  }
}

typedef FreeTimeArgs = ({
  DateTime day,
  int minutes,
  DateTime? from,
  DateTime? to,
});

final class FindFreeTimeTool extends AssistantTool<FreeTimeArgs> {
  const FindFreeTimeTool();

  /// The window searched when none is given.
  static const dayStartHour = 8;
  static const dayEndHour = 20;

  @override
  String get name => 'find_free_time';
  @override
  String get description =>
      'Free gaps of at least `minutes` on a day, between 08:00 and 20:00 '
      'unless `from`/`to` are given. Never returns time already past.';
  @override
  Map<String, Object?> get parameters => const {
        'type': 'object',
        'properties': {
          'day': {'type': 'string', 'description': 'Local date, YYYY-MM-DD.'},
          'minutes': {'type': 'integer', 'minimum': 5, 'maximum': 720},
          'from': {
            'type': 'string',
            'description': 'Local date-time, YYYY-MM-DDTHH:MM.',
          },
          'to': {
            'type': 'string',
            'description': 'Local date-time, YYYY-MM-DDTHH:MM.',
          },
        },
        'required': ['day', 'minutes'],
      };
  @override
  ActionRisk get risk => ActionRisk.read;

  @override
  FreeTimeArgs parse(Map<String, Object?> json) => (
        day: requireDay(json, 'day'),
        minutes: requireInt(json, 'minutes', min: 5, max: 720),
        from: optionalDateTime(json, 'from'),
        to: optionalDateTime(json, 'to'),
      );

  @override
  Future<ToolValidation> validate(FreeTimeArgs args, ToolEnv env) async {
    final (:from, :to) = _window(args, env.now);
    if (!to.isAfter(from)) {
      return const Invalid(InvalidReason.endBeforeStart, 'from/to');
    }
    return const Valid();
  }

  ({DateTime from, DateTime to}) _window(FreeTimeArgs a, DateTime now) {
    final d = a.day;
    var from = a.from ?? DateTime(d.year, d.month, d.day, dayStartHour);
    final to = a.to ?? DateTime(d.year, d.month, d.day, dayEndHour);
    if (from.isBefore(now)) {
      // Round "now" up to the next 5 minutes: nobody starts at 14:03.
      final next = now.add(Duration(minutes: 5 - now.minute % 5));
      from = DateTime(next.year, next.month, next.day, next.hour, next.minute);
    }
    return (from: from, to: to);
  }

  @override
  Future<ActionPreview> preview(FreeTimeArgs args, ToolEnv env) async =>
      ReadPreview(ReadKind.freeTime, day: args.day);

  @override
  Future<ToolOutcome> run(FreeTimeArgs args, ToolEnv env) async {
    final (:from, :to) = _window(args, env.now);
    final blocks = [
      ...await env.schedule.getBlocksForDay(args.day),
      // A window past midnight needs the next day's blocks too.
      if (!isSameDay(from, to) && to.isAfter(addDays(args.day, 1)))
        ...await env.schedule.getBlocksForDay(addDays(args.day, 1)),
    ];
    final slots = findFreeSlots(
        blocks: blocks, from: from, to: to, minutes: args.minutes);
    return ToolOutcome(result: {
      'slots': [
        for (final s in slots)
          {'start': isoLocal(s.start), 'end': isoLocal(s.end)},
      ],
    });
  }
}

typedef SearchTasksArgs = ({String query, bool includeDone});

final class SearchTasksTool extends AssistantTool<SearchTasksArgs> {
  const SearchTasksTool();

  @override
  String get name => 'search_tasks';
  @override
  String get description =>
      'Tasks whose title contains `query` (all open tasks when empty).';
  @override
  Map<String, Object?> get parameters => const {
        'type': 'object',
        'properties': {
          'query': {'type': 'string', 'maxLength': 200},
          'include_done': {'type': 'boolean'},
        },
        'required': ['query'],
      };
  @override
  ActionRisk get risk => ActionRisk.read;

  @override
  SearchTasksArgs parse(Map<String, Object?> json) {
    final includeDone = json['include_done'];
    if (includeDone != null && includeDone is! bool) {
      throw const ToolArgumentError('include_done', 'must be a boolean');
    }
    return (
      query: optionalString(json, 'query') ?? '',
      includeDone: includeDone == true,
    );
  }

  @override
  Future<ToolValidation> validate(SearchTasksArgs args, ToolEnv env) async =>
      const Valid();

  @override
  Future<ActionPreview> preview(SearchTasksArgs args, ToolEnv env) async =>
      const ReadPreview(ReadKind.searchTasks);

  @override
  Future<ToolOutcome> run(SearchTasksArgs args, ToolEnv env) async {
    final found = await env.tasks
        .findTasks(args.query, includeDone: args.includeDone, limit: _maxRows);
    return ToolOutcome(result: {
      'tasks': [for (final t in found) taskJson(t)],
    });
  }
}

final class GetTaskTool extends AssistantTool<TaskRef> {
  const GetTaskTool();

  @override
  String get name => 'get_task';
  @override
  String get description => 'One task with its notes and subtasks.';
  @override
  Map<String, Object?> get parameters => const {
        'type': 'object',
        'properties': taskRefProperties,
      };
  @override
  ActionRisk get risk => ActionRisk.read;

  @override
  TaskRef parse(Map<String, Object?> json) => TaskRef.parse(json);

  @override
  Future<ToolValidation> validate(TaskRef ref, ToolEnv env) async =>
      switch (await resolveTask(env, ref, includeDone: true)) {
        Found() => const Valid(),
        NotResolved(:final invalid) => invalid,
      };

  @override
  Future<ActionPreview> preview(TaskRef ref, ToolEnv env) async =>
      const ReadPreview(ReadKind.task);

  @override
  Future<ToolOutcome> run(TaskRef ref, ToolEnv env) async {
    final task = switch (await resolveTask(env, ref, includeDone: true)) {
      Found(:final value) => value,
      NotResolved(:final invalid) => throw StateError('$invalid'),
    };
    final subtasks = await env.tasks.getSubtasks(task.id);
    return ToolOutcome(result: {
      ...taskJson(task),
      if (task.notes.isNotEmpty) 'notes': task.notes,
      'subtasks': [
        for (final s in subtasks.take(_maxRows))
          {'id': s.id, 'title': s.title, 'status': s.status.name},
      ],
    });
  }
}
