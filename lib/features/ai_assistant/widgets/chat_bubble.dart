import 'package:flutter/material.dart';

import '../../../domain/entities/ai_message.dart';

import '../../../l10n/l10n.dart';

class ChatBubble extends StatelessWidget {
  const ChatBubble({super.key, required this.message});

  final AIMessage message;

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == AIMessageRole.user;
    final scheme = Theme.of(context).colorScheme;

    final Color bubbleColor;
    final Color textColor;
    if (message.isError) {
      bubbleColor = scheme.errorContainer;
      textColor = scheme.onErrorContainer;
    } else if (isUser) {
      bubbleColor = scheme.primary;
      textColor = scheme.onPrimary;
    } else {
      bubbleColor = scheme.surfaceContainerHigh;
      textColor = scheme.onSurface;
    }

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: message.isPending
            ? Semantics(
                label: context.l10n.assistantWaiting,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: textColor),
                    ),
                    const SizedBox(width: 8),
                    Text(context.l10n.assistantThinking,
                        style: TextStyle(
                            color: textColor, fontStyle: FontStyle.italic)),
                  ],
                ),
              )
            : Text(message.content, style: TextStyle(color: textColor)),
      ),
    );
  }
}
