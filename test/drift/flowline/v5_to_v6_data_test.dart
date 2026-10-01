import 'package:drift_dev/api/migrations_native.dart';
import 'package:drift/drift.dart';
import 'package:flowline/data/local/drift/app_database.dart';
import 'package:flutter_test/flutter_test.dart';

import 'generated/schema.dart';
import 'generated/schema_v5.dart' as v5;
import 'generated/schema_v6.dart' as v6;

/// v6 rebuilds schedule_blocks to add the recurrence columns. Every block
/// and the tasks pointing at it must survive the rebuild unchanged.
void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late SchemaVerifier verifier;
  setUpAll(() => verifier = SchemaVerifier(GeneratedHelper()));

  // Unix seconds, as these schema versions store date-times.
  final nine = DateTime(2026, 3, 10, 9).millisecondsSinceEpoch ~/ 1000;

  test('v5 -> v6 keeps blocks and the tasks in them', () async {
    await verifier.testWithDataIntegrity(
      oldVersion: 5,
      newVersion: 6,
      createOld: v5.DatabaseAtV5.new,
      createNew: v6.DatabaseAtV6.new,
      openTestedDatabase: AppDatabase.new,
      createItems: (batch, oldDb) {
        batch.insertAll(oldDb.scheduleBlocks, [
          v5.ScheduleBlocksData(
              id: 1,
              title: 'Deep work',
              startTime: nine,
              endTime: nine + 5400,
              source: 0,
              isLocked: 0),
        ]);
        batch.insertAll(oldDb.tasks, [
          v5.TasksData(
              id: 1,
              scheduleBlockId: 1,
              title: 'In a block',
              notes: '',
              priority: 1,
              status: 0,
              createdAt: nine),
        ]);
      },
      validateItems: (newDb) async {
        expect(await newDb.select(newDb.scheduleBlocks).get(), [
          v6.ScheduleBlocksData(
              id: 1,
              title: 'Deep work',
              startTime: nine,
              endTime: nine + 5400,
              source: 0,
              isLocked: 0),
        ]);
        expect(
            (await newDb.select(newDb.tasks).getSingle()).scheduleBlockId, 1);
        expect(
            await newDb.select(newDb.scheduleBlockExceptions).get(), isEmpty);
      },
    );
  });
}
