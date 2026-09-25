import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../domain/entities/focus_session.dart';
import '../../domain/services/focus_stats_calculator.dart';

/// Builds the PDF bytes for a weekly focus summary. Kept out of
/// `domain/` deliberately — unlike `ExportFormatter`'s CSV/JSON text
/// output, this depends directly on the `pdf` package's widget API, so
/// it belongs with the other data-layer, package-specific concerns
/// rather than pretending to be framework-free.
class WeeklyPdfExporter {
  const WeeklyPdfExporter();

  Future<Uint8List> build({
    required DateTime rangeStart,
    required DateTime rangeEnd,
    required List<FocusSession> sessions,
    required int streak,
  }) async {
    final doc = pw.Document();
    final dailyTotals = const FocusStatsCalculator().dailyTotals(sessions, days: 7);
    final weekTotalSeconds = dailyTotals.fold<int>(0, (sum, d) => sum + d.totalSeconds);
    final weekSessionCount = dailyTotals.fold<int>(0, (sum, d) => sum + d.sessionCount);
    final focusSessions = sessions.where((s) => s.sessionType == FocusSessionType.focus).toList()
      ..sort((a, b) => a.startedAt.compareTo(b.startedAt));

    doc.addPage(
      pw.Page(
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'Flowline \u2014 Weekly Focus Summary',
              style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 4),
            pw.Text('${_fmtDate(rangeStart)} \u2013 ${_fmtDate(rangeEnd)}'),
            pw.SizedBox(height: 16),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                _statBlock('Total Focus', _fmtDuration(weekTotalSeconds)),
                _statBlock('Sessions', '$weekSessionCount'),
                _statBlock('Day Streak', '$streak'),
              ],
            ),
            pw.SizedBox(height: 20),
            pw.Text('Daily Breakdown', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 8),
            pw.TableHelper.fromTextArray(
              headers: ['Date', 'Focus Time', 'Sessions'],
              data: [
                for (final day in dailyTotals)
                  [_fmtDate(day.date), _fmtDuration(day.totalSeconds), '${day.sessionCount}'],
              ],
            ),
            pw.SizedBox(height: 20),
            pw.Text('Session Log', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 8),
            if (focusSessions.isEmpty)
              pw.Text('No focus sessions logged this week.', style: const pw.TextStyle(fontSize: 10))
            else
              pw.TableHelper.fromTextArray(
                headers: ['Date', 'Time', 'Planned', 'Actual', 'Status'],
                data: [
                  for (final session in focusSessions)
                    [
                      _fmtDate(session.startedAt),
                      _fmtTime(session.startedAt),
                      '${(session.plannedDurationSec / 60).round()}m',
                      session.actualDurationSec == null
                          ? '\u2014'
                          : '${(session.actualDurationSec! / 60).round()}m',
                      session.completedAt == null
                          ? 'In progress'
                          : (session.endedEarly ? 'Ended early' : 'Completed'),
                    ],
                ],
              ),
            pw.SizedBox(height: 20),
            pw.Text(
              'Generated on-device by Flowline. Nothing is sent anywhere to produce this file.',
              style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
            ),
          ],
        ),
      ),
    );

    return doc.save();
  }

  pw.Widget _statBlock(String label, String value) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(value, style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
        pw.Text(label, style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
      ],
    );
  }

  String _fmtDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  String _fmtTime(DateTime d) =>
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

  String _fmtDuration(int totalSeconds) {
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    return hours > 0 ? '${hours}h ${minutes}m' : '${minutes}m';
  }
}
