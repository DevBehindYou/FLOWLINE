import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/entities/ai_provider_config.dart';
import '../../../shared_widgets/empty_state.dart';
import '../viewmodel/assistant_view_model.dart';
import '../widgets/chat_bubble.dart';

class AssistantScreen extends ConsumerWidget {
  const AssistantScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeProviderAsync = ref.watch(activeAiProviderProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Assistant'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'AI Providers',
            onPressed: () => context.push('/settings/ai-providers'),
          ),
        ],
      ),
      body: activeProviderAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) =>
            Center(child: Text('Something went wrong: $error')),
        data: (provider) {
          if (provider == null) {
            return EmptyState(
              icon: Icons.auto_awesome_outlined,
              title: 'Connect an AI provider',
              message: 'Add an API key in Settings to start chatting.',
              actionLabel: 'Go to AI Providers',
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
    if (text.isEmpty) return;
    _controller.clear();
    await ref.read(assistantViewModelProvider.notifier).send(
          providerId: widget.provider.id,
          existingConversationId: conversationId,
          prompt: text,
        );
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
            error: (error, _) =>
                Center(child: Text('Something went wrong: $error')),
            data: (conversation) {
              if (conversation == null) {
                return const EmptyState(
                  icon: Icons.chat_bubble_outline,
                  title: 'Ask me anything',
                  message: 'Try asking about your schedule, or just say hello.',
                );
              }
              return _MessageList(conversationId: conversation.id);
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
                    decoration: const InputDecoration(
                        hintText: 'Ask the assistant\u2026'),
                    minLines: 1,
                    maxLines: 4,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) =>
                        _send(conversationAsync.valueOrNull?.id),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  icon: const Icon(Icons.arrow_upward),
                  onPressed: isSending
                      ? null
                      : () => _send(conversationAsync.valueOrNull?.id),
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
  const _MessageList({required this.conversationId});

  final int conversationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messagesAsync =
        ref.watch(conversationMessagesProvider(conversationId));

    return messagesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('Something went wrong: $error')),
      data: (messages) {
        if (messages.isEmpty) {
          return const EmptyState(
            icon: Icons.chat_bubble_outline,
            title: 'Ask me anything',
            message: 'Try asking about your schedule, or just say hello.',
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          reverse: true,
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final message = messages[messages.length - 1 - index];
            return ChatBubble(message: message);
          },
        );
      },
    );
  }
}
