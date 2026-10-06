import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../design/atomic.dart';
import '../../../domain/assistant/ledger.dart';
import '../../../domain/time/calendar_day.dart';
import '../../../l10n/l10n.dart';
import '../../../shared_widgets/empty_state.dart';
import '../../../shared_widgets/error_view.dart';
import '../viewmodel/inbox_view_model.dart';
import '../widgets/activity_row.dart';

/// Everything AA did in the last 30 days, by day, with undo (docs/05
/// §29.9). Nothing AA does is invisible.
class ActivityScreen extends ConsumerWidget {
  const ActivityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final async = ref.watch(recentActionsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.activityTitle)),
      body: async.when(
        loading: () => AtomicLoading(label: l10n.loadingActivity),
        error: (error, _) => ErrorView(
            error: error, onRetry: () => ref.invalidate(recentActionsProvider)),
        data: (entries) {
          if (entries.isEmpty) {
            return EmptyState(
              icon: AtomicIcons.inbox,
              title: l10n.activityEmptyTitle,
              message: l10n.activityEmptyMessage,
            );
          }
          // Newest first, a mono day label above each day.
          final items = <Widget>[];
          DateTime? day;
          for (final LedgerEntry e in entries) {
            final d = startOfDay(e.at);
            if (day == null || d != day) {
              day = d;
              items.add(AtomicSectionLabel(l10n.dayLong(d)));
            }
            items.add(Padding(
              padding: const EdgeInsets.only(bottom: AtomicSpace.xs),
              child: ActivityRow(key: ValueKey(e.id), entry: e),
            ));
          }
          return ListView(
            padding: const EdgeInsets.all(AtomicSpace.s),
            children: items,
          );
        },
      ),
    );
  }
}
