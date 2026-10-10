import 'dart:convert';

import '../ai/ai_contract.dart';
import '../repositories/focus_session_repository.dart';
import '../repositories/list_repository.dart';
import '../repositories/people_repository.dart';
import '../repositories/reminder_repository.dart';
import '../repositories/schedule_repository.dart';
import '../repositories/task_repository.dart';
import 'action_preview.dart';
import 'autonomy.dart';
import 'ledger.dart';

// The tool interface (docs/05 §9.1). Pure Dart. A tool is the only way
// the assistant changes anything: the model (or the local grammar) names
// one with JSON arguments, and the core parses, validates, decides and
// runs it. Arguments are untrusted input (R16) at every step.

/// Why a call can't run as asked. Returned to the model so it can try
/// again, and worded by l10n when the user sees it. Append-only (R1).
enum InvalidReason {
  notFound,
  ambiguous,
  inPast,
  empty,
  tooLong,
  endBeforeStart,
  conflict,
  outOfRange,
  notSupported,
  alreadyDone,
  busy,
  nothingToChange,
}

sealed class ToolValidation {
  const ToolValidation();
}

final class Valid extends ToolValidation {
  const Valid();
}

final class Invalid extends ToolValidation {
  const Invalid(this.reason, [this.detail]);
  final InvalidReason reason;

  /// Model-facing specifics (a field name, the conflicting block's title,
  /// candidate titles). Never shown as UI text.
  final String? detail;

  @override
  String toString() => 'Invalid(${reason.name}, $detail)';
}

/// The arguments don't have the shape the tool's schema promises. Fed
/// back to the model to correct; never reaches the user as text.
final class ToolArgumentError implements Exception {
  const ToolArgumentError(this.field, this.problem);
  final String field;
  final String problem;

  @override
  String toString() => 'ToolArgumentError($field: $problem)';
}

/// What tools may read and write while validating or running. Writes go
/// through the normal repositories; the executor runs [AssistantTool.run]
/// inside one transaction with its ledger row, so a tool never manages
/// transactions itself.
abstract interface class ToolEnv {
  DateTime get now;
  TaskRepository get tasks;
  ScheduleRepository get schedule;
  FocusSessionRepository get focus;
  ReminderRepository get reminders;
  ListRepository get lists;
  PeopleRepository get people;

  /// Default length of a focus session, from Settings.
  Future<int> focusMinutes();

  /// The row as stored (SQL column names, JSON-safe values), for undo
  /// recipes. Null when there is no such row.
  Future<Map<String, Object?>?> storedRow(UndoTable table, int id);

  /// Stored rows of [table] where [column] equals [value].
  Future<List<Map<String, Object?>>> storedRowsWhere(
      UndoTable table, String column, int value);
}

/// Something to do after the transaction commits: never inside it, so a
/// rolled-back action can't leave a notification behind.
sealed class AfterCommit {
  const AfterCommit();
}

/// A focus session started; schedule its end-of-session alert.
final class FocusStarted extends AfterCommit {
  const FocusStarted(this.sessionId);
  final int sessionId;
}

/// A focus session was stopped or removed by undo; cancel its alert.
final class FocusStopped extends AfterCommit {
  const FocusStopped(this.sessionId);
  final int sessionId;
}

/// A reminder was created, changed or removed: bring its notification in
/// line with the database (schedule, move or cancel).
final class ReminderTouched extends AfterCommit {
  const ReminderTouched(this.reminderId);
  final int reminderId;
}

final class ToolOutcome {
  const ToolOutcome({
    required this.result,
    this.undo,
    this.afterCommit = const [],
  });

  /// Compact JSON for the model's next round (read tools return data).
  final Map<String, Object?> result;

  /// Null for reads.
  final UndoRecipe? undo;
  final List<AfterCommit> afterCommit;
}

/// One tool. [A] is its parsed, typed arguments.
abstract class AssistantTool<A extends Object> {
  const AssistantTool();

  /// Stable snake_case id, stored in the ledger and proposals.
  String get name;

  /// For the model only (English, never shown in the UI).
  String get description;

  /// JSON Schema in the portable subset (`tool_schema.dart`).
  Map<String, Object?> get parameters;
  ActionRisk get risk;

  /// Throws [ToolArgumentError] on a shape error.
  A parse(Map<String, Object?> json);

  /// Checks [args] against the current state, read fresh from [env].
  Future<ToolValidation> validate(A args, ToolEnv env);

  /// Typed description of the effect; the UI words it with l10n.
  Future<ActionPreview> preview(A args, ToolEnv env);

  /// Runs the effect and says how to undo it. Called only after
  /// [validate] returned [Valid] in the same transaction.
  Future<ToolOutcome> run(A args, ToolEnv env);

  AIToolSpec get spec =>
      AIToolSpec(name: name, description: description, parameters: parameters);

  /// Parses [json] and binds the result, so callers can hold calls to
  /// different tools in one list without knowing their argument types.
  PreparedCall prepare(Map<String, Object?> json) =>
      PreparedCall._(this, parse(json), jsonEncode(json));
}

/// A parsed call, ready to validate, preview or run.
final class PreparedCall {
  PreparedCall._(this._tool, this._args, this.argsJson);

  final AssistantTool<Object> _tool;
  final Object _args;

  /// The arguments as received, for the ledger and proposals.
  final String argsJson;

  String get toolName => _tool.name;
  ActionRisk get risk => _tool.risk;

  Future<ToolValidation> validate(ToolEnv env) => _tool.validate(_args, env);
  Future<ActionPreview> preview(ToolEnv env) => _tool.preview(_args, env);
  Future<ToolOutcome> run(ToolEnv env) => _tool.run(_args, env);
}
