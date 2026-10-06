import '../domain/assistant/autonomy.dart';
import '../domain/assistant/quick_parse.dart' show isoDate, isoLocal;
import '../domain/assistant/redact.dart';
import '../domain/assistant/tool.dart';
import '../domain/entities/schedule_block.dart';
import '../domain/entities/task.dart';
import '../domain/time/calendar_day.dart';

/// Builds the system prompt for one assistant turn (docs/05 §9.7): the
/// rules, now, today's and tomorrow's agenda and the open tasks, all with
/// ids so the model never has to guess one. Bounded: at most [maxItems]
/// per list and [maxChars] in all. Model-facing English, never shown.
///
/// Titles are redacted (§6.4) because they are context AA adds; the
/// user's own words go in the prompt untouched.
final class AssistantContextBuilder {
  const AssistantContextBuilder();

  static const maxItems = 20;
  static const maxTitle = 80;

  /// About 3,000 tokens at 4 characters per token.
  static const maxChars = 12000;

  Future<String> systemPrompt(ToolEnv env, AutonomyPreset preset) async {
    final now = env.now;
    final today = startOfDay(now);
    final tomorrow = addDays(now, 1);
    final out = StringBuffer()
      ..writeln('You are AA (Atomic Assist), a personal assistant inside '
          "the user's phone app. Act only through the tools. Never invent "
          'ids: use the ids below or look them up with a tool. If the '
          'request is unclear, ask one short question instead of acting. '
          'Times are local, written YYYY-MM-DDTHH:MM. Reply in one or two '
          'short sentences, in the language the user wrote in.')
      ..writeln()
      ..writeln('Now: ${isoLocal(now)} (${_weekday(now)}), '
          'UTC${_offset(now.timeZoneOffset)}.')
      ..writeln('Autonomy: ${preset.name}.')
      ..writeln();

    for (final (label, day) in [('Today', today), ('Tomorrow', tomorrow)]) {
      final blocks = await env.schedule.getBlocksForDay(day);
      out.writeln('$label (${isoDate(day)}) blocks:');
      if (blocks.isEmpty) out.writeln('- none');
      for (final b in blocks.take(maxItems)) {
        out.writeln(_block(b));
      }
      if (blocks.length > maxItems) {
        out.writeln('- … ${blocks.length - maxItems} more (use get_agenda)');
      }
    }

    final tasks = await env.tasks.findTasks('', limit: 200);
    tasks.sort(_byDueThenPriority);
    out
      ..writeln()
      ..writeln('Open tasks:');
    if (tasks.isEmpty) out.writeln('- none');
    for (final t in tasks.take(maxItems)) {
      out.writeln(_task(t));
    }
    if (tasks.length > maxItems) {
      out.writeln('- … ${tasks.length - maxItems} more (use search_tasks)');
    }

    final text = out.toString();
    return text.length <= maxChars ? text : text.substring(0, maxChars);
  }

  static String _title(String s) {
    final r = redact(s.replaceAll(RegExp(r'\s+'), ' ').trim());
    return r.length <= maxTitle ? r : '${r.substring(0, maxTitle - 1)}…';
  }

  static String _block(ScheduleBlock b) {
    final flags = [
      if (b.isLocked) 'locked',
      if (b.isOccurrence || b.isComputedOccurrence) 'repeats',
    ];
    return '- [${b.id}] ${isoLocal(b.startTime)}–${isoLocal(b.endTime)} '
        '${_title(b.title)}${flags.isEmpty ? '' : ' (${flags.join(', ')})'}';
  }

  static String _task(Task t) {
    final due = t.dueAt == null ? '' : ', due ${isoLocal(t.dueAt!)}';
    final block =
        t.scheduleBlockId == null ? '' : ', in block ${t.scheduleBlockId}';
    return '- [${t.id}] ${_title(t.title)} (${t.priority.name}$due$block)';
  }

  /// Due first (soonest first), then by priority, high first.
  static int _byDueThenPriority(Task a, Task b) {
    if (a.dueAt != null && b.dueAt != null) {
      final c = a.dueAt!.compareTo(b.dueAt!);
      if (c != 0) return c;
    } else if (a.dueAt != null || b.dueAt != null) {
      return a.dueAt != null ? -1 : 1;
    }
    return b.priority.index.compareTo(a.priority.index);
  }

  static String _weekday(DateTime d) => const [
        'Monday',
        'Tuesday',
        'Wednesday',
        'Thursday',
        'Friday',
        'Saturday',
        'Sunday',
      ][d.weekday - 1];

  static String _offset(Duration o) {
    final sign = o.isNegative ? '-' : '+';
    final m = o.inMinutes.abs();
    return '$sign${(m ~/ 60).toString().padLeft(2, '0')}:'
        '${(m % 60).toString().padLeft(2, '0')}';
  }
}
