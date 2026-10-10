import 'package:flutter/widgets.dart';

/// Material 3 window size classes (by width). Layouts branch on these,
/// never on literal pixel widths, so a foldable or tablet gets a sensible
/// layout without per-device code (docs/03 §9).
enum WindowSizeClass {
  /// Phones in portrait: under 600dp.
  compact,

  /// Foldables, small tablets, phones in landscape: 600-839dp.
  medium,

  /// Tablets and desktops: 840dp and up.
  expanded;

  static WindowSizeClass forWidth(double width) => width < 600
      ? compact
      : width < 840
          ? medium
          : expanded;

  static WindowSizeClass of(BuildContext context) =>
      forWidth(MediaQuery.sizeOf(context).width);
}
