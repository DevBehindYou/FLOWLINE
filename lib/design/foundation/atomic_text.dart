import 'package:flutter/widgets.dart';

import '../theme/atomic_theme.dart';
import '../tokens/atomic_type.dart';

enum _Role { display, mono, body }

/// Text in one of the three Atomic roles (§4).
///
/// Display text needs no transform: Bebas Neue is a caps-only face (its
/// lower-case letters are capital shapes), so the string stays as
/// written. Mono labels are upper-cased for the eye, and screen readers
/// get the words as written, so they read "Today" rather than spelling
/// "TODAY" (§11.7). Flutter has no text-transform, so this widget is the
/// one place that upper-cases (a code rule bans `.toUpperCase()` in
/// features).
class AtomicText extends StatelessWidget {
  /// Bebas Neue (caps-only glyphs). Defaults to the card-title size.
  const AtomicText.display(
    this.text, {
    super.key,
    this.style,
    this.maxLines,
    this.textAlign,
  }) : _role = _Role.display;

  /// JetBrains Mono, upper-case with tracking: labels, timestamps,
  /// counters. Defaults to the section-label size, muted.
  const AtomicText.mono(
    this.text, {
    super.key,
    this.style,
    this.maxLines,
    this.textAlign,
  }) : _role = _Role.mono;

  /// Hanken Grotesk, as written.
  const AtomicText.body(
    this.text, {
    super.key,
    this.style,
    this.maxLines,
    this.textAlign,
  }) : _role = _Role.body;

  final String text;

  /// Merged over the role's default (size, colour, weight).
  final TextStyle? style;
  final int? maxLines;
  final TextAlign? textAlign;
  final _Role _role;

  bool get _upper => _role == _Role.mono;

  @override
  Widget build(BuildContext context) {
    final palette = context.atomic.palette;
    final base = switch (_role) {
      _Role.display => AtomicType.cardTitle.copyWith(color: palette.text),
      _Role.mono => AtomicType.label.copyWith(color: palette.textMuted),
      _Role.body => AtomicType.body.copyWith(color: palette.text),
    };
    return Text(
      _upper ? text.toUpperCase() : text,
      style: base.merge(style),
      maxLines: maxLines,
      textAlign: textAlign,
      overflow: maxLines == null ? null : TextOverflow.ellipsis,
      semanticsLabel: _upper ? text : null,
    );
  }
}
