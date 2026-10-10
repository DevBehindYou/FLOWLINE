# Design token decisions

Where the token files in this folder disagree with each other or with
the code, the decision and its reason are recorded here.
`lib/core/theme/app_theme.dart` implements them, and
`test/core/theme/app_theme_test.dart` guards them.

## Canonical files

- **Light:** `flowline-focus-light.md`.
- **Dark:** `flowline-focus-dark-system.md` ("Flowline Focus System").
  `flowline-focus-dark-early.md` is an earlier draft, kept for history
  and not used.

## Dark primary: `#C0C1FF` (D8, decided in Phase 3)

The code used `#6366F1` with white text. The token file says `#C0C1FF`
with `#1000A9` on it. These are the WCAG contrast ratios:

| Pair | `#6366F1` | `#C0C1FF` |
|---|---|---|
| Primary on canvas `#0F1117` | 4.22 | 11.06 |
| Primary on container-high `#1F2430` | 3.47 | 9.10 |
| Text on primary | 4.47 (white) | 7.72 (`#1000A9`) |

`#6366F1` fails AA (4.5:1) for primary-coloured text and for text on
primary buttons, so the token value is used. `#6366F1` stays as the
**semantic** colour for focus sessions and "in progress". Those are
indicators, and they are the same in both themes by design-system
convention.

## Surfaces

- `colorScheme.surface` is **surface-canvas**, the app background: dark
  `#0F1117`, light `#FAF8FF`. The Android launch screen uses the same
  colour (`tool/ci/android_patches.dart`), so starting the app has no
  colour jump. The M3 `surface` token (`#111319` dark) is not used.
- In light mode, cards and sheets are **surface-card** `#FFFFFF`
  (`surfaceContainerLowest`).
- In dark mode, cards and sheets are **surface-container-high**
  `#1F2430`.
- `outlineVariant` is **surface-border**, the hairline around cards and
  fields: dark `#282E3E`, light `#C7C4D8`. The light token
  `surface-border` `#E2E8F0` is only 1.2:1 against white cards and
  disappears, so the M3 `outline-variant` value is kept for light.
- Every `surface-container-*` token is mapped. They are no longer
  derived from a seed colour.

## Type

The mobile sizes of the type scale, with Space Grotesk (600/700) for
display and headline styles and Inter (400–700) for the rest. Both are
bundled under `assets/fonts` (SIL OFL 1.1), and their licences appear
on the Licenses page (Settings → Data & privacy).

| Material role | Token |
|---|---|
| displayLarge | display-lg-mobile |
| displayMedium | display-md-mobile |
| displaySmall, headlineLarge | headline-lg |
| headlineMedium, headlineSmall | headline-md |
| title*, body*, label* | same-named tokens |

The focus timer uses displayLarge with tabular figures, so the digits
don't shift as they change.

The PDF export embeds Inter (B25), which covers Latin, Greek and
Cyrillic. Devanagari and other scripts aren't covered yet. Supporting
them means bundling a Noto font as a fallback (`pw.ThemeData.withFont`
`fontFallback`). That item is in the l10n work.
