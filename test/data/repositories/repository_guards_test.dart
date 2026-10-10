import 'package:drift/drift.dart' show Value;
import 'package:atomic_assist/data/local/drift/app_database.dart';
import 'package:atomic_assist/data/repositories/ai_repository_impl.dart';
import 'package:atomic_assist/data/local/secure/secure_key_store.dart';
import 'package:atomic_assist/data/repositories/focus_session_repository_impl.dart';
import 'package:atomic_assist/data/repositories/schedule_repository_impl.dart';
import 'package:atomic_assist/data/repositories/task_repository_impl.dart';
import 'package:atomic_assist/domain/entities/ai_message.dart';
import 'package:atomic_assist/domain/entities/ai_provider_config.dart';
import 'package:atomic_assist/domain/entities/focus_session.dart';
import 'package:atomic_assist/domain/entities/task.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/test_database.dart';

/// Regression tests for the Phase 1 repository guards (B5, B7, B12, B29,
/// B30) listed in docs/04-build-and-optimization-plan.md §3.
void main() {
  late AppDatabase db;

  setUp(() => db = createTestDatabase());
  tearDown(() => db.close());

  group('AI messages (B5)', () {
    test('messages written in the same second keep their insertion order',
        () async {
      final ai = AIRepositoryImpl(db, const SecureKeyStore(), const {});
      final conversationId =
          await ai.createConversation(providerId: AIProviderId.ollama);
      // Same sentAt for all three: only the id can order them.
      final sameSecond = DateTime(2026, 3, 10, 9, 0, 0);
      for (final (role, text) in [
        (AIMessageRole.user, 'first'),
        (AIMessageRole.assistant, 'second'),
        (AIMessageRole.user, 'third'),
      ]) {
        await db.into(db.aiMessages).insert(AiMessagesCompanion.insert(
              conversationId: conversationId,
              role: role,
              content: text,
              sentAt: Value(sameSecond),
            ));
      }

      final messages = await ai.watchMessages(conversationId).first;
      expect(messages.map((m) => m.content), ['first', 'second', 'third']);
    });
  });

  group('focus sessions (B7, B30)', () {
    late FocusSessionRepositoryImpl sessions;
    setUp(() => sessions = FocusSessionRepositoryImpl(db));

    Future<FocusSessionRow> row(int id) =>
        (db.select(db.focusSessions)..where((s) => s.id.equals(id)))
            .getSingle();

    test('pause and resume never touch a completed session', () async {
      final id = await sessions.startSession(
          sessionType: FocusSessionType.focus, plannedDurationSec: 1500);
      await sessions.completeSession(id, endedEarly: true);
      final completed = await row(id);

      await sessions.pauseSession(id);
      await sessions.resumeSession(id);

      final after = await row(id);
      expect(after.isPaused, completed.isPaused);
      expect(after.segmentStartedAt, completed.segmentStartedAt);
      expect(after.remainingSecAtSegmentStart,
          completed.remainingSecAtSegmentStart);
    });

    test('pausing twice keeps the first remaining time', () async {
      final id = await sessions.startSession(
          sessionType: FocusSessionType.focus, plannedDurationSec: 1500);
      await sessions.pauseSession(id);
      final first = (await row(id)).remainingSecAtSegmentStart;
      await sessions.pauseSession(id);
      expect((await row(id)).remainingSecAtSegmentStart, first);
    });

    test('resuming a running session does not move its anchor', () async {
      final id = await sessions.startSession(
          sessionType: FocusSessionType.focus, plannedDurationSec: 1500);
      final anchor = (await row(id)).segmentStartedAt;
      await sessions.resumeSession(id);
      expect((await row(id)).segmentStartedAt, anchor);
    });

    test('ranges window completed sessions by when they ended', () async {
      // Started before midnight, ended after it: it belongs to the day it
      // ended, everywhere (Focus footer, Insights, export).
      await db.into(db.focusSessions).insert(FocusSessionsCompanion.insert(
            sessionType: FocusSessionType.focus,
            plannedDurationSec: 1500,
            startedAt: DateTime(2026, 3, 9, 23, 50),
            remainingSecAtSegmentStart: 0,
            completedAt: Value(DateTime(2026, 3, 10, 0, 15)),
            actualDurationSec: const Value(1500),
          ));
      // Still running: not completed, so in no range.
      await sessions.startSession(
          sessionType: FocusSessionType.focus, plannedDurationSec: 1500);

      final ninth = await sessions
          .watchCompletedSessionsInRange(
              DateTime(2026, 3, 9), DateTime(2026, 3, 10))
          .first;
      final tenth = await sessions
          .watchCompletedSessionsInRange(
              DateTime(2026, 3, 10), DateTime(2026, 3, 11))
          .first;
      expect(ninth, isEmpty);
      expect(tenth, hasLength(1));
    });
  });

  group('subtask sprints (B12)', () {
    test('concurrent increments are all counted', () async {
      final tasks = TaskRepositoryImpl(db);
      final taskId =
          await tasks.createTask(title: 'Write', priority: TaskPriority.high);
      final subtaskId =
          await tasks.createSubtask(taskId: taskId, title: 'Draft');

      await Future.wait([
        for (var i = 0; i < 5; i++)
          tasks.incrementSubtaskCompletedSprints(subtaskId),
      ]);

      final subtask = await tasks.watchSubtasks(taskId).first;
      expect(subtask.single.completedSprints, 5);
    });

    test('the subtask stream refreshes after an increment', () async {
      final tasks = TaskRepositoryImpl(db);
      final taskId =
          await tasks.createTask(title: 'Write', priority: TaskPriority.high);
      final subtaskId =
          await tasks.createSubtask(taskId: taskId, title: 'Draft');
      final updates = tasks.watchSubtasks(taskId);
      final expectation = expectLater(
        updates.map((s) => s.single.completedSprints),
        emitsThrough(1),
      );
      await tasks.incrementSubtaskCompletedSprints(subtaskId);
      await expectation;
    });
  });

  group('blocks for a day (B29)', () {
    test('include a block that started the evening before', () async {
      final schedule = ScheduleRepositoryImpl(db);
      await schedule.createBlock(
        title: 'Late shift',
        startTime: DateTime(2026, 3, 9, 22),
        endTime: DateTime(2026, 3, 10, 2),
      );
      await schedule.createBlock(
        title: 'Morning',
        startTime: DateTime(2026, 3, 10, 9),
        endTime: DateTime(2026, 3, 10, 10),
      );
      await schedule.createBlock(
        title: 'Yesterday only',
        startTime: DateTime(2026, 3, 9, 9),
        endTime: DateTime(2026, 3, 9, 10),
      );
      await schedule.createBlock(
        title: 'Ends at midnight',
        startTime: DateTime(2026, 3, 9, 23),
        endTime: DateTime(2026, 3, 10),
      );

      final blocks =
          await schedule.watchBlocksForDay(DateTime(2026, 3, 10, 15)).first;
      expect(blocks.map((b) => b.title), ['Late shift', 'Morning']);
    });
  });
}
