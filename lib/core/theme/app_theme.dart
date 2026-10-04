import 'package:flutter/material.dart';

/// Semantic colors sourced from the original design files
/// (Flowline Focus System / Flowline Focus Light DESIGN.md, delivered by
/// the design team). Priority/status/session-type/feedback colors are
/// shared across both themes by design-system convention — only the
/// surface/text/primary tokens differ between light and dark.
class AtomicSemanticColors {
  const AtomicSemanticColors._();

  static const priorityLow = Color(0xFF64748B);
  static const priorityMedium = Color(0xFFF59E0B);
  static const priorityHigh = Color(0xFFEF4444);

  static const statusTodo = Color(0xFF94A3B8);
  static const statusInProgress = Color(0xFF6366F1);
  static const statusDone = Color(0xFF10B981);

  static const sessionFocus = Color(0xFF6366F1);
  static const sessionShortBreak = Color(0xFF06B6D4);
  static const sessionLongBreak = Color(0xFF8B5CF6);

  static const feedbackError = Color(0xFFF87171);
  static const feedbackValid = Color(0xFF34D399);
  static const feedbackOverdue = Color(0xFFFB7185);
}

/// Bundled typefaces (assets/fonts, SIL OFL 1.1). Space Grotesk for
/// display and headline styles, Inter for everything else.
class AtomicFonts {
  const AtomicFonts._();

  static const display = 'SpaceGrotesk';
  static const text = 'Inter';
}

/// Colour and type tokens from `docs/design-tokens/`, mapped explicitly
/// instead of derived from a seed, so what ships is what the design
/// files say. Decisions where the files disagree are recorded in
/// `docs/design-tokens/DECISIONS.md`.
class AppTheme {
  const AppTheme._();

