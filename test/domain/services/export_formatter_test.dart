import 'dart:convert';

import 'package:flowline/domain/entities/focus_session.dart';
import 'package:flowline/domain/services/export_formatter.dart';
import 'package:flutter_test/flutter_test.dart';

FocusSession _session({
  int id = 1,
  FocusSessionType sessionType = FocusSessionType.focus,
  required DateTime startedAt,
  DateTime? completedAt,
  int? actualDurationSec,
  bool endedEarly = false,
  int? taskId,
  int? subtaskId,
}) {
  return FocusSession(
    id: id,
    taskId: taskId,
    subtaskId: subtaskId,
    sessionType: sessionType,
    plannedDurationSec: 1500,
    startedAt: startedAt,
    segmentStartedAt: null,
    remainingSecAtSegmentStart: 0,
    isPaused: true,
    completedAt: completedAt,
    actualDurationSec: actualDurationSec,
    endedEarly: endedEarly,
  );
}

void main() {
  const formatter = ExportFormatter();
  final start = DateTime(2026, 1, 5, 9, 30);

  group('toCsv', () {
    test('emits only the header row for an empty session list', () {
      final csv = formatter.toCsv(const []);
      final lines = const LineSplitter().convert(csv.trim());
      expect(lines, ['Date,Start Time,Type,Planned Minutes,Actual Minutes,Completed,Ended Early']);
    });

    test('formats a completed session as one comma-separated row', () {
      final session = _session(
        startedAt: start,
        completedAt: start.add(const Duration(minutes: 25)),
        actualDurationSec: 1500,
      );
      final csv = formatter.toCsv([session]);
      final lines = const LineSplitter().convert(csv.trim());
      expect(lines[1], '2026-01-05,09:30,Focus,25,25,true,false');
    });

    test('leaves Actual Minutes blank rather than printing "null"', () {
      final session = _session(startedAt: start, completedAt: null, actualDurationSec: null);
      final csv = formatter.toCsv([session]);
      final lines = const LineSplitter().convert(csv.trim());
      expect(lines[1], '2026-01-05,09:30,Focus,25,,false,false');
    });

    test('every field type is comma-free so no cell needs quoting', () {
      final session = _session(
        startedAt: start,
        completedAt: start,
        actualDurationSec: 1500,
        endedEarly: true,
      );
      final csv = formatter.toCsv([session]);
      final dataLine = const LineSplitter().convert(csv.trim())[1];
      expect(dataLine.split(',').length, 7);
    });
  });

  group('toJson', () {
    test('round-trips a session with every field populated', () {
      final session = _session(
        id: 42,
        startedAt: start,
        completedAt: start.add(const Duration(minutes: 25)),
        actualDurationSec: 1500,
        taskId: 7,
        subtaskId: 3,
      );
      final jsonStr = formatter.toJson(
        [session],
        rangeStart: start,
        rangeEnd: start.add(const Duration(days: 7)),
      );
      final decoded = jsonDecode(jsonStr) as Map<String, dynamic>;
      final sessions = decoded['sessions'] as List;
      expect(sessions, hasLength(1));
      final entry = sessions.first as Map<String, dynamic>;
      expect(entry['id'], 42);
      expect(entry['sessionType'], 'Focus');
      expect(entry['plannedDurationSec'], 1500);
      expect(entry['actualDurationSec'], 1500);
      expect(entry['endedEarly'], false);
      expect(entry['taskId'], 7);
      expect(entry['subtaskId'], 3);
    });

    test('serializes a null actualDurationSec/completedAt as JSON null, not a crash', () {
      final session = _session(startedAt: start, completedAt: null, actualDurationSec: null);
      final jsonStr = formatter.toJson(
        [session],
        rangeStart: start,
        rangeEnd: start,
      );
      final decoded = jsonDecode(jsonStr) as Map<String, dynamic>;
      final entry = (decoded['sessions'] as List).first as Map<String, dynamic>;
      expect(entry['actualDurationSec'], isNull);
      expect(entry['completedAt'], isNull);
    });

    test('produces valid JSON for an empty session list', () {
      final jsonStr = formatter.toJson(const [], rangeStart: start, rangeEnd: start);
      final decoded = jsonDecode(jsonStr) as Map<String, dynamic>;
      expect(decoded['sessions'], isEmpty);
      expect(decoded['rangeStart'], start.toIso8601String());
    });
  });
}
