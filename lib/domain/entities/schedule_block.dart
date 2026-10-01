import '../recurrence/recurrence_rule.dart';

enum ScheduleBlockSource { local, aiGenerated, externalCalendar }

class ScheduleBlock {
  const ScheduleBlock({
    required this.id,
    required this.title,
    required this.startTime,
    required this.endTime,
    this.source = ScheduleBlockSource.local,
    this.isLocked = false,
    this.recurrence,
    this.recurrenceUntil,
    this.seriesId,
    this.occurrenceDate,
  });

  final int id;
  final String title;
  final DateTime startTime;
  final DateTime endTime;
  final ScheduleBlockSource source;
  final bool isLocked;

  /// Set on a series (the stored template, never shown itself) and copied
  /// onto each of its computed occurrences.
  final RecurrenceRule? recurrence;

  /// Last day a series occurs on, or null for no end.
  final DateTime? recurrenceUntil;

  /// The series an occurrence belongs to, computed or stored.
  final int? seriesId;

  /// The day an occurrence stands for in its series.
  final DateTime? occurrenceDate;

  /// One day of a recurring series, computed or stored.
  bool get isOccurrence => seriesId != null;

  /// A computed occurrence: no row of its own yet, so its [id] is a
  /// negative stand-in (see occurrenceId). Store it before attaching tasks
  /// or editing it alone (ScheduleRepository.storeOccurrence).
  bool get isComputedOccurrence => id < 0;

  Duration get duration => endTime.difference(startTime);

  ScheduleBlock copyWith({
    String? title,
    DateTime? startTime,
    DateTime? endTime,
    ScheduleBlockSource? source,
    bool? isLocked,
    RecurrenceRule? recurrence,
  }) {
    return ScheduleBlock(
      id: id,
      title: title ?? this.title,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      source: source ?? this.source,
      isLocked: isLocked ?? this.isLocked,
      recurrence: recurrence ?? this.recurrence,
      recurrenceUntil: recurrenceUntil,
      seriesId: seriesId,
      occurrenceDate: occurrenceDate,
    );
  }
}
