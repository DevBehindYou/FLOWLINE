import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/async/run_action.dart';
import '../../../data/assistant/undo_service.dart';
import '../../../design/atomic.dart';
import '../../../domain/assistant/ledger.dart';
import '../../../l10n/l10n.dart';
import '../viewmodel/assistant_view_model.dart';

/// What one assistant turn did, under its reply (docs/05 §29.10): a card
/// per action with its words and status, and one UNDO for the whole turn.
/// Live: an undo elsewhere (Activity) shows here at once.
class TurnActions extends ConsumerStatefulWidget {
  const TurnActions(
      {super.key, required this.groupId, this.replyIsEmpty = false});

  final String groupId;

  /// The reply has no text: say so when nothing was done either.
  final bool replyIsEmpty;

  @override
  ConsumerState<TurnActions> createState() => _TurnActionsState();
}

class _TurnActionsState extends ConsumerState<TurnActions> {
  bool _undoing = false;

  Future<void> _undo() async {
    if (_undoing) return;
    setState(() => _undoing = true);
    final messenger = ScaffoldMessenger.maybeOf(context);
    final l10n = context.l10n;
    final result = await runAction(
      context,
      () => ref
          .read(assistantViewModelProvider.notifier)
          .undoTurn(widget.groupId),
    );
    if (mounted) setState(() => _undoing = false);
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
    final p = context.atomic.palette;
    final entries = ref.watch(turnActionsProvider(widget.groupId)).value ??
        const <LedgerEntry>[];
    final shown = [
      for (final e in entries)
        if (e.preview != null) e,
    ];
    if (shown.isEmpty) {
      return widget.replyIsEmpty
          ? Padding(
              padding: const EdgeInsets.symmetric(vertical: AtomicSpace.xxs),
              child: AtomicText.body(l10n.turnNothingDone,
                  style: AtomicType.bodySmall.copyWith(color: p.textMuted)),
            )
          : const SizedBox.shrink();
    }
    final canUndo = shown.any((e) => e.canUndo);

    return Padding(
      padding: const EdgeInsets.only(bottom: AtomicSpace.xs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final e in shown)
            Padding(
              padding: const EdgeInsets.only(top: AtomicSpace.xxs),
              child: AtomicCard(
                kind: AtomicCardKind.panel,
                padding: const EdgeInsets.all(AtomicSpace.s),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AtomicText.mono(l10n.actionLabel(e.preview!),
                              style: AtomicType.caption),
                          const SizedBox(height: AtomicSpace.xxs),
                          AtomicText.body(l10n.actionDetail(e.preview!),
                              maxLines: 3),
                        ],
                      ),
                    ),
                    if (e.status != LedgerStatus.done)
                      AtomicText.mono(
                        e.status == LedgerStatus.undone
                            ? l10n.actionUndone
                            : l10n.actionFailed,
                        style: AtomicType.caption,
                      ),
                  ],
                ),
              ),
            ),
          if (canUndo)
            Align(
              alignment: Alignment.centerLeft,
              child: AtomicButton(
                label: l10n.undo,
                variant: AtomicButtonVariant.text,
                busy: _undoing,
                onPressed: _undoing ? null : _undo,
              ),
            ),
        ],
      ),
    );
  }
}
