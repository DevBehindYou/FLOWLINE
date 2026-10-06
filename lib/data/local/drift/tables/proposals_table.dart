import 'package:drift/drift.dart';

import '../../../../domain/assistant/autonomy.dart';
import '../../../../domain/assistant/proposal.dart';

/// Suggestions waiting in the Inbox (schema v8, docs/05 §9.5).
// At most one *open* proposal per dedupe key (R3). Status 0 is
// ProposalStatus.open, which is first and stays first (R1).
@TableIndex.sql('CREATE UNIQUE INDEX proposals_open_key '
    'ON proposals (dedupe_key) WHERE status = 0')
@TableIndex(name: 'proposals_status', columns: {#status})
@DataClassName('ProposalRow')
class Proposals extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get expiresAt => dateTime()
      .nullable()
      // ignore: recursive_getters
      .check(expiresAt.isBiggerThan(createdAt))();
  TextColumn get toolName =>
      // ignore: recursive_getters
      text().check(toolName.length.isBiggerThanValue(0))();
  TextColumn get argsJson => text()();
  IntColumn get origin => intEnum<ActionOrigin>()();
  IntColumn get reason => intEnum<ProposalReason>()();
  TextColumn get reasonJson => text().withDefault(const Constant('{}'))();
  TextColumn get sourceText => text().nullable()();
  TextColumn get dedupeKey =>
      // ignore: recursive_getters
      text().check(dedupeKey.length.isBiggerThanValue(0))();
  IntColumn get status => intEnum<ProposalStatus>()();
}
