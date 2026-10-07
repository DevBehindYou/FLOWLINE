import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../design/atomic.dart';
import '../../../domain/assistant/voice_state.dart';
import '../../../l10n/l10n.dart';
import '../viewmodel/voice_controller.dart';

/// Opens the listening panel and starts listening (docs/05 §29.11).
/// Closing it, however it closes, stops everything.
Future<void> showListeningPanel(BuildContext context, WidgetRef ref) async {
  final voice = ref.read(voiceControllerProvider.notifier);
  final label = context.l10n.voiceSheetLabel;
  final opened = showAtomicSheet<void>(
    context: context,
    label: label,
    builder: (_) => const ListeningPanel(),
  );
  await voice.start();
  await opened;
  await voice.stop();
}

/// What AA hears and what it made of it: live partials, an edit step when
/// it isn't sure, then the reply as a caption.
class ListeningPanel extends ConsumerStatefulWidget {
  const ListeningPanel({super.key});

  @override
  ConsumerState<ListeningPanel> createState() => _ListeningPanelState();
}

class _ListeningPanelState extends ConsumerState<ListeningPanel> {
  final _review = TextEditingController();

  @override
  void dispose() {
    _review.dispose();
    super.dispose();
  }

  String _errorText(AppLocalizations l10n, VoiceErrorKind kind) =>
      switch (kind) {
        VoiceErrorKind.noPermission => l10n.voiceErrorNoPermission,
        VoiceErrorKind.noEngine => l10n.voiceErrorNoEngine,
        VoiceErrorKind.noSpeech => l10n.voiceErrorNoSpeech,
        VoiceErrorKind.network => l10n.voiceErrorNetwork,
        VoiceErrorKind.busy => l10n.voiceErrorBusy,
        VoiceErrorKind.modelMissing => l10n.voiceErrorModelMissing,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final voice = ref.read(voiceControllerProvider.notifier);
    ref.listen(voiceControllerProvider, (_, next) {
      if (next is VoiceReview) _review.text = next.text;
    });
    final state = ref.watch(voiceControllerProvider);
    const gap = SizedBox(height: AtomicSpace.s);
    void close() => Navigator.of(context).maybePop();

    final List<Widget> body = switch (state) {
      VoiceIdle() => [
          AtomicText.mono(l10n.voiceListeningIn(voiceLanguageTag)),
        ],
      VoiceListening(:final partial) => [
          const Center(child: AtomMark(size: 56, animate: true)),
          gap,
          AtomicText.mono(l10n.voiceListeningIn(voiceLanguageTag)),
          gap,
          Semantics(
            liveRegion: true,
            child: AtomicText.display(partial, style: AtomicType.cardTitle),
          ),
          gap,
          AtomicButton(
            label: l10n.stop,
            icon: AtomicIcons.stop,
            expand: true,
            onPressed: voice.stop,
          ),
        ],
      VoiceReview() => [
          AtomicText.mono(l10n.voiceHeard),
          const SizedBox(height: AtomicSpace.xs),
          AtomicText.body(l10n.voiceReviewHint),
          gap,
          TextField(controller: _review, minLines: 1, maxLines: 3),
          gap,
          AtomicButton(
            label: l10n.confirmDo,
            expand: true,
            onPressed: () => voice.submit(_review.text),
          ),
          const SizedBox(height: AtomicSpace.xs),
          AtomicButton(
            label: l10n.cancel,
            variant: AtomicButtonVariant.ghost,
            expand: true,
            onPressed: close,
          ),
        ],
      VoiceThinking(:final text) => [
          AtomicText.mono(l10n.voiceThinking),
          gap,
          AtomicText.display(text, style: AtomicType.cardTitle),
          gap,
          const AtomicLoadingBar(),
        ],
      VoiceSpeaking(:final reply) => [
          AtomicText.mono(l10n.voiceHeard),
          gap,
          Semantics(liveRegion: true, child: AtomicText.body(reply)),
          gap,
          AtomicButton(
            label: l10n.voiceStartListening,
            icon: AtomicIcons.mic,
            variant: AtomicButtonVariant.ghost,
            expand: true,
            onPressed: voice.start,
          ),
          const SizedBox(height: AtomicSpace.xs),
          AtomicButton(label: l10n.voiceDone, expand: true, onPressed: close),
        ],
      VoiceError(:final kind) => [
          Semantics(
            liveRegion: true,
            child: AtomicText.body(_errorText(l10n, kind)),
          ),
          gap,
          AtomicButton(
            label: kind == VoiceErrorKind.noPermission
                ? l10n.voiceGrantMicrophone
                : l10n.voiceTryAgain,
            expand: true,
            onPressed: voice.start,
          ),
          const SizedBox(height: AtomicSpace.xs),
          AtomicButton(
            label: l10n.cancel,
            variant: AtomicButtonVariant.ghost,
            expand: true,
            onPressed: close,
          ),
        ],
    };

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: body,
    );
  }
}
