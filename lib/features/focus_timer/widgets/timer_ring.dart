import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../design/atomic.dart';

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
      // Sized from the window, not a LayoutBuilder: the Focus screen's
      // scroll-safe column measures intrinsic heights, which a
      // LayoutBuilder can't report.
      child: Builder(builder: (context) {
        final window = MediaQuery.sizeOf(context);
        final d = diameterFor(
          availableWidth: window.width,
          screenHeight: window.height,
        );
        return SizedBox(
          width: d,
          height: d,
          child: _ring(context, progress, d),
        );
      }),
    );
  }

  /// The ring scales with the window instead of a fixed 240dp: most of
  /// the width on a phone, capped by the screen height so the
  /// controls stay visible in landscape, and bounded so it neither
  /// shrinks into illegibility nor grows huge on a tablet.
  static double diameterFor({
    required double availableWidth,
    required double screenHeight,
  }) =>
      math.min(availableWidth * 0.72, screenHeight * 0.42).clamp(160.0, 360.0);

  Widget _ring(BuildContext context, double progress, double d) {
    final p = context.atomic.palette;
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox.expand(
          child: CustomPaint(
            painter: _RingPainter(
              progress: progress,
              stroke: d / _strokeRatio,
              track: p.track,
              arc: color,
            ),
          ),
        ),
        // Scales down inside the ring instead of overflowing it at large
        // system font sizes (spec: survive 200% text scale).
        Padding(
          padding: EdgeInsets.all(d * _digitInset),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              _format(remainingSec),
              // Monospace digits keep one width, so the countdown doesn't
              // shift sideways every second (system §4.4: numbers that
              // change are mono).
              style: AtomicType.timer.copyWith(color: p.text),
            ),
          ),
        ),
      ],
    );
  }

  static const _strokeRatio = 24;
  static const _digitInset = 0.12;

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

/// The track and the remaining-time arc, from 12 o'clock clockwise. Square
/// caps: Atomic edges are hard (system §1.3).
class _RingPainter extends CustomPainter {
  const _RingPainter({
    required this.progress,
    required this.stroke,
    required this.track,
    required this.arc,
  });

  final double progress;
  final double stroke;
  final Color track;
  final Color arc;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = (Offset.zero & size).deflate(stroke / 2);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.butt;
    canvas.drawArc(rect, 0, 2 * math.pi, false, paint..color = track);
    if (progress > 0) {
      canvas.drawArc(rect, -math.pi / 2, 2 * math.pi * progress.clamp(0, 1),
          false, paint..color = arc);
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress ||
      old.stroke != stroke ||
      old.track != track ||
      old.arc != arc;
}
