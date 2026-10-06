import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/entities/ai_provider_config.dart';
import '../../../core/async/run_action.dart';
import '../../../design/atomic.dart';
import '../../../shared_widgets/empty_state.dart';
import '../../../shared_widgets/error_view.dart';
import '../../../shared_widgets/settings_action.dart';
import '../viewmodel/assistant_view_model.dart';
import '../../../assistant/orchestrator.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/turn_actions.dart';
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
          AtomicIconButton(
            icon: AtomicIcons.ai,
            semanticLabel: context.l10n.settingsAiProviders,
            onPressed: () => context.push('/settings/ai-providers'),
          ),
          const SettingsAction(),
        ],
      ),
      body: activeProviderAsync.when(
        loading: () => AtomicLoading(label: context.l10n.loadingAssistant),
        error: (error, _) => ErrorView(
          error: error,
          onRetry: () => ref.invalidate(activeAiProviderProvider),
        ),
        data: (provider) {
          if (provider == null) {
            return EmptyState(
              icon: AtomicIcons.ai,
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

  Future<void> _onNotice(AssistNotice? notice) async {
    if (notice == null) return;
    ref.read(assistNoticesProvider.notifier).clear();
    final l10n = context.l10n;
    switch (notice) {
      case AssistStopped(:final limit):
        ScaffoldMessenger.maybeOf(context)?.showSnackBar(SnackBar(
            content: Text(switch (limit) {
          TurnLimit.rounds => l10n.turnStoppedRounds,
          TurnLimit.calls => l10n.turnStoppedCalls,
          TurnLimit.timeout => l10n.turnStoppedTimeout,
        })));
      case AssistConfirm(:final pending):
        final yes = await showAtomicConfirm(
          context: context,
          label: l10n.confirmSheetLabel,
          title: l10n.confirmActionTitle,
          message: l10n.confirmMessage(pending.preview),
          confirmLabel: l10n.confirmDo,
          cancelLabel: l10n.cancel,
        );
        if (!yes || !mounted) return;
        await runAction(
            context,
            () =>
                ref.read(assistantViewModelProvider.notifier).confirm(pending));
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(assistNoticesProvider, (_, next) => _onNotice(next));
    final conversationAsync =
        ref.watch(latestConversationForProviderProvider(widget.provider.id));
    final isSending = ref.watch(assistantViewModelProvider);

    return Column(
      children: [
        // Which provider and model answer: the real state, in mono.
        Padding(
          padding: const EdgeInsets.fromLTRB(
              AtomicSpace.s, AtomicSpace.s, AtomicSpace.s, 0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: AtomicTag(
              context.l10n.providerAndModel(
                  widget.provider.displayName, widget.provider.defaultModel),
              tone: AtomicTagTone.outline,
            ),
          ),
        ),
        Expanded(
          child: conversationAsync.when(
            loading: () =>
                AtomicLoading(label: context.l10n.loadingConversation),
            error: (error, _) => ErrorView(
              error: error,
              onRetry: () => ref.invalidate(
                  latestConversationForProviderProvider(widget.provider.id)),
            ),
            data: (conversation) {
              if (conversation == null) {
                return EmptyState(
                  icon: AtomicIcons.assist,
                  title: context.l10n.assistantEmptyTitle,
                  message: context.l10n.assistantEmptyMessage,
                );
              }
              return _MessageList(
                  conversationId: conversation.id, provider: widget.provider);
            },
          ),
        ),
        if (isSending) const AtomicLoadingBar(),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AtomicSpace.s, vertical: AtomicSpace.xs),
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
                const SizedBox(width: AtomicSpace.xxs),
                // Send, or Stop while a reply is on its way (spec §5.9).
                isSending
                    ? AtomicIconButton(
                        icon: AtomicIcons.stop,
                        semanticLabel: context.l10n.stop,
                        style: AtomicIconButtonStyle.ink,
                        onPressed:
                            ref.read(assistantViewModelProvider.notifier).stop,
                      )
                    : AtomicIconButton(
                        icon: AtomicIcons.send,
                        semanticLabel: context.l10n.send,
                        style: AtomicIconButtonStyle.signal,
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
      loading: () => AtomicLoading(label: context.l10n.loadingConversation),
      error: (error, _) => ErrorView(
        error: error,
        onRetry: () =>
            ref.invalidate(conversationMessagesProvider(conversationId)),
      ),
      data: (messages) {
        if (messages.isEmpty) {
          return EmptyState(
            icon: AtomicIcons.assist,
            title: context.l10n.assistantEmptyTitle,
            message: context.l10n.assistantEmptyMessage,
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: AtomicSpace.s),
          reverse: true,
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final message = messages[messages.length - 1 - index];
            final group = message.turnGroupId;
            if (group == null || message.isPending || message.isError) {
              return ChatBubble(message: message, provider: provider);
            }
            // An assistant turn: its text (if any), then what it did.
            final empty = message.content.trim().isEmpty;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!empty) ChatBubble(message: message, provider: provider),
                TurnActions(groupId: group, replyIsEmpty: empty),
              ],
            );
          },
        );
      },
    );
  }
}
