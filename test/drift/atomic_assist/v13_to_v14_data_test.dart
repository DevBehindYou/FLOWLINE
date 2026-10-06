import 'package:drift_dev/api/migrations_native.dart';
import 'package:drift/drift.dart';
import 'package:atomic_assist/data/local/drift/app_database.dart';
import 'package:flutter_test/flutter_test.dart';

import 'generated/schema.dart';
import 'generated/schema_v13.dart' as v13;
import 'generated/schema_v14.dart' as v14;

/// v14 rebuilds tasks with `recurrence` and its CHECK. Every task and its
/// subtasks come through (the rebuild runs with foreign keys off, so the
/// drop can't cascade), none of them repeating.
void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late SchemaVerifier verifier;
  setUpAll(() => verifier = SchemaVerifier(GeneratedHelper()));

  final nine = DateTime(2026, 10, 5, 9).millisecondsSinceEpoch ~/ 1000;
  final five = DateTime(2026, 10, 6, 17).millisecondsSinceEpoch ~/ 1000;

  test('v13 -> v14 keeps tasks and subtasks, none repeating', () async {
    await verifier.testWithDataIntegrity(
      oldVersion: 13,
      newVersion: 14,
      createOld: v13.DatabaseAtV13.new,
      createNew: v14.DatabaseAtV14.new,
      openTestedDatabase: AppDatabase.new,
      createItems: (batch, oldDb) {
        batch.insertAll(oldDb.tasks, [
          v13.TasksData(
              id: 1,
              title: 'Water plants',
              notes: 'balcony',
              priority: 1,
              status: 0,
              dueAt: five,
              createdAt: nine),
          v13.TasksData(
              id: 2,
              title: 'Call bank',
              notes: '',
              priority: 0,
              status: 2,
              createdAt: nine),
        ]);
        batch.insertAll(oldDb.subtasks, [
          const v13.SubtasksData(
              id: 1,
              taskId: 1,
              title: 'Fill can',
              status: 0,
              plannedSprints: 1,
              completedSprints: 0,
              orderIndex: 0),
        ]);
      },
      validateItems: (newDb) async {
        expect(await newDb.select(newDb.tasks).get(), [
          v14.TasksData(
              id: 1,
              title: 'Water plants',
              notes: 'balcony',
              priority: 1,
              status: 0,
              dueAt: five,
              createdAt: nine),
          v14.TasksData(
              id: 2,
              title: 'Call bank',
              notes: '',
              priority: 0,
              status: 2,
              createdAt: nine),
        ]);
        expect((await newDb.select(newDb.subtasks).get()).single.taskId, 1);
      },
    );
  });
}
