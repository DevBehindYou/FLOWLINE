import 'package:flowline/domain/entities/schedule_block.dart';
import 'package:flowline/domain/services/conflict_resolution_ai.dart';
import 'package:flutter_test/flutter_test.dart';

ScheduleBlock _block(
  int id,
  String title,
  DateTime start,
  DateTime end, {
  bool locked = false,
}) =>
    ScheduleBlock(
      id: id,
      title: title,
      startTime: start,
      endTime: end,
      isLocked: locked,
    );

ConflictResolutionSuggestion _suggest(DateTime start, DateTime end) =>
    ConflictResolutionSuggestion(
      newStartTime: start,
      newEndTime: end,
      reason: 'test',
    );

void main() {
  // All dates are local; the tests hold in any timezone the suite runs in.
  final day = DateTime(2026, 3, 10);
  DateTime at(int hour, [int minute = 0]) =>
      DateTime(day.year, day.month, day.day, hour, minute);

  group('formatWithOffset', () {
    test('always includes an explicit UTC offset', () {
      final text = formatWithOffset(at(14, 5));
      expect(
        text,
        matches(RegExp(r'^2026-03-10T14:05:00[+-]\d{2}:\d{2}$')),
      );
    });

    test('round-trips through parseConflictSuggestion to the same instant', () {
      final start = at(14);
      final end = at(15);
      final parsed = parseConflictSuggestion(
        'SUGGESTED_START=${formatWithOffset(start)}\n'
        'SUGGESTED_END=${formatWithOffset(end)}\n'
        'REASON=Free after lunch',
      );
      expect(parsed, isNotNull);
      expect(parsed!.newStartTime, start);
      expect(parsed.newEndTime, end);
      expect(parsed.newStartTime.isUtc, isFalse);
      expect(parsed.reason, 'Free after lunch');
    });
  });

  group('parseConflictSuggestion', () {
    test('converts a UTC ("Z") reply to the same instant in local time', () {
      final parsed = parseConflictSuggestion(
        'SUGGESTED_START=2026-03-10T09:00:00Z\n'
        'SUGGESTED_END=2026-03-10T10:00:00Z\n'
        'REASON=x',
      );
      expect(parsed!.newStartTime, DateTime.utc(2026, 3, 10, 9).toLocal());
      expect(parsed.newStartTime.isUtc, isFalse);
    });

    test('reads a reply with no offset as local clock time', () {
      final parsed = parseConflictSuggestion(
        'SUGGESTED_START=2026-03-10T16:00:00\n'
        'SUGGESTED_END=2026-03-10T17:30:00\n'
        'REASON=x',
      );
      expect(parsed!.newStartTime, at(16));
      expect(parsed.newEndTime, at(17, 30));
    });

    test('tolerates chatter around the three lines', () {
      final parsed = parseConflictSuggestion(
        'Sure! Here you go:\n'
        'SUGGESTED_START=2026-03-10T16:00:00\n'
        'SUGGESTED_END=2026-03-10T17:00:00\n'
        'REASON=Open afternoon slot\nHope that helps.',
      );
      expect(parsed, isNotNull);
      expect(parsed!.reason, 'Open afternoon slot');
    });

    test('defaults the reason when the REASON line is missing', () {
      final parsed = parseConflictSuggestion(
        'SUGGESTED_START=2026-03-10T16:00:00\n'
        'SUGGESTED_END=2026-03-10T17:00:00',
      );
      expect(parsed!.reason, 'Suggested by AI');
    });

    for (final (name, reply) in [
      ('free-form text', 'How about sometime in the afternoon?'),
      ('a missing end', 'SUGGESTED_START=2026-03-10T16:00:00'),
      ('an unparsable time', 'SUGGESTED_START=4pm\nSUGGESTED_END=5pm'),
      (
        'an end before its start',
        'SUGGESTED_START=2026-03-10T17:00:00\nSUGGESTED_END=2026-03-10T16:00:00'
      ),
      (
        'an end equal to its start',
        'SUGGESTED_START=2026-03-10T17:00:00\nSUGGESTED_END=2026-03-10T17:00:00'
      ),
      ('an empty reply', ''),
    ]) {
      test('returns null, never throws, on $name', () {
        expect(parseConflictSuggestion(reply), isNull);
      });
    }
  });

  group('validateConflictSuggestion', () {
    final lunch = _block(1, 'Lunch', at(12), at(13));
    final call = _block(2, 'Client call', at(15), at(16), locked: true);
    final blocks = [lunch, call];

    SuggestionProblem? validate(
      DateTime start,
      DateTime end, {
      List<ScheduleBlock>? on,
      int? excludeBlockId,
    }) =>
        validateConflictSuggestion(
          suggestion: _suggest(start, end),
          pendingStart: at(12, 30),
          pendingEnd: at(13, 30),
          blocksForDay: on ?? blocks,
          excludeBlockId: excludeBlockId,
        );

    test('accepts a free slot on the same day with the same length', () {
      expect(validate(at(13), at(14)), isNull);
    });

    test('accepts a slot ending exactly at midnight', () {
      expect(
        validate(at(23), DateTime(day.year, day.month, day.day + 1)),
        isNull,
      );
    });

    test('rejects an end that is not after its start', () {
      expect(validate(at(14), at(14)), isA<SuggestionEndNotAfterStart>());
    });

    test('rejects a different day', () {
      final nextDay = DateTime(day.year, day.month, day.day + 1, 9);
      expect(
        validate(nextDay, nextDay.add(const Duration(hours: 1))),
        isA<SuggestionNotSameDay>(),
      );
    });

    test('rejects a slot that runs past midnight', () {
      expect(
        validate(at(23, 30), DateTime(day.year, day.month, day.day + 1, 0, 30)),
        isA<SuggestionNotSameDay>(),
      );
    });

    test('rejects a changed duration', () {
      expect(
        validate(at(13), at(14, 30)),
        isA<SuggestionLengthChanged>()
            .having((p) => p.got, 'got', 90)
            .having((p) => p.wanted, 'wanted', 60),
      );
    });

    test('rejects an overlap with any block, not only the original conflict',
        () {
      expect(
        validate(at(14, 30), at(15, 30)),
        isA<SuggestionStillOverlaps>()
            .having((p) => p.blockTitle, 'blockTitle', 'Client call'),
      );
    });

    test('rejects an overlap with a locked block', () {
      expect(
        validate(at(15), at(16)),
        isA<SuggestionStillOverlaps>()
            .having((p) => p.blockTitle, 'blockTitle', 'Client call'),
      );
    });

    test('ignores the block being edited (its old slot is being freed)', () {
      final editing = _block(3, 'Deep work', at(9), at(10));
      expect(
        validate(at(9), at(10), on: [...blocks, editing], excludeBlockId: 3),
        isNull,
      );
    });
  });

  group('buildConflictResolutionPrompt', () {
    final lunch = _block(1, 'Lunch', at(12), at(13));
    final standup = _block(2, 'Standup', at(9), at(9, 15));
    final call = _block(3, 'Client call', at(15), at(16), locked: true);

    final prompt = buildConflictResolutionPrompt(
      pendingTitle: 'Deep work',
      pendingStart: at(12, 30),
      pendingEnd: at(13, 30),
      conflicts: [lunch],
      dayBlocks: [standup, lunch, call],
    );

    test('lists every block on the day, not only the conflict (B14)', () {
      expect(prompt, contains('"Lunch"'));
      expect(prompt, contains('"Standup"'));
      expect(prompt, contains('"Client call"'));
    });

    test('lists a conflicting block once', () {
      expect('"Lunch"'.allMatches(prompt).length, 1);
    });

    test('marks locked blocks as fixed', () {
      expect(prompt, contains('"Client call" from'));
      expect(prompt, contains('(fixed, cannot move)'));
    });

    test('states every time with an explicit offset (B13)', () {
      expect(prompt, contains(formatWithOffset(at(12, 30))));
      expect(prompt, contains(formatWithOffset(at(15))));
      expect(prompt, isNot(contains(at(12, 30).toIso8601String())));
    });

    test('keeps the duration and the exact reply format', () {
      expect(prompt, contains('60 minutes'));
      expect(prompt, contains('SUGGESTED_START='));
      expect(prompt, contains('SUGGESTED_END='));
      expect(prompt, contains('REASON='));
    });

    test('omits the "rest of the day" section when nothing else is booked', () {
      final bare = buildConflictResolutionPrompt(
        pendingTitle: 'Deep work',
        pendingStart: at(12, 30),
        pendingEnd: at(13, 30),
        conflicts: [lunch],
        dayBlocks: [lunch],
      );
      expect(bare, isNot(contains('rest of that day')));
    });
  });
}
