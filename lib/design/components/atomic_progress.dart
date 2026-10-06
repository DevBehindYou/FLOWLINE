import 'package:flutter/material.dart';

import '../theme/atomic_theme.dart';
import '../tokens/atomic_colors.dart';
import '../tokens/atomic_metrics.dart';
import '../tokens/atomic_motion.dart';

/// The energy bar's fill colour by percent (§9.8): under 10 plum, 10–79
/// Signal, 80 and over orange. Used for DAY LOAD (docs/05 DS-7).
Color atomicLoadColor(double percent) => percent < 10
    ? AtomicColors.energyLow
    : percent >= 80
        ? AtomicColors.energyHigh
        : AtomicColors.signal;

/// The energy bar (§9.8). Always show the number next to it (§11.4);
/// [semanticValue] is what a screen reader hears ("72%").
class AtomicProgressBar extends StatelessWidget {
  const AtomicProgressBar({
    super.key,
    required this.percent,
    required this.semanticValue,
    this.onInk = false,
  });

  /// 0–100 (clamped).
  final double percent;
  final String semanticValue;

  /// On a dark module the track is paper at 16%.
  final bool onInk;

  @override
  Widget build(BuildContext context) {
    final p = context.atomic.palette;
    final value = percent.clamp(0, 100) / 100;
    final track = onInk ? AtomicColors.paperHairline : p.track;
    return Semantics(
      value: semanticValue,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AtomicRadius.xs),
        child: SizedBox(
          height: AtomicSize.progressBar,
          child: LayoutBuilder(
            builder: (context, c) => Stack(children: [
              Positioned.fill(child: ColoredBox(color: track)),
              AnimatedContainer(
                duration: context.atomicMotion.enter,
                curve: AtomicMotion.curve,
                width: c.maxWidth * value,
                color: atomicLoadColor(percent),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
