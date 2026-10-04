import 'package:flutter/widgets.dart';

import 'atomic_metrics.dart';

/// Motion tokens (§8). Everything eases; nothing bounces.
abstract final class AtomicDurations {
  static const press = Duration(milliseconds: 120);
  static const hover = Duration(milliseconds: 150);
  static const toggle = Duration(milliseconds: 200);
  static const enter = Duration(milliseconds: 350);
  static const reveal = Duration(milliseconds: 500);
  static const orbit = Duration(seconds: 34);

  /// What remains of an entrance when the OS asks for reduced motion.
  static const reducedFade = Duration(milliseconds: 120);
}

/// Durations for one context. When the OS asks for reduced motion
/// (`MediaQuery.disableAnimations`), transforms stop and only short fades
/// remain (§8 rule 3).
@immutable
final class AtomicMotion {
  const AtomicMotion({required this.reduced});

  factory AtomicMotion.of(BuildContext context) => AtomicMotion(
      reduced: MediaQuery.maybeDisableAnimationsOf(context) ?? false);

  final bool reduced;

  static const Curve curve = Curves.ease;

  Duration get press => reduced ? Duration.zero : AtomicDurations.press;
  Duration get hover => reduced ? Duration.zero : AtomicDurations.hover;
  Duration get toggle => reduced ? Duration.zero : AtomicDurations.toggle;
  Duration get enter =>
      reduced ? AtomicDurations.reducedFade : AtomicDurations.enter;
  Duration get reveal =>
      reduced ? AtomicDurations.reducedFade : AtomicDurations.reveal;

  /// Entrance slide distance (16 dp), zero when reduced.
  double get slide => reduced ? 0 : AtomicSpace.m;

  /// Decorative loops (the atom's orbit) run only without reduced motion.
  bool get ambient => !reduced;
}
