import 'package:flutter/material.dart';

import '../tokens/atomic_colors.dart';
import '../tokens/atomic_metrics.dart';
import '../tokens/atomic_motion.dart';
import '../tokens/atomic_palette.dart';
import '../tokens/atomic_type.dart';

/// The Atomic palette and motion for widgets, next to Material's theme.
/// Read it with `context.atomic`.
@immutable
class AtomicThemeData extends ThemeExtension<AtomicThemeData> {
  const AtomicThemeData({required this.palette});

  final AtomicPalette palette;

  @override
  AtomicThemeData copyWith({AtomicPalette? palette}) =>
      AtomicThemeData(palette: palette ?? this.palette);

  // Light and dark are different designs, not a continuum: switch at the
  // midpoint instead of blending colours.
  @override
  AtomicThemeData lerp(AtomicThemeData? other, double t) =>
      t < 0.5 || other == null ? this : other;
}

extension AtomicContext on BuildContext {
  AtomicThemeData get atomic =>
      Theme.of(this).extension<AtomicThemeData>() ??
      const AtomicThemeData(palette: AtomicPalette.light);

  AtomicMotion get atomicMotion => AtomicMotion.of(this);
}

/// Material 3 themes built only from Atomic tokens
/// (docs/design-system/atomic-design-system.md §14.3, docs/05 §26).
///
/// Material components keep their behaviour; their look comes from here.
/// What Material can't express (hard shadows, the ink nav pill, the
/// pressed-key translate) lives in the component library.
abstract final class AtomicTheme {
  static ThemeData light() => _build(_lightScheme, AtomicPalette.light);
  static ThemeData dark() => _build(_darkScheme, AtomicPalette.dark);

  static const _lightScheme = ColorScheme(
    brightness: Brightness.light,
    primary: AtomicColors.signal,
    onPrimary: AtomicColors.white,
    primaryContainer: AtomicColors.signalMist,
    onPrimaryContainer: AtomicColors.signalDeep,
    secondary: AtomicColors.ink,
    onSecondary: AtomicColors.paper,
    secondaryContainer: AtomicColors.surface,
    onSecondaryContainer: AtomicColors.ink,
    tertiary: AtomicColors.signalDeep,
    onTertiary: AtomicColors.white,
    error: AtomicColors.error,
    onError: AtomicColors.white,
    errorContainer: AtomicColors.errorContainer,
    onErrorContainer: AtomicColors.onErrorContainer,
    surface: AtomicColors.paper,
    onSurface: AtomicColors.ink,
    onSurfaceVariant: AtomicColors.slate,
    surfaceDim: AtomicColors.surface,
    surfaceBright: AtomicColors.raised,
    surfaceContainerLowest: AtomicColors.white,
    surfaceContainerLow: AtomicColors.raised,
    surfaceContainer: AtomicColors.surface,
    surfaceContainerHigh: AtomicColors.surface,
    surfaceContainerHighest: AtomicColors.track,
    outline: AtomicColors.ink,
    outlineVariant: AtomicColors.line,
    inverseSurface: AtomicColors.ink,
    onInverseSurface: AtomicColors.paper,
    inversePrimary: AtomicColors.signalLight,
    shadow: AtomicColors.ink,
    scrim: AtomicColors.scrim,
    surfaceTint: Colors.transparent,
  );

