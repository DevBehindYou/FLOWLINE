import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../design/atomic.dart';
import '../../../l10n/l10n.dart';
import '../../../shared_widgets/empty_state.dart';
import '../../../shared_widgets/error_view.dart';
import '../viewmodel/lists_view_model.dart';

/// Lists with their open / total counts (docs/05 §17, §29.17).
class ListsScreen extends ConsumerWidget {
  const ListsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final async = ref.watch(checklistsProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.listsTitle)),
      body: async.when(
        loading: () => AtomicLoading(label: l10n.loadingLists),
        error: (error, _) => ErrorView(
            error: error, onRetry: () => ref.invalidate(checklistsProvider)),
        data: (lists) => lists.isEmpty
            ? EmptyState(
                icon: AtomicIcons.task,
                title: l10n.listsEmptyTitle,
                message: l10n.listsEmptyMessage,
              )
            : ListView(
                children: [
                  for (final l in lists)
                    AtomicSettingsRow(
                      key: ValueKey(l.id),
                      leading: AtomicIcons.task,
                      title: l.name,
                      subtitle: l10n.listCounter(l.openCount, l.totalCount),
                      onTap: () => context.push('/library/lists/${l.id}'),
                    ),
                ],
              ),
      ),
    );
  }
}
