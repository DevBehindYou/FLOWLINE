import 'package:drift/drift.dart';

import '../../../../domain/assistant/utterance.dart';

/// Everything the user said or typed to AA (schema v8). Retention is a
/// setting (docs/05 §6.4); the ledger keeps its rows when an utterance is
/// deleted (`utterance_id` is set to null).
@TableIndex(name: 'utterances_at', columns: {#at})
@DataClassName('UtteranceRow')
class Utterances extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get at => dateTime()();
  // Drift's documented pattern for a column CHECK: the getter is read by
  // the code generator, never called at runtime.
  // ignore: recursive_getters
  TextColumn get body => text().check(body.length.isBiggerThanValue(0))();
  IntColumn get source => intEnum<UtteranceSource>()();
  TextColumn get language => text().nullable()();
  RealColumn get confidence => real()
      .nullable()
      // ignore: recursive_getters
      .check(confidence.isBetweenValues(0, 1))();
}
