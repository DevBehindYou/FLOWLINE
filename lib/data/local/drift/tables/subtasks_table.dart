import 'package:drift/drift.dart';

import '../../../../domain/entities/subtask.dart';
import 'tasks_table.dart';

@DataClassName('SubtaskRow')
class Subtasks extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get taskId => integer().references(Tasks, #id, onDelete: KeyAction.cascade)();
  TextColumn get title => text()();
  IntColumn get status => intEnum<SubtaskStatus>()();
  IntColumn get plannedSprints => integer().withDefault(const Constant(1))();
  IntColumn get completedSprints => integer().withDefault(const Constant(0))();
  IntColumn get orderIndex => integer().withDefault(const Constant(0))();
}
