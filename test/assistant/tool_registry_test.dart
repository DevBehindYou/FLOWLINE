import 'package:atomic_assist/assistant/tools/tool_registry.dart';
import 'package:atomic_assist/domain/ai/tool_schema.dart';
import 'package:atomic_assist/domain/assistant/autonomy.dart';
import 'package:atomic_assist/domain/assistant/quick_parse.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final registry = ToolRegistry();

  test('every tool has a portable schema', () {
    expect(registry.tools, hasLength(21));
    for (final t in registry.tools) {
      expect(toolNamePattern.hasMatch(t.name), isTrue, reason: t.name);
      expect(unsupportedSchemaKeywords(t.parameters), isEmpty, reason: t.name);
      expect(t.parameters['type'], 'object', reason: t.name);
      expect(t.description, isNotEmpty, reason: t.name);
    }
    expect(
        registry.specs.map((s) => s.name), registry.tools.map((t) => t.name));
  });

  test('risk classes', () {
    Set<String> withRisk(ActionRisk r) => {
          for (final t in registry.tools)
            if (t.risk == r) t.name
        };
    expect(withRisk(ActionRisk.read), {
      'get_agenda',
      'find_free_time',
      'search_tasks',
      'get_task',
      'list_items'
    });
    expect(withRisk(ActionRisk.destructive),
        {'delete_task', 'delete_block', 'clear_checked'});
    expect(withRisk(ActionRisk.forbidden), isEmpty);
  });

  test('a duplicate name or an unportable schema is a programming error', () {
    expect(() => ToolRegistry([...defaultTools, defaultTools.first]),
        throwsArgumentError);
  });

  group('prepare never throws', () {
    test('unknown tools do not exist, whatever they are called', () {
      for (final name in ['pay', 'send_sms', 'record_call', '']) {
        expect(registry.prepare(name, '{}'), isA<UnknownTool>());
      }
    });

    test('malformed arguments name the field', () {
      BadArguments bad(String tool, String json) =>
          registry.prepare(tool, json) as BadArguments;
      expect(bad('create_task', 'not json').field, r'$');
      expect(bad('create_task', '[1]').field, r'$');
      expect(bad('create_task', '{}').field, 'title');
      expect(bad('create_task', '{"title": 7}').field, 'title');
      expect(
          bad('create_task', '{"title": "x", "due": "tomorrow"}').field, 'due');
      expect(bad('create_task', '{"title": "x", "due": "2026-02-30"}').field,
          'due');
      expect(bad('create_task', '{"title": "x", "priority": "urgent"}').field,
          'priority');
      expect(bad('create_task', '{"title": "${'x' * 201}"}').field, 'title');
      expect(
          bad('schedule_task', '{"task_id": 1, "start": "2026-10-05T10:00"}')
              .field,
          'minutes');
      expect(
          bad('schedule_task',
                  '{"task_id": 1, "start": "2026-10-05T10:00", "minutes": 2.5}')
              .field,
          'minutes');
      expect(
          bad('break_down_task', '{"task_id": 1, "steps": ["only one"]}').field,
          'steps');
      expect(bad('complete_task', '{}').field, 'task_id');
    });

    test('a whole number sent as a float is accepted', () {
      expect(
          registry.prepare('schedule_task',
              '{"task_id": 1.0, "start": "2026-10-05T10:00", "minutes": 30.0}'),
          isA<Prepared>());
    });

    test('a zoned time is converted to local', () {
      expect(
          registry.prepare(
              'create_task', '{"title": "x", "due": "2026-10-05T10:00Z"}'),
          isA<Prepared>());
    });
  });

  test('every call the local grammar makes to these tools parses', () {
    final now = DateTime(2026, 10, 5, 16, 40);
    final phrases = [
      'add a task send deck to Priya by Friday',
      'mark write report done',
      'report ho gaya',
      'start a focus for 30 minutes on write report',
      'start focus',
      'add milk, eggs and bread to shopping',
      "what's on tomorrow",
      'aaj kya hai',
    ];
    for (final p in phrases) {
      final call = quickParse(p, now: now);
      expect(call, isNotNull, reason: p);
      expect(registry[call!.tool], isNotNull, reason: '${call.tool} ($p)');
      expect(registry.prepareMap(call.tool, call.args), isA<Prepared>(),
          reason: '$call');
    }
  });
}
