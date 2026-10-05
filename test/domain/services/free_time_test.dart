import 'package:atomic_assist/domain/entities/schedule_block.dart';
import 'package:atomic_assist/domain/services/free_time.dart';
import 'package:flutter_test/flutter_test.dart';

ScheduleBlock block(int id, DateTime start, DateTime end) => ScheduleBlock(
    id: id,
    title: 'b$id',
    startTime: start,
    endTime: end,
    source: ScheduleBlockSource.local);

void main() {
  DateTime t(int h, [int m = 0]) => DateTime(2026, 10, 5, h, m);

  test('an empty day is one slot', () {
    expect(findFreeSlots(blocks: [], from: t(9), to: t(17), minutes: 30),
        [(start: t(9), end: t(17))]);
  });

  test('gaps between, before and after blocks; short gaps skipped', () {
    final slots = findFreeSlots(
      blocks: [
        block(1, t(10), t(11)),
        block(2, t(11, 20), t(12)), // 20-minute gap before it: too short
        block(3, t(14), t(15)),
      ],
      from: t(9),
      to: t(17),
      minutes: 30,
    );
    expect(slots, [
      (start: t(9), end: t(10)),
      (start: t(12), end: t(14)),
      (start: t(15), end: t(17)),
    ]);
  });

  test('overlapping and nested blocks merge; touching leaves no gap', () {
    final slots = findFreeSlots(
      blocks: [
        block(1, t(9), t(12)),
        block(2, t(10), t(11)),
        block(3, t(12), t(13)),
      ],
      from: t(9),
      to: t(14),
      minutes: 15,
    );
    expect(slots, [(start: t(13), end: t(14))]);
  });

  test('blocks outside the window are clipped or ignored', () {
    final slots = findFreeSlots(
      blocks: [
        block(1, t(7), t(9, 30)),
        block(2, t(18), t(19)),
      ],
      from: t(9),
      to: t(12),
      minutes: 60,
    );
    expect(slots, [(start: t(9, 30), end: t(12))]);
  });

  test('limit and degenerate windows', () {
    final many = [
      for (var h = 9; h < 17; h++) block(h, t(h, 30), t(h + 1)),
    ];
    expect(
        findFreeSlots(
            blocks: many, from: t(9), to: t(17), minutes: 30, limit: 3),
        hasLength(3));
    expect(
        findFreeSlots(blocks: [], from: t(9), to: t(9), minutes: 5), isEmpty);
    expect(
        findFreeSlots(blocks: [], from: t(9), to: t(10), minutes: 61), isEmpty);
  });
}
