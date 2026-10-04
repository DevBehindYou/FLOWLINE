import 'package:atomic_assist/l10n/app_localizations_en.dart';
import 'package:atomic_assist/l10n/l10n.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUpAll(() => initializeDateFormatting());

  // Only English ships so far; the formats read localeName, so other
  // languages are simulated with the English strings and another locale.
  final en = lookupAppLocalizations(const Locale('en'));

  test('weekday labels are one letter per day in English', () {
    final week = [for (var d = 9; d < 16; d++) DateTime(2026, 3, d)];
    expect(week.map(en.weekdayNarrow).join(), 'MTWTFSS');
  });

  test('weekday labels tell the seven days apart in Chinese (B19)', () {
    // The old label was the first character of the short name, which in
    // zh is "周" for every day ("周一", "周二", ...).
    final zh = AppLocalizationsEn('zh');
    final labels = {
      for (var d = 9; d < 16; d++) zh.weekdayNarrow(DateTime(2026, 3, d)),
    };
    expect(labels, hasLength(7));
  });

  test('times follow the locale', () {
    expect(en.time(DateTime(2026, 3, 10, 17)), '5:00 PM');
  });
}
