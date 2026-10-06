import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../design/atomic.dart';
import '../../../l10n/l10n.dart';
import '../../../shared_widgets/empty_state.dart';
import '../../../shared_widgets/error_view.dart';
import '../viewmodel/people_view_model.dart';

/// The people AA knows about (docs/05 §15, §29.16).
class PeopleScreen extends ConsumerWidget {
  const PeopleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final async = ref.watch(peopleProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.peopleTitle)),
      body: async.when(
        loading: () => AtomicLoading(label: l10n.loadingPeople),
        error: (error, _) => ErrorView(
            error: error, onRetry: () => ref.invalidate(peopleProvider)),
        data: (people) => people.isEmpty
            ? EmptyState(
                icon: AtomicIcons.event,
                title: l10n.peopleEmptyTitle,
                message: l10n.peopleEmptyMessage,
              )
            : ListView(
                children: [
                  for (final p in people)
                    AtomicSettingsRow(
                      key: ValueKey(p.id),
                      leading: AtomicIcons.event,
                      title: p.name,
                      subtitle: p.relation,
                      onTap: () => context.push('/library/people/${p.id}'),
                    ),
                ],
              ),
      ),
    );
  }
}
