import 'package:flowline/domain/entities/schedule_block.dart';
import 'package:flowline/domain/services/schedule_conflict_checker.dart';
import 'package:flutter_test/flutter_test.dart';

DateTime _t(int hour, [int minute = 0]) => DateTime(2026, 1, 1, hour, minute);

ScheduleBlock _block(
  int id,
  DateTime startTime,
  DateTime endTime, {
  ScheduleBlockSource source = ScheduleBlockSource.local,
  bool isLocked = false,
}) {
  return ScheduleBlock(
    id: id,
    title: 'Block $id',
    startTime: startTime,
    endTime: endTime,
    source: source,
    isLocked: isLocked,
  );
}

void main() {
  const checker = ScheduleConflictChecker();

  group('findConflicts', () {
    test('returns nothing against an empty schedule', () {
      final result = checker.findConflicts(
        startTime: _t(9),
        endTime: _t(10),
        existingBlocks: const [],
      );
      expect(result, isEmpty);
    });

    test('flags an exact same start/end block as a conflict', () {
      final existing = _block(1, _t(9), _t(10));
      final result = checker.findConflicts(
        startTime: _t(9),
        endTime: _t(10),
        existingBlocks: [existing],
      );
      expect(result, [existing]);
    });

    test('does not flag a block that ends exactly when the new one starts', () {
      final existing = _block(1, _t(8), _t(9));
      final result = checker.findConflicts(
        startTime: _t(9),
        endTime: _t(10),
        existingBlocks: [existing],
      );
      expect(result, isEmpty);
    });

    test('does not flag a block that starts exactly when the new one ends', () {
      final existing = _block(1, _t(10), _t(11));
      final result = checker.findConflicts(
        startTime: _t(9),
        endTime: _t(10),
        existingBlocks: [existing],
      );
      expect(result, isEmpty);
    });

    test('flags a block fully nested inside the new range', () {
      final existing = _block(1, _t(9, 30), _t(9, 45));
      final result = checker.findConflicts(
        startTime: _t(9),
        endTime: _t(11),
        existingBlocks: [existing],
      );
      expect(result, [existing]);
    });

    test('flags a partial overlap on the leading edge', () {
      final existing = _block(1, _t(8), _t(9, 30));
      final result = checker.findConflicts(
        startTime: _t(9),
        endTime: _t(10),
        existingBlocks: [existing],
      );
      expect(result, [existing]);
    });

    test('flags a partial overlap on the trailing edge', () {
      final existing = _block(1, _t(9, 30), _t(10, 30));
      final result = checker.findConflicts(
        startTime: _t(9),
        endTime: _t(10),
        existingBlocks: [existing],
      );
      expect(result, [existing]);
    });

    test('returns every overlapping block when there are multiple', () {
      final a = _block(1, _t(9), _t(10));
      final b = _block(2, _t(9, 30), _t(10, 30));
      final unrelated = _block(3, _t(14), _t(15));
      final result = checker.findConflicts(
        startTime: _t(9),
        endTime: _t(10),
        existingBlocks: [a, b, unrelated],
      );
      expect(result, containsAll([a, b]));
      expect(result, isNot(contains(unrelated)));
    });

    test('excludes the block being edited from conflicting with its own pre-edit self', () {
      final self = _block(1, _t(9), _t(10));
      final result = checker.findConflicts(
        startTime: _t(9),
        endTime: _t(10),
        existingBlocks: [self],
        excludeBlockId: 1,
      );
      expect(result, isEmpty);
    });
  });

  group('findConflictingBlockIds', () {
    test('returns an empty set when nothing overlaps', () {
      final blocks = [_block(1, _t(9), _t(10)), _block(2, _t(11), _t(12))];
      expect(checker.findConflictingBlockIds(blocks), isEmpty);
    });

    test('flags only the pair that overlaps, not an unrelated third block', () {
      final a = _block(1, _t(9), _t(10));
      final b = _block(2, _t(9, 30), _t(10, 30));
      final c = _block(3, _t(14), _t(15));
      final result = checker.findConflictingBlockIds([a, b, c]);
      expect(result, {1, 2});
    });

    test('a locked external block still participates in conflict detection', () {
      final locked = _block(
        1,
        _t(9),
        _t(10),
        source: ScheduleBlockSource.externalCalendar,
        isLocked: true,
      );
      final local = _block(2, _t(9, 30), _t(10, 30));
      final result = checker.findConflictingBlockIds([locked, local]);
      expect(result, {1, 2});
    });
  });
}
