import 'package:clock/clock.dart';

import '../data/assistant/tool_executor.dart';
import '../domain/assistant/autonomy.dart';
import 'tools/tool_registry.dart';

/// Runs one tool call for a tap in the app (not the chat): the same tool,
/// validation and ledger row as anything else AA does, so the tap shows
/// in Activity with undo. A destructive call must be confirmed by the
/// screen before this is called. Returns the executor's result; a
/// malformed call is a programming error.
Future<ExecutionResult> runDirectAction({
  required ToolRegistry registry,
  required ToolExecutor executor,
  required String tool,
  required Map<String, Object?> args,
}) {
  final prepared = registry.prepareMap(tool, args);
  if (prepared is! Prepared) {
    throw ArgumentError('Bad direct action $tool: $prepared');
  }
  final call = prepared.call;
  return executor.execute(
    call,
    groupId: 'tap-$tool-${clock.now().microsecondsSinceEpoch}',
    origin: ActionOrigin.said,
    decision: call.risk == ActionRisk.destructive
        ? Decision.confirm
        : Decision.executeWithUndo,
  );
}
