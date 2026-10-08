import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/async/run_action.dart';
import '../../../design/atomic.dart';
import '../../../domain/assistant/briefing.dart';
import '../../../domain/assistant/quick_parse.dart' show isoDate;
import '../../../l10n/l10n.dart';
import '../../../shared_widgets/error_view.dart';
import '../viewmodel/briefing_view_model.dart';
import 'briefing_text.dart';

/// A morning or end-of-day briefing (docs/05 §21, §29.12): the day in one
/// screen, one primary action, and READ ALOUD.
class BriefingScreen extends ConsumerWidget {
  const BriefingScreen({super.key, required this.kind});

  final BriefingKind kind;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final async = ref.watch(briefingProvider(kind));
    return Scaffold(
      appBar: AppBar(title: Text(l10n.briefingKindName(kind))),
      body: async.when(
        loading: () => AtomicLoading(label: l10n.loadingBriefing),
        error: (e, _) => ErrorView(
            error: e, onRetry: () => ref.invalidate(briefingProvider(kind))),
        data: (b) => _Body(briefing: b),
      ),
    );
  }
}

class _Body extends ConsumerStatefulWidget {
  const _Body({required this.briefing});
  final Briefing briefing;

  @override
  ConsumerState<_Body> createState() => _BodyState();
}

class _BodyState extends ConsumerState<_Body> {
  bool _busy = false;

  Future<void> _moveUnfinished(UnfinishedSection s) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.maybeOf(context);
    final actions = ref.read(briefingActionsProvider.notifier);
    setState(() => _busy = true);
    final result =
        await runAction(context, () => actions.moveToTomorrow(s.tasks));
    if (mounted) setState(() => _busy = false);
    if (result == null || result.moved == 0) return;
    messenger
      ?..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(l10n.briefingMoved(result.moved)),
        action: SnackBarAction(
            label: l10n.undo, onPressed: () => actions.undo(result.groupId)),
      ));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final b = widget.briefing;
    final headline = l10n.briefingHeadline(b);
    final unfinished = b.sections.whereType<UnfinishedSection>().firstOrNull;
    const gap = SizedBox(height: AtomicSpace.m);

    final primary = switch (b.kind) {
      BriefingKind.morning || BriefingKind.checkIn => AtomicButton(
          label: l10n.briefingOpenInbox,
          expand: true,
          onPressed: () => context.go('/inbox'),
        ),
      BriefingKind.shutdown || BriefingKind.weekly => unfinished == null
          ? null
          : AtomicButton(
              label: l10n.briefingMoveUnfinished,
              busy: _busy,
              busyLabel: l10n.saving,
              expand: true,
              onPressed: _busy ? null : () => _moveUnfinished(unfinished),
            ),
    };

    return ListView(
      padding: const EdgeInsets.all(AtomicSpace.screenMargin),
      children: [
        AtomicEyebrow(l10n.briefingEyebrow(
            l10n.briefingKindName(b.kind), isoDate(b.day))),
        const SizedBox(height: AtomicSpace.xs),
        Semantics(
          header: true,
          child: AtomicSplitHeadline(headline.first, headline.second),
        ),
        gap,
        for (final block in l10n.briefingBlocks(b)) ...[
          AtomicCard(
            kind: AtomicCardKind.panel,
            padding: const EdgeInsets.all(AtomicSpace.s),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AtomicText.mono(block.label, style: AtomicType.caption),
                const SizedBox(height: AtomicSpace.xxs),
                for (final line in block.lines)
                  Padding(
                    padding: const EdgeInsets.only(top: AtomicSpace.xxs),
                    child: AtomicText.body(line),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AtomicSpace.xs),
        ],
        gap,
        AtomicButton(
          label: l10n.briefingReadAloud,
          icon: AtomicIcons.mic,
          variant: AtomicButtonVariant.ghost,
          expand: true,
          onPressed: () => unawaited(ref
              .read(briefingActionsProvider.notifier)
              .readAloud(l10n.briefingScript(b))),
        ),
        if (primary != null) ...[
          const SizedBox(height: AtomicSpace.xs),
          primary,
        ],
      ],
    );
  }
}
