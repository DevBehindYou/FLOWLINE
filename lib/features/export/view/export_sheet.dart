import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/export_format.dart';
import '../../../core/async/run_action.dart';
import '../../../design/atomic.dart';
import '../viewmodel/export_view_model.dart';
import '../../../l10n/l10n.dart';

class ExportSheet extends ConsumerWidget {
  const ExportSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isExporting = ref.watch(exportViewModelProvider);
    final viewModel = ref.read(exportViewModelProvider.notifier);

    Future<void> handle(ExportFormat format) async {
      if (isExporting) return;
      final done = await runAction(
        context,
        () async {
          await viewModel.export(format);
          return true;
        },
        failureMessage: context.l10n.exportFailed,
      );
      if (done == true && context.mounted) Navigator.of(context).pop();
    }

    return AtomicSheetFrame(
      label: context.l10n.exportThisWeek,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AtomicText.body(context.l10n.exportDescription),
          const SizedBox(height: AtomicSpace.m),
          if (isExporting)
            AtomicLoading(label: context.l10n.exporting, compact: true)
          else ...[
            AtomicSettingsRow(
              leading: AtomicIcons.pdf,
              title: context.l10n.exportPdf,
              onTap: () => handle(ExportFormat.pdf),
            ),
            AtomicSettingsRow(
              leading: AtomicIcons.table,
              title: context.l10n.exportCsv,
              onTap: () => handle(ExportFormat.csv),
            ),
            AtomicSettingsRow(
              leading: AtomicIcons.code,
              title: context.l10n.exportJson,
              divider: false,
              onTap: () => handle(ExportFormat.json),
            ),
          ],
        ],
      ),
    );
  }
}
