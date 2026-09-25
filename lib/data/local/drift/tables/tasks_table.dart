import 'package:drift/drift.dart';

import '../../../../domain/entities/task.dart';

@DataClassName('TaskRow')
class Tasks extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get scheduleBlockId => integer().nullable()();
  TextColumn get title => text()();
  TextColumn get notes => text().withDefault(const Constant(''))();
  IntColumn get priority => intEnum<TaskPriority>()();
  IntColumn get status => intEnum<TaskStatus>()();
  DateTimeColumn get dueAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
