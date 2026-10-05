import 'dart:async';
import 'dart:convert';

import '../data/assistant/tool_executor.dart';
import '../domain/ai/ai_contract.dart';
import '../domain/assistant/action_preview.dart';
import '../domain/assistant/autonomy.dart';
import '../domain/assistant/quick_parse.dart';
import '../domain/assistant/tool.dart';
import '../domain/assistant/utterance.dart';
import '../domain/repositories/ai_repository.dart';
import '../domain/repositories/assistant_repository.dart';
import 'context_builder.dart';
import 'tools/tool_registry.dart';

// The orchestrator (docs/05 §9.3): one path for every request. The local
// grammar first (instant, offline, free); otherwise rounds with the model
// and tools. Every call is parsed, validated against fresh state, put
// through the policy, and only then run, with its ledger row, by the
// executor. A confirmation stops the turn; the UI resumes it.

/// What happened to one call in a turn.
enum CallStatus {
  /// Ran (with a ledger row unless it was a read).
  done,

  /// Didn't fit the current state, or the tool or arguments don't exist.
  rejected,

  /// The tool threw; nothing changed.
  failed,

  /// The policy says ask first; see [TurnNeedsConfirmation].
  needsConfirmation,

  /// Not allowed at all.
  refused,
}

final class ActedCall {
  const ActedCall({
    required this.toolName,
    required this.status,
    this.preview,
    this.invalid,
    this.entryId,
    this.result = const {},
  });

  final String toolName;
  final CallStatus status;

  /// Present for calls that passed validation.
  final ActionPreview? preview;

  /// Why it was rejected, when it was.
  final Invalid? invalid;
  final int? entryId;
  final Map<String, Object?> result;
}

/// A call the policy holds for the user's explicit yes.
final class PendingConfirmation {
  const PendingConfirmation({
    required this.groupId,
    required this.call,
    required this.preview,
    this.utteranceId,
  });
  final String groupId;
  final PreparedCall call;
  final ActionPreview preview;
  final int? utteranceId;
}

enum TurnLimit { rounds, calls, timeout }

sealed class TurnResult {
  const TurnResult(this.groupId, this.acted);

  /// Shared by every action of the turn: one UNDO reverses it.
  final String groupId;
  final List<ActedCall> acted;

  bool get changedSomething =>
      acted.any((a) => a.status == CallStatus.done && a.entryId != null);
}

/// The turn finished. [text] is the model's reply (empty for the local
/// grammar: the UI words [acted] instead).
final class TurnAnswered extends TurnResult {
  const TurnAnswered(super.groupId, super.acted, {this.text = ''});
  final String text;
}

final class TurnNeedsConfirmation extends TurnResult {
  const TurnNeedsConfirmation(super.groupId, super.acted,
      {required this.pending, this.text = ''});
  final PendingConfirmation pending;
  final String text;
}

final class TurnFailed extends TurnResult {
  const TurnFailed(super.groupId, super.acted, this.failure);
  final AIFailureKind failure;
}

final class TurnStopped extends TurnResult {
  const TurnStopped(super.groupId, super.acted, this.limit);
  final TurnLimit limit;
}

final class AssistantOrchestrator {
  AssistantOrchestrator({
    required this.registry,
    required this.ai,
    required this.executor,
    required this.store,
    required this.env,
    required this.autonomy,
    this.context = const AssistantContextBuilder(),
    this.turnTimeout = defaultTurnTimeout,
  });

  final ToolRegistry registry;
  final AIRepository ai;
  final ToolExecutor executor;
  final AssistantRepository store;
  final ToolEnv Function() env;
  final Future<AutonomyPreset> Function() autonomy;
  final AssistantContextBuilder context;

  /// Per model round.
  final Duration turnTimeout;

  static const maxRounds = 4;
  static const maxCallsPerTurn = 8;
  static const defaultTurnTimeout = Duration(seconds: 30);

  /// Read results going back to the model are capped (§9.3).
  static const maxResultChars = 4000;

