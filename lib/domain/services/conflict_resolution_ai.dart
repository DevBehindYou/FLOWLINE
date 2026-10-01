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
String buildConflictResolutionPrompt({
  required String pendingTitle,
  required DateTime pendingStart,
  required DateTime pendingEnd,
  required List<ScheduleBlock> conflicts,
}) {
  final duration = pendingEnd.difference(pendingStart).inMinutes;
  final conflictLines = conflicts
      .map((c) =>
          '- "${c.title}" from ${c.startTime.toIso8601String()} to ${c.endTime.toIso8601String()}')
      .join('\n');

  return '''
I want to schedule a block titled "$pendingTitle" from ${pendingStart.toIso8601String()} to ${pendingEnd.toIso8601String()} ($duration minutes), but it overlaps with:
$conflictLines

Suggest a new time for "$pendingTitle" later the same day that does not overlap any of the above and keeps the same $duration-minute duration.

Respond with EXACTLY these three lines and nothing else — no greeting, no explanation outside the REASON line:
SUGGESTED_START=<ISO8601 datetime>
SUGGESTED_END=<ISO8601 datetime>
REASON=<one short sentence>
''';
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
    // A reply with "Z" or an offset parses as UTC; the rest of the app
    // (display, same-day checks) works in local time.
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
