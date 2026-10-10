import 'package:flutter/painting.dart';

/// Bundled typefaces (assets/fonts, SIL OFL 1.1; §4.1).
abstract final class AtomicFonts {
  /// Always shown upper-case: titles, big numbers, app button labels.
  static const display = 'BebasNeue';

  /// Sentence case: paragraphs, descriptions, form values.
  static const body = 'HankenGrotesk';

  /// Labels, timestamps, counters, chips (upper-case with tracking).
  static const mono = 'JetBrainsMono';
}

/// The app type scale (§4.3), in logical pixels (sp). Colours are left
/// unset: the theme or the component supplies them.
abstract final class AtomicType {
  static const _displayHeight = 0.95;
  static const _bodyHeight = 1.5;

  static TextStyle _display(double size, {double tracking = 0.5}) => TextStyle(
        fontFamily: AtomicFonts.display,
        fontSize: size,
        height: _displayHeight,
        letterSpacing: tracking,
        fontWeight: FontWeight.w400,
      );

  static TextStyle _body(double size, FontWeight weight) => TextStyle(
        fontFamily: AtomicFonts.body,
        fontSize: size,
        height: _bodyHeight,
        fontWeight: weight,
      );

  static TextStyle _mono(double size, double tracking, FontWeight weight) =>
      TextStyle(
        fontFamily: AtomicFonts.mono,
        fontSize: size,
        letterSpacing: tracking,
        fontWeight: weight,
      );

  // Display.
  static final hero = _display(48);
  static final screenTitle = _display(40);
  static final pushedTitle = _display(30);
  static final cardTitle = _display(24);
  static final rowTitle = _display(20);
  static final button = _display(20, tracking: 0.6);
  static final buttonSmall = _display(18, tracking: 0.6);

  // Body (≥ 15 sp for reading text, §11.6).
  static final bodyLarge = _body(16, FontWeight.w400);
  static final body = _body(15, FontWeight.w400);
  static final bodyStrong = _body(15, FontWeight.w700);
  static final bodyMedium = _body(15, FontWeight.w500);
  static final bodySmall = _body(13, FontWeight.w400);

  // Mono (never below 12 sp, §4.4.7).
  static final label = _mono(13, 1.5, FontWeight.w500);
  static final eyebrow = _mono(12, 2, FontWeight.w500);
  static final caption = _mono(12, 1, FontWeight.w400);
  static final counter = _mono(12, 1, FontWeight.w500);
  static final number = _mono(16, 0, FontWeight.w700);

  /// The focus timer's digits: monospace so they don't jump.
  static final timer = _mono(56, 0, FontWeight.w500);
}
