import 'package:drift/drift.dart';

import '../../../../domain/entities/schedule_block.dart';

@DataClassName('ScheduleBlockRow')
class ScheduleBlocks extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  DateTimeColumn get startTime => dateTime()();
  DateTimeColumn get endTime => dateTime()();
  IntColumn get source =>
      intEnum<ScheduleBlockSource>().withDefault(const Constant(0))();
  BoolColumn get isLocked => boolean().withDefault(const Constant(false))();
}
