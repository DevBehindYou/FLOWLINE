/// How a schedule block repeats: on a set of weekdays, every week. Stored
/// as an RRULE subset (RFC 5545) so a later calendar sync can map it:
/// `FREQ=DAILY` or `FREQ=WEEKLY;BYDAY=MO,WE,FR`. Anything else is not a
/// rule this app understands, and [tryParse] returns null for it.
class RecurrenceRule {
  RecurrenceRule(Iterable<int> weekdays)
      : weekdays = Set.unmodifiable(weekdays.where(_isWeekday)) {
    if (this.weekdays.isEmpty) {
      throw ArgumentError.value(weekdays, 'weekdays', 'pick at least one day');
    }
  }

  RecurrenceRule.daily() : this(_allDays);

  /// Monday to Friday.
  RecurrenceRule.weekdays() : this(_workDays);

  /// [DateTime.monday] .. [DateTime.sunday].
  final Set<int> weekdays;

  bool get isDaily => weekdays.length == 7;
  bool get isWeekdays =>
      weekdays.length == 5 && _workDays.every(weekdays.contains);

  bool occursOnWeekday(int weekday) => weekdays.contains(weekday);

  static const _allDays = [1, 2, 3, 4, 5, 6, 7];
  static const _workDays = [1, 2, 3, 4, 5];
  static const _codes = ['MO', 'TU', 'WE', 'TH', 'FR', 'SA', 'SU'];

  static bool _isWeekday(int d) => d >= DateTime.monday && d <= DateTime.sunday;

  String format() {
    if (isDaily) return 'FREQ=DAILY';
    final days = (weekdays.toList()..sort()).map((d) => _codes[d - 1]);
    return 'FREQ=WEEKLY;BYDAY=${days.join(',')}';
  }

  /// Null for null, empty or anything outside the supported subset, so a
  /// row written by a newer version never breaks reading the day.
  static RecurrenceRule? tryParse(String? text) {
    if (text == null) return null;
    final parts = <String, String>{};
    for (final part in text.toUpperCase().split(';')) {
      final kv = part.split('=');
      if (kv.length != 2) return null;
      parts[kv[0].trim()] = kv[1].trim();
    }
    switch (parts['FREQ']) {
      case 'DAILY' when parts.length == 1:
        return RecurrenceRule.daily();
      case 'WEEKLY' when parts.length == 2 && parts.containsKey('BYDAY'):
        final days = <int>[];
        for (final code in parts['BYDAY']!.split(',')) {
          final index = _codes.indexOf(code.trim());
          if (index < 0) return null;
          days.add(index + 1);
        }
        return days.isEmpty ? null : RecurrenceRule(days);
      default:
        return null;
    }
  }

  @override
  bool operator ==(Object other) =>
      other is RecurrenceRule &&
      other.weekdays.length == weekdays.length &&
      other.weekdays.containsAll(weekdays);

  @override
  int get hashCode => Object.hashAllUnordered(weekdays);
}
