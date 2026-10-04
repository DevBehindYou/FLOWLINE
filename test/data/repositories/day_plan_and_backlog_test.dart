import 'package:atomic_assist/data/local/drift/app_database.dart';
import 'package:atomic_assist/data/repositories/schedule_repository_impl.dart';
import 'package:atomic_assist/data/repositories/task_repository_impl.dart';
import 'package:atomic_assist/domain/entities/task.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/test_database.dart';

void main() {
  late AppDatabase db;
  late TaskRepositoryImpl tasks;
  late ScheduleRepositoryImpl schedule;
  setUp(() {
    db = createTestDatabase();
    tasks = TaskRepositoryImpl(db);
    schedule = ScheduleRepositoryImpl(db);
  });
  tearDown(() => db.close());

  group('day plan (B21)', () {
    test('returns each block once, in start order, with its tasks', () async {
      final late = await schedule.createBlock(
          title: 'Afternoon',
          startTime: DateTime(2026, 3, 10, 14),
          endTime: DateTime(2026, 3, 10, 15));
      final early = await schedule.createBlock(
          title: 'Morning',
          startTime: DateTime(2026, 3, 10, 9),
          endTime: DateTime(2026, 3, 10, 10));
      await schedule.createBlock(
          title: 'Empty',
          startTime: DateTime(2026, 3, 10, 11),
          endTime: DateTime(2026, 3, 10, 12));
      await schedule.createBlock(
          title: 'Other day',
          startTime: DateTime(2026, 3, 11, 9),
          endTime: DateTime(2026, 3, 11, 10));
      for (final (title, block) in [
        ('a1', late),
        ('m1', early),
        ('a2', late),
      ]) {
        await tasks.createTask(
            title: title, priority: TaskPriority.low, scheduleBlockId: block);
      }
      await tasks.createTask(title: 'loose', priority: TaskPriority.low);

      final plan = await schedule.watchDayPlan(DateTime(2026, 3, 10)).first;
      expect(plan.map((p) => p.block.title), ['Morning', 'Empty', 'Afternoon']);
      expect(plan.map((p) => p.tasks.map((t) => t.title).toList()), [
        ['m1'],
        <String>[],
        ['a1', 'a2'],
      ]);
    });

    test('updates when a task changes (one query watches both tables)',
        () async {
      final block = await schedule.createBlock(
          title: 'B',
          startTime: DateTime(2026, 3, 10, 9),
          endTime: DateTime(2026, 3, 10, 10));
      final updates = schedule
          .watchDayPlan(DateTime(2026, 3, 10))
          .map((plan) => plan.single.tasks.length);
      final expectation = expectLater(updates, emitsThrough(1));
      await tasks.createTask(
          title: 't', priority: TaskPriority.low, scheduleBlockId: block);
      await expectation;
    });
  });

  group('backlog (B20)', () {
    Future<int> add(String title, {bool done = false}) async {
      final id =
          await tasks.createTask(title: title, priority: TaskPriority.low);
      if (done) await tasks.setTaskStatus(id, TaskStatus.done);
      return id;
    }

    test('open tasks oldest first, without completed ones', () async {
      await add('first');
      await add('finished', done: true);
      await add('second');

      final open =
          await tasks.watchUnscheduledTasks(done: false, limit: 50).first;
      expect(open.map((t) => t.title), ['first', 'second']);
    });

    test('a limit caps the page', () async {
      for (var i = 0; i < 5; i++) {
        await add('t$i');
      }
      final page =
          await tasks.watchUnscheduledTasks(done: false, limit: 3).first;
      expect(page.map((t) => t.title), ['t0', 't1', 't2']);
    });

    test('completed tasks newest first, with a count', () async {
      await add('old', done: true);
      await add('open');
      await add('new', done: true);

      final done =
          await tasks.watchUnscheduledTasks(done: true, limit: 50).first;
      expect(done.map((t) => t.title), ['new', 'old']);
      expect(await tasks.watchUnscheduledDoneCount().first, 2);
    });
  });
}
