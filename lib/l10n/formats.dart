import 'package:intl/intl.dart';

import 'app_localizations.dart';

/// Locale-aware date and time formats. Skeletons (not fixed patterns), so
/// each language gets its own order and punctuation; widgets never build a
/// DateFormat themselves.
extension L10nFormats on AppLocalizations {
  /// "Tuesday, March 10".
  String dayLong(DateTime d) => DateFormat.MMMMEEEEd(localeName).format(d);

  /// "Tue, Mar 10".
  String dayShort(DateTime d) => DateFormat.MMMEd(localeName).format(d);

  /// "Mar 10".
  String monthDay(DateTime d) => DateFormat.MMMd(localeName).format(d);

  /// "5:00 PM" (or "17:00" where the locale uses 24-hour time).
  String time(DateTime d) => DateFormat.jm(localeName).format(d);

  /// The one-letter weekday ("T"), from the locale's own narrow form.
  /// Cutting the first character of the short name split characters in
  /// scripts like Devanagari and gave two identical "T"s wrongly (B19).
  String weekdayNarrow(DateTime d) => DateFormat.EEEEE(localeName).format(d);
}
