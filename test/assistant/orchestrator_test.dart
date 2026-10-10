import 'dart:async';
import 'dart:convert';

import 'package:atomic_assist/assistant/orchestrator.dart';
import 'package:atomic_assist/assistant/proposal_service.dart';
import 'package:atomic_assist/assistant/tools/tool_registry.dart';
import 'package:atomic_assist/data/assistant/drift_tool_env.dart';
import 'package:atomic_assist/data/assistant/stored_rows.dart';
import 'package:atomic_assist/data/assistant/tool_executor.dart';
import 'package:atomic_assist/data/assistant/undo_service.dart';
import 'package:atomic_assist/data/local/drift/app_database.dart';
import 'package:atomic_assist/data/repositories/app_settings_repository_impl.dart';
import 'package:atomic_assist/data/repositories/assistant_repository_impl.dart';
import 'package:atomic_assist/data/repositories/focus_session_repository_impl.dart';
import 'package:atomic_assist/data/repositories/list_repository_impl.dart';
import 'package:atomic_assist/data/repositories/people_repository_impl.dart';
import 'package:atomic_assist/data/repositories/reminder_repository_impl.dart';
import 'package:atomic_assist/data/repositories/schedule_repository_impl.dart';
import 'package:atomic_assist/data/repositories/task_repository_impl.dart';
import 'package:atomic_assist/domain/ai/ai_contract.dart';
import 'package:atomic_assist/domain/assistant/action_preview.dart';
import 'package:atomic_assist/domain/assistant/autonomy.dart';
import 'package:atomic_assist/domain/assistant/proposal.dart';
import 'package:atomic_assist/domain/assistant/tool.dart';
import 'package:atomic_assist/domain/assistant/utterance.dart';
import 'package:atomic_assist/domain/entities/ai_message.dart';
import 'package:atomic_assist/domain/entities/task.dart';
import 'package:atomic_assist/domain/repositories/ai_repository.dart';
import 'package:clock/clock.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/test_database.dart';

