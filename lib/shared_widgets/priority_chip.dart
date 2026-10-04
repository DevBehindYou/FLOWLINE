import 'package:flutter/widgets.dart';

import '../design/atomic.dart';
import '../domain/entities/task.dart';
import '../l10n/l10n.dart';

/// Priority as words with weight, not colour (docs/05 DS-4).
class PriorityChip extends StatelessWidget {
  const PriorityChip({super.key, required this.priority});

  final TaskPriority priority;

  @override
  Widget build(BuildContext context) => AtomicTag(
        context.l10n.priorityName(priority),
        tone: switch (priority) {
          TaskPriority.low => AtomicTagTone.quiet,
          TaskPriority.medium => AtomicTagTone.outline,
          TaskPriority.high => AtomicTagTone.solid,
        },
      );
}
