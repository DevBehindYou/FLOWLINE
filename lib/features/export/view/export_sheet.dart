import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/export_format.dart';
import '../../../core/async/run_action.dart';
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

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.l10n.exportThisWeek,
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 4),
          Text(
            context.l10n.exportDescription,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 20),
          if (isExporting)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
            )
          else ...[
            _ExportOption(
              icon: Icons.picture_as_pdf_outlined,
              label: context.l10n.exportPdf,
              onTap: () => handle(ExportFormat.pdf),
            ),
            _ExportOption(
              icon: Icons.table_chart_outlined,
              label: context.l10n.exportCsv,
              onTap: () => handle(ExportFormat.csv),
            ),
            _ExportOption(
              icon: Icons.code,
              label: context.l10n.exportJson,
              onTap: () => handle(ExportFormat.json),
            ),
          ],
        ],
      ),
    );
  }
}

class _ExportOption extends StatelessWidget {
  const _ExportOption(
      {required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon),
      title: Text(label),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
