import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/async/run_action.dart';
import '../../../data/assistant/undo_service.dart';
import '../../../design/atomic.dart';
import '../../../domain/assistant/ledger.dart';
import '../../../l10n/l10n.dart';
import '../viewmodel/inbox_view_model.dart';

/// One thing AA did (docs/05 §29.9): what, when and why, and UNDO while
/// it can be undone. UNDO reverses the whole turn it belonged to.
class ActivityRow extends ConsumerStatefulWidget {
  const ActivityRow({super.key, required this.entry});

  final LedgerEntry entry;

  @override
  ConsumerState<ActivityRow> createState() => _ActivityRowState();
}

class _ActivityRowState extends ConsumerState<ActivityRow> {
  bool _busy = false;

  Future<void> _undo() async {
    setState(() => _busy = true);
    final messenger = ScaffoldMessenger.maybeOf(context);
    final l10n = context.l10n;
    final result = await runAction(
        context,
        () => ref
            .read(inboxActionsProvider.notifier)
            .undoTurn(widget.entry.groupId));
    if (mounted) setState(() => _busy = false);
    final message = switch (result) {
      UndoResult.changedSince => l10n.actionChangedSince,
      UndoResult.nothing => l10n.actionNothingToUndo,
      UndoResult.undone || null => null,
    };
    if (message != null) {
      messenger?.showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final e = widget.entry;
    final preview = e.preview;
    final status = switch (e.status) {
      LedgerStatus.undone => l10n.actionUndone,
      LedgerStatus.failed => l10n.actionFailed,
      LedgerStatus.done || LedgerStatus.handedOff => null,
    };

    return AtomicCard(
      kind: AtomicCardKind.panel,
      padding: const EdgeInsets.all(AtomicSpace.s),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AtomicText.mono(
                    preview == null ? e.toolName : l10n.actionLabel(preview),
                    style: AtomicType.caption),
                if (preview != null) ...[
                  const SizedBox(height: AtomicSpace.xxs),
                  AtomicText.body(l10n.actionDetail(preview), maxLines: 3),
                ],
                const SizedBox(height: AtomicSpace.xxs),
                AtomicText.mono(
                    l10n.actionTimeOrigin(
                        l10n.time(e.at), l10n.originName(e.origin)),
                    style: AtomicType.caption),
              ],
            ),
          ),
          if (status != null)
            AtomicText.mono(status, style: AtomicType.caption)
          else if (e.canUndo)
            AtomicButton(
              label: l10n.undo,
              variant: AtomicButtonVariant.text,
              busy: _busy,
              onPressed: _busy ? null : _undo,
            ),
        ],
      ),
    );
  }
}
