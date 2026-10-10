import '../time/calendar_day.dart';

// Times and days people say (docs/05 §9.8), in English and the Hinglish
// that is common in India. Pure Dart; "now" is always passed in (R8), and
// day arithmetic goes through addDays, so DST never shifts a day (R7).

/// When something should happen.
sealed class TimePhrase {
  const TimePhrase();
}

/// A moment: "at 7", "in 20 minutes", "tomorrow morning".
final class AtInstant extends TimePhrase {
  const AtInstant(this.at);
  final DateTime at;

  @override
  bool operator ==(Object other) => other is AtInstant && other.at == at;
  @override
  int get hashCode => at.hashCode;
  @override
  String toString() => 'AtInstant($at)';
}

/// A day without a time: "on Friday", "tomorrow", "kal".
final class OnDay extends TimePhrase {
  const OnDay(this.day);

  /// Local midnight of the day.
  final DateTime day;

  @override
  bool operator ==(Object other) => other is OnDay && other.day == day;
  @override
  int get hashCode => day.hashCode;
  @override
  String toString() => 'OnDay($day)';
}

/// Hours that the parts of the day mean (Settings may change them).
final class DayParts {
  const DayParts({
    this.morning = 9,
    this.afternoon = 14,
    this.evening = 18,
    this.night = 20,
  });
  final int morning;
  final int afternoon;
  final int evening;
  final int night;
}

/// A [TimePhrase] and where it was in the text, so a caller can take it
/// out ("remind me to call Mum at 7" → title "call Mum").
final class TimePhraseMatch {
  const TimePhraseMatch(this.value, this.spans);
  final TimePhrase value;

  /// The matched pieces, as `[start, end)` ranges in the original text.
  final List<(int, int)> spans;

  /// [text] with the matched pieces removed and whitespace tidied.
  String strip(String text) {
    final sorted = [...spans]..sort((a, b) => b.$1.compareTo(a.$1));
    var out = text;
    for (final (s, e) in sorted) {
      out = out.replaceRange(s, e, ' ');
    }
    return out.replaceAll(RegExp(r'\s+'), ' ').trim();
  }
}

const _weekdays = {
  'monday': DateTime.monday,
  'mon': DateTime.monday,
  'tuesday': DateTime.tuesday,
  'tue': DateTime.tuesday,
  'tues': DateTime.tuesday,
  'wednesday': DateTime.wednesday,
  'wed': DateTime.wednesday,
  'thursday': DateTime.thursday,
  'thu': DateTime.thursday,
  'thurs': DateTime.thursday,
  'friday': DateTime.friday,
  'fri': DateTime.friday,
  'saturday': DateTime.saturday,
  'sat': DateTime.saturday,
  'sunday': DateTime.sunday,
  'sun': DateTime.sunday,
};

const _months = {
  'jan': 1,
  'feb': 2,
  'mar': 3,
  'apr': 4,
  'may': 5,
  'jun': 6,
  'jul': 7,
  'aug': 8,
  'sep': 9,
  'oct': 10,
  'nov': 11,
  'dec': 12,
};

const _numberWords = {
  'a': 1,
  'an': 1,
  'one': 1,
  'two': 2,
  'three': 3,
  'four': 4,
  'five': 5,
  'ten': 10,
  'fifteen': 15,
  'twenty': 20,
  'thirty': 30,
  'forty five': 45,
};

final _weekdayNames = _weekdays.keys.join('|');
final _monthNames = _months.keys.map((m) => '$m[a-z]*').join('|');
final _numberWordAlt = _numberWords.keys.join('|');

// Each pattern matches one component. Word boundaries keep "monday" out
// of "mondays" and "at 7" out of "at 75".
final _iso = RegExp(r'\b(\d{4})-(\d{2})-(\d{2})\b');
final _dayMonth =
    RegExp('\\b(?:on\\s+)?(\\d{1,2})(?:st|nd|rd|th)?\\s+($_monthNames)\\b');
final _monthDay =
    RegExp('\\b(?:on\\s+)?($_monthNames)\\s+(\\d{1,2})(?:st|nd|rd|th)?\\b');
// Digits may take a one-letter unit ("20m", "2h"); number words need the
// whole unit word, or "8 am" would read as "a m(inute)".
final _relative = RegExp(
    '\\b(?:in\\s+)?(?:(\\d+)\\s*(minutes?|mins?|m|hours?|hrs?|h|ghante|ghanta)'
    '|($_numberWordAlt|half an?)\\s+(minutes?|mins?|hours?|hrs?|ghante|ghanta))'
    '(?:\\s+(?:baad|mein|me|later))?\\b');
