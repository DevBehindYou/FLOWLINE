import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Static rules from `docs/04-build-and-optimization-plan.md` §2 that a
/// grep can enforce. They run with the normal test suite, so CI and any
/// local `flutter test` catch a regression without extra tooling.
void main() {
  final sources = Directory('lib')
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart') && !f.path.endsWith('.g.dart'))
      .toList();

  List<String> offenders(RegExp pattern, {Set<String> allow = const {}}) {
    final hits = <String>[];
    for (final file in sources) {
      final path = file.path.replaceAll(r'\', '/');
      if (allow.contains(path)) continue;
      final lines = file.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        final line = lines[i].trimLeft();
        if (line.startsWith('//')) continue; // comments may name the rule
        if (pattern.hasMatch(line)) hits.add('$path:${i + 1}: $line');
      }
    }
    return hits;
  }

  test('R8: lib/ reads the time through package:clock, never DateTime.now()',
      () {
    expect(offenders(RegExp(r'DateTime\.now\(\)')), isEmpty,
        reason: 'Use clock.now() (or today()/currentDayProvider) so tests can '
            'control time.');
  });

  test('R7: no Duration(days:) for calendar math in lib/', () {
    expect(offenders(RegExp(r'Duration\(\s*days\s*:')), isEmpty,
        reason: 'Use addDays()/startOfDay() from '
            'lib/domain/time/calendar_day.dart; a local day is 23 or 25 '
            'hours long on a DST change.');
  });

  test('domain/ stays framework-free (no Flutter, Drift or Riverpod)', () {
    final domain = sources
        .where((f) => f.path.replaceAll(r'\', '/').startsWith('lib/domain/'));
    final banned = RegExp(
        r'''import\s+'package:(flutter|drift|riverpod|flutter_riverpod|riverpod_annotation)[/:]''');
    final hits = [
      for (final f in domain)
        for (final line in f.readAsLinesSync())
          if (banned.hasMatch(line)) '${f.path}: $line',
    ];
    expect(hits, isEmpty);
  });
}