  int _turns = 0;

  Future<TurnResult> handle(Utterance utterance) async {
    final start = env();
    final utteranceId = await store.recordUtterance(utterance, at: start.now);
    final groupId =
        'turn-$utteranceId-${start.now.microsecondsSinceEpoch}-${_turns++}';
    final preset = await autonomy();

    // 1. The local grammar.
    final local = quickParse(utterance.text, now: start.now);
    ActedCall? localRejection;
    final localCall =
        local == null ? null : registry.prepareMap(local.tool, local.args);
    if (localCall case Prepared(:final call)) {
      final round =
          await _act([_Call.local(call)], groupId, utteranceId, preset);
      if (round.pending != null) {
        return TurnNeedsConfirmation(groupId, round.acted,
            pending: round.pending!);
      }
      final only = round.acted.single;
      if (only.status != CallStatus.rejected) {
        return TurnAnswered(groupId, round.acted);
      }
      // e.g. a title that matches two tasks: the model can look them up.
      localRejection = only;
    }

    // 2. The model, with tools.
    final acted = <ActedCall>[];
    final turns = <AITurn>[];
    final cancel = AICancelToken();
    for (var round = 0; round < maxRounds; round++) {
      final AIToolTurnResult reply;
      try {
        reply = await ai
            .completeWithTools(
              prompt: utterance.text,
              system: await context.systemPrompt(env(), preset),
              tools: registry.specs,
              continuation: turns,
              cancel: cancel,
            )
            .timeout(turnTimeout);
      } on TimeoutException {
        cancel.cancel();
        return TurnStopped(groupId, acted, TurnLimit.timeout);
      }
      switch (reply) {
        case AIToolTurnFailed(:final failure):
          // Offline or no provider: what the grammar found still counts.
          if (localRejection != null && acted.isEmpty) {
            return TurnAnswered(groupId, [localRejection]);
          }
          return TurnFailed(groupId, acted, failure.kind);
        case AIToolTurnReply(:final text, :final calls):
          if (calls.isEmpty) {
            return TurnAnswered(groupId, acted, text: text);
          }
          if (acted.length + calls.length > maxCallsPerTurn) {
            return TurnStopped(groupId, acted, TurnLimit.calls);
          }
          final prepared = [
            for (final c in calls)
              _Call.model(c, registry.prepare(c.name, c.argumentsJson)),
          ];
          final result = await _act(prepared, groupId, utteranceId, preset);
          acted.addAll(result.acted);
          if (result.pending != null) {
            return TurnNeedsConfirmation(groupId, acted,
                pending: result.pending!, text: text);
          }
          turns
            ..add(AIAssistantTurn(text: text, toolCalls: calls))
            ..addAll(result.resultTurns);
      }
    }
    return TurnStopped(groupId, acted, TurnLimit.rounds);
  }

  /// Runs a held call after the user said yes. The tap is the consent;
  /// the state is checked again, since time has passed.
  Future<ActedCall> confirm(PendingConfirmation p) async {
    final e = env();
    final preview = await _safePreview(p.call, e) ?? p.preview;
    return _execute(p.call, e, preview,
        groupId: p.groupId,
        utteranceId: p.utteranceId,
        decision: Decision.confirm);
  }

