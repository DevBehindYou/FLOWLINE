import 'package:flutter/material.dart';

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

    return SizedBox(
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
          Text(
            _format(remainingSec),
            style: Theme.of(context)
                .textTheme
                .displaySmall
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  String _format(int totalSeconds) {
    final safeSeconds = totalSeconds < 0 ? 0 : totalSeconds;
    final minutes = (safeSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (safeSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
