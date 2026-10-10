import 'package:flutter/widgets.dart';

import '../theme/atomic_theme.dart';
import '../tokens/atomic_metrics.dart';
import '../tokens/atomic_motion.dart';

/// A shape with a hard offset shadow that goes down like a key when
/// pressed: it moves by the shadow's offset and the shadow drops to 0
/// (system §6.3). Reduced motion: the shadow still drops, nothing moves.
///
/// Semantics and focus belong to the caller (buttons wrap this in their
/// own `Semantics`/`FocusableActionDetector`).
class AtomicPressable extends StatefulWidget {
  const AtomicPressable({
    super.key,
    required this.child,
    required this.onTap,
    this.onLongPress,
    this.shadowLevel = 2,
    this.shadowColor,
    this.radius = AtomicRadius.sm,
  });

  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  /// 0–6, see [AtomicShadow.offsets]. 0 = flat.
  final int shadowLevel;

  /// Defaults to the theme's shadow (ink on light, Signal on dark).
  final Color? shadowColor;
  final double radius;

  @override
  State<AtomicPressable> createState() => _AtomicPressableState();
}

class _AtomicPressableState extends State<AtomicPressable> {
  var _down = false;

  void _set(bool down) {
    if (_down != down) setState(() => _down = down);
  }

  @override
  Widget build(BuildContext context) {
    final motion = context.atomicMotion;
    final enabled = widget.onTap != null || widget.onLongPress != null;
    final pressed = _down && enabled;
    final offset = AtomicShadow.offsets[widget.shadowLevel];
    final travel = pressed && !motion.reduced ? offset : 0.0;
    final shadow = !enabled || pressed
        ? const <BoxShadow>[]
        : AtomicShadow.hard(widget.shadowLevel,
            widget.shadowColor ?? context.atomic.palette.shadow);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: enabled ? (_) => _set(true) : null,
      onTapUp: enabled ? (_) => _set(false) : null,
      onTapCancel: () => _set(false),
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      child: AnimatedContainer(
        duration: motion.press,
        curve: AtomicMotion.curve,
        // Leave room for the shadow so it never paints over neighbours'
        // layout, and so pressing doesn't change the widget's size.
        margin: EdgeInsets.only(right: offset, bottom: offset),
        transform: Matrix4.translationValues(travel, travel, 0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.radius),
          boxShadow: shadow,
        ),
        child: widget.child,
      ),
    );
  }
}
