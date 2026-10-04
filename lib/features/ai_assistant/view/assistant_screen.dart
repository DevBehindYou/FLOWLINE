import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/entities/ai_provider_config.dart';
import '../../../core/async/run_action.dart';
import '../../../shared_widgets/empty_state.dart';
import '../../../shared_widgets/error_view.dart';
import '../../../shared_widgets/settings_action.dart';
import '../viewmodel/assistant_view_model.dart';
import '../widgets/chat_bubble.dart';
import '../../../l10n/l10n.dart';

class AssistantScreen extends ConsumerWidget {
  const AssistantScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeProviderAsync = ref.watch(activeAiProviderProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.navAssistant),
        actions: [
          IconButton(
            icon: const Icon(Icons.smart_toy_outlined),
            tooltip: context.l10n.settingsAiProviders,
            onPressed: () => context.push('/settings/ai-providers'),
          ),
          const SettingsAction(),
        ],
      ),
      body: activeProviderAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => ErrorView(
          error: error,
          onRetry: () => ref.invalidate(activeAiProviderProvider),
        ),
        data: (provider) {
          if (provider == null) {
            return EmptyState(
              icon: Icons.auto_awesome_outlined,
              title: context.l10n.assistantNoProviderTitle,
              message: context.l10n.assistantNoProviderMessage,
              actionLabel: context.l10n.assistantGoToProviders,
              onAction: () => context.push('/settings/ai-providers'),
            );
          }
          return _ChatBody(provider: provider);
        },
      ),
    );
  }
}

class _ChatBody extends ConsumerStatefulWidget {
  const _ChatBody({required this.provider});

  final AIProviderConfig provider;

  @override
  ConsumerState<_ChatBody> createState() => _ChatBodyState();
}

class _ChatBodyState extends ConsumerState<_ChatBody> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _send(int? conversationId) async {
    final text = _controller.text.trim();
    if (text.isEmpty || ref.read(assistantViewModelProvider)) return;
    _controller.clear();
    final sent = await runAction(
      context,
      () async {
        await ref.read(assistantViewModelProvider.notifier).send(
              providerId: widget.provider.id,
              existingConversationId: conversationId,
              prompt: text,
            );
        return true;
      },
      failureMessage: context.l10n.assistantSendFailed,
    );
    // Vendor errors arrive as error bubbles; this is for local failures
    // (e.g. the database write), where the text would otherwise be lost.
    if (sent != true && mounted && _controller.text.isEmpty) {
      _controller.text = text;
    }
  }

  @override
  Widget build(BuildContext context) {
    final conversationAsync =
        ref.watch(latestConversationForProviderProvider(widget.provider.id));
    final isSending = ref.watch(assistantViewModelProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Chip(
              avatar: const Icon(Icons.smart_toy_outlined, size: 16),
              label: Text(
                  '${widget.provider.displayName} \u2022 ${widget.provider.defaultModel}'),
            ),
          ),
        ),
        Expanded(
          child: conversationAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => ErrorView(
              error: error,
              onRetry: () => ref.invalidate(
                  latestConversationForProviderProvider(widget.provider.id)),
            ),
            data: (conversation) {
              if (conversation == null) {
                return EmptyState(
                  icon: Icons.chat_bubble_outline,
                  title: context.l10n.assistantEmptyTitle,
                  message: context.l10n.assistantEmptyMessage,
                );
              }
              return _MessageList(
                  conversationId: conversation.id, provider: widget.provider);
            },
          ),
        ),
        if (isSending) const LinearProgressIndicator(minHeight: 2),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                        hintText: context.l10n.assistantInputHint),
                    minLines: 1,
                    maxLines: 4,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _send(conversationAsync.value?.id),
                  ),
                ),
                const SizedBox(width: 8),
                // Send, or Stop while a reply is on its way (spec §5.9).
                isSending
                    ? IconButton.filledTonal(
                        tooltip: context.l10n.stop,
                        icon: const Icon(Icons.stop),
                        onPressed:
                            ref.read(assistantViewModelProvider.notifier).stop,
                      )
                    : IconButton.filled(
                        tooltip: context.l10n.send,
                        icon: const Icon(Icons.arrow_upward),
                        onPressed: () => _send(conversationAsync.value?.id),
                      ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _MessageList extends ConsumerWidget {
  const _MessageList({required this.conversationId, required this.provider});

  final int conversationId;
  final AIProviderConfig provider;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messagesAsync =
        ref.watch(conversationMessagesProvider(conversationId));

    return messagesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => ErrorView(
        error: error,
        onRetry: () =>
            ref.invalidate(conversationMessagesProvider(conversationId)),
      ),
      data: (messages) {
        if (messages.isEmpty) {
          return EmptyState(
            icon: Icons.chat_bubble_outline,
            title: context.l10n.assistantEmptyTitle,
            message: context.l10n.assistantEmptyMessage,
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          reverse: true,
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final message = messages[messages.length - 1 - index];
            return ChatBubble(message: message, provider: provider);
          },
        );
      },
    );
  }
}
