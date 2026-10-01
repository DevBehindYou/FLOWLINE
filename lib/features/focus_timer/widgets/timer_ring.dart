import 'package:flutter/material.dart';

import '../../../l10n/l10n.dart';

class TimerRing extends StatelessWidget {
  const TimerRing({
    super.key,
    required this.remainingSec,
    required this.plannedSec,
    required this.color,
  });

  final int remainingSec;
  final int plannedSec;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final progress =
        plannedSec == 0 ? 0.0 : (remainingSec / plannedSec).clamp(0.0, 1.0);

    // One label for screen readers instead of three unlabeled progress
    // indicators and a bare "12:34" (K13).
    return Semantics(
      label: context.l10n.timer,
      value: _spoken(context.l10n, remainingSec),
      excludeSemantics: true,
      child: SizedBox(
        width: 240,
        height: 240,
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox.expand(
              child: CircularProgressIndicator(
                value: 1,
                strokeWidth: 10,
                color: Theme.of(context).colorScheme.surfaceContainerHigh,
              ),
            ),
            SizedBox.expand(
              child: CircularProgressIndicator(
                value: progress,
                strokeWidth: 10,
                color: color,
                strokeCap: StrokeCap.round,
              ),
            ),
            // Scales down inside the ring instead of overflowing it at large
            // system font sizes (spec: survive 200% text scale).
            Padding(
              padding: const EdgeInsets.all(28),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  _format(remainingSec),
                  // Tabular figures: digits keep one width, so the
                  // countdown doesn't shift sideways every second.
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _spoken(AppLocalizations l10n, int totalSeconds) {
    final safe = totalSeconds < 0 ? 0 : totalSeconds;
    final minutes = safe ~/ 60;
    final seconds = safe % 60;
    return l10n.timerRemaining(minutes, seconds);
  }

  String _format(int totalSeconds) {
    final safeSeconds = totalSeconds < 0 ? 0 : totalSeconds;
    final minutes = (safeSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (safeSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
