import '../../domain/assistant/quick_parse.dart' show isoDate, isoLocal;
import '../../domain/assistant/tool.dart';
import '../../domain/entities/schedule_block.dart';
import '../../domain/entities/task.dart';
import '../../domain/recurrence/occurrences.dart';
import '../../domain/recurrence/recurrence_rule.dart';

// Argument parsing shared by the tools. Model output is untrusted (R16):
// every reader checks type and range and throws ToolArgumentError, which
// goes back to the model to correct. Times are local ISO 8601, the same
// format the local grammar emits ("2026-10-05T19:00", "2026-10-05").

const maxTitleLength = 200;

String requireString(Map<String, Object?> json, String key,
    {int maxLength = maxTitleLength}) {
  final v = optionalString(json, key, maxLength: maxLength);
  if (v == null) throw ToolArgumentError(key, 'required');
  return v;
}

/// Trimmed; an empty string counts as missing.
String? optionalString(Map<String, Object?> json, String key,
    {int maxLength = maxTitleLength}) {
  final v = json[key];
  if (v == null) return null;
  if (v is! String) throw ToolArgumentError(key, 'must be a string');
  final s = v.trim();
  if (s.isEmpty) return null;
  if (s.length > maxLength) {
    throw ToolArgumentError(key, 'at most $maxLength characters');
  }
  return s;
}

/// Accepts a whole number sent as a float (3.0), as some models do.
int? optionalInt(Map<String, Object?> json, String key,
    {required int min, required int max}) {
  final v = json[key];
  if (v == null) return null;
  if (v is! num || v != v.roundToDouble()) {
    throw ToolArgumentError(key, 'must be a whole number');
  }
  final n = v.toInt();
  if (n < min || n > max) {
    throw ToolArgumentError(key, 'must be between $min and $max');
  }
  return n;
}

int requireInt(Map<String, Object?> json, String key,
    {required int min, required int max}) {
  final v = optionalInt(json, key, min: min, max: max);
  if (v == null) throw ToolArgumentError(key, 'required');
  return v;
}

final _isoPattern = RegExp(r'^(\d{4})-(\d{2})-(\d{2})'
    r'(?:[T ](\d{2}):(\d{2})(?::(\d{2})(?:\.\d+)?)?)?'
    r'(Z|[+-]\d{2}:?\d{2})?$');

/// A local date-time. A zone ("Z", "+05:30") is honoured and converted
/// to local time; an impossible date ("2026-02-30") is rejected rather
/// than rolled over.
DateTime? optionalDateTime(Map<String, Object?> json, String key) {
  final v = json[key];
  if (v == null) return null;
  if (v is! String) throw ToolArgumentError(key, 'must be an ISO 8601 string');
  final m = _isoPattern.firstMatch(v.trim());
  if (m == null) throw ToolArgumentError(key, 'must be ISO 8601');
  final y = int.parse(m.group(1)!), mo = int.parse(m.group(2)!);
  final d = int.parse(m.group(3)!);
  final h = int.parse(m.group(4) ?? '0'), mi = int.parse(m.group(5) ?? '0');
  final s = int.parse(m.group(6) ?? '0');
  if (mo < 1 || mo > 12 || h > 23 || mi > 59 || s > 59) {
    throw ToolArgumentError(key, 'not a real date or time');
  }
  final local = DateTime(y, mo, d, h, mi, s);
  if (local.month != mo || local.day != d) {
    throw ToolArgumentError(key, 'not a real date');
  }
  if (m.group(7) == null) return local;
  return DateTime.parse(v.trim()).toLocal();
}

DateTime requireDateTime(Map<String, Object?> json, String key) {
  final v = optionalDateTime(json, key);
  if (v == null) throw ToolArgumentError(key, 'required');
  return v;
}

/// A calendar day (local midnight); a date-time is cut to its day.
DateTime requireDay(Map<String, Object?> json, String key) {
  final t = requireDateTime(json, key);
  return DateTime(t.year, t.month, t.day);
}

T? optionalEnum<T extends Enum>(
    Map<String, Object?> json, String key, List<T> values) {
  final v = json[key];
  if (v == null) return null;
  for (final e in values) {
    if (e.name == v) return e;
  }
  throw ToolArgumentError(
      key, 'one of ${values.map((e) => e.name).join(', ')}');
}

/// The JSON schema of a `repeat` argument, read by [optionalRepeat].
const repeatProperty = {
  'type': 'string',
  'description': 'daily, weekdays, or days of the week such as "mon,thu".',
};

const _dayCodes = ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'];

