import 'package:drift/drift.dart';

import '../../../../domain/entities/person.dart';
import 'reminders_table.dart';

/// People (schema v13, docs/05 §15). Names are unique ignoring case, so
/// "Priya" is one person however she's typed.
@TableIndex.sql(
    'CREATE UNIQUE INDEX people_name_nocase ON people (name COLLATE NOCASE)')
@DataClassName('PersonRow')
class People extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name =>
      // Drift's documented pattern for a column CHECK.
      // ignore: recursive_getters
      text().check(name.length.isBetweenValues(1, 120))();
  TextColumn get relation => text().nullable()();
}

@TableIndex(name: 'person_dates_person', columns: {#personId})
@DataClassName('PersonDateRow')
class PersonDates extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get personId =>
      integer().references(People, #id, onDelete: KeyAction.cascade)();
  IntColumn get kind => intEnum<PersonDateKind>()();
  // ignore: recursive_getters
  IntColumn get month => integer().check(month.isBetweenValues(1, 12))();
  // ignore: recursive_getters
  IntColumn get day => integer().check(day.isBetweenValues(1, 31))();
  IntColumn get year => integer().nullable()();
  TextColumn get label => text().nullable()();
}

@TableIndex(name: 'follow_ups_status', columns: {#status, #waitUntil})
@DataClassName('FollowUpRow')
class FollowUps extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get personId =>
      integer().references(People, #id, onDelete: KeyAction.cascade)();
  TextColumn get about =>
      // ignore: recursive_getters
      text().check(about.length.isBetweenValues(1, 200))();
  DateTimeColumn get waitUntil => dateTime()();
  IntColumn get status => intEnum<FollowUpStatus>()();
  IntColumn get reminderId => integer()
      .nullable()
      .references(Reminders, #id, onDelete: KeyAction.setNull)();
}
