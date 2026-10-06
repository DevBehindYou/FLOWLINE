import '../data/assistant/tool_executor.dart';
import '../domain/assistant/autonomy.dart';
import '../domain/assistant/proposal.dart';
import '../domain/assistant/tool.dart';
import '../domain/repositories/assistant_repository.dart';
import 'tools/tool_registry.dart';

enum AcceptResult {
  done,

  /// Things changed since it was suggested (the task is gone, the time is
  /// taken, it expired): "No longer possible." It is closed as expired.
  noLongerPossible,

  /// Already accepted, dismissed or expired (a second tap).
  alreadyClosed,

  /// The tool threw; nothing changed and the proposal stays open.
  failed,
}

/// ACCEPT and DISMISS for Inbox proposals (docs/05 §9.5, §11).
final class ProposalService {
  ProposalService({
    required this.registry,
    required this.executor,
    required this.store,
    required this.env,
  });

  final ToolRegistry registry;
  final ToolExecutor executor;
  final AssistantRepository store;
  final ToolEnv Function() env;

  final _inFlight = <int>{};

  /// Runs the proposal's call, re-validated against the state now. The
  /// tap is the user's consent, so it runs as `said`; a destructive one
  /// is recorded as confirmed (the Inbox asks before calling this).
  Future<AcceptResult> accept(int id) async {
    if (!_inFlight.add(id)) return AcceptResult.alreadyClosed;
    try {
      final p = await store.getProposal(id);
      if (p == null || p.status != ProposalStatus.open) {
        return AcceptResult.alreadyClosed;
      }
      final e = env();
      if (p.expiresAt != null && !p.expiresAt!.isAfter(e.now)) {
        await store.closeProposal(id, ProposalStatus.expired);
        return AcceptResult.noLongerPossible;
      }
      final prepared = registry.prepare(p.toolName, p.argsJson);
      if (prepared is! Prepared) {
        await store.closeProposal(id, ProposalStatus.expired);
        return AcceptResult.noLongerPossible;
      }
      final call = prepared.call;
      final preview =
          await call.validate(e) is Valid ? await call.preview(e) : null;
      final result = await executor.execute(
        call,
        groupId: 'proposal-$id',
        origin: ActionOrigin.said,
        decision: call.risk == ActionRisk.destructive
            ? Decision.confirm
            : decide(
                risk: call.risk,
                origin: ActionOrigin.said,
                preset: AutonomyPreset.balanced),
        preview: preview,
      );
      switch (result) {
        case Executed():
          await store.closeProposal(id, ProposalStatus.accepted);
          return AcceptResult.done;
        case Rejected():
          await store.closeProposal(id, ProposalStatus.expired);
          return AcceptResult.noLongerPossible;
        case Failed():
          return AcceptResult.failed;
      }
    } finally {
      _inFlight.remove(id);
    }
  }

  Future<bool> dismiss(int id) =>
      store.closeProposal(id, ProposalStatus.dismissed);
}
