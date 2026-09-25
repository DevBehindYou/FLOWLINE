import 'dart:convert';

import '../entities/focus_session.dart';

/// Pure text formatting — no Flutter, no `pdf`/`share_plus` packages.
/// Deliberately hand-rolled rather than pulling in the `csv` package:
/// every field below is a date, time, enum label, number, or boolean —
/// provably comma-free — so the usual reason to need a real CSV encoder
/// (escaping free-text fields like a task title) doesn't apply here. If
/// a future export ever includes a free-text column, that's the moment
/// to add the dependency, not before.
class ExportFormatter {
  const ExportFormatter();

  String toCsv(List<FocusSession> sessions) {
    final buffer = StringBuffer()
      ..writeln('Date,Start Time,Type,Planned Minutes,Actual Minutes,Completed,Ended Early');
    for (final session in sessions) {
      buffer.writeln(
        [
          _dateStr(session.startedAt),
          _timeStr(session.startedAt),
          _typeLabel(session.sessionType),
          (session.plannedDurationSec / 60).round(),
          session.actualDurationSec == null ? '' : (session.actualDurationSec! / 60).round(),
          session.completedAt != null,
          session.endedEarly,
        ].join(','),
      );
    }
    return buffer.toString();
  }

  String toJson(
    List<FocusSession> sessions, {
    required DateTime rangeStart,
    required DateTime rangeEnd,
  }) {
    final data = {
      'exportedAt': DateTime.now().toIso8601String(),
      'rangeStart': rangeStart.toIso8601String(),
      'rangeEnd': rangeEnd.toIso8601String(),
      'sessions': [
        for (final session in sessions)
          {
            'id': session.id,
            'sessionType': _typeLabel(session.sessionType),
            'startedAt': session.startedAt.toIso8601String(),
            'plannedDurationSec': session.plannedDurationSec,
            'actualDurationSec': session.actualDurationSec,
            'completedAt': session.completedAt?.toIso8601String(),
            'endedEarly': session.endedEarly,
            'taskId': session.taskId,
            'subtaskId': session.subtaskId,
          },
      ],
    };
    return const JsonEncoder.withIndent('  ').convert(data);
  }

  String _typeLabel(FocusSessionType type) => switch (type) {
        FocusSessionType.focus => 'Focus',
        FocusSessionType.shortBreak => 'Short Break',
        FocusSessionType.longBreak => 'Long Break',
      };

  String _dateStr(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  String _timeStr(DateTime d) =>
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
}
