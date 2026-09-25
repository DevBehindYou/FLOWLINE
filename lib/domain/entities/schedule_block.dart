enum ScheduleBlockSource { local, aiGenerated, externalCalendar }

class ScheduleBlock {
  const ScheduleBlock({
    required this.id,
    required this.title,
    required this.startTime,
    required this.endTime,
    this.source = ScheduleBlockSource.local,
    this.isLocked = false,
  });

  final int id;
  final String title;
  final DateTime startTime;
  final DateTime endTime;
  final ScheduleBlockSource source;
  final bool isLocked;

  Duration get duration => endTime.difference(startTime);

  ScheduleBlock copyWith({
    String? title,
    DateTime? startTime,
    DateTime? endTime,
  }) {
    return ScheduleBlock(
      id: id,
      title: title ?? this.title,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      source: source,
      isLocked: isLocked,
    );
  }
}
