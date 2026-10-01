import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../domain/entities/task.dart';
import '../l10n/l10n.dart';

class PriorityChip extends StatelessWidget {
  const PriorityChip({super.key, required this.priority});

  final TaskPriority priority;

  @override
  Widget build(BuildContext context) {
    final label = context.l10n.priorityName(priority);
    final color = switch (priority) {
      TaskPriority.low => FlowlineSemanticColors.priorityLow,
      TaskPriority.medium => FlowlineSemanticColors.priorityMedium,
      TaskPriority.high => FlowlineSemanticColors.priorityHigh,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
