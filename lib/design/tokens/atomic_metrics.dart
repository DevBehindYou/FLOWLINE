import 'package:flutter/painting.dart';

/// Spacing: the bold steps of the system's scale (§5.1).
abstract final class AtomicSpace {
  static const xxs = 4.0;
  static const xs = 8.0;
  static const s = 12.0;
  static const m = 16.0;
  static const l = 22.0;
  static const xl = 24.0;
  static const xxl = 32.0;
  static const x3l = 44.0;
  static const x4l = 56.0;
  static const x5l = 74.0;

  /// Screen side margin (app: 16 dp).
  static const screenMargin = m;
  static const cardPadding = m;
  static const rowGap = s;
  static const chipGap = xs;

  /// Horizontal padding inside a filter chip (§9.2).
  static const chipPadding = 14.0;

  /// Gap inside a chip or between an icon and its label (system: 6–9).
  static const iconLabelGap = 6.0;
}

/// Corner radii (§6.1). Nearly square, or fully round: nothing between,
/// except bottom-sheet tops.
abstract final class AtomicRadius {
  static const xs = 3.0;
  static const sm = 4.0;
  static const md = 6.0;
  static const lg = 8.0;
  static const sheet = 28.0;
  static const pill = 999.0;
}

/// Border widths (§6.2).
abstract final class AtomicStroke {
  static const hair = 1.0;
  static const rule = 1.0;
  static const structure = 1.5;
  static const control = 2.0;
  static const selected = 2.0;
  static const danger = 2.0;
  static const priority = 4.0;
}

/// Hard offset shadows: a solid copy of the shape, no blur (§6.3).
abstract final class AtomicShadow {
  /// Offsets for levels 0–6 (level 2, 3 px, is the primary button).
  static const offsets = [0.0, 2.0, 3.0, 4.0, 5.0, 6.0, 8.0];

  static List<BoxShadow> hard(int level, Color color) => level == 0
      ? const []
      : [
          BoxShadow(
            color: color,
            offset: Offset(offsets[level], offsets[level]),
          ),
        ];
}

/// Fixed sizes from the app specs (§5.3, §7.2, §9).
abstract final class AtomicSize {
  static const touchTarget = 48.0;
  static const headerHeight = 56.0;
  static const bottomBarHeight = 64.0;
  static const navPillWidth = 104.0;
  static const navPillHeight = 44.0;
  static const buttonPrimary = 52.0;
  static const buttonSecondary = 44.0;
  static const chip = 32.0;
  static const iconTile = 40.0;
  static const backButton = 36.0;
  static const icon = 24.0;
  static const iconSmall = 20.0;

  /// Inline icons beside a mono label (a due date, a lock).
  static const iconTiny = 16.0;
  static const unreadDot = 8.0;
  static const progressBar = 8.0;
  static const loadingBar = 2.0;
  static const switchWidth = 52.0;

  /// Settings and list rows (≈ 56 dp, §9.4).
  static const rowHeight = 56.0;
  static const dragHandleWidth = 32.0;
  static const dragHandleHeight = 4.0;

  /// Body text stays under ~75 characters per line.
  static const readingWidth = 640.0;

  /// Space a list leaves at its end so the floating action never covers
  /// the last row.
  static const floatingActionClearance = buttonPrimary + AtomicSpace.x3l;
}

/// The disabled look (§9.1): 40% opacity, no shadow.
const atomicDisabledOpacity = 0.4;
