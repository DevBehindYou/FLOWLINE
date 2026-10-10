import 'dart:convert';

import 'package:atomic_assist/domain/ai/ai_contract.dart';
import 'package:atomic_assist/domain/ai/json_plan.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const tool = AIToolSpec(
    name: 'create_task',
    description: 'Create a task.',
    parameters: {
      'type': 'object',
      'properties': {
        'title': {'type': 'string'},
      },
    },
  );

  group('parseJsonPlan', () {
    test('turns actions into calls in order, with plan ids', () {
      final plan = parseJsonPlan(jsonEncode({
        'reply': 'Done.',
        'actions': [
          {
            'tool': 'create_task',
            'args': {'title': 'A'},
          },
          {
            'tool': 'create_task',
            'args': {'title': 'B'},
          },
        ],
      }))!;
      expect(plan.text, 'Done.');
      expect(plan.calls.map((c) => c.id), ['plan_0', 'plan_1']);
      expect(plan.calls.map((c) => jsonDecode(c.argumentsJson)), [
        {'title': 'A'},
        {'title': 'B'},
      ]);
      expect(plan.stopReason, AIStopReason.toolUse);
    });

    test('tolerates a code fence and prose around the object', () {
      final plan = parseJsonPlan('Sure!\n```json\n'
          '{"reply":"ok","actions":[{"tool":"create_task","args":{}}]}\n```')!;
      expect(plan.calls.single.name, 'create_task');
      expect(plan.calls.single.argumentsJson, '{}');
    });

    test('no actions is a plain reply', () {
      final plan = parseJsonPlan('{"reply":"Nothing to do.","actions":[]}')!;
      expect(plan.calls, isEmpty);
      expect(plan.stopReason, AIStopReason.complete);
    });

    test('drops malformed actions, keeps good ones (R16)', () {
      final plan = parseJsonPlan(jsonEncode({
        'actions': [
          {'tool': '', 'args': <String, Object?>{}},
          {'args': <String, Object?>{}},
          {'tool': 'x', 'args': 'not an object'},
          'junk',
          {'tool': 'create_task'},
        ],
      }))!;
      expect(plan.calls.map((c) => c.name), ['create_task']);
      expect(plan.text, '');
    });

    for (final bad in [
      '',
      'no json here',
      '{"actions": "nope"}',
      '[1,2]',
      '{"reply": "x", ',
    ]) {
      test('no usable plan in "$bad"', () {
        expect(parseJsonPlan(bad), isNull);
      });
    }
  });

  test('instructions list every tool and the exact format', () {
    final text = jsonPlanInstructions(const [tool]);
    expect(text, contains('create_task'));
    expect(text, contains('Create a task.'));
    expect(text, contains('"actions"'));
  });

  test('continuation replays calls and results as text', () {
    final text = jsonPlanContinuation(const [
      AIAssistantTurn(toolCalls: [
        AIToolCall(
            id: 'c', name: 'create_task', argumentsJson: '{"title":"A"}'),
      ]),
      AIToolResultTurn(callId: 'c', name: 'create_task', json: '{"id":7}'),
      AIToolResultTurn(
          callId: 'd', name: 'find', json: '"not found"', isError: true),
    ]);
    expect(text, contains('create_task {"title":"A"}'));
    expect(text, contains('result of create_task: {"id":7}'));
    expect(text, contains('error from find'));
    expect(jsonPlanContinuation(const []), isEmpty);
  });
}
