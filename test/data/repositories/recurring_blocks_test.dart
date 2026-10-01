import 'package:drift/drift.dart' show Value;
import 'package:flowline/data/local/drift/app_database.dart';
import 'package:flowline/data/repositories/schedule_repository_impl.dart';
import 'package:flowline/data/repositories/task_repository_impl.dart';
import 'package:flowline/domain/entities/schedule_block.dart';
import 'package:flowline/domain/entities/task.dart';
import 'package:flowline/domain/recurrence/recurrence_rule.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/test_database.dart';

void main() {
  late AppDatabase db;
  late ScheduleRepositoryImpl schedule;
  late TaskRepositoryImpl tasks;
  setUp(() {
    db = createTestDatabase();
    schedule = ScheduleRepositoryImpl(db);
    tasks = TaskRepositoryImpl(db);
  });
  tearDown(() => db.close());

  // A weekday series from Tuesday 10 March 2026, 9:00-10:00.
  Future<int> weekdaySeries() => schedule.createBlock(
        title: 'Standup',
        startTime: DateTime(2026, 3, 10, 9),
        endTime: DateTime(2026, 3, 10, 10),
        recurrence: RecurrenceRule.weekdays(),
      );

  Future<List<ScheduleBlock>> on(int day) =>
      schedule.getBlocksForDay(DateTime(2026, 3, day));

  test('a series shows once on each matching day, never as itself', () async {
    final id = await weekdaySeries();
    expect(await on(9), isEmpty); // before it starts
    final tuesday = await on(10);
    expect(tuesday.single.title, 'Standup');
    expect(tuesday.single.seriesId, id);
    expect(tuesday.single.isComputedOccurrence, isTrue);
    expect(await on(14), isEmpty); // Saturday
    expect((await on(16)).single.startTime, DateTime(2026, 3, 16, 9));
  });

  test('a series sits alongside plain blocks, in start order', () async {
    await weekdaySeries();
    await schedule.createBlock(
        title: 'Early',
        startTime: DateTime(2026, 3, 11, 8),
        endTime: DateTime(2026, 3, 11, 8, 30));
    expect((await on(11)).map((b) => b.title), ['Early', 'Standup']);
  });

  test('deleting one occurrence removes only that day', () async {
    await weekdaySeries();
    final wednesday = (await on(11)).single;
    await schedule.deleteBlock(wednesday.id);
    expect(await on(11), isEmpty);
    expect(await on(12), hasLength(1));
  });

  test('a task added to an occurrence stores it, once', () async {
    final seriesId = await weekdaySeries();
    final computed = (await on(11)).single;

    final rowId = await schedule.storeOccurrence(computed.id);
    expect(rowId, isPositive);
    expect(await schedule.storeOccurrence(computed.id), rowId);
    await tasks.createTask(
        title: 'Notes', priority: TaskPriority.low, scheduleBlockId: rowId);

    final plan = await schedule.watchDayPlan(DateTime(2026, 3, 11)).first;
    expect(plan.single.block.id, rowId);
    expect(plan.single.block.seriesId, seriesId);
    expect(plan.single.tasks.single.title, 'Notes');
    // Other days are untouched.
    expect((await on(12)).single.isComputedOccurrence, isTrue);
  });

  test('editing one occurrence moves only that day', () async {
    await weekdaySeries();
    final wednesday = (await on(11)).single;
    await schedule.updateBlock(wednesday.copyWith(
      title: 'Late standup',
      startTime: DateTime(2026, 3, 11, 15),
      endTime: DateTime(2026, 3, 11, 16),
    ));
    final moved = (await on(11)).single;
    expect(moved.title, 'Late standup');
    expect(moved.startTime.hour, 15);
    expect(moved.isComputedOccurrence, isFalse);
    expect((await on(12)).single.title, 'Standup');
  });

  test('deleting a stored occurrence does not bring the computed one back',
      () async {
    await weekdaySeries();
    final rowId = await schedule.storeOccurrence((await on(11)).single.id);
    final taskId = await tasks.createTask(
        title: 'Notes', priority: TaskPriority.low, scheduleBlockId: rowId);

    await schedule.deleteBlock(rowId);
    expect(await on(11), isEmpty);
    // Its task moves to the backlog.
    expect((await tasks.watchTask(taskId).first)!.scheduleBlockId, isNull);
  });

  test('"this and following" ends the series the day before', () async {
    final id = await weekdaySeries();
    final stored = await schedule.storeOccurrence((await on(16)).single.id);
    final taskId = await tasks.createTask(
        title: 'Later', priority: TaskPriority.low, scheduleBlockId: stored);

    await schedule.endSeriesAt((await on(12)).single);
    expect(await on(11), hasLength(1));
    expect(await on(12), isEmpty);
    expect(await on(16), isEmpty);
    expect(
        (await schedule.getBlock(id))!.recurrenceUntil, DateTime(2026, 3, 11));
    expect((await tasks.watchTask(taskId).first)!.scheduleBlockId, isNull);
  });

  test('"this and following" from the first day deletes the series', () async {
    final id = await weekdaySeries();
    await schedule.endSeriesAt((await on(10)).single);
    expect(await schedule.getBlock(id), isNull);
    expect(await on(11), isEmpty);
  });

  test('editing the series changes every computed occurrence', () async {
    final id = await weekdaySeries();
    final series = (await schedule.getBlock(id))!;
    await schedule.updateBlock(ScheduleBlock(
      id: id,
      title: 'Sync',
      startTime: DateTime(2026, 3, 10, 10),
      endTime: DateTime(2026, 3, 10, 10, 30),
      recurrence: RecurrenceRule.daily(),
    ));
    expect(series.title, 'Standup');
    final saturday = (await on(14)).single;
    expect(saturday.title, 'Sync');
    expect(saturday.startTime, DateTime(2026, 3, 14, 10));
  });

  test('the day stream updates when an occurrence is deleted', () async {
    await weekdaySeries();
    final counts = schedule
        .watchBlocksForDay(DateTime(2026, 3, 11))
        .map((blocks) => blocks.length);
    final expectation = expectLater(counts, emitsInOrder([1, 0]));
    await Future<void>.delayed(Duration.zero);
    await schedule.deleteBlock((await on(11)).single.id);
    await expectation;
  });

  test('the schema rejects a half-set occurrence (R3)', () async {
    expect(
      () => db.into(db.scheduleBlocks).insert(ScheduleBlocksCompanion.insert(
            title: 'x',
            startTime: DateTime(2026, 3, 10, 9),
            endTime: DateTime(2026, 3, 10, 10),
            occurrenceDate: Value(DateTime(2026, 3, 10)),
          )),
      throwsA(anything),
    );
  });
}
