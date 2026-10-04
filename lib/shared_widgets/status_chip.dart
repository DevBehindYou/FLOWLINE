import 'package:flutter/widgets.dart';

import '../design/atomic.dart';
import '../domain/entities/task.dart';
import '../l10n/l10n.dart';

/// Status as words (docs/05 DS-5): in progress is the one accented state.
class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.status});

  final TaskStatus status;

  @override
  Widget build(BuildContext context) => AtomicTag(
        context.l10n.statusName(status),
        tone: switch (status) {
          TaskStatus.todo => AtomicTagTone.quiet,
          TaskStatus.inProgress => AtomicTagTone.accent,
          TaskStatus.done => AtomicTagTone.outline,
        },
      );
}
