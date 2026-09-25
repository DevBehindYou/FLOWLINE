import '../entities/schedule_block.dart';

/// Pure, framework-free overlap detection — no Flutter, no Drift, no
/// Riverpod. Used both to gate saving a new/edited block and to flag
/// already-saved overlaps ("Save anyway") on the Today timeline, so the
/// two call sites can't quietly disagree about what "conflicting" means.
class ScheduleConflictChecker {
  const ScheduleConflictChecker();

  /// Blocks from [existingBlocks] whose time range overlaps
  /// [startTime]..[endTime]. Pass [excludeBlockId] when checking an edit
  /// so a block doesn't conflict with its own pre-edit self.
  List<ScheduleBlock> findConflicts({
    required DateTime startTime,
    required DateTime endTime,
    required List<ScheduleBlock> existingBlocks,
    int? excludeBlockId,
  }) {
    return existingBlocks.where((block) {
      if (block.id == excludeBlockId) return false;
      return startTime.isBefore(block.endTime) &&
          endTime.isAfter(block.startTime);
    }).toList();
  }

  /// The id of every block in [blocks] that overlaps at least one other
  /// block in the same list — for flagging existing conflicts (ones the
  /// user chose "Save anyway" on) rather than checking a pending one.
  Set<int> findConflictingBlockIds(List<ScheduleBlock> blocks) {
    final conflictingIds = <int>{};
    for (final block in blocks) {
      final conflicts = findConflicts(
        startTime: block.startTime,
        endTime: block.endTime,
        existingBlocks: blocks,
        excludeBlockId: block.id,
      );
      if (conflicts.isNotEmpty) {
        conflictingIds.add(block.id);
        conflictingIds.addAll(conflicts.map((c) => c.id));
      }
    }
    return conflictingIds;
  }
}
