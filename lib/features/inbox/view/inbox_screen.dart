import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../design/atomic.dart';
import '../../../l10n/l10n.dart';
import '../../../shared_widgets/empty_state.dart';
import '../../../shared_widgets/error_view.dart';
import '../../../shared_widgets/settings_action.dart';
import '../viewmodel/inbox_view_model.dart';
import '../widgets/activity_row.dart';
import '../widgets/proposal_card.dart';

/// The secretary's desk (docs/05 §11, §29.8): suggestions waiting for a
/// tap, and what AA did today, with undo. Empty sections are hidden.
class InboxScreen extends ConsumerWidget {
  const InboxScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final proposalsAsync = ref.watch(openProposalsProvider);
    final doneAsync = ref.watch(todaysActionsProvider);

    Widget body() {
      if (proposalsAsync.isLoading || doneAsync.isLoading) {
        return AtomicLoading(label: l10n.loadingInbox);
      }
      final error = proposalsAsync.error ?? doneAsync.error;
      if (error != null) {
        return ErrorView(
          error: error,
          onRetry: () => ref
            ..invalidate(openProposalsProvider)
            ..invalidate(todaysActionsProvider),
        );
      }
      final proposals = proposalsAsync.value ?? const [];
      final done = doneAsync.value ?? const [];
      return ListView(
        padding: const EdgeInsets.all(AtomicSpace.s),
        children: [
          if (proposals.isEmpty && done.isEmpty)
            EmptyState(
              icon: AtomicIcons.inbox,
              title: l10n.inboxEmptyTitle,
              message: l10n.inboxEmptyMessage,
            ),
          if (proposals.isNotEmpty) ...[
            AtomicSectionLabel(l10n.inboxSuggested, count: proposals.length),
            for (final p in proposals)
              Padding(
                padding: const EdgeInsets.only(bottom: AtomicSpace.xs),
                child: ProposalCard(key: ValueKey(p.id), proposal: p),
              ),
          ],
          if (done.isNotEmpty) ...[
            AtomicSectionLabel(l10n.inboxDoneToday, count: done.length),
            for (final e in done)
              Padding(
                padding: const EdgeInsets.only(bottom: AtomicSpace.xs),
                child: ActivityRow(key: ValueKey(e.id), entry: e),
              ),
          ],
          Align(
            alignment: Alignment.centerLeft,
            child: AtomicButton(
              label: l10n.inboxAllActivity,
              variant: AtomicButtonVariant.text,
              icon: AtomicIcons.forward,
              onPressed: () => context.push('/inbox/activity'),
            ),
          ),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.inboxTitle),
        actions: const [SettingsAction()],
      ),
      body: body(),
    );
  }
}