/// "daily", "weekdays" or a comma list of day names ("mon, thu"; the
/// first three letters are enough).
RecurrenceRule? optionalRepeat(Map<String, Object?> json, String key) {
  final v = json[key];
  if (v == null) return null;
  if (v is! String) throw ToolArgumentError(key, 'must be a string');
  final text = v.trim().toLowerCase();
  if (text == 'daily' || text == 'every day') return RecurrenceRule.daily();
  if (text == 'weekdays') return RecurrenceRule.weekdays();
  final days = <int>{};
  for (final part in text.split(',')) {
    final code = part.trim();
    final index =
        code.length < 3 ? -1 : _dayCodes.indexOf(code.substring(0, 3));
    if (index < 0) {
      throw ToolArgumentError(key, 'daily, weekdays or days like mon,thu');
    }
    days.add(index + 1);
  }
  return RecurrenceRule(days);
}

String repeatJson(RecurrenceRule r) => r.isDaily
    ? 'daily'
    : r.isWeekdays
        ? 'weekdays'
        : (r.weekdays.toList()..sort()).map((d) => _dayCodes[d - 1]).join(',');

List<String> requireStringList(Map<String, Object?> json, String key,
    {required int minItems, required int maxItems}) {
  final v = json[key];
  if (v is! List) throw ToolArgumentError(key, 'must be a list of strings');
  final items = <String>[];
  for (final item in v) {
    if (item is! String) {
      throw ToolArgumentError(key, 'must be a list of strings');
    }
    final s = item.trim();
    if (s.isEmpty) continue;
    if (s.length > maxTitleLength) {
      throw ToolArgumentError(key, 'items at most $maxTitleLength characters');
    }
    items.add(s);
  }
  if (items.length < minItems || items.length > maxItems) {
    throw ToolArgumentError(key, '$minItems to $maxItems items');
  }
  return items;
}

/// A task named by id, or by title (what the local grammar and a model
/// that hasn't looked the id up send).
final class TaskRef {
  const TaskRef.id(int this.id) : title = null;
  const TaskRef.title(String this.title) : id = null;
  final int? id;
  final String? title;

  static TaskRef parse(Map<String, Object?> json) {
    final id = optionalInt(json, 'task_id', min: 1, max: 1 << 52);
    if (id != null) return TaskRef.id(id);
    final title = optionalString(json, 'task');
    if (title != null) return TaskRef.title(title);
    throw const ToolArgumentError('task_id', 'task_id or task is required');
  }
}

/// Schema properties for a [TaskRef].
const taskRefProperties = <String, Object?>{
  'task_id': {'type': 'integer', 'description': 'Id of the task.'},
  'task': {
    'type': 'string',
    'description': 'Title of the task, when the id is not known.',
  },
};

sealed class Resolved<T> {
  const Resolved();
}

final class Found<T> extends Resolved<T> {
  const Found(this.value);
  final T value;
}

final class NotResolved<T> extends Resolved<T> {
  const NotResolved(this.invalid);
  final Invalid invalid;
}

/// Finds the task [ref] names. A title must match one task: exactly
/// (ignoring case), or as the only task containing it; otherwise the
/// model is told the candidates and asked to pick an id.
Future<Resolved<Task>> resolveTask(ToolEnv env, TaskRef ref,
    {bool includeDone = false}) async {
  if (ref.id != null) {
    final task = await env.tasks.getTask(ref.id!);
    return task == null
        ? NotResolved(Invalid(InvalidReason.notFound, 'task_id ${ref.id}'))
        : Found(task);
  }
  final title = ref.title!;
  final candidates =
      await env.tasks.findTasks(title, includeDone: includeDone, limit: 10);
  final exact = candidates
      .where((t) => t.title.toLowerCase() == title.toLowerCase())
      .toList();
  if (exact.length == 1) return Found(exact.single);
  if (candidates.length == 1) return Found(candidates.single);
  if (candidates.isEmpty) {
    return NotResolved(Invalid(InvalidReason.notFound, title));
  }
  final names = [for (final t in candidates) '${t.id}: ${t.title}'];
  return NotResolved(Invalid(InvalidReason.ambiguous, names.join('; ')));
}

/// A block by id: a stored row, or a computed occurrence of a series
/// (negative id, as the agenda lists it).
Future<ScheduleBlock?> findBlock(ToolEnv env, int id) async {
  final occurrence = decodeOccurrenceId(id);
  if (occurrence == null) return env.schedule.getBlock(id);
  final blocks = await env.schedule.getBlocksForDay(occurrence.day);
  for (final b in blocks) {
    if (b.id == id) return b;
  }
  return null;
}

Map<String, Object?> taskJson(Task t) => {
      'id': t.id,
      'title': t.title,
      'status': t.status.name,
      'priority': t.priority.name,
      if (t.dueAt != null) 'due': isoLocal(t.dueAt!),
      if (t.scheduleBlockId != null) 'block_id': t.scheduleBlockId,
      if (t.repeat != null) 'repeat': repeatJson(t.repeat!),
    };

Map<String, Object?> blockJson(ScheduleBlock b) => {
      'id': b.id,
      'title': b.title,
      'start': isoLocal(b.startTime),
      'end': isoLocal(b.endTime),
      if (b.isLocked) 'locked': true,
      if (b.isOccurrence || b.isComputedOccurrence) 'repeats': true,
    };

String dayJson(DateTime day) => isoDate(day);
