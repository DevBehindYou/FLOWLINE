import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/async/run_action.dart';
import '../../../data/assistant/tool_executor.dart';
import '../../../design/atomic.dart';
import '../../../domain/entities/checklist.dart';
import '../../../l10n/l10n.dart';
import '../../../shared_widgets/error_view.dart';
import '../viewmodel/lists_view_model.dart';

/// One list: tick items, add one, clear the ticked ones (confirmed).
/// Every change is a tool call, so it shows in Activity with undo.
class ListDetailScreen extends ConsumerStatefulWidget {
  const ListDetailScreen({super.key, required this.listId});

  final int listId;

  @override
  ConsumerState<ListDetailScreen> createState() => _ListDetailScreenState();
}

class _ListDetailScreenState extends ConsumerState<ListDetailScreen> {
  final _controller = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Checklist? get _list => ref
      .read(checklistsProvider)
      .value
      ?.where((l) => l.id == widget.listId)
      .firstOrNull;

  Future<void> _guard(Future<ExecutionResult> Function() action) async {
    if (_busy) return;
    setState(() => _busy = true);
    await runAction(context, action);
    if (mounted) setState(() => _busy = false);
  }

  Future<void> _add() async {
    final text = _controller.text.trim();
    final list = _list;
    if (text.isEmpty || list == null) return;
    _controller.clear();
    await _guard(
        () => ref.read(listsActionsProvider.notifier).add(list.name, text));
  }

  Future<void> _clear(Checklist list, int ticked) async {
    final l10n = context.l10n;
    final yes = await showAtomicConfirm(
      context: context,
      label: l10n.confirmSheetLabel,
      title: l10n.confirmActionTitle,
      message: l10n.confirmClearCheckedMessage(ticked, list.name),
      confirmLabel: l10n.listClearChecked,
      cancelLabel: l10n.cancel,
    );
    if (!yes || !mounted) return;
    await _guard(
        () => ref.read(listsActionsProvider.notifier).clearChecked(list.name));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final list = ref
        .watch(checklistsProvider)
        .value
        ?.where((l) => l.id == widget.listId)
        .firstOrNull;
    final itemsAsync = ref.watch(checklistItemsProvider(widget.listId));
    final items = itemsAsync.value ?? const <ChecklistItem>[];
    final ticked = items.where((i) => i.checked).length;

    return Scaffold(
      appBar: AppBar(
        title: Text(list?.name ?? l10n.listsTitle),
        actions: [
          if (list != null && ticked > 0)
            AtomicIconButton(
              icon: AtomicIcons.delete,
              semanticLabel: l10n.listClearChecked,
              onPressed: _busy ? null : () => _clear(list, ticked),
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: itemsAsync.when(
              loading: () => AtomicLoading(label: l10n.loadingLists),
              error: (error, _) => ErrorView(
                  error: error,
                  onRetry: () =>
                      ref.invalidate(checklistItemsProvider(widget.listId))),
              data: (items) => items.isEmpty
                  ? Center(child: AtomicText.body(l10n.listEmptyMessage))
                  : ListView(
                      children: [
                        for (final i in items)
                          CheckboxListTile(
                            key: ValueKey(i.id),
                            value: i.checked,
                            controlAffinity: ListTileControlAffinity.leading,
                            title: Text(i.text,
                                style: i.checked
                                    ? const TextStyle(
                                        decoration: TextDecoration.lineThrough)
                                    : null),
                            onChanged: _busy
                                ? null
                                : (v) => _guard(() => ref
                                    .read(listsActionsProvider.notifier)
                                    .setChecked(i.id, v ?? false)),
                          ),
                      ],
                    ),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(AtomicSpace.s),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(hintText: l10n.listAddHint),
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _add(),
                    ),
                  ),
                  const SizedBox(width: AtomicSpace.xs),
                  AtomicIconButton(
                    icon: AtomicIcons.add,
                    semanticLabel: l10n.listAdd,
                    style: AtomicIconButtonStyle.signal,
                    onPressed: _busy ? null : _add,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
