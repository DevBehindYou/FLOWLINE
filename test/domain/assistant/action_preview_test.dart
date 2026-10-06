import 'dart:convert';

import 'package:atomic_assist/domain/assistant/action_preview.dart';
import 'package:atomic_assist/domain/entities/task.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final t = DateTime(2026, 10, 5, 17, 30);
  final all = <ActionPreview>[
    ReadPreview(ReadKind.agenda, day: DateTime(2026, 10, 5)),
    const ReadPreview(ReadKind.searchTasks),
    CreateTaskPreview(title: 'Deck', priority: TaskPriority.high, due: t),
    const CreateTaskPreview(title: 'No due', priority: TaskPriority.low),
    const UpdateTaskPreview(
        title: 'Report', fields: {TaskField.title, TaskField.due}),
    const CompleteTaskPreview('Report'),
    ScheduleTaskPreview(
        title: 'Report', start: t, end: t.add(const Duration(hours: 1))),
    CreateBlockPreview(
        title: 'Walk', start: t, end: t.add(const Duration(minutes: 30))),
    MoveBlockPreview(
        title: 'Gym',
        fromStart: t,
        fromEnd: t.add(const Duration(hours: 1)),
        toStart: t.add(const Duration(hours: 2)),
        toEnd: t.add(const Duration(hours: 3))),
    const StartFocusPreview(minutes: 25, taskTitle: 'Report'),
    const StartFocusPreview(minutes: 50),
    const BreakDownTaskPreview(title: 'Report', steps: ['A', 'B']),
    const DeletePreview(
        kind: DeleteKind.task, titles: ['Old'], subtaskCount: 2),
    const DeletePreview(
        kind: DeleteKind.block, titles: ['Deep work'], unscheduledTaskCount: 1),
  ];

  test('every preview survives the stored form unchanged', () {
    for (final p in all) {
      final json = jsonDecode(jsonEncode(previewToJson(p)));
      final back = previewFromJson(json)!;
      expect(back.runtimeType, p.runtimeType);
      expect(previewToJson(back), previewToJson(p), reason: '$p');
    }
  });

  test('anything else decodes to null, never throws', () {
    for (final bad in <Object?>[
      null,
      'text',
      [1],
      {'k': 'launchRocket'},
      {'k': 'createTask', 'title': 'x'}, // no priority
      {'k': 'createTask', 'title': 'x', 'priority': 'urgent'},
      {'k': 'completeTask', 'title': 7},
      {'k': 'scheduleTask', 'title': 'x', 'start': '9am', 'end': 1},
      {
        'k': 'updateTask',
        'title': 'x',
        'fields': ['colour']
      },
      {
        'k': 'breakDown',
        'title': 'x',
        'steps': [1, 2]
      },
      {
        'k': 'delete',
        'kind': 'person',
        'titles': ['x'],
        'subtasks': 0,
        'unscheduled': 0
      },
    ]) {
      expect(previewFromJson(bad), isNull, reason: '$bad');
    }
  });
}
