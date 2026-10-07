import '../../../domain/assistant/briefing.dart';
import '../../../domain/entities/person.dart';
import '../../../domain/services/person_dates.dart';
import '../../../domain/time/calendar_day.dart';
import '../../../l10n/l10n.dart';

typedef BriefingBlock = ({String label, List<String> lines});

/// The words of a briefing (docs/05 §21): the screen shows them, READ
/// ALOUD speaks them, so the two never disagree.
extension BriefingWords on AppLocalizations {
  String briefingKindName(BriefingKind k) => switch (k) {
        BriefingKind.morning => briefingMorning,
        BriefingKind.checkIn => briefingCheckIn,
        BriefingKind.shutdown => briefingShutdown,
        BriefingKind.weekly => briefingWeekly,
      };

  /// The split headline: the fact, then the accent beat.
  ({String first, String second}) briefingHeadline(Briefing b) {
    T? find<T>() => b.sections.whereType<T>().firstOrNull;
    switch (b.kind) {
      case BriefingKind.morning || BriefingKind.checkIn:
        final load = find<LoadSection>();
        final top = find<TopTasksSection>()?.tasks.firstOrNull;
        return (
          first: briefingMorningHeadline(load?.blocks ?? 0),
          second:
              top == null ? briefingNothingDue : briefingStartWith(top.title),
        );
      case BriefingKind.shutdown || BriefingKind.weekly:
        final done = find<DoneSection>();
        final first = find<TomorrowSection>()?.first;
        return (
          first: briefingShutdownHeadline(done?.focusMinutes ?? 0),
          second: first == null
              ? briefingTomorrowClear
              : briefingTomorrowStarts(time(first.startTime)),
        );
    }
  }

  List<BriefingBlock> briefingBlocks(Briefing b) {
    String kindName(PersonDateKind k) => switch (k) {
          PersonDateKind.birthday => dateKindBirthday,
          PersonDateKind.anniversary => dateKindAnniversary,
          PersonDateKind.other => dateKindOther,
        };
    String due(DateTime d) => '${dayShort(d)} ${time(d)}';
    return [
      for (final s in b.sections)
        switch (s) {
          LoadSection(:final blocks, :final busyMinutes, :final first) => (
              label: briefingFirstUp,
              lines: [
                briefingBlocksLine(blocks, busyMinutes),
                if (first != null)
                  '${time(first.startTime)}–${time(first.endTime)} · '
                      '${first.title}',
              ],
            ),
          TopTasksSection(:final tasks) => (
              label: briefingTopTasks,
              lines: [
                for (final t in tasks)
                  t.dueAt == null ? t.title : '${t.title} · ${due(t.dueAt!)}',
              ],
            ),
          DatesSection(:final dates) => (
              label: briefingComingUp,
              lines: [
                for (final d in dates)
                  '${d.person.name} · ${kindName(d.date.kind)} · '
                      '${_when(d.date, b.day)}',
              ],
            ),
          ProposalsSection(:final count) => (
              label: briefingSuggestions,
              lines: [briefingSuggestionsLine(count)]
            ),
          DoneSection(:final sessions, :final focusMinutes) => (
              label: briefingDoneToday,
              lines: [briefingDoneLine(sessions, focusMinutes)],
            ),
          ActionsByAaSection(:final count) => (
              label: briefingDoneByAa,
              lines: [briefingByAaLine(count)]
            ),
          UnfinishedSection(:final tasks) => (
              label: briefingUnfinished,
              lines: [for (final t in tasks) '${t.title} · ${due(t.dueAt!)}'],
            ),
          FollowUpsSection(:final followUps) => (
              label: briefingWaitingOn,
              lines: [
                for (final f in followUps)
                  '${f.person.name} · ${f.followUp.about}',
              ],
            ),
          TomorrowSection(:final first) => (
              label: briefingTomorrow,
              lines: [
                first == null
                    ? briefingNothingYet
                    : '${time(first.startTime)} · ${first.title}',
              ],
            ),
        },
    ];
  }

  /// What READ ALOUD says.
  String briefingScript(Briefing b) {
    final h = briefingHeadline(b);
    return [
      h.first,
      h.second,
      for (final block in briefingBlocks(b)) ...[
        '${block.label}.',
        for (final line in block.lines) '$line.',
      ],
    ].join(' ');
  }

  String _when(PersonDate d, DateTime today) {
    final n = daysUntil(d, startOfDay(today));
    return n == 0 ? personDateToday : personDateInDays(n);
  }
}
