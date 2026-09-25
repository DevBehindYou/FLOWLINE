import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

import '../../domain/entities/focus_session.dart';
import '../../domain/services/export_formatter.dart';
import 'weekly_pdf_exporter.dart';

/// Not a Repository — this doesn't read or persist domain data, it takes
/// data the caller already fetched and produces + shares a file as a
/// side effect. Modeled as a plain injectable class (same pattern as
/// `NotificationService`), not an interface with swappable
/// implementations, since there's no realistic second implementation to
/// swap in.
class ExportService {
  const ExportService();

  Future<void> sharePdf(
    List<FocusSession> sessions, {
    required DateTime rangeStart,
    required DateTime rangeEnd,
    required int streak,
  }) async {
    final bytes = await const WeeklyPdfExporter().build(
      rangeStart: rangeStart,
      rangeEnd: rangeEnd,
      sessions: sessions,
      streak: streak,
    );
    await Printing.sharePdf(
      bytes: bytes,
      filename: 'flowline-focus-${_fileStamp(rangeStart, rangeEnd)}.pdf',
    );
  }

  Future<void> shareCsv(
    List<FocusSession> sessions, {
    required DateTime rangeStart,
    required DateTime rangeEnd,
  }) {
    final csv = const ExportFormatter().toCsv(sessions);
    return _shareText(
      content: csv,
      filename: 'flowline-focus-${_fileStamp(rangeStart, rangeEnd)}.csv',
    );
  }

  Future<void> shareJson(
    List<FocusSession> sessions, {
    required DateTime rangeStart,
    required DateTime rangeEnd,
  }) {
    final json = const ExportFormatter().toJson(sessions, rangeStart: rangeStart, rangeEnd: rangeEnd);
    return _shareText(
      content: json,
      filename: 'flowline-focus-${_fileStamp(rangeStart, rangeEnd)}.json',
    );
  }

  Future<void> _shareText({required String content, required String filename}) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$filename');
    await file.writeAsString(content);
    await SharePlus.instance.share(
      ShareParams(files: [XFile(file.path)], subject: 'Flowline export'),
    );
  }

  String _fileStamp(DateTime start, DateTime end) {
    String pad(DateTime d) =>
        '${d.year}${d.month.toString().padLeft(2, '0')}${d.day.toString().padLeft(2, '0')}';
    return '${pad(start)}-${pad(end)}';
  }
}
