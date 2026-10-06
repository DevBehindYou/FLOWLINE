import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../design/atomic.dart';
import '../../../l10n/l10n.dart';
import '../../../shared_widgets/settings_action.dart';

/// The Library hub (docs/05 §28, §29.15): the things AA keeps for you.
/// Review (was Insights) for now; People, Lists, Money, Trips, Documents
/// and What AA knows join it in later phases.
class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.libraryTitle),
        actions: const [SettingsAction()],
      ),
      body: ListView(
        children: [
          AtomicSettingsRow(
            leading: AtomicIcons.review,
            title: l10n.libraryReview,
            subtitle: l10n.libraryReviewHint,
            onTap: () => context.push('/library/review'),
          ),
        ],
      ),
    );
  }
}
