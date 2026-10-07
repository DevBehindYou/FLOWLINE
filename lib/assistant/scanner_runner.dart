import 'dart:convert';

import '../data/assistant/tool_executor.dart';
import '../domain/assistant/autonomy.dart';
import '../domain/assistant/proposal.dart';
import '../domain/assistant/quick_parse.dart' show isoLocal;
import '../domain/assistant/scanners.dart';
import '../domain/entities/person.dart';
import '../domain/repositories/app_settings_repository.dart';
import '../domain/repositories/assistant_repository.dart';
import '../domain/repositories/people_repository.dart';
import '../domain/repositories/schedule_repository.dart';
import '../domain/repositories/task_repository.dart';
import '../domain/time/calendar_day.dart';
import '../l10n/l10n.dart';
import 'tools/tool_registry.dart';

/// Runs the context scanners (docs/05 §5.2) and turns what they find into
/// Inbox proposals for real tools (§9.5). Nothing runs until the user
/// taps ACCEPT, which re-validates the call against the state then.
final class ScannerRunner {
  ScannerRunner({
    required this.tasks,
    required this.schedule,
    required this.people,
    required this.store,
    required this.settings,
    required this.l10n,
    required this.registry,
    required this.executor,
  });

  final TaskRepository tasks;
  final ScheduleRepository schedule;
  final PeopleRepository people;
  final AssistantRepository store;
  final AppSettingsRepository settings;
  final AppLocalizations Function() l10n;
  final ToolRegistry registry;
  final ToolExecutor executor;

  /// How many things it suggested or did (0 when the kill switch is off).
  /// What it notices is a suggestion, except under HANDS-OFF, where a
  /// reversible one runs with UNDO (the policy, `decide()`).
  Future<int> run(DateTime now) async {
    final prefs = await settings.get();
    if (!prefs.suggestions) return 0;
    await store.expireProposals(now);

    final findings = runScanners(await _snapshot(now));
    final known = await store.knownProposalKeys(findings.map((f) => f.key));
    var created = 0;
    for (final f in findings) {
      if (known.contains(f.key)) continue;
      final draft = _draft(f, now);
      if (draft == null) continue;
      final id = await store.createProposal(draft, at: now);
      if (id == null) continue;
      created++;
      final prepared = registry.prepare(draft.toolName, draft.argsJson);
      if (prepared is! Prepared ||
          decide(
                  risk: prepared.call.risk,
                  origin: ActionOrigin.context,
                  preset: prefs.autonomy) !=
              Decision.executeWithUndo) {
        continue;
      }
      // Done on its own: the proposal row is kept (closed) so the key is
      // known and it never happens twice; the ledger shows it with UNDO.
      final result = await executor.execute(prepared.call,
          groupId: 'scan-$id',
          origin: ActionOrigin.context,
          decision: Decision.executeWithUndo);
      if (result is Executed) {
        await store.closeProposal(id, ProposalStatus.accepted);
      }
    }
    return created;
  }

  Future<ScanSnapshot> _snapshot(DateTime now) async {
    final dates = await people.getAllDates();
    final followUps = await people.getOpenFollowUps();
    final ids = {
      for (final d in dates) d.personId,
      for (final f in followUps) f.personId,
    };
    final byId = <int, Person>{
      for (final id in ids)
        if (await people.getPerson(id) case final p?) id: p,
    };
    return ScanSnapshot(
      now: now,
      openTasks: await tasks.findTasks('', limit: 500),
      blocksToday: await schedule.getBlocksForDay(startOfDay(now)),
      people: byId,
      personDates: dates,
      openFollowUps: followUps,
    );
  }

  ProposalDraft? _draft(ScanFinding f, DateTime now) {
    final words = l10n();
    ProposalDraft draft(
            String tool, Map<String, Object?> args, ProposalReason reason,
            {DateTime? expiresAt, Map<String, Object?> why = const {}}) =>
        ProposalDraft(
          toolName: tool,
          argsJson: jsonEncode(args),
          origin: ActionOrigin.context,
          reason: reason,
          reasonJson: jsonEncode(why),
          dedupeKey: f.key,
          expiresAt: expiresAt,
        );

    switch (f) {
      case UpcomingDateFinding(:final person, :final date, :final on):
        // A reminder on the morning of the day, while that's still ahead.
        final at = DateTime(on.year, on.month, on.day, 9);
        if (!at.isAfter(now)) return null;
        final title = switch (date.kind) {
          PersonDateKind.birthday => words.scanReminderBirthday(person.name),
          PersonDateKind.anniversary =>
            words.scanReminderAnniversary(person.name),
          PersonDateKind.other => words.scanReminderDate(
              person.name, date.label ?? words.dateKindOther),
        };
        return draft('create_reminder', {'title': title, 'at': isoLocal(at)},
            ProposalReason.upcomingDate,
            expiresAt: at,
            why: {'person': person.name, 'kind': date.kind.name});
      case OverdueTaskFinding(:final task):
        // Same time tomorrow; it expires tonight, when tomorrow changes.
        final due = task.dueAt!;
        final tomorrow = addDays(now, 1);
        final next = DateTime(
            tomorrow.year, tomorrow.month, tomorrow.day, due.hour, due.minute);
        return draft('update_task', {'task_id': task.id, 'due': isoLocal(next)},
            ProposalReason.overdueDrift,
            expiresAt: addDays(now, 1));
      case FreeGapFinding(:final task, :final start, :final minutes):
        return draft(
            'schedule_task',
            {'task_id': task.id, 'start': isoLocal(start), 'minutes': minutes},
            ProposalReason.freeGapForTasks,
            expiresAt: start);
      case FollowUpDueFinding(:final followUp, :final person):
        return draft('complete_follow_up', {'follow_up_id': followUp.id},
            ProposalReason.followUpDue,
            why: {'person': person.name});
      case DayOverbookedFinding(:final move):
        final tomorrow = addDays(move.startTime, 1);
        final start = DateTime(tomorrow.year, tomorrow.month, tomorrow.day,
            move.startTime.hour, move.startTime.minute);
        final length = move.endTime.difference(move.startTime);
        return draft(
            'move_block',
            {
              'block_id': move.id,
              'start': isoLocal(start),
              'end': isoLocal(start.add(length)),
            },
            ProposalReason.dayOverbooked,
            expiresAt: move.startTime);
    }
  }
}