final _inPrefix = RegExp(r'\bin\s+$');
final _dayWord =
    RegExp(r'\b(today|aaj|tonight|tomorrow|tmrw|tmr|kal|parso|parson|'
        r'day after tomorrow)\b');
final _weekday =
    RegExp('\\b(?:(?:on|this|next|coming)\\s+)?($_weekdayNames)\\b');
final _partOfDay =
    RegExp(r'\b(?:in the\s+|this\s+)?(morning|subah|afternoon|dopahar|evening|'
        r'shaam|sham|night|raat)\b');
final _clock = RegExp(r'\b(?:at\s+|@\s*)?(\d{1,2})(?::|\.)(\d{2})\s*'
    r'(am|pm|a\.m\.|p\.m\.)?(?!\d)');
final _hourMeridiem =
    RegExp(r'\b(?:at\s+|@\s*)?(\d{1,2})\s*(am|pm|a\.m\.|p\.m\.)');
final _atHour = RegExp(r'(?:\bat|@)\s*(\d{1,2})\b(?![:.]\d)');
final _bajeHour = RegExp(r'\b(\d{1,2})\s*baje\b');
final _noon = RegExp(r'\b(noon|midday|midnight)\b');

/// Finds the time phrase in [text] relative to [now], or null. Never
/// returns a past moment: an hour already gone today means tomorrow.
TimePhraseMatch? findTimePhrase(
  String text, {
  required DateTime now,
  DayParts parts = const DayParts(),
}) {
  final t = text.toLowerCase();
  final spans = <(int, int)>[];

  // 1. Relative: "in 20 minutes", "2 ghante baad". Exact; nothing else
  //    combines with it.
  final rel = _relative.firstMatch(t);
  if (rel != null) {
    final amount = _amount(rel.group(1) ?? rel.group(3)!);
    final unit = rel.group(2) ?? rel.group(4)!;
    // "m"/"h" alone only count right after a number ("20m", "2h").
    final isMinutes = unit.startsWith('m');
    final minutes = (amount * (isMinutes ? 1 : 60)).round();
    var start = rel.start;
    final before = t.substring(0, start);
    final inMatch = _inPrefix.firstMatch(before);
    if (inMatch != null) start = inMatch.start;
    if (minutes > 0) {
      return TimePhraseMatch(
          AtInstant(now.add(Duration(minutes: minutes))), [(start, rel.end)]);
    }
  }

  // 2. The day.
  DateTime? day;
  var dayIsExplicit = false;
  String? dayWord;
  final iso = _iso.firstMatch(t);
  final dm = _dayMonth.firstMatch(t);
  final md = _monthDay.firstMatch(t);
  final dw = _dayWord.firstMatch(t);
  final wd = _weekday.firstMatch(t);
  if (iso != null) {
    day = DateTime(int.parse(iso.group(1)!), int.parse(iso.group(2)!),
        int.parse(iso.group(3)!));
    spans.add((iso.start, iso.end));
  } else if (dm != null || md != null) {
    final m = (dm ?? md)!;
    final dayNum = int.parse(dm != null ? m.group(1)! : m.group(2)!);
    final monthName = (dm != null ? m.group(2)! : m.group(1)!).substring(0, 3);
    final month = _months[monthName]!;
    var candidate = DateTime(now.year, month, dayNum);
    if (candidate.isBefore(startOfDay(now))) {
      candidate = DateTime(now.year + 1, month, dayNum);
    }
    day = candidate;
    spans.add((m.start, m.end));
  } else if (dw != null) {
    dayWord = dw.group(1)!;
    day = switch (dayWord) {
      'today' || 'aaj' || 'tonight' => startOfDay(now),
      'parso' || 'parson' || 'day after tomorrow' => addDays(now, 2),
      _ => addDays(now, 1), // tomorrow, tmrw, tmr, kal (future intent)
    };
    spans.add((dw.start, dw.end));
  } else if (wd != null) {
    final target = _weekdays[wd.group(1)!]!;
    // The next such day after today; today's own weekday means next week.
    var ahead = (target - now.weekday) % 7;
    if (ahead == 0) ahead = 7;
    day = addDays(now, ahead);
    spans.add((wd.start, wd.end));
  }
  if (day != null) dayIsExplicit = true;

  // 3. The time of day.
  int? hour;
  var minute = 0;
  var meridiemKnown = false;
  final clock = _clock.firstMatch(t);
  final hm = _hourMeridiem.firstMatch(t);
  final noon = _noon.firstMatch(t);
  final atHour = _atHour.firstMatch(t);
  final baje = _bajeHour.firstMatch(t);
  if (clock != null) {
    hour = int.parse(clock.group(1)!);
    minute = int.parse(clock.group(2)!);
    final mer = clock.group(3);
    if (mer != null) {
      hour = _withMeridiem(hour, mer);
      meridiemKnown = true;
    } else if (hour > 12 || clock.group(1)!.length == 2 && hour < 10) {
      meridiemKnown = true; // 19:00, 07:30 are 24-hour
    }
    spans.add((clock.start, clock.end));
  } else if (hm != null) {
    hour = _withMeridiem(int.parse(hm.group(1)!), hm.group(2)!);
    meridiemKnown = true;
    spans.add((hm.start, hm.end));
  } else if (noon != null) {
    hour = noon.group(1) == 'midnight' ? 0 : 12;
    meridiemKnown = true;
    spans.add((noon.start, noon.end));
  } else if (atHour != null) {
    hour = int.parse(atHour.group(1)!);
    spans.add((atHour.start, atHour.end));
  } else if (baje != null) {
    hour = int.parse(baje.group(1)!);
    spans.add((baje.start, baje.end));
  }
  if (hour != null && (hour > 23 || minute > 59)) return null;

  // 4. Part of the day: a default hour, or the meaning of a bare hour.
  final part = _partOfDay.firstMatch(t);
  int? partHour;
  var partIsPm = false;
  if (part != null) {
    final p = part.group(1)!;
    (partHour, partIsPm) = switch (p) {
      'morning' || 'subah' => (parts.morning, false),
      'afternoon' || 'dopahar' => (parts.afternoon, true),
      'evening' || 'shaam' || 'sham' => (parts.evening, true),
      _ => (parts.night, true), // night, raat
    };
    spans.add((part.start, part.end));
  }
  if (dayWord == 'tonight') {
    partHour ??= parts.night;
    partIsPm = true;
  }

  if (hour == null && partHour == null) {
    if (day == null) return null;
    return TimePhraseMatch(OnDay(day), spans);
  }

  if (hour == null) {
    hour = partHour;
  } else if (!meridiemKnown && hour <= 12) {
    // A bare hour: the part of the day decides, else the next one that
    // makes sense.
    if (partHour != null) {
      if (partIsPm && hour < 12) hour += 12;
      if (!partIsPm && hour == 12) hour = 0;
    } else if (dayIsExplicit && !isSameDay(day!, now)) {
      // Another day: 7–11 in the morning, 12 noon, 1–6 in the afternoon.
      if (hour >= 1 && hour <= 6) hour += 12;
    } else {
      // Today: the next time the clock shows this hour.
      final amHour = hour == 12 ? 0 : hour;
      final pmHour = hour == 12 ? 12 : hour + 12;
      final am = _at(now, amHour, minute);
      final pm = _at(now, pmHour, minute);
      if (am.isAfter(now)) {
        hour = amHour;
      } else if (pm.isAfter(now)) {
        hour = pmHour;
      } else {
        day = addDays(now, 1);
        hour = amHour;
      }
    }
  }

  var at = _at(day ?? now, hour!, minute);
  if (!dayIsExplicit && !at.isAfter(now)) {
    at = _at(addDays(now, 1), hour, minute);
  }
  // "today at 9" said at 10 stays in the past: the caller validates
  // (a reminder in the past is refused, not silently moved).
  return TimePhraseMatch(AtInstant(at), spans);
}

/// [findTimePhrase] without the spans.
TimePhrase? parseTimePhrase(String text,
        {required DateTime now, DayParts parts = const DayParts()}) =>
    findTimePhrase(text, now: now, parts: parts)?.value;

DateTime _at(DateTime day, int hour, int minute) =>
    DateTime(day.year, day.month, day.day, hour, minute);

int _withMeridiem(int hour, String meridiem) {
  final pm = meridiem.startsWith('p');
  if (hour == 12) return pm ? 12 : 0;
  return pm ? hour + 12 : hour;
}

double _amount(String text) {
  if (text.startsWith('half')) return 0.5;
  return _numberWords[text]?.toDouble() ?? double.parse(text);
}
