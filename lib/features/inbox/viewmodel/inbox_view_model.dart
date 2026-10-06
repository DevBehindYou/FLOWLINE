import 'package:clock/clock.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../assistant/assistant_providers.dart';
import '../../../assistant/proposal_service.dart';
import '../../../assistant/tools/tool_registry.dart';
import '../../../core/providers.dart';
import '../../../core/time/current_day.dart';
import '../../../data/assistant/undo_service.dart';
import '../../../domain/assistant/action_preview.dart';
import '../../../domain/assistant/autonomy.dart';
import '../../../domain/assistant/ledger.dart';
import '../../../domain/assistant/proposal.dart';
import '../../../domain/assistant/tool.dart';
import '../../../domain/time/calendar_day.dart';

part 'inbox_view_model.g.dart';

/// Open proposals, newest first (docs/05 §11 SUGGESTED).
@riverpod
Stream<List<Proposal>> openProposals(Ref ref) {
  // Re-read at midnight too, so a proposal that expired overnight goes.
  ref.watch(currentDayProvider);
  return ref.watch(assistantRepositoryProvider).watchOpenProposals(clock.now());
}

/// The Inbox tab's badge.
@riverpod
int openProposalCount(Ref ref) =>
    ref.watch(openProposalsProvider).value?.length ?? 0;

/// What a proposal would do, worded from the tool's own preview against
/// the state now; null when it no longer fits (it can't be accepted).
@riverpod
Future<({ActionPreview preview, ActionRisk risk})?> proposalPreview(
    Ref ref, Proposal proposal) async {
  final prepared = ref
      .watch(toolRegistryProvider)
      .prepare(proposal.toolName, proposal.argsJson);
  if (prepared is! Prepared) return null;
  final env = ref.read(toolEnvFactoryProvider)();
  if (await prepared.call.validate(env) is Invalid) return null;
  return (preview: await prepared.call.preview(env), risk: prepared.call.risk);
}

/// Today's ledger (DONE BY AA · TODAY).
@riverpod
Stream<List<LedgerEntry>> todaysActions(Ref ref) {
  final day = dayRange(ref.watch(currentDayProvider));
  return ref
      .watch(assistantRepositoryProvider)
      .watchLedger(from: day.start, to: day.end);
}

/// The last 30 days, for Activity, newest first.
@riverpod
Stream<List<LedgerEntry>> recentActions(Ref ref) {
  final today = ref.watch(currentDayProvider);
  return ref
      .watch(assistantRepositoryProvider)
      .watchLedger(from: addDays(today, -29), to: addDays(today, 1));
}

// keepAlive (R11): uses ref after awaits.
@Riverpod(keepAlive: true)
class InboxActions extends _$InboxActions {
  @override
  void build() {}

  Future<AcceptResult> accept(int proposalId) =>
      ref.read(proposalServiceProvider).accept(proposalId);

  Future<bool> dismiss(int proposalId) =>
      ref.read(proposalServiceProvider).dismiss(proposalId);

  Future<UndoResult> undoTurn(String groupId) =>
      ref.read(undoServiceProvider).undoGroup(groupId);
}