  static ThemeData light() {
    const scheme = ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xFF3525CD),
      onPrimary: Color(0xFFFFFFFF),
      primaryContainer: Color(0xFF4F46E5),
      onPrimaryContainer: Color(0xFFDAD7FF),
      secondary: Color(0xFF4648D4),
      onSecondary: Color(0xFFFFFFFF),
      secondaryContainer: Color(0xFF6063EE),
      onSecondaryContainer: Color(0xFFFFFBFF),
      tertiary: Color(0xFF313BA4),
      onTertiary: Color(0xFFFFFFFF),
      tertiaryContainer: Color(0xFF4A55BE),
      onTertiaryContainer: Color(0xFFD7D8FF),
      error: Color(0xFFBA1A1A),
      onError: Color(0xFFFFFFFF),
      errorContainer: Color(0xFFFFDAD6),
      onErrorContainer: Color(0xFF93000A),
      surface: Color(0xFFFAF8FF),
      onSurface: Color(0xFF131B2E),
      onSurfaceVariant: Color(0xFF464555),
      surfaceDim: Color(0xFFD2D9F4),
      surfaceBright: Color(0xFFFAF8FF),
      surfaceContainerLowest: Color(0xFFFFFFFF),
      surfaceContainerLow: Color(0xFFF2F3FF),
      surfaceContainer: Color(0xFFF1F5F9),
      surfaceContainerHigh: Color(0xFFE2E8F0),
      surfaceContainerHighest: Color(0xFFDAE2FD),
      outline: Color(0xFF777587),
      outlineVariant: Color(0xFFC7C4D8),
      inverseSurface: Color(0xFF283044),
      onInverseSurface: Color(0xFFEEF0FF),
      inversePrimary: Color(0xFFC3C0FF),
      surfaceTint: Color(0xFF4D44E3),
      shadow: Color(0xFF000000),
      scrim: Color(0xFF000000),
    );
    // surface-card: cards and sheets are white on the tinted canvas.
    return _buildTheme(scheme, card: scheme.surfaceContainerLowest);
  }

  static ThemeData dark() {
    const scheme = ColorScheme(
      brightness: Brightness.dark,
      // #C0C1FF, not the earlier #6366F1: see DECISIONS.md (contrast).
      primary: Color(0xFFC0C1FF),
      onPrimary: Color(0xFF1000A9),
      primaryContainer: Color(0xFF8083FF),
      onPrimaryContainer: Color(0xFF0D0096),
      secondary: Color(0xFFBDC2FF),
      onSecondary: Color(0xFF131E8C),
      secondaryContainer: Color(0xFF2F3AA3),
      onSecondaryContainer: Color(0xFFA8AFFF),
      tertiary: Color(0xFFB8C4FF),
      onTertiary: Color(0xFF1A2B6A),
      tertiaryContainer: Color(0xFF6473B6),
      onTertiaryContainer: Color(0xFF00031D),
      error: Color(0xFFFFB4AB),
      onError: Color(0xFF690005),
      errorContainer: Color(0xFF93000A),
      onErrorContainer: Color(0xFFFFDAD6),
      // surface-canvas, the app background (also the launch screen).
      surface: Color(0xFF0F1117),
      onSurface: Color(0xFFF1F5F9),
      onSurfaceVariant: Color(0xFFC7C4D7),
      surfaceDim: Color(0xFF111319),
      surfaceBright: Color(0xFF373940),
      surfaceContainerLowest: Color(0xFF0C0E14),
      surfaceContainerLow: Color(0xFF191B22),
      surfaceContainer: Color(0xFF161922),
      surfaceContainerHigh: Color(0xFF1F2430),
      surfaceContainerHighest: Color(0xFF33343B),
      outline: Color(0xFF908FA0),
      // surface-border: the hairline around cards and fields.
      outlineVariant: Color(0xFF282E3E),
      inverseSurface: Color(0xFFE2E2EB),
      onInverseSurface: Color(0xFF2E3037),
      inversePrimary: Color(0xFF494BD6),
      surfaceTint: Color(0xFFC0C1FF),
      shadow: Color(0xFF000000),
      scrim: Color(0xFF000000),
    );
    return _buildTheme(scheme, card: scheme.surfaceContainerHigh);
  }

  /// The token type scale (mobile sizes). Letter spacing is given in em
  /// in the tokens and converted here.
  static TextTheme textTheme(Color color) {
    TextStyle style(
            String family, double size, FontWeight weight, double lineHeight,
            [double letterSpacingEm = 0]) =>
        TextStyle(
          fontFamily: family,
          fontSize: size,
          fontWeight: weight,
          height: lineHeight / size,
          letterSpacing: size * letterSpacingEm,
          color: color,
        );
    const d = AtomicFonts.display;
    const t = AtomicFonts.text;
    const bold = FontWeight.w700;
    const semi = FontWeight.w600;
    const medium = FontWeight.w500;
    const regular = FontWeight.w400;
    return TextTheme(
      displayLarge: style(d, 44, bold, 52, -0.03),
      displayMedium: style(d, 32, bold, 40, -0.02),
      displaySmall: style(d, 30, semi, 36, -0.02),
      headlineLarge: style(d, 30, semi, 36, -0.02),
      headlineMedium: style(d, 24, semi, 30, -0.01),
      headlineSmall: style(d, 24, semi, 30, -0.01),
      titleLarge: style(t, 20, semi, 26),
      titleMedium: style(t, 16, semi, 22),
      titleSmall: style(t, 14, semi, 20),
      bodyLarge: style(t, 16, regular, 24),
      bodyMedium: style(t, 14, regular, 20),
      bodySmall: style(t, 12, regular, 16),
      labelLarge: style(t, 14, medium, 20, 0.01),
      labelMedium: style(t, 12, medium, 16, 0.02),
      labelSmall: style(t, 11, semi, 14, 0.03),
    );
  }

  static ThemeData _buildTheme(ColorScheme colorScheme, {required Color card}) {
    final border = colorScheme.outlineVariant;
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      fontFamily: AtomicFonts.text,
      textTheme: textTheme(colorScheme.onSurface),
      scaffoldBackgroundColor: colorScheme.surface,
      cardTheme: CardThemeData(
        color: card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: border),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHigh,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          minimumSize: const Size.fromHeight(48),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: card,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        indicatorColor: colorScheme.primary.withValues(alpha: 0.16),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      dividerColor: border,
    );
  }
}
