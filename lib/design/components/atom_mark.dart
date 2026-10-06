import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../theme/atomic_theme.dart';
import '../tokens/atomic_colors.dart';
import '../tokens/atomic_motion.dart';

/// The atom mark (§2.2): three Signal orbits at 0°/60°/120°, an ink
/// nucleus and three Signal electrons. With [animate] the electrons
/// orbit (ambient motion, 34 s per turn), only without reduced motion;
/// AA uses it to show it is listening (docs/05 DS-11).
class AtomMark extends StatefulWidget {
  const AtomMark({super.key, this.size = 48, this.animate = false});

  final double size;
  final bool animate;

  @override
  State<AtomMark> createState() => _AtomMarkState();
}

class _AtomMarkState extends State<AtomMark>
    with SingleTickerProviderStateMixin {
  late final _turn =
      AnimationController(vsync: this, duration: AtomicDurations.orbit);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync();
  }

  @override
  void didUpdateWidget(AtomMark oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sync();
  }

  void _sync() {
    final run = widget.animate && context.atomicMotion.ambient;
    if (run && !_turn.isAnimating) {
      _turn.repeat();
    } else if (!run && _turn.isAnimating) {
      _turn.stop();
    }
  }

  @override
  void dispose() {
    _turn.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.atomic.palette;
    return ExcludeSemantics(
      child: SizedBox.square(
        dimension: widget.size,
        child: AnimatedBuilder(
          animation: _turn,
          builder: (context, _) => CustomPaint(
            painter: AtomMarkPainter(
              orbit: p.accentText,
              nucleus: p.text,
              phase: _turn.value,
            ),
          ),
        ),
      ),
    );
  }
}

/// Paints the atom in a square. [phase] (0–1) moves the electrons along
/// their orbits.
class AtomMarkPainter extends CustomPainter {
  const AtomMarkPainter({
    this.orbit = AtomicColors.signal,
    this.nucleus = AtomicColors.ink,
    this.phase = 0,
  });

  final Color orbit;
  final Color nucleus;
  final double phase;

  // Proportions of the mark, relative to its side.
  static const _orbitRx = 0.46;
  static const _orbitRy = 0.17;
  static const _stroke = 0.045;
  static const _nucleusR = 0.09;
  static const _electronR = 0.055;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide;
    final center = size.center(Offset.zero);
    final line = Paint()
      ..color = orbit
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * _stroke;
    final dot = Paint()..color = orbit;
    for (var i = 0; i < 3; i++) {
      final angle = i * math.pi / 3;
      canvas
        ..save()
        ..translate(center.dx, center.dy)
        ..rotate(angle);
      canvas.drawOval(
          Rect.fromCenter(
              center: Offset.zero,
              width: s * _orbitRx * 2,
              height: s * _orbitRy * 2),
          line);
      final t = (phase + i / 3) * 2 * math.pi;
      canvas.drawCircle(
          Offset(math.cos(t) * s * _orbitRx, math.sin(t) * s * _orbitRy),
          s * _electronR,
          dot);
      canvas.restore();
    }
    canvas.drawCircle(center, s * _nucleusR, Paint()..color = nucleus);
  }

  @override
  bool shouldRepaint(AtomMarkPainter old) =>
      old.phase != phase || old.orbit != orbit || old.nucleus != nucleus;
}