/// The orchestrator against the real database, executor and tools, with
/// a scripted model (docs/05 §37: unknown tools, malformed args, invalid
/// targets, round and call limits, confirmation stops).
void main() {
  // Monday 2026-10-05, 16:40.
  final now = DateTime(2026, 10, 5, 16, 40);

  late AppDatabase db;
  late TaskRepositoryImpl tasks;
  late ScheduleRepositoryImpl schedule;
  late AssistantRepositoryImpl store;
  late _ScriptedAi ai;
  late ToolExecutor executor;
  late UndoService undo;
  late AutonomyPreset preset;
  late AssistantOrchestrator orchestrator;

  ToolEnv env() => DriftToolEnv(
        tasks: tasks,
        schedule: schedule,
        focus: FocusSessionRepositoryImpl(db),
        reminders: ReminderRepositoryImpl(db),
        lists: ListRepositoryImpl(db),
        people: PeopleRepositoryImpl(db),
        settings: AppSettingsRepositoryImpl(db),
        rows: StoredRows(db),
        now: clock.now(),
      );

  setUp(() {
    db = createTestDatabase();
    tasks = TaskRepositoryImpl(db);
    schedule = ScheduleRepositoryImpl(db);
    store = AssistantRepositoryImpl(db);
    ai = _ScriptedAi();
    executor = ToolExecutor(db: db, env: env);
    undo = UndoService(db: db, focus: FocusSessionRepositoryImpl(db));
    preset = AutonomyPreset.balanced;
    orchestrator = AssistantOrchestrator(
      registry: ToolRegistry(),
      ai: ai,
      executor: executor,
      store: store,
      env: env,
      autonomy: () async => preset,
      turnTimeout: const Duration(milliseconds: 200),
    );
  });
  tearDown(() => db.close());

  Future<T> at<T>(Future<T> Function() body) =>
      withClock(Clock.fixed(now), body);

  Future<TurnResult> say(String text) => at(() =>
      orchestrator.handle(Utterance(text, source: UtteranceSource.typed)));

  AIToolCall call(String name, Map<String, Object?> args, [String id = 'c']) =>
      AIToolCall(id: id, name: name, argumentsJson: jsonEncode(args));

  group('the local grammar', () {
    test('acts without the model, records the utterance and the action',
        () async {
      final r = await say('add a task send deck to Priya by Friday');
      expect(r, isA<TurnAnswered>());
      expect(ai.requests, isEmpty);
      final done = r.acted.single;
      expect(done.status, CallStatus.done);
      expect(done.preview, isA<CreateTaskPreview>());
      final task = (await tasks.findTasks('deck')).single;
      expect(task.dueAt, DateTime(2026, 10, 9, 17));
      final utterance = await db.select(db.utterances).getSingle();
      expect(utterance.body, 'add a task send deck to Priya by Friday');
      final entry = await db.select(db.assistantActions).getSingle();
      expect(entry.utteranceId, utterance.id);
      expect(entry.groupId, r.groupId);
      expect(r.changedSomething, isTrue);

      expect(await at(() => undo.undoGroup(r.groupId)), UndoResult.undone);
      expect(await tasks.findTasks('deck'), isEmpty);
    });

    test('a rejected local call goes to the model, which can resolve it',
        () async {
      await at(() async {
        await tasks.createTask(
            title: 'Report draft', priority: TaskPriority.low);
        await tasks.createTask(
            title: 'Report final', priority: TaskPriority.low);
      });
      final draft = (await tasks.findTasks('draft')).single;
      ai.script = [
        AIToolTurnReply(calls: [
          call('complete_task', {'task_id': draft.id})
        ]),
        const AIToolTurnReply(text: 'Done.'),
      ];
      final r = await say('mark report done');
      expect(r, isA<TurnAnswered>());
      expect((r as TurnAnswered).text, 'Done.');
      expect((await tasks.getTask(draft.id))!.status, TaskStatus.done);
    });

    test('offline, the local rejection is the answer', () async {
      await at(() async {
        await tasks.createTask(
            title: 'Report draft', priority: TaskPriority.low);
        await tasks.createTask(
            title: 'Report final', priority: TaskPriority.low);
      });
      ai.script = [
        const AIToolTurnFailed(AIFailure(AIFailureKind.noActiveProvider)),
      ];
      final r = await say('mark report done');
      expect(r, isA<TurnAnswered>());
      expect(r.acted.single.invalid!.reason, InvalidReason.ambiguous);
    });

    test('with no grammar match and no provider, the turn fails plainly',
        () async {
      ai.script = [
        const AIToolTurnFailed(AIFailure(AIFailureKind.noActiveProvider)),
      ];
      final r = await say('plan my week around the gym');
      expect((r as TurnFailed).failure, AIFailureKind.noActiveProvider);
    });
  });

  group('rounds with the model', () {
    test('a read, then an action, then the reply; results go back with ids',
        () async {
      ai.script = [
        AIToolTurnReply(calls: [
          call(
              'find_free_time',
              {
                'day': '2026-10-05',
                'minutes': 30,
              },
              'r1')
        ]),
        AIToolTurnReply(calls: [
          call(
              'create_block',
              {
                'title': 'Walk',
                'start': '2026-10-05T17:00',
                'end': '2026-10-05T17:30',
              },
              'r2')
        ]),
        const AIToolTurnReply(text: 'Added a walk at 17:00.'),
      ];
      final r = await say('find me half an hour for a walk');
      expect((r as TurnAnswered).text, 'Added a walk at 17:00.');
      expect(r.acted.map((a) => a.status), [CallStatus.done, CallStatus.done]);
      expect(ai.requests, hasLength(3));
      final third = ai.requests.last.continuation;
      final results = third.whereType<AIToolResultTurn>().toList();
      expect(results.map((t) => t.callId), ['r1', 'r2']);
      expect(_json(results.first.json)['slots'], isNotEmpty);
      expect(_json(results.last.json)['block_id'], isA<int>());
      expect(ai.requests.first.system, contains('Now: 2026-10-05T16:40'));
      expect(ai.requests.first.tools, hasLength(25));
      // One turn, one group: a single UNDO removes the walk.
      expect(await at(() => undo.undoGroup(r.groupId)), UndoResult.undone);
      expect(await schedule.getBlocksForDay(now), isEmpty);
    });

    test('unknown tools, bad arguments and invalid targets go back as errors',
        () async {
      ai.script = [
        AIToolTurnReply(calls: [
          call('send_payment', {'to': 'x'}, 'a'),
          call('create_task', {'title': 42}, 'b'),
          call('complete_task', {'task_id': 999}, 'c'),
        ]),
        const AIToolTurnReply(text: 'I could not do that.'),
      ];
      final r = await say('pay Ravi and finish task 999');
      expect(r.acted.map((a) => a.status), everyElement(CallStatus.rejected));
      final errors = ai.requests.last.continuation
          .whereType<AIToolResultTurn>()
          .map((t) => (t.isError, _json(t.json)['error']))
          .toList();
      expect(errors, [
        (true, 'unknown_tool'),
        (true, 'bad_arguments'),
        (true, 'notFound'),
      ]);
      expect(await db.select(db.assistantActions).get(), isEmpty);
      expect(r.changedSomething, isFalse);
    });

    test('the model failing ends the turn with its kind', () async {
      ai.script = [const AIToolTurnFailed(AIFailure(AIFailureKind.invalidKey))];
      final r = await say('what should I do next');
      expect((r as TurnFailed).failure, AIFailureKind.invalidKey);
    });

    test('a round limit', () async {
      ai.script = List.generate(
          10,
          (i) => AIToolTurnReply(calls: [
                call('search_tasks', {'query': ''})
              ]));
      final r = await say('keep looking');
      expect((r as TurnStopped).limit, TurnLimit.rounds);
      expect(ai.requests, hasLength(AssistantOrchestrator.maxRounds));
    });

    test('a call limit: too many calls at once run none of them', () async {
      ai.script = [
        AIToolTurnReply(calls: [
          for (var i = 0; i < 9; i++)
            call('create_task', {'title': 'T$i'}, 'c$i'),
        ]),
      ];
      final r = await say('make nine tasks');
      expect((r as TurnStopped).limit, TurnLimit.calls);
      expect(await tasks.findTasks(''), isEmpty);
    });

    test('a model that never answers times out', () async {
      ai.hang = true;
      final r = await say('are you there');
      expect((r as TurnStopped).limit, TurnLimit.timeout);
      expect(ai.lastCancel!.isCancelled, isTrue);
    });
  });

  group('the policy', () {
    test('a delete stops the turn for a confirm; nothing goes until yes',
        () async {
      final id = await at(() =>
          tasks.createTask(title: 'Old idea', priority: TaskPriority.low));
      ai.script = [
        AIToolTurnReply(calls: [
          call('delete_task', {'task_id': id}, 'd'),
          call('create_task', {'title': 'Never runs'}, 'e'),
        ]),
      ];
      final r = await say('delete old idea and add another');
      final pending = (r as TurnNeedsConfirmation).pending;
      expect(pending.preview, isA<DeletePreview>());
      expect(await tasks.getTask(id), isNotNull);
      expect(await tasks.findTasks('Never'), isEmpty);

      final done = await at(() => orchestrator.confirm(pending));
      expect(done.status, CallStatus.done);
      expect(await tasks.getTask(id), isNull);
      final entry = await db.select(db.assistantActions).getSingle();
      expect(entry.decision, Decision.confirm);
      expect(entry.groupId, r.groupId);
      expect(await at(() => undo.undoGroup(r.groupId)), UndoResult.undone);
      expect((await tasks.getTask(id))!.title, 'Old idea');
    });

    test('careful: even a reversible request asks first', () async {
      preset = AutonomyPreset.careful;
      final r = await say('add a task water the plants');
      expect(r, isA<TurnNeedsConfirmation>());
      expect(await tasks.findTasks(''), isEmpty);
    });

    test('a confirm checks again: a task deleted meanwhile is rejected',
        () async {
      final id = await at(() =>
          tasks.createTask(title: 'Gone soon', priority: TaskPriority.low));
      ai.script = [
        AIToolTurnReply(calls: [
          call('delete_task', {'task_id': id})
        ]),
      ];
      final r = await say('delete gone soon') as TurnNeedsConfirmation;
      await tasks.deleteTask(id);
      final done = await at(() => orchestrator.confirm(r.pending));
      expect(done.status, CallStatus.rejected);
    });
  });

  group('proposals', () {
    late ProposalService proposals;
    setUp(() => proposals = ProposalService(
        registry: ToolRegistry(), executor: executor, store: store, env: env));

    ProposalDraft draft(String args, {String key = 'k1', DateTime? expires}) =>
        ProposalDraft(
          toolName: 'create_task',
          argsJson: args,
          origin: ActionOrigin.commitment,
          reason: ProposalReason.commitment,
          dedupeKey: key,
          sourceText: 'I told Priya I would send the deck',
          expiresAt: expires,
        );

    test('dedupe: a second open proposal with the same key is not stored',
        () async {
      expect(await store.createProposal(draft('{"title": "Deck"}'), at: now),
          isNotNull);
      expect(await store.createProposal(draft('{"title": "Deck"}'), at: now),
          isNull);
      expect(
          await store.createProposal(draft('{"title": "x"}', key: 'k2'),
              at: now),
          isNotNull);
    });

    test('accept runs it once, as said, and closes it', () async {
      final id = (await store.createProposal(draft('{"title": "Send deck"}'),
          at: now))!;
      expect(await at(() => proposals.accept(id)), AcceptResult.done);
      expect(await at(() => proposals.accept(id)), AcceptResult.alreadyClosed);
      expect(await tasks.findTasks('Send deck'), hasLength(1));
      expect((await store.getProposal(id))!.status, ProposalStatus.accepted);
      final entry = await db.select(db.assistantActions).getSingle();
      expect(entry.origin, ActionOrigin.said);
      expect(entry.groupId, 'proposal-$id');
    });

    test('accept re-validates: a deleted target is no longer possible',
        () async {
      final t = await at(
          () => tasks.createTask(title: 'Report', priority: TaskPriority.low));
      final id = (await store.createProposal(
          ProposalDraft(
            toolName: 'complete_task',
            argsJson: '{"task_id": $t}',
            origin: ActionOrigin.context,
            reason: ProposalReason.overdueDrift,
            dedupeKey: 'overdue:$t',
          ),
          at: now))!;
      await tasks.deleteTask(t);
      expect(
          await at(() => proposals.accept(id)), AcceptResult.noLongerPossible);
      expect((await store.getProposal(id))!.status, ProposalStatus.expired);
    });

    test('expired proposals are hidden and cannot be accepted', () async {
      final soon = now.add(const Duration(minutes: 5));
      final id = (await store.createProposal(
          draft('{"title": "Later"}', expires: soon),
          at: now))!;
      expect(await store.watchOpenProposals(now).first, hasLength(1));
      final later = now.add(const Duration(hours: 1));
      expect(await store.watchOpenProposals(later).first, isEmpty);
      expect(await withClock(Clock.fixed(later), () => proposals.accept(id)),
          AcceptResult.noLongerPossible);
      expect(await store.expireProposals(later), 0); // already closed
    });

    test('dismiss closes it once; the key is free again', () async {
      final id =
          (await store.createProposal(draft('{"title": "a"}'), at: now))!;
      expect(await proposals.dismiss(id), isTrue);
      expect(await proposals.dismiss(id), isFalse);
      expect(await store.createProposal(draft('{"title": "a"}'), at: now),
          isNotNull);
    });
  });
}

Map<String, Object?> _json(String s) => jsonDecode(s) as Map<String, Object?>;

final class _ScriptedAi implements AIRepository {
  List<AIToolTurnResult> script = [];
  final requests =
      <({String? system, List<AIToolSpec> tools, List<AITurn> continuation})>[];
  bool hang = false;
  AICancelToken? lastCancel;

  @override
  Future<AIToolTurnResult> completeWithTools({
    required String prompt,
    required List<AIToolSpec> tools,
    String? system,
    List<AIMessage> history = const [],
    List<AITurn> continuation = const [],
    AIToolChoice toolChoice = AIToolChoice.auto,
    AICancelToken? cancel,
  }) {
    lastCancel = cancel;
    requests.add((
      system: system,
      tools: tools,
      continuation: List.of(continuation),
    ));
    if (hang) return Completer<AIToolTurnResult>().future;
    if (script.isEmpty) {
      return Future.value(const AIToolTurnReply(text: 'ok'));
    }
    return Future.value(script.removeAt(0));
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
