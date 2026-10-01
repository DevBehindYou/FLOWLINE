import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flowline/data/local/drift/app_database.dart';
import 'package:flutter_test/flutter_test.dart';

import 'generated/schema.dart';
import 'generated/schema_v3.dart' as v3;
import 'generated/schema_v4.dart' as v4;

/// Upgrading must keep every row, repair the ones that would violate the
/// new constraints, and never cascade a delete while tables are rebuilt.
/// v3 is the schema every APK built so far shipped with.
void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late SchemaVerifier verifier;
  setUpAll(() => verifier = SchemaVerifier(GeneratedHelper()));

  final t0 = DateTime(2026, 3, 10, 9);
  DateTime at(int minutes) => t0.add(Duration(minutes: minutes));

  test('v3 -> v4 keeps all data and repairs constraint violations', () async {
    await verifier.testWithDataIntegrity(
      oldVersion: 3,
      newVersion: 4,
      createOld: v3.DatabaseAtV3.new,
      createNew: v4.DatabaseAtV4.new,
      openTestedDatabase: AppDatabase.new,
      createItems: (batch, oldDb) {
        batch.insertAll(oldDb.scheduleBlocks, [
          v3.ScheduleBlocksData(
              id: 1,
              title: 'Deep work',
              startTime: at(0),
              endTime: at(90),
              source: 0,
              isLocked: false),
          // Inverted: violates the new CHECK, must be repaired, not lost.
          v3.ScheduleBlocksData(
              id: 2,
              title: 'Broken',
              startTime: at(120),
              endTime: at(110),
              source: 0,
              isLocked: false),
        ]);
        batch.insertAll(oldDb.tasks, [
          v3.TasksData(
              id: 1,
              scheduleBlockId: 1,
              title: 'In a block',
              notes: '',
              priority: 1,
              status: 0,
              createdAt: t0),
          // Points at a block that no longer exists (pre-v4 bug).
          v3.TasksData(
              id: 2,
              scheduleBlockId: 99,
              title: 'Orphaned',
              notes: 'keep me',
              priority: 2,
              status: 1,
              dueAt: at(600),
              createdAt: t0),
        ]);
        // Subtasks must survive the tasks table being rebuilt (dropping it
        // with foreign keys on would cascade-delete them).
        batch.insertAll(oldDb.subtasks, [
          const v3.SubtasksData(
              id: 1,
              taskId: 1,
              title: 'Outline',
              status: 1,
              plannedSprints: 2,
              completedSprints: 2,
              orderIndex: 0),
          const v3.SubtasksData(
              id: 2,
              taskId: 2,
              title: 'Draft',
              status: 0,
              plannedSprints: 1,
              completedSprints: 0,
              orderIndex: 1),
        ]);
        batch.insertAll(oldDb.focusSessions, [
          v3.FocusSessionsData(
              id: 1,
              taskId: 1,
              subtaskId: 1,
              sessionType: 0,
              plannedDurationSec: 1500,
              startedAt: at(0),
              remainingSecAtSegmentStart: 0,
              isPaused: false,
              completedAt: at(25),
              actualDurationSec: 1500,
              endedEarly: false),
          // Two active sessions: only the newest may stay active.
          v3.FocusSessionsData(
              id: 2,
              sessionType: 0,
              plannedDurationSec: 1500,
              startedAt: at(30),
              segmentStartedAt: at(30),
              remainingSecAtSegmentStart: 1500,
              isPaused: false,
              endedEarly: false),
          v3.FocusSessionsData(
              id: 3,
              sessionType: 1,
              plannedDurationSec: 300,
              startedAt: at(31),
              segmentStartedAt: at(31),
              remainingSecAtSegmentStart: 300,
              isPaused: false,
              endedEarly: false),
        ]);
        batch.insertAll(oldDb.aiConversations, [
          v3.AiConversationsData(
              id: 1, providerId: 3, title: 'Plan', createdAt: t0),
        ]);
        batch.insertAll(oldDb.aiMessages, [
          v3.AiMessagesData(
              id: 1,
              conversationId: 1,
              role: 0,
              content: 'hi',
              isError: false,
              sentAt: t0),
          v3.AiMessagesData(
              id: 2,
              conversationId: 1,
              role: 1,
              content: 'hello',
              isError: false,
              sentAt: t0),
        ]);
      },
      validateItems: (newDb) async {
        expect(
          await newDb.select(newDb.scheduleBlocks).get(),
          [
            v4.ScheduleBlocksData(
                id: 1,
                title: 'Deep work',
                startTime: at(0),
                endTime: at(90),
                source: 0,
                isLocked: false),
            v4.ScheduleBlocksData(
                id: 2,
                title: 'Broken',
                startTime: at(120),
                endTime: at(121),
                source: 0,
                isLocked: false),
          ],
        );
        expect(
          await newDb.select(newDb.tasks).get(),
          [
            v4.TasksData(
                id: 1,
                scheduleBlockId: 1,
                title: 'In a block',
                notes: '',
                priority: 1,
                status: 0,
                createdAt: t0),
            v4.TasksData(
                id: 2,
                title: 'Orphaned',
                notes: 'keep me',
                priority: 2,
                status: 1,
                dueAt: at(600),
                createdAt: t0),
          ],
        );
        expect(await newDb.select(newDb.subtasks).get(), hasLength(2));

        final sessions = await (newDb.select(newDb.focusSessions)
              ..orderBy([(s) => OrderingTerm.asc(s.id)]))
            .get();
        expect(sessions, hasLength(3));
        expect(sessions[0].completedAt, at(25), reason: 'history untouched');
        expect(sessions[0].taskId, 1);
        expect(sessions[1].completedAt, at(30), reason: 'older active closed');
        expect(sessions[1].endedEarly, isTrue);
        expect(sessions[1].segmentStartedAt, isNull);
        expect(sessions[2].completedAt, isNull, reason: 'newest stays active');

        final messages = await newDb.select(newDb.aiMessages).get();
        expect(messages.map((m) => m.content), ['hi', 'hello']);
        expect(messages.every((m) => !m.isPending), isTrue);
      },
    );
  });

  test('after upgrading, the new constraints are enforced', () async {
    final schema = await verifier.schemaAt(3);
    final db = AppDatabase(schema.newConnection());
    await verifier.migrateAndValidate(db, 4);
    await db.customStatement('PRAGMA foreign_keys = ON');

    // One active session at most.
    Future<void> insertActive(int id) => db.customStatement(
        'INSERT INTO focus_sessions (id, session_type, planned_duration_sec, '
        'started_at, remaining_sec_at_segment_start) VALUES (?, 0, 60, 0, 60)',
        [id]);
    await insertActive(10);
    await expectLater(insertActive(11), throwsA(anything));

    // end_time > start_time.
    await expectLater(
      db.customStatement('INSERT INTO schedule_blocks (title, start_time, '
          'end_time) VALUES (\'x\', 100, 100)'),
      throwsA(anything),
    );

    // Deleting a block unschedules its tasks via the foreign key.
    await db.customStatement('INSERT INTO schedule_blocks (id, title, '
        'start_time, end_time) VALUES (5, \'b\', 0, 60)');
    await db.customStatement('INSERT INTO tasks (id, schedule_block_id, title, '
        'priority, status) VALUES (5, 5, \'t\', 0, 0)');
    await db.customStatement('DELETE FROM schedule_blocks WHERE id = 5');
    final row = await db
        .customSelect('SELECT schedule_block_id FROM tasks WHERE id = 5')
        .getSingle();
    expect(row.data['schedule_block_id'], isNull);

    await db.close();
  });
}
