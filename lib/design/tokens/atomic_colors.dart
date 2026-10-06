import 'package:flutter/painting.dart';

/// The Atomic palette (docs/design-system/atomic-design-system.md §3).
/// Raw values only: widgets read roles from `AtomicPalette`, not these.
abstract final class AtomicColors {
  // Core (§3.1): more than 95% of every screen.
  static const ink = Color(0xFF15171B);
  static const paper = Color(0xFFF4F5F1);
  static const white = Color(0xFFFFFFFF);
  static const surface = Color(0xFFEDEEE8);
  static const signal = Color(0xFF3A2FF0);

  // Neutrals (§3.2).
  static const inkDeep = Color(0xFF0B0C0E);
  static const textBody = Color(0xFF2B2E34);
  static const slate = Color(0xFF45474B); // slate-app
  static const line = Color(0xFFC6C6CB);
  static const track = Color(0xFFE8E9E3);
  static const raised = Color(0xFFF9FAF4);

  // Accent family (§3.3).
  static const signalHover = Color(0xFF2A20C9);
  static const signalDeep = Color(0xFF1D14A0);

  /// The accent on ink backgrounds. Never Signal itself on ink (2.43:1).
  static const signalLight = Color(0xFF8F88FF);
  static const signalMist = Color(0xFFD8D6FF);

  // Semantic (§3.4).
  static const error = Color(0xFFBA1A1A);
  static const errorContainer = Color(0xFFFFDAD6);
  static const onErrorContainer = Color(0xFF93000A);
  static const negativeOnDark = Color(0xFFFF8A80);

  /// Bar fills only; as text on paper it fails contrast (2.57:1).
  static const energyHigh = Color(0xFFEB7D00);
  static const energyLow = Color(0xFF601D49);

  /// Black at 54%, behind sheets and dialogs.
  static const scrim = Color(0x8A000000);

  // Dark theme (§13.9): ink background, these cards, paper text.
  static const darkCard = Color(0xFF1E2026);
  static const darkContainerLow = Color(0xFF1A1C21);
  static const darkContainerHigh = Color(0xFF26282F);
  static const darkContainerHighest = Color(0xFF2E3038);

  /// Paper at 62% over ink (muted text on dark, 6.5:1).
  static const paperMuted = Color(0xFF9FA1A0);

  /// Paper at 16% over ink, flattened (hairlines on dark).
  static const paperHairline = Color(0xFF393B3E);
}
