import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../assistant/proposal_service.dart';
import '../../../core/async/run_action.dart';
import '../../../design/atomic.dart';
import '../../../domain/assistant/autonomy.dart';
import '../../../domain/assistant/proposal.dart';
import '../../../l10n/l10n.dart';
import '../viewmodel/inbox_view_model.dart';

/// A suggestion waiting for one tap (docs/05 §11): why, what exactly it
/// would do (the tool's own preview, against the state now), and what
/// the user said when it came from their words. ACCEPT re-checks first;
/// a destructive one asks once more, stating what goes.
class ProposalCard extends ConsumerStatefulWidget {
  const ProposalCard({super.key, required this.proposal});

  final Proposal proposal;

  @override
  ConsumerState<ProposalCard> createState() => _ProposalCardState();
}

class _ProposalCardState extends ConsumerState<ProposalCard> {
  bool _busy = false;

  Future<void> _accept(ActionRisk risk, String confirmMessage) async {
    final l10n = context.l10n;
    if (risk == ActionRisk.destructive) {
      final yes = await showAtomicConfirm(
        context: context,
        label: l10n.confirmSheetLabel,
        title: l10n.confirmActionTitle,
        message: confirmMessage,
        confirmLabel: l10n.confirmDo,
        cancelLabel: l10n.cancel,
      );
      if (!yes || !mounted) return;
    }
    setState(() => _busy = true);
    final messenger = ScaffoldMessenger.maybeOf(context);
    final result = await runAction(
        context,
        () =>
            ref.read(inboxActionsProvider.notifier).accept(widget.proposal.id));
    if (mounted) setState(() => _busy = false);
    if (result == AcceptResult.noLongerPossible) {
      messenger?.showSnackBar(
          SnackBar(content: Text(l10n.proposalNoLongerPossible)));
    }
  }

  Future<void> _dismiss() async {
    setState(() => _busy = true);
    await runAction(
        context,
        () => ref
            .read(inboxActionsProvider.notifier)
            .dismiss(widget.proposal.id));
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final p = widget.proposal;
    final what = ref.watch(proposalPreviewProvider(p)).value;
    final source = p.sourceText;

    return AtomicCard(
      kind: AtomicCardKind.content,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AtomicText.mono(l10n.proposalReasonName(p.reason),
              style: AtomicType.caption),
          const SizedBox(height: AtomicSpace.xs),
          if (what != null) ...[
            AtomicText.mono(l10n.actionLabel(what.preview),
                style: AtomicType.label),
            const SizedBox(height: AtomicSpace.xxs),
            AtomicText.body(l10n.actionDetail(what.preview)),
          ] else
            AtomicText.body(l10n.proposalNoLongerPossible),
          if (source != null) ...[
            const SizedBox(height: AtomicSpace.xs),
            AtomicText.body(l10n.proposalYouSaid(source),
                style: AtomicType.bodySmall, maxLines: 3),
          ],
          const SizedBox(height: AtomicSpace.s),
          Wrap(
            spacing: AtomicSpace.xs,
            runSpacing: AtomicSpace.xs,
            children: [
              if (what != null)
                AtomicButton(
                  label: l10n.proposalAccept,
                  busy: _busy,
                  onPressed: _busy
                      ? null
                      : () =>
                          _accept(what.risk, l10n.confirmMessage(what.preview)),
                ),
              AtomicButton(
                label: l10n.proposalDismiss,
                variant: AtomicButtonVariant.ghost,
                onPressed: _busy ? null : _dismiss,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
