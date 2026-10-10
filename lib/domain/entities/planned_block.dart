import 'schedule_block.dart';
import 'task.dart';

/// A schedule block with the tasks placed in it, as the Today timeline
/// shows them. Read in one query for the whole day (B21).
class PlannedBlock {
  const PlannedBlock({required this.block, required this.tasks});

  final ScheduleBlock block;

  /// In creation order.
  final List<Task> tasks;
}
