import 'package:flutter/material.dart';

import '../../../design/atomic.dart';
import '../../../domain/entities/ai_message.dart';
import '../../../domain/entities/ai_provider_config.dart';
import '../../../l10n/l10n.dart';

/// One message (docs/05 DS-9): yours is an ink card on the right, AA's a
/// white card on the left, an error a warning card. Radius 4, no bubbles.
class ChatBubble extends StatelessWidget {
  const ChatBubble({super.key, required this.message, this.provider});

  final AIMessage message;

  /// The conversation's provider, to name it in an error.
  final AIProviderConfig? provider;

  /// Messages leave room on the other side so the two voices stay apart.
  static const _maxWidthFactor = 0.82;

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == AIMessageRole.user;
    final p = context.atomic.palette;

    final (Color fill, Color border, Color text) = message.isError
        ? (p.dangerContainer, p.danger, p.onDangerContainer)
        : isUser
            ? (p.inverse, p.inverse, p.onInverse)
            : (p.card, p.hairline, p.text);
    final style = AtomicType.body.copyWith(color: text);

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: AtomicSpace.xxs),
        padding: const EdgeInsets.all(AtomicSpace.s),
        constraints: BoxConstraints(
            maxWidth: MediaQuery.sizeOf(context).width * _maxWidthFactor),
        decoration: BoxDecoration(
          color: fill,
          borderRadius: BorderRadius.circular(AtomicRadius.sm),
          border: Border.all(color: border, width: AtomicStroke.hair),
        ),
        child: message.isPending && message.content.isNotEmpty
            // Streaming: the reply so far, with the ink bar while it grows.
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(message.content, style: style),
                  const SizedBox(height: AtomicSpace.xs),
                  const SizedBox(
                      width: AtomicSize.touchTarget, child: AtomicLoadingBar()),
                ],
              )
            : message.isPending
                ? Semantics(
                    label: context.l10n.assistantWaiting,
                    excludeSemantics: true,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AtomicText.mono(context.l10n.assistantThinking,
                            style: AtomicType.caption),
                        const SizedBox(height: AtomicSpace.xs),
                        const SizedBox(
                            width: AtomicSize.touchTarget,
                            child: AtomicLoadingBar()),
                      ],
                    ),
                  )
                : message.wasCutOff
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(message.content, style: style),
                          const SizedBox(height: AtomicSpace.xs),
                          Text(context.l10n.assistantCutOff,
                              style: AtomicType.caption
                                  .copyWith(color: p.textMuted)),
                        ],
                      )
                    : Text(
                        message.failure == null
                            ? message.content
                            : context.l10n
                                .aiFailure(message.failure!, provider),
                        style: style),
      ),
    );
  }
}
