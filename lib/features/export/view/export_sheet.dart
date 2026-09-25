import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/export_format.dart';
import '../viewmodel/export_view_model.dart';

class ExportSheet extends ConsumerWidget {
  const ExportSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isExporting = ref.watch(exportViewModelProvider);
    final viewModel = ref.read(exportViewModelProvider.notifier);

    Future<void> handle(ExportFormat format) async {
      await viewModel.export(format);
      if (context.mounted) Navigator.of(context).pop();
    }

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Export this week', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 4),
          Text(
            'Focus session history for the last 7 days, generated on-device \u2014 '
            'nothing is sent anywhere to produce it.',
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
              label: 'PDF summary',
              onTap: () => handle(ExportFormat.pdf),
            ),
            _ExportOption(
              icon: Icons.table_chart_outlined,
              label: 'CSV (spreadsheet)',
              onTap: () => handle(ExportFormat.csv),
            ),
            _ExportOption(
              icon: Icons.code,
              label: 'JSON (raw data)',
              onTap: () => handle(ExportFormat.json),
            ),
          ],
        ],
      ),
    );
  }
}

class _ExportOption extends StatelessWidget {
  const _ExportOption({required this.icon, required this.label, required this.onTap});

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
