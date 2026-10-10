import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/async/run_action.dart';
import '../../../design/atomic.dart';
import '../../../domain/entities/person.dart';
import '../../../domain/services/person_dates.dart';
import '../../../l10n/l10n.dart';
import '../viewmodel/people_view_model.dart';

/// One person: their dates (soonest first, with how far away) and open
/// follow-ups, each with "Replied".
class PersonScreen extends ConsumerWidget {
  const PersonScreen({super.key, required this.personId});

  final int personId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final person = ref.watch(personProvider(personId)).value;
    final dates = ref.watch(personDatesProvider(personId)).value ?? const [];
    final followUps = [
      for (final f in ref.watch(personFollowUpsProvider(personId)).value ??
          const <FollowUp>[])
        if (f.status == FollowUpStatus.open) f,
    ];
    final today = clock.now();
    final sorted = [...dates]
      ..sort((a, b) => daysUntil(a, today).compareTo(daysUntil(b, today)));

    String kindName(PersonDateKind k) => switch (k) {
          PersonDateKind.birthday => l10n.dateKindBirthday,
          PersonDateKind.anniversary => l10n.dateKindAnniversary,
          PersonDateKind.other => l10n.dateKindOther,
        };

    return Scaffold(
      appBar: AppBar(title: Text(person?.name ?? l10n.peopleTitle)),
      body: ListView(
        padding: const EdgeInsets.all(AtomicSpace.s),
        children: [
          AtomicSectionLabel(l10n.personDates, count: dates.length),
          if (sorted.isEmpty) AtomicText.body(l10n.personNoDates),
          for (final d in sorted)
            Padding(
              padding: const EdgeInsets.only(bottom: AtomicSpace.xs),
              child: AtomicCard(
                kind: AtomicCardKind.panel,
                padding: const EdgeInsets.all(AtomicSpace.s),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AtomicText.mono(
                        '${kindName(d.kind)} · ${l10n.monthDay(nextOccurrence(d, today))}',
                        style: AtomicType.caption),
                    const SizedBox(height: AtomicSpace.xxs),
                    AtomicText.body([
                      daysUntil(d, today) == 0
                          ? l10n.personDateToday
                          : l10n.personDateInDays(daysUntil(d, today)),
                      if (yearsAtNext(d, today) case final age?
                          when d.kind == PersonDateKind.birthday)
                        l10n.personTurnsAge(age),
                    ].join(' · ')),
                  ],
                ),
              ),
            ),
          const SizedBox(height: AtomicSpace.s),
          AtomicSectionLabel(l10n.personFollowUps, count: followUps.length),
          if (followUps.isEmpty) AtomicText.body(l10n.personNoFollowUps),
          for (final f in followUps)
            Padding(
              padding: const EdgeInsets.only(bottom: AtomicSpace.xs),
              child: AtomicCard(
                kind: AtomicCardKind.content,
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AtomicText.mono(
                              '${l10n.dayShort(f.waitUntil)} ${l10n.time(f.waitUntil)}',
                              style: AtomicType.caption),
                          const SizedBox(height: AtomicSpace.xxs),
                          AtomicText.body(f.about),
                        ],
                      ),
                    ),
                    AtomicButton(
                      label: l10n.followUpReplied,
                      variant: AtomicButtonVariant.ghost,
                      onPressed: () => runAction(
                          context,
                          () => ref
                              .read(peopleActionsProvider.notifier)
                              .replied(f.id)),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
