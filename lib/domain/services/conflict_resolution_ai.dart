import '../entities/schedule_block.dart';
import 'schedule_conflict_checker.dart';

class ConflictResolutionSuggestion {
  const ConflictResolutionSuggestion({
    required this.newStartTime,
    required this.newEndTime,
    required this.reason,
  });

  final DateTime newStartTime;
  final DateTime newEndTime;
  final String reason;
}

/// Builds a deliberately narrow, format-constrained prompt rather than an
/// open-ended one. A free-form "how should I resolve this?" prompt reads
/// nicer but is much harder to turn back into a concrete new time — this
/// asks for exactly one machine-parseable line so [parseConflictSuggestion]
/// has something reliable to work with across four very different vendors
/// (including a user's own local Ollama model, whose instruction-following
/// quality is unpredictable).
///
/// [dayBlocks] is every block already on that day, not just [conflicts]:
/// a suggestion is validated against the whole day before it can be
/// applied, so a model that only saw the clashing blocks kept proposing
/// slots that hit one it was never told about. Every time carries an
/// explicit UTC offset so a reply in UTC ("Z") converts correctly instead
/// of being misread as local time.
String buildConflictResolutionPrompt({
  required String pendingTitle,
  required DateTime pendingStart,
  required DateTime pendingEnd,
  required List<ScheduleBlock> conflicts,
  List<ScheduleBlock> dayBlocks = const [],
}) {
  final duration = pendingEnd.difference(pendingStart).inMinutes;
  String line(ScheduleBlock b) => '- "${b.title}" from '
      '${formatWithOffset(b.startTime)} to ${formatWithOffset(b.endTime)}'
      '${b.isLocked ? ' (fixed, cannot move)' : ''}';

  final conflictIds = {for (final c in conflicts) c.id};
  final otherBlocks =
      dayBlocks.where((b) => !conflictIds.contains(b.id)).toList();
  final busySection = otherBlocks.isEmpty
      ? ''
      : '\nThe rest of that day is also already booked:\n'
          '${otherBlocks.map(line).join('\n')}\n';

  return '''
I want to schedule a block titled "$pendingTitle" from ${formatWithOffset(pendingStart)} to ${formatWithOffset(pendingEnd)} ($duration minutes), but it overlaps with:
${conflicts.map(line).join('\n')}
$busySection
Suggest a new time for "$pendingTitle" later the same day that does not overlap ANY block listed above and keeps the same $duration-minute duration.

Respond with EXACTLY these three lines and nothing else — no greeting, no explanation outside the REASON line. Use the same ISO 8601 format and UTC offset as the times above:
SUGGESTED_START=<ISO 8601 datetime with offset>
SUGGESTED_END=<ISO 8601 datetime with offset>
REASON=<one short sentence>
''';
}

/// ISO 8601 with the local UTC offset, e.g. `2026-10-01T14:00:00+05:30`.
/// Dart's own `toIso8601String()` omits the offset for local times, which
/// leaves a model free to guess (often wrongly) that they're UTC.
String formatWithOffset(DateTime local) {
  String two(int n) => n.toString().padLeft(2, '0');
  final offset = local.timeZoneOffset;
  final sign = offset.isNegative ? '-' : '+';
  final minutes = offset.inMinutes.abs();
  return '${local.year.toString().padLeft(4, '0')}-${two(local.month)}-'
      '${two(local.day)}T${two(local.hour)}:${two(local.minute)}:'
      '${two(local.second)}$sign${two(minutes ~/ 60)}:${two(minutes % 60)}';
}

/// Returns null (rather than throwing) on anything unparseable — a model
/// that ignores the format instructions is a real, expected outcome, not
/// a bug, and the caller falls back to showing the raw text instead of a
/// one-tap "Apply" it can't actually trust.
ConflictResolutionSuggestion? parseConflictSuggestion(String aiText) {
  final startMatch = RegExp(r'SUGGESTED_START=([^\s]+)').firstMatch(aiText);
  final endMatch = RegExp(r'SUGGESTED_END=([^\s]+)').firstMatch(aiText);
  final reasonMatch = RegExp(r'REASON=(.+)').firstMatch(aiText);

  if (startMatch == null || endMatch == null) return null;

  try {
    // A reply with "Z" or an offset parses as that instant in UTC and is
    // converted to local time; the prompt sends explicit offsets, so that
    // conversion is correct rather than a guess. A reply with no offset is
    // read as local clock time.
    final start = DateTime.parse(startMatch.group(1)!).toLocal();
    final end = DateTime.parse(endMatch.group(1)!).toLocal();
    if (!end.isAfter(start)) return null;

    return ConflictResolutionSuggestion(
      newStartTime: start,
      newEndTime: end,
      reason: reasonMatch?.group(1)?.trim() ?? 'Suggested by AI',
    );
  } on FormatException {
    return null;
  }
}

/// Why a parsed AI suggestion can't be applied, or null when it can. AI
/// output is never authoritative: the suggestion must keep the pending
/// block's day and duration and must not overlap anything already on the
/// schedule (locked external blocks included), checked against the
/// current blocks rather than the ones the AI was told about.
String? validateConflictSuggestion({
  required ConflictResolutionSuggestion suggestion,
  required DateTime pendingStart,
  required DateTime pendingEnd,
  required List<ScheduleBlock> blocksForDay,
  int? excludeBlockId,
}) {
  final start = suggestion.newStartTime;
  final end = suggestion.newEndTime;
  if (!end.isAfter(start)) {
    return 'The suggested end time is not after its start.';
  }

  final dayStart =
      DateTime(pendingStart.year, pendingStart.month, pendingStart.day);
  final nextDay = DateTime(dayStart.year, dayStart.month, dayStart.day + 1);
  if (start.isBefore(dayStart) || end.isAfter(nextDay)) {
    return 'The suggested time is not on the same day.';
  }

  final wanted = pendingEnd.difference(pendingStart).inMinutes;
  final got = end.difference(start).inMinutes;
  if (got != wanted) {
    return 'The suggestion changes the length to $got min '
        '(expected $wanted min).';
  }

  final conflicts = const ScheduleConflictChecker().findConflicts(
    startTime: start,
    endTime: end,
    existingBlocks: blocksForDay,
    excludeBlockId: excludeBlockId,
  );
  if (conflicts.isNotEmpty) {
    return 'That time still overlaps "${conflicts.first.title}".';
  }
  return null;
}
