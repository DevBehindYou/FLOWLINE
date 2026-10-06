import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../design/atomic.dart';
import '../../../domain/entities/ai_provider_config.dart';
import '../../../shared_widgets/error_view.dart';
import '../../ai_assistant/viewmodel/assistant_view_model.dart';
import '../viewmodel/ai_providers_view_model.dart';
import 'add_edit_ai_provider_sheet.dart';
import '../../../l10n/l10n.dart';

class AiProvidersScreen extends ConsumerWidget {
  const AiProvidersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final providersAsync = ref.watch(aiProvidersProvider);

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.settingsAiProviders)),
      body: providersAsync.when(
        loading: () => AtomicLoading(label: context.l10n.loadingProviders),
        error: (error, _) => ErrorView(
          error: error,
          onRetry: () => ref.invalidate(aiProvidersProvider),
        ),
        data: (providers) => RadioGroup<AIProviderId>(
          groupValue: providers.where((p) => p.isActive).firstOrNull?.id,
          onChanged: (id) {
            if (id == null) return;
            unawaited(
                ref.read(aiProvidersViewModelProvider.notifier).setActive(id));
          },
          child: ListView.separated(
            padding: const EdgeInsets.all(AtomicSpace.screenMargin),
            itemCount: providers.length,
            separatorBuilder: (_, __) => const SizedBox(height: AtomicSpace.s),
            itemBuilder: (context, index) =>
                _ProviderCard(config: providers[index]),
          ),
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
    final canActivate = isOllama || hasKeyAsync.value == true;

    final String subtitle;
    if (isOllama) {
      subtitle =
          '${config.baseUrl ?? 'http://localhost:11434'} \u2022 ${config.defaultModel}';
    } else {
      subtitle = hasKeyAsync.when(
        data: (hasKey) => hasKey
            ? context.l10n.providerConnected(config.defaultModel)
            : context.l10n.providerNotConnected,
        loading: () => '\u2026',
        error: (_, __) => context.l10n.providerStatusUnknown,
      );
    }

    // The active provider is the selected card (2 dp Signal border).
    final isActive = config.isActive;
    return AtomicCard(
      kind: isActive ? AtomicCardKind.selected : AtomicCardKind.content,
      padding: const EdgeInsets.symmetric(
          horizontal: AtomicSpace.xxs, vertical: AtomicSpace.xxs),
      child: Row(
        children: [
          Radio<AIProviderId>(value: config.id, enabled: canActivate),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AtomicText.display(config.displayName,
                    style: AtomicType.rowTitle),
                AtomicText.mono(subtitle, style: AtomicType.caption),
              ],
            ),
          ),
          AtomicIconButton(
            icon: AtomicIcons.edit,
            semanticLabel: context.l10n.edit,
            onPressed: () => showModalBottomSheet<void>(
              context: context,
              isScrollControlled: true,
              builder: (_) => AddEditAiProviderSheet(config: config),
            ),
          ),
        ],
      ),
    );
  }
}
