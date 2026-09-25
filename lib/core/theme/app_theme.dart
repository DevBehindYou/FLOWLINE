import 'package:flutter/material.dart';

/// Semantic colors sourced from the Flowline design system
/// (Flowline Focus System / Flowline Focus Light DESIGN.md, delivered by
/// the design team). Priority/status/session-type/feedback colors are
/// shared across both themes by design-system convention — only the
/// surface/text/primary tokens differ between light and dark.
class FlowlineSemanticColors {
  const FlowlineSemanticColors._();

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

class AppTheme {
  const AppTheme._();

  static ThemeData light() {
    const primary = Color(0xFF3525CD);
    const surface = Color(0xFFFAF8FF);
    const border = Color(0xFFC7C4D8);
    const onSurface = Color(0xFF131B2E);

    final colorScheme = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.light,
    ).copyWith(
      primary: primary,
      onPrimary: Colors.white,
      surface: surface,
      onSurface: onSurface,
      outlineVariant: border,
    );

    return _buildTheme(colorScheme, border);
  }

  static ThemeData dark() {
    const primary = Color(0xFF6366F1);
    const surface = Color(0xFF0F1117);
    const border = Color(0xFF282E3E);
    const onSurface = Color(0xFFF1F5F9);

    final colorScheme = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.dark,
    ).copyWith(
      primary: primary,
      onPrimary: Colors.white,
      surface: surface,
      onSurface: onSurface,
      outlineVariant: border,
    );

    return _buildTheme(colorScheme, border);
  }

  static ThemeData _buildTheme(ColorScheme colorScheme, Color border) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      cardTheme: CardThemeData(
        color: colorScheme.surfaceContainerHigh,
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
        backgroundColor: colorScheme.surfaceContainerHigh,
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
