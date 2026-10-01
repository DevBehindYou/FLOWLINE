// dart format width=80
// ignore_for_file: unused_local_variable, unused_import
import 'package:drift/drift.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flowline/data/local/drift/app_database.dart';
import 'package:flutter_test/flutter_test.dart';
import 'generated/schema.dart';

import 'generated/schema_v3.dart' as v3;
import 'generated/schema_v4.dart' as v4;

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late SchemaVerifier verifier;

  setUpAll(() {
    verifier = SchemaVerifier(GeneratedHelper());
  });

  group('simple database migrations', () {
    // These simple tests verify all possible schema updates with a simple (no
    // data) migration. This is a quick way to ensure that written database
    // migrations properly alter the schema.
    const versions = GeneratedHelper.versions;
    for (final (i, fromVersion) in versions.indexed) {
      group('from $fromVersion', () {
        for (final toVersion in versions.skip(i + 1)) {
          test('to $toVersion', () async {
            final schema = await verifier.schemaAt(fromVersion);
            final db = AppDatabase(schema.newConnection());
            await verifier.migrateAndValidate(db, toVersion);
            await db.close();
          });
        }
      });
    }
  });

  // The following template shows how to write tests ensuring your migrations
  // preserve existing data.
  // Testing this can be useful for migrations that change existing columns
  // (e.g. by alterating their type or constraints). Migrations that only add
  // tables or columns typically don't need these advanced tests. For more
  // information, see https://drift.simonbinder.eu/migrations/tests/#verifying-data-integrity
  // TODO: This generated template shows how these tests could be written. Adopt
  // it to your own needs when testing migrations with data integrity.
  test('migration from v3 to v4 does not corrupt data', () async {
    // Add data to insert into the old database, and the expected rows after the
    // migration.
    // TODO: Fill these lists
    final oldTasksData = <v3.TasksData>[];
    final expectedNewTasksData = <v4.TasksData>[];

    final oldSubtasksData = <v3.SubtasksData>[];
    final expectedNewSubtasksData = <v4.SubtasksData>[];

    final oldScheduleBlocksData = <v3.ScheduleBlocksData>[];
    final expectedNewScheduleBlocksData = <v4.ScheduleBlocksData>[];

    final oldFocusSessionsData = <v3.FocusSessionsData>[];
    final expectedNewFocusSessionsData = <v4.FocusSessionsData>[];

    final oldAiProviderConfigsData = <v3.AiProviderConfigsData>[];
    final expectedNewAiProviderConfigsData = <v4.AiProviderConfigsData>[];

    final oldAiConversationsData = <v3.AiConversationsData>[];
    final expectedNewAiConversationsData = <v4.AiConversationsData>[];

    final oldAiMessagesData = <v3.AiMessagesData>[];
    final expectedNewAiMessagesData = <v4.AiMessagesData>[];

    await verifier.testWithDataIntegrity(
      oldVersion: 3,
      newVersion: 4,
      createOld: v3.DatabaseAtV3.new,
      createNew: v4.DatabaseAtV4.new,
      openTestedDatabase: AppDatabase.new,
      createItems: (batch, oldDb) {
        batch.insertAll(oldDb.tasks, oldTasksData);
        batch.insertAll(oldDb.subtasks, oldSubtasksData);
        batch.insertAll(oldDb.scheduleBlocks, oldScheduleBlocksData);
        batch.insertAll(oldDb.focusSessions, oldFocusSessionsData);
        batch.insertAll(oldDb.aiProviderConfigs, oldAiProviderConfigsData);
        batch.insertAll(oldDb.aiConversations, oldAiConversationsData);
        batch.insertAll(oldDb.aiMessages, oldAiMessagesData);
      },
      validateItems: (newDb) async {
        expect(expectedNewTasksData, await newDb.select(newDb.tasks).get());
        expect(
            expectedNewSubtasksData, await newDb.select(newDb.subtasks).get());
        expect(expectedNewScheduleBlocksData,
            await newDb.select(newDb.scheduleBlocks).get());
        expect(expectedNewFocusSessionsData,
            await newDb.select(newDb.focusSessions).get());
        expect(expectedNewAiProviderConfigsData,
            await newDb.select(newDb.aiProviderConfigs).get());
        expect(expectedNewAiConversationsData,
            await newDb.select(newDb.aiConversations).get());
        expect(expectedNewAiMessagesData,
            await newDb.select(newDb.aiMessages).get());
      },
    );
  });
}
