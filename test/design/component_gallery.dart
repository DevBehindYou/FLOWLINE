import 'package:atomic_assist/design/atomic.dart';
import 'package:flutter/material.dart';

/// Every Atomic component in its main states, on one scrollable page.
/// Used by the component goldens and the accessibility checks. Test-only
/// strings are fine here (they never ship).
class ComponentGallery extends StatelessWidget {
  const ComponentGallery({super.key});

  @override
  Widget build(BuildContext context) {
    const gap = SizedBox(height: AtomicSpace.m);
    return Scaffold(
      appBar: AppBar(title: const Text('Components')),
      bottomNavigationBar: AtomicBottomBar(
        selectedIndex: 0,
        onSelected: (_) {},
        destinations: const [
          AtomicDestination(icon: AtomicIcons.today, label: 'Today'),
          AtomicDestination(
              icon: AtomicIcons.inbox, label: 'Inbox', badgeCount: 3),
          AtomicDestination(icon: AtomicIcons.assist, label: 'Assist'),
          AtomicDestination(icon: AtomicIcons.focus, label: 'Focus'),
          AtomicDestination(icon: AtomicIcons.library, label: 'Library'),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AtomicSpace.screenMargin),
        children: [
          const AtomicTitleRow('Today', counter: '3 / 7'),
          gap,
          const AtomicEyebrow('How it works'),
          const AtomicSplitHeadline('Tell it once.', 'AA does the rest.'),
          gap,
          AtomicButton(label: 'Add task', onPressed: () {}, expand: true),
          gap,
          Wrap(spacing: AtomicSpace.xs, runSpacing: AtomicSpace.xs, children: [
            AtomicButton(
                label: 'Save',
                variant: AtomicButtonVariant.solid,
                onPressed: () {}),
            AtomicButton(
                label: 'Cancel',
                variant: AtomicButtonVariant.ghost,
                onPressed: () {}),
            AtomicButton(
                label: 'Delete',
                variant: AtomicButtonVariant.destructive,
                onPressed: () {}),
            AtomicButton(
                label: 'Open',
                variant: AtomicButtonVariant.text,
                onPressed: () {}),
            const AtomicButton(label: 'Disabled', onPressed: null),
          ]),
          gap,
          Row(children: [
            AtomicIconButton(
                icon: AtomicIcons.back,
                semanticLabel: 'Back',
                style: AtomicIconButtonStyle.ink,
                onPressed: () {}),
            AtomicIconButton(
                icon: AtomicIcons.mic,
                semanticLabel: 'Speak',
                style: AtomicIconButtonStyle.signal,
                onPressed: () {}),
            AtomicIconButton(
                icon: AtomicIcons.delete,
                semanticLabel: 'Delete',
                style: AtomicIconButtonStyle.destructive,
                onPressed: () {}),
            AtomicIconButton(
                icon: AtomicIcons.settings,
                semanticLabel: 'Settings',
                onPressed: () {}),
          ]),
          gap,
          Wrap(spacing: AtomicSpace.xs, children: [
            AtomicChip(label: 'All', selected: true, onSelected: (_) {}),
            AtomicChip(label: 'High', selected: false, onSelected: (_) {}),
            const AtomicTag('High', tone: AtomicTagTone.solid),
            const AtomicTag('Medium', tone: AtomicTagTone.outline),
            const AtomicTag('Low'),
            const AtomicTag('Now', tone: AtomicTagTone.accent),
            const AtomicTag('Overdue', tone: AtomicTagTone.danger),
          ]),
          gap,
          const AtomicSectionLabel('Timeline', count: 2),
          gap,
          const AtomicCard(
            child: Text('A white content card.'),
          ),
          gap,
          AtomicCard(
            shadowLevel: 4,
            onTap: () {},
            child: const Text('A card with a hard shadow.'),
          ),
          gap,
          const AtomicCard(
            priorityColor: AtomicColors.error,
            child: Text('A card with a priority border.'),
          ),
          gap,
          const AtomicCard(
            kind: AtomicCardKind.selected,
            child: Text('Selected.'),
          ),
          gap,
          AtomicCard(
            kind: AtomicCardKind.dark,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AtomicEyebrow('Day load'),
                AtomicText.display('72%', style: AtomicType.hero),
                const AtomicProgressBar(
                    percent: 72, semanticValue: '72%', onInk: true),
              ],
            ),
          ),
          gap,
          const AtomicProgressBar(percent: 5, semanticValue: '5%'),
          gap,
          const AtomicProgressBar(percent: 92, semanticValue: '92%'),
          gap,
          const AtomicFactRow(label: 'Due', value: Text('2026-03-10 17:00')),
          const AtomicSettingsRow(
              title: 'Appearance', subtitle: 'System', onTap: _noop),
          gap,
          const AtomicWarningBox(
              title: 'Notifications off',
              message: 'Focus alerts can\'t reach you.'),
          gap,
          const AtomicErrorState(
              message: 'Couldn\'t load the day.',
              retryLabel: 'Retry',
              onRetry: _noop,
              compact: true),
          gap,
          const AtomicLoading(label: 'Loading the day…', compact: true),
          gap,
          AtomicDangerZone(
            label: 'Danger zone',
            warning: 'These actions run immediately.',
            children: [
              AtomicButton(
                  label: 'Delete all data',
                  variant: AtomicButtonVariant.destructive,
                  onPressed: () {}),
            ],
          ),
          gap,
          const Center(child: AtomMark()),
        ],
      ),
    );
  }
}

void _noop() {}
