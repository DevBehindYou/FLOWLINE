import 'package:drift/drift.dart';

import '../../../../domain/assistant/autonomy.dart';
import '../../../../domain/assistant/ledger.dart';
import 'utterances_table.dart';

/// The action ledger (schema v8, docs/05 §9.4): one row per action AA
/// ran, written in the same transaction as the change.
///
/// No CHECKs on the enum columns: each enum is append-only (R1), and a
/// range CHECK would force a table rebuild every time one grows.
@TableIndex(name: 'assistant_actions_at', columns: {#at})
@TableIndex(name: 'assistant_actions_group', columns: {#groupId})
@DataClassName('AssistantActionRow')
class AssistantActions extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get at => dateTime()();
  TextColumn get groupId =>
      // ignore: recursive_getters
      text().check(groupId.length.isBiggerThanValue(0))();
  TextColumn get toolName =>
      // ignore: recursive_getters
      text().check(toolName.length.isBiggerThanValue(0))();
  TextColumn get argsJson => text()();
  IntColumn get origin => intEnum<ActionOrigin>()();
  IntColumn get decision => intEnum<Decision>()();
  IntColumn get status => intEnum<LedgerStatus>()();

  /// `encodeUndoRecipe` output; null when the action has no undo.
  TextColumn get undoJson => text().nullable()();
  IntColumn get utteranceId => integer()
      .nullable()
      .references(Utterances, #id, onDelete: KeyAction.setNull)();
}
