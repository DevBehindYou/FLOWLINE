import 'package:drift/drift.dart';

import '../../../../domain/entities/schedule_block.dart';

@TableIndex(name: 'schedule_blocks_start_time', columns: {#startTime})
@DataClassName('ScheduleBlockRow')
class ScheduleBlocks extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  DateTimeColumn get startTime => dateTime()();
  // A zero-length or inverted block can't be shown or conflict-checked
  // sensibly; every UI path already validates this, the CHECK makes it a
  // guarantee (rule R3).
  // Drift's documented pattern for a column CHECK: the getter is read by
  // the code generator, never called at runtime.
  DateTimeColumn get endTime =>
      // ignore: recursive_getters
      dateTime().check(endTime.isBiggerThan(startTime))();
  IntColumn get source =>
      intEnum<ScheduleBlockSource>().withDefault(const Constant(0))();
  BoolColumn get isLocked => boolean().withDefault(const Constant(false))();
}
