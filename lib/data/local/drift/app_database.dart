import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart' show sqlite3;

// The generated part file shares this library's imports, so every enum a
// table stores via intEnum<T>() must be imported here, not only in the
// table's own file.
import '../../../domain/ai/ai_contract.dart';
import '../../../domain/assistant/autonomy.dart';
import '../../../domain/assistant/ledger.dart';
import '../../../domain/assistant/proposal.dart';
import '../../../domain/assistant/utterance.dart';
import '../../../domain/entities/ai_message.dart';
import '../../../domain/entities/ai_provider_config.dart';
import '../../../domain/entities/focus_session.dart';
import '../../../domain/entities/schedule_block.dart';
import '../../../domain/entities/subtask.dart';
import '../../../domain/entities/task.dart';
import 'tables/ai_conversations_table.dart';
import 'tables/app_settings_table.dart';
import 'tables/ai_messages_table.dart';
import 'tables/ai_provider_configs_table.dart';
import 'tables/assistant_actions_table.dart';
import 'tables/focus_sessions_table.dart';
import 'tables/proposals_table.dart';
import 'tables/schedule_blocks_table.dart';
import 'tables/subtasks_table.dart';
import 'tables/tasks_table.dart';
import 'tables/utterances_table.dart';
import 'app_database.steps.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [
  AppSettingsEntries,
  Tasks,
  Subtasks,
  ScheduleBlocks,
  ScheduleBlockExceptions,
  FocusSessions,
  AiProviderConfigs,
  AiConversations,
  AiMessages,
  Utterances,
  AssistantActions,
  Proposals,
])
class AppDatabase extends _$AppDatabase {
  /// [executor] is for tests and migration verification; the app always
  /// opens the on-device file.
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @visibleForTesting
  AppDatabase.forTesting(super.executor);

