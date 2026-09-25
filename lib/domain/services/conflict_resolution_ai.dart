import '../entities/schedule_block.dart';

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
      .map((c) => '- "${c.title}" from ${c.startTime.toIso8601String()} to ${c.endTime.toIso8601String()}')
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
    final start = DateTime.parse(startMatch.group(1)!);
    final end = DateTime.parse(endMatch.group(1)!);
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
