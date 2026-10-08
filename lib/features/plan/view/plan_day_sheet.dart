import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/async/run_action.dart';
import '../../../design/atomic.dart';
import '../../../domain/assistant/day_planner.dart';
import '../../../l10n/l10n.dart';
import '../../../shared_widgets/error_view.dart';
import '../viewmodel/plan_day_view_model.dart';

/// PLAN MY DAY (docs/05 §12.3): the plan as a preview, then one APPLY.
Future<void> showPlanDaySheet(BuildContext context) => showAtomicSheet<void>(
      context: context,
      label: context.l10n.planMyDay,
      builder: (_) => const PlanDaySheet(),
    );

class PlanDaySheet extends ConsumerStatefulWidget {
  const PlanDaySheet({super.key});

  @override
  ConsumerState<PlanDaySheet> createState() => _PlanDaySheetState();
}

class _PlanDaySheetState extends ConsumerState<PlanDaySheet> {
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final async = ref.watch(dayPlanPreviewProvider);
    return async.when(
      loading: () => AtomicLoading(label: l10n.loadingPlan),
      error: (e, _) => ErrorView(
          error: e,
          compact: true,
          onRetry: () => ref.invalidate(dayPlanPreviewProvider)),
      data: (plan) {
        if (plan.isEmpty) return AtomicText.body(l10n.planNothing);
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AtomicText.body(l10n.planIntro, style: AtomicType.bodySmall),
            const SizedBox(height: AtomicSpace.s),
            for (final p in plan)
              Padding(
                padding: const EdgeInsets.only(bottom: AtomicSpace.xs),
                child: AtomicCard(
                  kind: AtomicCardKind.panel,
                  padding: const EdgeInsets.all(AtomicSpace.s),
                  child: Row(
                    children: [
                      AtomicText.mono(
                          '${l10n.time(p.start)}–'
                          '${l10n.time(p.start.add(Duration(minutes: p.minutes)))}',
                          style: AtomicType.caption),
                      const SizedBox(width: AtomicSpace.s),
                      Expanded(
                          child: AtomicText.body(p.task.title, maxLines: 2)),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: AtomicSpace.s),
            AtomicButton(
              label: l10n.planApply,
              busy: _busy,
              busyLabel: l10n.saving,
              expand: true,
              onPressed: _busy ? null : () => _apply(plan),
            ),
          ],
        );
      },
    );
  }

  Future<void> _apply(List<PlannedTask> plan) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.maybeOf(context);
    final navigator = Navigator.of(context);
    final actions = ref.read(planDayActionsProvider.notifier);
    setState(() => _busy = true);
    final result = await runAction(context, () => actions.apply(plan));
    if (!mounted) return;
    setState(() => _busy = false);
    if (result == null) return;
    navigator.pop();
    messenger
      ?..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(l10n.planDone(result.planned)),
        action: SnackBarAction(
            label: l10n.undo, onPressed: () => actions.undo(result.groupId)),
      ));
  }
}