  // Every bump: add a step below, then `dart run drift_dev make-migrations`
  // and commit drift_schemas/ and test/drift/ (rule R2).
  @override
  int get schemaVersion => 10;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();
        },
        // Step by step (drift's generated app_database.steps.dart): each
        // step sees the schema of the version it migrates to, not today's
        // tables. Rebuilding a table from the current definition in an old
        // step breaks as soon as a later version adds a column to it.
        // v1/v2 never shipped (no snapshots), so steps start at v3.
        onUpgrade: (Migrator m, int from, int to) async {
          await stepByStep(
            // Constraints and indexes (Phase 1 of
            // docs/04-build-and-optimization-plan.md). Repair first, so no
            // existing row can violate a new constraint, then rebuild.
            from3To4: (m, schema) async {
              await _repairForV4();
              // Rebuilds: CHECK(end_time > start_time) on schedule_blocks
              // and the schedule_block_id foreign key on tasks. alterTable
              // copies every row and turns foreign keys off while it runs,
              // so the drop/re-create can't cascade into subtasks or
              // sessions.
              await m.alterTable(TableMigration(schema.scheduleBlocks));
              await m.alterTable(TableMigration(schema.tasks));
              await m.addColumn(schema.aiMessages, schema.aiMessages.isPending);
              for (final index in schema.entities.whereType<Index>()) {
                await m.create(index);
              }
            },
            // User preferences (Phase 3).
            from4To5: (m, schema) async {
              await m.createTable(schema.appSettings);
            },
            // Recurring blocks (Phase 3): series columns, the CHECKs
            // between them, deleted-occurrence exceptions, and the unique
            // index on (series, day).
            from5To6: (m, schema) async {
              await m.alterTable(TableMigration(
                schema.scheduleBlocks,
                newColumns: [
                  schema.scheduleBlocks.recurrence,
                  schema.scheduleBlocks.recurrenceUntil,
                  schema.scheduleBlocks.seriesId,
                  schema.scheduleBlocks.occurrenceDate,
                ],
              ));
              await m.createTable(schema.scheduleBlockExceptions);
              await m.create(schema.scheduleBlocksSeriesOccurrence);
            },
            // Typed AI errors (Phase 4): the failure kind and status of an
            // error reply.
            from6To7: (m, schema) async {
              await m.addColumn(schema.aiMessages, schema.aiMessages.errorKind);
              await m.addColumn(
                  schema.aiMessages, schema.aiMessages.errorStatus);
            },
            // The assistant core (docs/05 Phase E): the action ledger,
            // proposals and utterances. New tables only; nothing existing
            // changes.
            from7To8: (m, schema) async {
              await m.createTable(schema.utterances);
              await m.createTable(schema.assistantActions);
              await m.createTable(schema.proposals);
              await m.create(schema.utterancesAt);
              await m.create(schema.assistantActionsAt);
              await m.create(schema.assistantActionsGroup);
              await m.create(schema.proposalsOpenKey);
              await m.create(schema.proposalsStatus);
            },
            // Why a reply ended (B18): "cut off" for the length limit.
            from8To9: (m, schema) async {
              await m.addColumn(
                  schema.aiMessages, schema.aiMessages.stopReason);
            },
            // The chat acts (docs/05 E.5): each action keeps its preview,
            // each reply the turn it belongs to.
            from9To10: (m, schema) async {
              await m.addColumn(
                  schema.assistantActions, schema.assistantActions.previewJson);
              await m.addColumn(
                  schema.aiMessages, schema.aiMessages.turnGroupId);
            },
          )(m, from, to);
          await _assertForeignKeysIntact();
        },
        // SQLite ignores every `references(..., onDelete: ...)` above unless
        // this is set per connection; without it deleting a task orphans
        // its subtasks and leaves focus sessions pointing at a dead id.
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );

  /// Deletes every row in every table, children first so no foreign key
  /// is ever violated. Used by "Clear all data" (Data & privacy).
  Future<void> wipeAllData() {
    return transaction(() async {
      for (final TableInfo<Table, Object?> table in [
        assistantActions,
        proposals,
        utterances,
        aiMessages,
        aiConversations,
        focusSessions,
        subtasks,
        tasks,
        scheduleBlockExceptions,
        scheduleBlocks,
        aiProviderConfigs,
        appSettingsEntries,
      ]) {
        await delete(table).go();
      }
    });
  }

  /// Makes v3 data satisfy the v4 constraints before they're created.
  /// Each statement is a no-op on clean data.
  Future<void> _repairForV4() async {
    // A task pointing at a deleted block is in no block and not
    // "unscheduled" either; unschedule it so the new FK holds.
    await customStatement('UPDATE tasks SET schedule_block_id = NULL '
        'WHERE schedule_block_id IS NOT NULL AND schedule_block_id NOT IN '
        '(SELECT id FROM schedule_blocks)');
    // Date-times are stored as Unix seconds: give a zero-length or
    // inverted block one minute so CHECK(end_time > start_time) holds.
    await customStatement(
        'UPDATE schedule_blocks SET end_time = start_time + 60 '
        'WHERE end_time <= start_time');
    // Keep only the newest active focus session; close any older ones as
    // ended early at their start, so the unique index can be created.
    await customStatement('UPDATE focus_sessions '
        'SET completed_at = started_at, actual_duration_sec = 0, '
        'ended_early = 1, segment_started_at = NULL '
        'WHERE completed_at IS NULL AND id <> '
        '(SELECT MAX(id) FROM focus_sessions WHERE completed_at IS NULL)');
  }

  /// A migration must never leave a dangling reference behind. Cheap on a
  /// phone-sized database, and it turns silent corruption into a loud,
  /// testable failure.
  Future<void> _assertForeignKeysIntact() async {
    final violations = await customSelect('PRAGMA foreign_key_check').get();
    if (violations.isNotEmpty) {
      throw StateError(
          'Migration left ${violations.length} foreign key violation(s): '
          '${violations.map((r) => r.data).join(', ')}');
    }
  }

  static LazyDatabase _openConnection() {
    return LazyDatabase(() async {
      final dbFolder = await getApplicationDocumentsDirectory();
      final file = File(p.join(dbFolder.path, 'atomic_assist.sqlite'));
      // Android's sandbox has no writable /tmp, so SQLite can fail on
      // large sorts or temp tables unless it's pointed at the app's own
      // cache directory (Drift's documented setup; K18).
      if (Platform.isAndroid) {
        sqlite3.tempDirectory = (await getTemporaryDirectory()).path;
      }
      return NativeDatabase.createInBackground(file);
    });
  }
}
