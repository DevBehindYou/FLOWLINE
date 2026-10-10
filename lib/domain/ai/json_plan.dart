import 'dart:convert';

import 'ai_contract.dart';

// The JSON-plan fallback (docs/05 §8.2). When a model or server refuses
// tools, the same tools go into the instructions and the model answers
// with a plan in one JSON object. The plan becomes the same AIToolCalls
// native tool calling produces, so nothing downstream can tell them
// apart. Its contents are untrusted (R16): callers validate every call.

/// Instructions that describe [tools] and the plan format. Model-facing
/// text, never shown in the UI.
String jsonPlanInstructions(List<AIToolSpec> tools) {
  final catalogue = [
    for (final t in tools)
      {'tool': t.name, 'description': t.description, 'args': t.parameters},
  ];
  return '''
You can act only by listing actions from this catalogue:
${jsonEncode(catalogue)}

Answer with exactly one JSON object and nothing else:
{"reply": "<one short sentence for the user>", "actions": [{"tool": "<name>", "args": {<arguments>}}]}
Use an empty "actions" list when no action is needed. Never invent tools or ids.''';
}

/// Earlier rounds of this request, as text for a model without tools.
String jsonPlanContinuation(List<AITurn> turns) {
  if (turns.isEmpty) return '';
  final lines = <String>['', 'Earlier in this request:'];
  for (final t in turns) {
    switch (t) {
      case AIAssistantTurn(:final toolCalls):
        for (final c in toolCalls) {
          lines.add('- you asked for ${c.name} ${c.argumentsJson}');
        }
      case AIToolResultTurn(:final name, :final json, :final isError):
        lines.add('- ${isError ? 'error from' : 'result of'} $name: $json');
    }
  }
  return lines.join('\n');
}

/// A plan as calls, or null when [text] holds no usable plan. Tolerates a
/// Markdown code fence and prose around the object; drops actions that
/// have no tool name or whose args aren't an object.
AIToolTurnReply? parseJsonPlan(String text) {
  final start = text.indexOf('{');
  final end = text.lastIndexOf('}');
  if (start < 0 || end <= start) return null;
  final Object? decoded;
  try {
    decoded = jsonDecode(text.substring(start, end + 1));
  } on FormatException {
    return null;
  }
  if (decoded is! Map) return null;
  final reply = decoded['reply'];
  final actions = decoded['actions'];
  if (actions != null && actions is! List) return null;
  final calls = <AIToolCall>[];
  for (final (i, a) in (actions as List? ?? const []).indexed) {
    if (a is! Map) continue;
    final tool = a['tool'];
    final args = a['args'] ?? const <String, Object?>{};
    if (tool is! String || tool.isEmpty || args is! Map) continue;
    calls.add(
        AIToolCall(id: 'plan_$i', name: tool, argumentsJson: jsonEncode(args)));
  }
  return AIToolTurnReply(
    text: reply is String ? reply : '',
    calls: calls,
    stopReason: calls.isEmpty ? AIStopReason.complete : AIStopReason.toolUse,
  );
}
