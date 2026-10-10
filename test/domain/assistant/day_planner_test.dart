import 'package:atomic_assist/domain/assistant/day_planner.dart';
import 'package:atomic_assist/domain/entities/schedule_block.dart';
import 'package:atomic_assist/domain/entities/task.dart';
import 'package:flutter_test/flutter_test.dart';

/// Plan my day (docs/05 §12.3) with a fixed clock.
void main() {
  // Monday 5 October 2026, 08:00: the plan starts at 09:00.
  final early = DateTime(2026, 10, 5, 8);
  DateTime at(int h, [int m = 0]) => DateTime(2026, 10, 5, h, m);

  Task task(int id,
          {TaskPriority priority = TaskPriority.medium,
          DateTime? due,
          int? block,
          DateTime? made}) =>
      Task(
          id: id,
          title: 'T$id',
          priority: priority,
          status: TaskStatus.todo,
          dueAt: due,
          scheduleBlockId: block,
          createdAt: made ?? DateTime(2026, 9, id));

  ScheduleBlock block(int id, DateTime start, DateTime end) =>
      ScheduleBlock(id: id, title: 'B$id', startTime: start, endTime: end);

  String show(List<PlannedTask> plan) => [
        for (final p in plan)
          '${p.task.title}@${p.start.hour}:${p.start.minute.toString().padLeft(2, '0')}',
      ].join(' ');

  test('most urgent first: due soonest, then priority, then oldest', () {
    final plan = planDay(now: early, tasks: [
      task(1),
      task(2, priority: TaskPriority.high),
      task(3, due: DateTime(2026, 10, 6, 17)),
      task(4, due: DateTime(2026, 10, 5, 17)),
      task(5, priority: TaskPriority.high, made: DateTime(2026, 8, 1)),
    ], blocks: []);
    expect(show(plan), 'T4@9:00 T3@9:30 T5@10:00 T2@10:30 T1@11:00');
    expect(plan.every((p) => p.minutes == 30), isTrue);
  });

  test('around existing blocks, with 10 minutes after each', () {
    final plan = planDay(now: early, tasks: [
      task(1),
      task(2),
      task(3)
    ], blocks: [
      block(1, at(9), at(10)),
      block(2, at(10, 40), at(12)),
    ]);
    // 10:10–10:40 fits one; then after 12:00 + 10.
    expect(show(plan), 'T1@10:10 T2@12:10 T3@12:40');
  });

  test('from the next quarter hour once the day has started', () {
    final plan = planDay(now: at(14, 7), tasks: [task(1)], blocks: const []);
    expect(plan.single.start, at(14, 15));
  });

  test('tasks with a block or done are left alone', () {
    final done = Task(
        id: 9,
        title: 'T9',
        priority: TaskPriority.high,
        status: TaskStatus.done,
        createdAt: DateTime(2026, 9, 1));
    expect(planDay(now: early, tasks: [task(1, block: 4), done], blocks: []),
        isEmpty);
  });

  test('a task due before its slot would end is skipped; overdue ones fit', () {
    final plan = planDay(now: at(11), tasks: [
      task(1, due: at(11, 20)), // 11:15–11:45 ends after its due time
      task(2, due: at(10)), // already overdue: plan it anyway
    ], blocks: const []);
    expect(show(plan), 'T2@11:15');
  });

  test('stops at the end of the working day and at maxTasks', () {
    expect(
        planDay(now: at(17, 50), tasks: [task(1)], blocks: const []), isEmpty);
    final many = planDay(
        now: early,
        tasks: [for (var i = 1; i <= 20; i++) task(i)],
        blocks: const []);
    expect(many, hasLength(const DayPlanRules().maxTasks));
  });

  test('no gap long enough: nothing', () {
    expect(
        planDay(now: early, tasks: [
          task(1)
        ], blocks: [
          block(1, at(9), at(11, 50)),
          block(2, at(12, 20), at(18)),
        ]),
        isEmpty);
  });
}
