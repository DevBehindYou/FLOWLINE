import 'dart:convert';

import '../../domain/ai/ai_contract.dart';
import '../../domain/ai/tool_schema.dart';
import '../../domain/assistant/tool.dart';
import 'block_tools.dart';
import 'delete_tools.dart';
import 'focus_tool.dart';
import 'read_tools.dart';
import 'task_tools.dart';

/// The tools AA has (docs/05 §9.2), first slice: the ones the current
/// schema can back. There are no forbidden tools to register: an unknown
/// name is rejected, so "pay", "send" or "record" don't exist at all.
const List<AssistantTool<Object>> defaultTools = [
  GetAgendaTool(),
  FindFreeTimeTool(),
  SearchTasksTool(),
  GetTaskTool(),
  CreateTaskTool(),
  UpdateTaskTool(),
  CompleteTaskTool(),
  ScheduleTaskTool(),
  BreakDownTaskTool(),
  CreateBlockTool(),
  MoveBlockTool(),
  StartFocusTool(),
  DeleteTaskTool(),
  DeleteBlockTool(),
];

/// What [ToolRegistry.prepare] made of one call.
sealed class PrepareResult {
  const PrepareResult();
}

final class Prepared extends PrepareResult {
  const Prepared(this.call);
  final PreparedCall call;
}

final class UnknownTool extends PrepareResult {
  const UnknownTool(this.name);
  final String name;
}

/// The arguments aren't JSON, aren't an object, or don't fit the tool.
final class BadArguments extends PrepareResult {
  const BadArguments(this.field, this.problem);
  final String field;
  final String problem;
}

final class ToolRegistry {
  /// Throws [ArgumentError] on a duplicate or malformed name, or a schema
  /// outside the portable subset: a programming error, caught by tests.
  ToolRegistry([List<AssistantTool<Object>> tools = defaultTools])
      : _tools = {for (final t in tools) t.name: t} {
    if (_tools.length != tools.length) {
      throw ArgumentError('Duplicate tool names');
    }
    for (final t in tools) {
      if (!toolNamePattern.hasMatch(t.name)) {
        throw ArgumentError('Bad tool name ${t.name}');
      }
      final problems = unsupportedSchemaKeywords(t.parameters);
      if (problems.isNotEmpty) {
        throw ArgumentError('${t.name}: unsupported schema $problems');
      }
    }
  }

  final Map<String, AssistantTool<Object>> _tools;

  Iterable<AssistantTool<Object>> get tools => _tools.values;
  List<AIToolSpec> get specs => [for (final t in _tools.values) t.spec];
  AssistantTool<Object>? operator [](String name) => _tools[name];

  /// Parses one call from a model or the local grammar. Never throws.
  PrepareResult prepare(String name, String argumentsJson) {
    final Object? decoded;
    try {
      decoded = argumentsJson.trim().isEmpty ? {} : jsonDecode(argumentsJson);
    } on FormatException {
      return const BadArguments(r'$', 'not JSON');
    }
    if (decoded is! Map) return const BadArguments(r'$', 'not an object');
    return prepareMap(name, decoded.cast<String, Object?>());
  }

  PrepareResult prepareMap(String name, Map<String, Object?> args) {
    final tool = _tools[name];
    if (tool == null) return UnknownTool(name);
    try {
      return Prepared(tool.prepare(args));
    } on ToolArgumentError catch (e) {
      return BadArguments(e.field, e.problem);
    }
  }
}
