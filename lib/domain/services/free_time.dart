import '../entities/schedule_block.dart';

typedef TimeSlot = ({DateTime start, DateTime end});

/// Gaps of at least [minutes] between [from] and [to] that no block
/// covers, earliest first, at most [limit]. Locked blocks count as busy
/// like any other. Touching blocks leave no gap between them.
List<TimeSlot> findFreeSlots({
  required List<ScheduleBlock> blocks,
  required DateTime from,
  required DateTime to,
  required int minutes,
  int limit = 5,
}) {
  if (!to.isAfter(from) || minutes <= 0) return const [];
  final busy = [
    for (final b in blocks)
      if (b.endTime.isAfter(from) && b.startTime.isBefore(to))
        (
          start: b.startTime.isBefore(from) ? from : b.startTime,
          end: b.endTime.isAfter(to) ? to : b.endTime,
        ),
  ]..sort((a, b) => a.start.compareTo(b.start));

  final slots = <TimeSlot>[];
  var cursor = from;
  void gapUntil(DateTime end) {
    if (end.difference(cursor).inMinutes >= minutes && slots.length < limit) {
      slots.add((start: cursor, end: end));
    }
  }

  for (final b in busy) {
    if (b.start.isAfter(cursor)) gapUntil(b.start);
    if (b.end.isAfter(cursor)) cursor = b.end;
  }
  gapUntil(to);
  return slots;
}
