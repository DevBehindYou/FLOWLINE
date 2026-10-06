import 'dart:convert';

import 'package:drift/drift.dart';

import '../../domain/assistant/action_preview.dart';
import '../../domain/assistant/autonomy.dart';
import '../../domain/assistant/ledger.dart';
import '../../domain/assistant/tool.dart';
import '../local/drift/app_database.dart';

/// Runs work that must wait for a commit (notifications). Failures are
/// swallowed by the caller: the data change already happened and must
/// not be reported as failed because an alert couldn't be scheduled.
abstract interface class AfterCommitHandler {
  Future<void> handle(AfterCommit effect);
}

final class NoAfterCommit implements AfterCommitHandler {
  const NoAfterCommit();
  @override
  Future<void> handle(AfterCommit effect) async {}
}

sealed class ExecutionResult {
  const ExecutionResult();
}

final class Executed extends ExecutionResult {
  const Executed(this.outcome, {this.entryId});
  final ToolOutcome outcome;

  /// The ledger row; null for reads, which write none.
  final int? entryId;
}

/// Validation failed against the state inside the transaction. Nothing
/// changed and nothing was recorded.
final class Rejected extends ExecutionResult {
  const Rejected(this.invalid);
  final Invalid invalid;
}

/// The tool threw; the transaction rolled back and a `failed` ledger row
/// records the attempt (for anything but a read).
final class Failed extends ExecutionResult {
  const Failed(this.error);
  final Object error;
}

/// Runs one prepared call: validate again, run, and write its ledger row,
/// all in one transaction (docs/05 §6.3), then the after-commit effects.
final class ToolExecutor {
  ToolExecutor({
    required AppDatabase db,
    required ToolEnv Function() env,
    AfterCommitHandler effects = const NoAfterCommit(),
  })  : _db = db,
        _env = env,
        _effects = effects;

  final AppDatabase _db;
  final ToolEnv Function() _env;
  final AfterCommitHandler _effects;

  Future<ExecutionResult> execute(
    PreparedCall call, {
    required String groupId,
    required ActionOrigin origin,
    required Decision decision,
    int? utteranceId,
    ActionPreview? preview,
  }) async {
    final env = _env();
    AssistantActionsCompanion row(LedgerStatus status, String? undo) =>
        AssistantActionsCompanion.insert(
          at: env.now,
          groupId: groupId,
          toolName: call.toolName,
          argsJson: call.argsJson,
          origin: origin,
          decision: decision,
          status: status,
          undoJson: Value(undo),
          utteranceId: Value(utteranceId),
          previewJson: Value(
              preview == null ? null : jsonEncode(previewToJson(preview))),
        );
    final records = call.risk != ActionRisk.read;

    final ExecutionResult result;
    try {
      result = await _db.transaction(() async {
        final validation = await call.validate(env);
        if (validation is Invalid) return Rejected(validation);
        final outcome = await call.run(env);
        int? entryId;
        if (records) {
          final undo = outcome.undo;
          entryId = await _db.into(_db.assistantActions).insert(row(
              LedgerStatus.done, undo == null ? null : encodeUndoRecipe(undo)));
        }
        return Executed(outcome, entryId: entryId);
      });
    } on Object catch (error) {
      if (records) {
        await _db
            .into(_db.assistantActions)
            .insert(row(LedgerStatus.failed, null));
      }
      return Failed(error);
    }
    if (result is Executed) await _runEffects(result.outcome.afterCommit);
    return result;
  }

  Future<void> _runEffects(List<AfterCommit> effects) async {
    for (final e in effects) {
      try {
        await _effects.handle(e);
      } on Object {
        // See AfterCommitHandler.
      }
    }
  }
}
