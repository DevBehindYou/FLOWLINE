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
import '../../../domain/entities/ai_message.dart';
import '../../../domain/entities/ai_provider_config.dart';
import '../../../domain/entities/focus_session.dart';
import '../../../domain/entities/schedule_block.dart';
import '../../../domain/entities/subtask.dart';
import '../../../domain/entities/task.dart';
import 'tables/ai_conversations_table.dart';
import 'tables/ai_messages_table.dart';
import 'tables/ai_provider_configs_table.dart';
import 'tables/focus_sessions_table.dart';
import 'tables/schedule_blocks_table.dart';
import 'tables/subtasks_table.dart';
import 'tables/tasks_table.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [
  Tasks,
  Subtasks,
  ScheduleBlocks,
  FocusSessions,
  AiProviderConfigs,
  AiConversations,
  AiMessages,
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
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();
        },
        onUpgrade: (Migrator m, int from, int to) async {
          // v1 -> v2: added FocusSessions (Phase 2).
          if (from < 2) {
            await m.createTable(focusSessions);
          }
          // v2 -> v3: added the AI Assistant's tables (Phase 3). No user
          // data exists in the wild yet, so these are plain additive
          // migrations — nothing to backfill.
          if (from < 3) {
            await m.createTable(aiProviderConfigs);
            await m.createTable(aiConversations);
            await m.createTable(aiMessages);
          }
          // v3 -> v4: constraints and indexes (Phase 1 of
          // docs/04-build-and-optimization-plan.md). Repair first, so no
          // existing row can violate a new constraint, then rebuild.
          if (from < 4) {
            await _repairForV4();
            // Rebuilds: CHECK(end_time > start_time) on schedule_blocks and
            // the schedule_block_id foreign key on tasks. alterTable copies
            // every row and turns foreign keys off while it runs, so the
            // drop/re-create can't cascade into subtasks or sessions.
            await m.alterTable(TableMigration(scheduleBlocks));
            await m.alterTable(TableMigration(tasks));
            await m.addColumn(aiMessages, aiMessages.isPending);
            for (final index in allSchemaEntities.whereType<Index>()) {
              await m.create(index);
            }
          }
          await _assertForeignKeysIntact();
        },
        // SQLite ignores every `references(..., onDelete: ...)` above unless
        // this is set per connection; without it deleting a task orphans
        // its subtasks and leaves focus sessions pointing at a dead id.
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );

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
      final file = File(p.join(dbFolder.path, 'flowline.sqlite'));
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
