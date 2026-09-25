import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../domain/entities/task.dart';

class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.status});

  final TaskStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      TaskStatus.todo => ('Todo', FlowlineSemanticColors.statusTodo),
      TaskStatus.inProgress => (
          'In Progress',
          FlowlineSemanticColors.statusInProgress
        ),
      TaskStatus.done => ('Done', FlowlineSemanticColors.statusDone),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
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
