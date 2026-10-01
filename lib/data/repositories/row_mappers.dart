import '../../domain/entities/schedule_block.dart';
import '../../domain/entities/task.dart';
import '../local/drift/app_database.dart';

// Row -> entity mapping shared by the repositories that read these tables
// (a join in one repository must map rows exactly like the other does).

Task taskFromRow(TaskRow row) => Task(
      id: row.id,
      title: row.title,
      notes: row.notes,
      priority: row.priority,
      status: row.status,
      scheduleBlockId: row.scheduleBlockId,
      dueAt: row.dueAt,
      createdAt: row.createdAt,
    );

ScheduleBlock blockFromRow(ScheduleBlockRow row) => ScheduleBlock(
      id: row.id,
      title: row.title,
      startTime: row.startTime,
      endTime: row.endTime,
      source: row.source,
      isLocked: row.isLocked,
    );