  Future<_Round> _act(List<_Call> calls, String groupId, int? utteranceId,
      AutonomyPreset preset) async {
    final acted = <ActedCall>[];
    final turns = <AIToolResultTurn>[];
    void reply(_Call c, Map<String, Object?> json, {bool error = false}) {
      final id = c.modelCall;
      if (id == null) return;
      var text = jsonEncode(json);
      if (text.length > maxResultChars) {
        text = jsonEncode({'truncated': true, 'size': text.length});
      }
      turns.add(AIToolResultTurn(
          callId: id.id, name: id.name, json: text, isError: error));
    }

    for (final c in calls) {
      final PreparedCall call;
      switch (c.prepared) {
        case UnknownTool(:final name):
          acted.add(ActedCall(
              toolName: name,
              status: CallStatus.rejected,
              invalid: const Invalid(InvalidReason.notSupported)));
          reply(c, {'error': 'unknown_tool', 'tool': name}, error: true);
          continue;
        case BadArguments(:final field, :final problem):
          final name = c.modelCall?.name ?? '';
          acted.add(ActedCall(
              toolName: name,
              status: CallStatus.rejected,
              invalid: Invalid(InvalidReason.outOfRange, field)));
          reply(
              c, {'error': 'bad_arguments', 'field': field, 'problem': problem},
              error: true);
          continue;
        case Prepared(call: final p):
          call = p;
      }

      final e = env();
      final validation = await call.validate(e);
      if (validation is Invalid) {
        acted.add(ActedCall(
            toolName: call.toolName,
            status: CallStatus.rejected,
            invalid: validation));
        reply(
            c,
            {
              'error': validation.reason.name,
              if (validation.detail != null) 'detail': validation.detail,
            },
            error: true);
        continue;
      }
      final preview = await call.preview(e);
      final decision =
          decide(risk: call.risk, origin: ActionOrigin.said, preset: preset);
      switch (decision) {
        case Decision.refuse:
          acted.add(ActedCall(
              toolName: call.toolName,
              status: CallStatus.refused,
              preview: preview));
          reply(c, {'error': 'not_allowed'}, error: true);
        case Decision.confirm:
          acted.add(ActedCall(
              toolName: call.toolName,
              status: CallStatus.needsConfirmation,
              preview: preview));
          // The turn stops here: nothing after a held call runs.
          return _Round(acted, turns,
              pending: PendingConfirmation(
                  groupId: groupId,
                  call: call,
                  preview: preview,
                  utteranceId: utteranceId));
        case Decision.propose:
          // Never for something the user said (the policy's invariant);
          // proposals come from scanners, through the repository.
          throw StateError('propose for a said action');
        case Decision.execute:
        case Decision.executeWithUndo:
          final done = await _execute(call, e, preview,
              groupId: groupId, utteranceId: utteranceId, decision: decision);
          acted.add(done);
          switch (done.status) {
            case CallStatus.done:
              reply(c, done.result);
            case CallStatus.rejected:
              reply(c, {'error': done.invalid!.reason.name}, error: true);
            default:
              reply(c, {'error': 'failed'}, error: true);
          }
      }
    }
    return _Round(acted, turns);
  }

  Future<ActedCall> _execute(
      PreparedCall call, ToolEnv e, ActionPreview preview,
      {required String groupId,
      required int? utteranceId,
      required Decision decision}) async {
    final result = await executor.execute(call,
        groupId: groupId,
        origin: ActionOrigin.said,
        decision: decision,
        utteranceId: utteranceId);
    return switch (result) {
      Executed(:final outcome, :final entryId) => ActedCall(
          toolName: call.toolName,
          status: CallStatus.done,
          preview: preview,
          entryId: entryId,
          result: outcome.result),
      Rejected(:final invalid) => ActedCall(
          toolName: call.toolName,
          status: CallStatus.rejected,
          preview: preview,
          invalid: invalid),
      Failed() => ActedCall(
          toolName: call.toolName, status: CallStatus.failed, preview: preview),
    };
  }

  Future<ActionPreview?> _safePreview(PreparedCall call, ToolEnv e) async {
    if (await call.validate(e) is Invalid) return null;
    return call.preview(e);
  }
}

final class _Call {
  _Call.local(PreparedCall call)
      : prepared = Prepared(call),
        modelCall = null;
  _Call.model(AIToolCall this.modelCall, this.prepared);

  final PrepareResult prepared;

  /// The model's call, when it came from the model (its id goes back in
  /// the result turn).
  final AIToolCall? modelCall;
}

final class _Round {
  const _Round(this.acted, this.resultTurns, {this.pending});
  final List<ActedCall> acted;
  final List<AIToolResultTurn> resultTurns;
  final PendingConfirmation? pending;
}
