import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

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
  AppDatabase() : super(_openConnection());

  @visibleForTesting
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 3;

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
        },
        // SQLite ignores every `references(..., onDelete: ...)` above unless
        // this is set per connection; without it deleting a task orphans
        // its subtasks and leaves focus sessions pointing at a dead id.
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );

  static LazyDatabase _openConnection() {
    return LazyDatabase(() async {
      final dbFolder = await getApplicationDocumentsDirectory();
      final file = File(p.join(dbFolder.path, 'flowline.sqlite'));
      return NativeDatabase.createInBackground(file);
    });
  }
}
