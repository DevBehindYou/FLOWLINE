import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/ai_provider_config.dart';
import '../../ai_assistant/viewmodel/assistant_view_model.dart';
import 'add_edit_ai_provider_sheet.dart';

class AiProvidersScreen extends ConsumerWidget {
  const AiProvidersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final providersAsync = ref.watch(aiProvidersProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('AI Providers')),
      body: providersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Something went wrong: $error')),
        data: (providers) => ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: providers.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) => _ProviderCard(config: providers[index]),
        ),
      ),
    );
  }
}

class _ProviderCard extends ConsumerWidget {
  const _ProviderCard({required this.config});

  final AIProviderConfig config;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOllama = config.id == AIProviderId.ollama;
    final hasKeyAsync = ref.watch(providerHasKeyProvider(config.id));
    final canActivate = isOllama || hasKeyAsync.valueOrNull == true;

    final String subtitle;
    if (isOllama) {
      subtitle = '${config.baseUrl ?? 'http://localhost:11434'} \u2022 ${config.defaultModel}';
    } else {
      subtitle = hasKeyAsync.when(
        data: (hasKey) => hasKey ? 'Connected \u2022 ${config.defaultModel}' : 'Not connected',
        loading: () => '\u2026',
        error: (_, __) => 'Unknown',
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: [
            Radio<bool>(
              value: true,
              groupValue: config.isActive ? true : null,
              onChanged: canActivate
                  ? (_) => ref.read(aiProvidersViewModelProvider.notifier).setActive(config.id)
                  : null,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(config.displayName, style: Theme.of(context).textTheme.titleMedium),
                  Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Edit',
              onPressed: () => showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (_) => AddEditAiProviderSheet(config: config),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
