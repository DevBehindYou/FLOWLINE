import 'package:atomic_assist/domain/entities/task.dart';
import 'package:atomic_assist/domain/services/task_due.dart';
import 'package:flutter_test/flutter_test.dart';

Task _task({DateTime? dueAt, TaskStatus status = TaskStatus.todo}) => Task(
      id: 1,
      title: 't',
      priority: TaskPriority.low,
      status: status,
      dueAt: dueAt,
      createdAt: DateTime(2026),
    );

void main() {
  final now = DateTime(2026, 3, 10, 12);

  test('no due date reads as none', () {
    expect(dueStateOf(_task(), now: now), DueState.none);
  });

  test('past due and not done is overdue', () {
    expect(dueStateOf(_task(dueAt: DateTime(2026, 3, 10, 11)), now: now),
        DueState.overdue);
    expect(dueStateOf(_task(dueAt: DateTime(2026, 3, 1)), now: now),
        DueState.overdue);
  });

  test('a done task is never overdue', () {
    expect(
        dueStateOf(_task(dueAt: DateTime(2026, 3, 1), status: TaskStatus.done),
            now: now),
        DueState.none);
  });

  test('later today vs a later day', () {
    expect(dueStateOf(_task(dueAt: DateTime(2026, 3, 10, 18)), now: now),
        DueState.dueToday);
    expect(dueStateOf(_task(dueAt: DateTime(2026, 3, 11, 9)), now: now),
        DueState.upcoming);
  });
}
