import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:atomic_assist/data/export/weekly_pdf_exporter.dart';
import 'package:atomic_assist/domain/entities/focus_session.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pdf/widgets.dart' as pw;

FocusSession _session(int id, DateTime completedAt, {bool early = false}) =>
    FocusSession(
      id: id,
      sessionType: FocusSessionType.focus,
      plannedDurationSec: 1500,
      startedAt: completedAt.subtract(const Duration(minutes: 25)),
      segmentStartedAt: null,
      remainingSecAtSegmentStart: 0,
      isPaused: false,
      completedAt: completedAt,
      actualDurationSec: early ? 600 : 1500,
      endedEarly: early,
    );

void main() {
  final rangeStart = DateTime(2026, 3, 4);
  final rangeEnd = DateTime(2026, 3, 11);

  // The same files the app bundles (pubspec.yaml `fonts:`).
  pw.Font font(String file) => pw.Font.ttf(
      ByteData.sublistView(File('assets/fonts/$file').readAsBytesSync()));
  final fonts = PdfFonts(
    regular: font('HankenGrotesk-Regular.ttf'),
    bold: font('HankenGrotesk-Bold.ttf'),
  );

  Future<List<int>> build(List<FocusSession> sessions) =>
      const WeeklyPdfExporter().build(
        rangeStart: rangeStart,
        rangeEnd: rangeEnd,
        sessions: sessions,
        streak: 3,
        fonts: fonts,
      );

  test('builds a valid PDF for a week with sessions', () async {
    final bytes = await build([
      _session(1, DateTime(2026, 3, 9, 10)),
      _session(2, DateTime(2026, 3, 10, 15), early: true),
    ]);
    expect(latin1.decode(bytes.take(5).toList()), '%PDF-');
    expect(bytes.length, greaterThan(1000));
  });

  test('builds a valid PDF for an empty week', () async {
    final bytes = await build(const []);
    expect(latin1.decode(bytes.take(5).toList()), '%PDF-');
  });

  test('every character has a glyph in the embedded font (B25)', () async {
    // The pdf package reports a missing glyph, or a fallback to the
    // Latin-1-only Helvetica, with print() (in debug builds). The document
    // uses an em dash, an en dash and, for an unfinished session, "—".
    final logged = <String>[];
    final running = FocusSession(
      id: 3,
      sessionType: FocusSessionType.focus,
      plannedDurationSec: 1500,
      startedAt: DateTime(2026, 3, 10, 9),
      segmentStartedAt: DateTime(2026, 3, 10, 9),
      remainingSecAtSegmentStart: 1500,
      isPaused: false,
      completedAt: null,
      actualDurationSec: null,
      endedEarly: false,
    );
    await runZoned(
      () => build([_session(1, DateTime(2026, 3, 9, 10)), running]),
      zoneSpecification: ZoneSpecification(
        print: (self, parent, zone, line) => logged.add(line),
      ),
    );
    expect(
        logged.where((m) =>
            m.contains('Unable to find a font') ||
            m.contains('has no Unicode support')),
        isEmpty,
        reason: logged.join('\n'));
  });
}
