import 'package:flowline/domain/entities/schedule_block.dart';
import 'package:flowline/domain/entities/task.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final task = Task(
    id: 1,
    title: 'Write',
    priority: TaskPriority.medium,
    status: TaskStatus.todo,
    scheduleBlockId: 7,
    dueAt: DateTime(2026, 3, 10, 17),
    createdAt: DateTime(2026, 3, 1),
  );

  group('Task.copyWith (B11)', () {
    test('keeps nullable fields when they are not given', () {
      final copy = task.copyWith(title: 'Edit');
      expect(copy.title, 'Edit');
      expect(copy.scheduleBlockId, 7);
      expect(copy.dueAt, DateTime(2026, 3, 10, 17));
    });

    test('can clear the schedule block and the due date', () {
      final copy =
          task.copyWith(scheduleBlockId: () => null, dueAt: () => null);
      expect(copy.scheduleBlockId, isNull);
      expect(copy.dueAt, isNull);
    });

    test('can change them', () {
      final copy = task.copyWith(
          scheduleBlockId: () => 9, dueAt: () => DateTime(2026, 3, 11));
      expect(copy.scheduleBlockId, 9);
      expect(copy.dueAt, DateTime(2026, 3, 11));
    });

    test('never changes id or createdAt', () {
      final copy = task.copyWith(title: 'x');
      expect(copy.id, task.id);
      expect(copy.createdAt, task.createdAt);
    });
  });

  test('ScheduleBlock.copyWith can change source and lock state', () {
    final block = ScheduleBlock(
      id: 1,
      title: 'Deep work',
      startTime: DateTime(2026, 3, 10, 9),
      endTime: DateTime(2026, 3, 10, 11),
    );
    final copy =
        block.copyWith(source: ScheduleBlockSource.aiGenerated, isLocked: true);
    expect(copy.source, ScheduleBlockSource.aiGenerated);
    expect(copy.isLocked, isTrue);
    expect(copy.title, block.title);
    expect(block.copyWith().isLocked, isFalse);
  });
}