  // On ink, Signal fails as text (2.43:1), and Material uses `primary` for
  // both text and fills. So the dark scheme's primary is signal-light with
  // ink on it (6.1:1). Atomic components that need a Signal *fill* with
  // white text take it from the palette instead (docs/05 §25 DS-16).
  static const _darkScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: AtomicColors.signalLight,
    onPrimary: AtomicColors.ink,
    primaryContainer: AtomicColors.signal,
    onPrimaryContainer: AtomicColors.white,
    secondary: AtomicColors.paper,
    onSecondary: AtomicColors.ink,
    secondaryContainer: AtomicColors.darkContainerHigh,
    onSecondaryContainer: AtomicColors.paper,
    tertiary: AtomicColors.signalMist,
    onTertiary: AtomicColors.ink,
    error: AtomicColors.negativeOnDark,
    onError: AtomicColors.ink,
    errorContainer: AtomicColors.onErrorContainer,
    onErrorContainer: AtomicColors.errorContainer,
    surface: AtomicColors.ink,
    onSurface: AtomicColors.paper,
    onSurfaceVariant: AtomicColors.paperMuted,
    surfaceDim: AtomicColors.inkDeep,
    surfaceBright: AtomicColors.darkContainerHighest,
    surfaceContainerLowest: AtomicColors.inkDeep,
    surfaceContainerLow: AtomicColors.darkContainerLow,
    surfaceContainer: AtomicColors.darkCard,
    surfaceContainerHigh: AtomicColors.darkCard,
    surfaceContainerHighest: AtomicColors.darkContainerHigh,
    outline: AtomicColors.paper,
    outlineVariant: AtomicColors.paperHairline,
    inverseSurface: AtomicColors.paper,
    onInverseSurface: AtomicColors.ink,
    inversePrimary: AtomicColors.signal,
    shadow: AtomicColors.signal,
    scrim: AtomicColors.scrim,
    surfaceTint: Colors.transparent,
  );

  /// Material's text roles mapped onto the Atomic scale. Display and title
  /// roles use the display face (it has only capitals); body roles use
  /// the grotesque; label roles use mono.
  static TextTheme textTheme(Color text, Color muted) => TextTheme(
        displayLarge: AtomicType.hero,
        displayMedium: AtomicType.hero,
        displaySmall: AtomicType.screenTitle,
        headlineLarge: AtomicType.screenTitle,
        headlineMedium: AtomicType.pushedTitle,
        headlineSmall: AtomicType.pushedTitle,
        titleLarge: AtomicType.cardTitle,
        titleMedium: AtomicType.rowTitle,
        titleSmall: AtomicType.bodyStrong,
        bodyLarge: AtomicType.bodyLarge,
        bodyMedium: AtomicType.body,
        bodySmall: AtomicType.bodySmall.copyWith(color: muted),
        labelLarge: AtomicType.label,
        labelMedium: AtomicType.counter,
        labelSmall: AtomicType.caption,
      ).apply(bodyColor: text, displayColor: text);

  static ThemeData _build(ColorScheme scheme, AtomicPalette palette) {
    final text = textTheme(palette.text, palette.textMuted);
    final square = RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AtomicRadius.sm));
    final control =
        BorderSide(color: palette.rule, width: AtomicStroke.control);
    // A finite minimum width: buttons also sit inside Rows. Full-width
    // primaries are the component library's job (AtomicButton.expand).
    const buttonSize = Size(AtomicSize.touchTarget, AtomicSize.buttonSecondary);
    final focusSide =
        BorderSide(color: palette.accentText, width: AtomicStroke.control);

    OutlineInputBorder inputBorder(BorderSide side) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(AtomicRadius.sm), borderSide: side);

    return ThemeData(
      useMaterial3: true,
      brightness: scheme.brightness,
      colorScheme: scheme,
      fontFamily: AtomicFonts.body,
      textTheme: text,
      primaryTextTheme: text,
      scaffoldBackgroundColor: palette.background,
      canvasColor: palette.background,
      splashFactory: NoSplash.splashFactory,
      extensions: [AtomicThemeData(palette: palette)],
      appBarTheme: AppBarTheme(
        backgroundColor: palette.background,
        foregroundColor: palette.text,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        toolbarHeight: AtomicSize.headerHeight,
        titleTextStyle: AtomicType.pushedTitle.copyWith(color: palette.text),
        // The 1 dp ink divider under every header (§5.3).
        shape: Border(
            bottom: BorderSide(color: palette.rule, width: AtomicStroke.rule)),
      ),
      cardTheme: CardThemeData(
        color: palette.card,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AtomicRadius.sm),
          side: BorderSide(color: palette.hairline, width: AtomicStroke.hair),
        ),
      ),
      dividerTheme: DividerThemeData(
          color: palette.hairline,
          thickness: AtomicStroke.hair,
          space: AtomicStroke.hair),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: palette.accent,
          foregroundColor: palette.onAccent,
          minimumSize:
              const Size(AtomicSize.touchTarget, AtomicSize.buttonPrimary),
          shape: square,
          side: const BorderSide(
              color: AtomicColors.ink, width: AtomicStroke.control),
          textStyle: AtomicType.button,
          elevation: 0,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: palette.accent,
          foregroundColor: palette.onAccent,
          minimumSize: const Size.fromHeight(AtomicSize.buttonPrimary),
          shape: square,
          side: const BorderSide(
              color: AtomicColors.ink, width: AtomicStroke.control),
          textStyle: AtomicType.button,
          elevation: 0,
          shadowColor: Colors.transparent,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: palette.text,
          minimumSize: buttonSize,
          shape: square,
          side: control,
          textStyle: AtomicType.buttonSmall,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: palette.accentText,
          minimumSize:
              const Size(AtomicSize.touchTarget, AtomicSize.touchTarget),
          shape: square,
          textStyle: AtomicType.label,
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: palette.text,
          minimumSize:
              const Size(AtomicSize.touchTarget, AtomicSize.touchTarget),
          shape: square,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: palette.inverse,
        foregroundColor: palette.onInverse,
        elevation: 0,
        focusElevation: 0,
        hoverElevation: 0,
        highlightElevation: 0,
        shape: square,
        extendedTextStyle: AtomicType.label,
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          shape: const WidgetStatePropertyAll(StadiumBorder()),
          side: WidgetStatePropertyAll(control),
          textStyle: WidgetStatePropertyAll(AtomicType.caption),
          backgroundColor: WidgetStateProperty.resolveWith(
              (s) => s.contains(WidgetState.selected) ? palette.inverse : null),
          foregroundColor: WidgetStateProperty.resolveWith((s) =>
              s.contains(WidgetState.selected)
                  ? palette.onInverse
                  : palette.text),
          iconColor: WidgetStateProperty.resolveWith((s) =>
              s.contains(WidgetState.selected)
                  ? palette.onInverse
                  : palette.text),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: StadiumBorder(
            side: BorderSide(
                color: palette.hairline, width: AtomicStroke.structure)),
        side:
            BorderSide(color: palette.hairline, width: AtomicStroke.structure),
        backgroundColor: palette.background,
        selectedColor: palette.inverse,
        labelStyle: AtomicType.caption.copyWith(color: palette.textMuted),
        secondaryLabelStyle:
            AtomicType.caption.copyWith(color: palette.onInverse),
        showCheckmark: false,
        padding: const EdgeInsets.symmetric(horizontal: AtomicSpace.xxs),
      ),
      switchTheme: SwitchThemeData(
        trackColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected)
                ? palette.accent
                : palette.background),
        thumbColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected) ? palette.onAccent : palette.rule),
        trackOutlineColor: WidgetStatePropertyAll(palette.rule),
        trackOutlineWidth: const WidgetStatePropertyAll(AtomicStroke.control),
      ),
      checkboxTheme: CheckboxThemeData(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AtomicRadius.xs)),
        side:
            BorderSide(color: palette.textMuted, width: AtomicStroke.structure),
        fillColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected) ? palette.accent : null),
        checkColor: WidgetStatePropertyAll(palette.onAccent),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected)
                ? palette.accentText
                : palette.textMuted),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: palette.card,
        contentPadding: const EdgeInsets.symmetric(
            horizontal: AtomicSpace.s, vertical: AtomicSpace.s),
        labelStyle: AtomicType.label.copyWith(color: palette.textMuted),
        floatingLabelStyle: AtomicType.label.copyWith(color: palette.textMuted),
        hintStyle: AtomicType.body.copyWith(color: palette.textMuted),
        helperStyle: AtomicType.bodySmall.copyWith(color: palette.textMuted),
        errorStyle: AtomicType.bodySmall.copyWith(color: palette.danger),
        border: inputBorder(control),
        enabledBorder: inputBorder(control),
        focusedBorder: inputBorder(focusSide),
        errorBorder: inputBorder(
            BorderSide(color: palette.danger, width: AtomicStroke.control)),
        focusedErrorBorder: inputBorder(
            BorderSide(color: palette.danger, width: AtomicStroke.control)),
        disabledBorder: inputBorder(
            BorderSide(color: palette.hairline, width: AtomicStroke.control)),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: palette.text,
        titleTextStyle: AtomicType.bodyLarge.copyWith(color: palette.text),
        subtitleTextStyle:
            AtomicType.bodySmall.copyWith(color: palette.textMuted),
        leadingAndTrailingTextStyle:
            AtomicType.caption.copyWith(color: palette.textMuted),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: AtomicSpace.screenMargin),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: palette.background,
        surfaceTintColor: Colors.transparent,
        modalBarrierColor: AtomicColors.scrim,
        elevation: 0,
        modalElevation: 0,
        showDragHandle: true,
        dragHandleColor: palette.textMuted,
        dragHandleSize:
            const Size(AtomicSize.dragHandleWidth, AtomicSize.dragHandleHeight),
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
                top: Radius.circular(AtomicRadius.sheet))),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: palette.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        barrierColor: AtomicColors.scrim,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AtomicRadius.sm),
          side: BorderSide(color: palette.rule, width: AtomicStroke.structure),
        ),
        titleTextStyle: AtomicType.cardTitle.copyWith(color: palette.text),
        contentTextStyle: AtomicType.body.copyWith(color: palette.text),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: palette.inverse,
        contentTextStyle: AtomicType.body.copyWith(color: palette.onInverse),
        // The snackbar is ink on light (accent on ink: signal-light) and
        // paper on dark (Signal reads fine on paper).
        actionTextColor: palette.inverse == AtomicColors.ink
            ? AtomicColors.signalLight
            : AtomicColors.signal,
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        shape: square,
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: palette.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        textStyle: AtomicType.body.copyWith(color: palette.text),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AtomicRadius.sm),
          side: BorderSide(
              color: palette.hairline, width: AtomicStroke.structure),
        ),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
            color: palette.inverse,
            borderRadius: BorderRadius.circular(AtomicRadius.sm)),
        textStyle: AtomicType.caption.copyWith(color: palette.onInverse),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: palette.rule,
        linearTrackColor: palette.track,
        circularTrackColor: Colors.transparent,
        linearMinHeight: AtomicSize.loadingBar,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: palette.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        height: AtomicSize.bottomBarHeight,
        indicatorColor: palette.inverse,
        indicatorShape: square,
        labelTextStyle: WidgetStatePropertyAll(
            AtomicType.caption.copyWith(color: palette.text)),
        iconTheme: WidgetStateProperty.resolveWith((s) => IconThemeData(
            color: s.contains(WidgetState.selected)
                ? palette.onInverse
                : palette.text)),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: palette.background,
        elevation: 0,
        indicatorColor: palette.inverse,
        indicatorShape: square,
        selectedIconTheme: IconThemeData(color: palette.onInverse),
        unselectedIconTheme: IconThemeData(color: palette.text),
        selectedLabelTextStyle:
            AtomicType.caption.copyWith(color: palette.text),
        unselectedLabelTextStyle:
            AtomicType.caption.copyWith(color: palette.textMuted),
      ),
      iconTheme: IconThemeData(color: palette.text, size: AtomicSize.icon),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: palette.accentText,
        selectionHandleColor: palette.accentText,
        selectionColor: palette.accent.withValues(alpha: 0.24),
      ),
      timePickerTheme: TimePickerThemeData(
        backgroundColor: palette.background,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AtomicRadius.sm)),
      ),
      datePickerTheme: DatePickerThemeData(
        backgroundColor: palette.background,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AtomicRadius.sm)),
        headerHeadlineStyle: AtomicType.pushedTitle,
      ),
      // Focus and hover use the accent, never Material's grey overlays.
      focusColor: palette.accent.withValues(alpha: 0.12),
      hoverColor: palette.accent.withValues(alpha: 0.06),
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      dividerColor: palette.hairline,
      visualDensity: VisualDensity.standard,
      materialTapTargetSize: MaterialTapTargetSize.padded,
    );
  }
}
