---
name: Flowline Focus System
colors:
  surface: '#111319'
  surface-dim: '#111319'
  surface-bright: '#373940'
  surface-container-lowest: '#0c0e14'
  surface-container-low: '#191b22'
  surface-container: '#161922'
  surface-container-high: '#1F2430'
  surface-container-highest: '#33343b'
  on-surface: '#e2e2eb'
  on-surface-variant: '#c7c4d7'
  inverse-surface: '#e2e2eb'
  inverse-on-surface: '#2e3037'
  outline: '#908fa0'
  outline-variant: '#464554'
  surface-tint: '#c0c1ff'
  primary: '#c0c1ff'
  on-primary: '#1000a9'
  primary-container: '#8083ff'
  on-primary-container: '#0d0096'
  inverse-primary: '#494bd6'
  secondary: '#bdc2ff'
  on-secondary: '#131e8c'
  secondary-container: '#2f3aa3'
  on-secondary-container: '#a8afff'
  tertiary: '#b8c4ff'
  on-tertiary: '#1a2b6a'
  tertiary-container: '#6473b6'
  on-tertiary-container: '#00031d'
  error: '#ffb4ab'
  on-error: '#690005'
  error-container: '#93000a'
  on-error-container: '#ffdad6'
  primary-fixed: '#e1e0ff'
  primary-fixed-dim: '#c0c1ff'
  on-primary-fixed: '#07006c'
  on-primary-fixed-variant: '#2f2ebe'
  secondary-fixed: '#e0e0ff'
  secondary-fixed-dim: '#bdc2ff'
  on-secondary-fixed: '#000767'
  on-secondary-fixed-variant: '#2f3aa3'
  tertiary-fixed: '#dde1ff'
  tertiary-fixed-dim: '#b8c4ff'
  on-tertiary-fixed: '#001354'
  on-tertiary-fixed-variant: '#334282'
  background: '#111319'
  on-background: '#e2e2eb'
  surface-variant: '#33343b'
  surface-canvas: '#0F1117'
  surface-border: '#282E3E'
  text-primary: '#F1F5F9'
  text-secondary: '#94A3B8'
  text-muted: '#64748B'
  semantic-priority-low: '#64748B'
  semantic-priority-medium: '#F59E0B'
  semantic-priority-high: '#EF4444'
  semantic-status-todo: '#94A3B8'
  semantic-status-inprogress: '#6366F1'
  semantic-status-done: '#10B981'
  semantic-session-focus: '#6366F1'
  semantic-session-shortbreak: '#06B6D4'
  semantic-session-longbreak: '#8B5CF6'
  semantic-feedback-error: '#F87171'
  semantic-feedback-valid: '#34D399'
  semantic-feedback-overdue: '#FB7185'
typography:
  display-lg:
    fontFamily: Space Grotesk
    fontSize: 56px
    fontWeight: '700'
    lineHeight: 64px
    letterSpacing: -0.04em
  display-lg-mobile:
    fontFamily: Space Grotesk
    fontSize: 44px
    fontWeight: '700'
    lineHeight: 52px
    letterSpacing: -0.03em
  display-md:
    fontFamily: Space Grotesk
    fontSize: 40px
    fontWeight: '700'
    lineHeight: 48px
    letterSpacing: -0.03em
  display-md-mobile:
    fontFamily: Space Grotesk
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Space Grotesk
    fontSize: 30px
    fontWeight: '600'
    lineHeight: 36px
    letterSpacing: -0.02em
  headline-md:
    fontFamily: Space Grotesk
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 30px
    letterSpacing: -0.01em
  title-lg:
    fontFamily: Inter
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 26px
  title-md:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '600'
    lineHeight: 22px
  title-sm:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '600'
    lineHeight: 20px
  body-lg:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-md:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  body-sm:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '400'
    lineHeight: 16px
  label-lg:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '500'
    lineHeight: 20px
    letterSpacing: 0.01em
  label-md:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '500'
    lineHeight: 16px
    letterSpacing: 0.02em
  label-sm:
    fontFamily: Inter
    fontSize: 11px
    fontWeight: '600'
    lineHeight: 14px
    letterSpacing: 0.03em
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  gutter: 1rem
  margin: 1rem
  margin-tablet: 1.5rem
  space-xxs: 0.25rem
  space-xs: 0.5rem
  space-sm: 0.75rem
  space-md: 1rem
  space-lg: 1.5rem
  space-xl: 2rem
  space-xxl: 3rem
---

## Brand & Style

This design system delivers a quiet, local-first focus ecosystem designed to eliminate cognitive friction and visual fatigue. Built upon the most restrained end of Material 3 Expressive, the aesthetic pairs a deep, monolithic slate canvas with a laser-focused electric indigo seed. It rejects consumer "gamification" tropes, aggressive gradients, decorative drop shadows, and ornamental graphics in favor of precision, intentionality, and tactile calm.

The visual tone is clinical yet refined:
- **Focus-First Atmosphere**: Dark mode by default, anchoring the interface into muted zinc and deep slate layers that recede into the device bezel.
- **Single Electric Accent**: Vibrant indigo/violet reserved strictly for direct interactive focus, live state execution, and primary user intent.
- **Utilitarian Speed**: Local-first fluidity with deterministic data updates; no pull-to-refresh spinners or decorative motion delays.
- **Architectural Typography**: Dramatic optical contrast between utilitarian, legible information hierarchy and bold, monospaced-scale display numerals for timers and key metrics.

## Colors

The color architecture is built strictly on functional intent. Color is never employed ornamentally; every chromatic pixel conveys state, focus, or operational priority.

### Surface Tonal Hierarchy (Dark Mode Default)
- `surface-canvas` (`#0F1117`): Base ambient background for all primary screens.
- `surface-container` (`#161922`): Elevated single step for interactive cards, schedule rows, and bottom sheets.
- `surface-container-high` (`#1F2430`): Active selection states, hover/pressed fills, dialog overlays, and segmented controls.
- `surface-border` (`#282E3E`): Ghost outlines and hairline dividers for structural boundaries without elevation shadows.

### Core Brand Tokens
- `primary` (`#6366F1`): The primary operational accent. Drives active CTA buttons, the running focus countdown ring, the active navigation tab, and the current time block.
- `secondary` (`#818CF8`): Secondary interactive states, selected chip text, and active badge backgrounds.
- `tertiary` (`#A5B4FC`): Focused outlines and subtle selection tints.

### Semantic Role Mappings
- **Priority**: Low (`#64748B`), Medium (`#F59E0B`), High (`#EF4444`). Always accompanied by an icon or text indicator; color is never the exclusive signal.
- **Status**: Todo (`#94A3B8`), In-Progress (`#6366F1`), Done (`#10B981`).
- **Session Types**: Focus (`#6366F1`), Short Break (`#06B6D4`), Long Break (`#8B5CF6`). Drives countdown rings and session selector segments.
- **Feedback**: Error/Destructive (`#F87171`), Valid/Connected (`#34D399`), Overdue Warning (`#FB7185`).

## Typography

The type system blends the technical, high-precision geometry of Space Grotesk for metrics and headline structures with the neutral, hyper-legible utility of Inter for dense workflow lists, task notes, and labels.

### Structural Applications
- **Display Large & Medium (`Space Grotesk`)**: Dedicated exclusively to active countdown timers, primary productivity stats, and key numerical indicators. Uses tabular numerical figures to prevent layout jitter during live second countdowns.
- **Headlines (`Space Grotesk`)**: Top-level dashboard headers, session phase transitions, and sheet headers.
- **Titles (`Inter Semi-bold`)**: Task titles, schedule card headers, bottom sheet titles, and modal headers.
- **Body (`Inter Regular`)**: Uncluttered, readable text for task descriptions, streaming AI assistant responses, and system settings.
- **Labels (`Inter Medium/Semi-bold`)**: All interactive elements including chips, segmented controls, status indicators, tabs, and button labels.

### Accessibility Standards
Layouts must accommodate 200% OS font scaling without truncating strings or breaking horizontal row flows. Display timer counters auto-scale using fluid constraints (`FittedBox` / responsive clamp) within their circular rings to preserve full visibility under aggressive user font overrides.

## Layout & Spacing

The layout is anchored to an uncompromising 8pt spatial grid with a 4pt sub-grid reserved for tight component internal padding and glyph alignment.

### Grid & Viewport Principles
- **Base Rhythm**: Every margin, padding, gap, and component dimension is an exact multiple of `8dp` (or `4dp` for micro-elements).
- **Mobile First Canvas**: Single-column vertical scroll flow configured with fixed outer edge margins of `16dp` (`margin`), expanding to `24dp` on larger viewport widths.
- **Touch Target Integrity**: All tap targets (`IconButton`, `Chip`, checkbox hit boxes, segmented buttons, bottom tabs) strictly enforce a minimum interactive boundary of `48dp × 48dp` regardless of the rendered visual glyph size.
- **Generous Spacing Over Density**: Workflow cards and timer rings prioritize breathing room over information packing. Vertical stack separations use `12dp` or `16dp` gaps to avoid crowded clusters.

## Elevation & Depth

This system intentionally rejects multi-tiered shadow stacks, diffuse colored glows, and frosted glass layers. Depth is communicated strictly through surface luminance stepping and delicate 1px boundary lines.

### Depth Hierarchy
1. **Base Surface (Elevation 0 - `#0F1117`)**: The screen canvas. All primary views and canvas containers live here.
2. **Container Tier (Elevation 1 - `#161922`)**: Task Cards, Schedule Blocks, Stat Cards, and Bottom Sheets sit exactly one tier above the canvas. Visual delineation is reinforced with a crisp 1px stroke of `surface-border` (`#282E3E`) rather than drop shadows.
3. **Floating Overlays (Elevation 2 - `#1F2430`)**: Dialogs, contextual dropdown menus, and the primary action button. A restrained ambient shadow is permitted only when an overlay must occlude content directly underneath:
   - `box-shadow: 0 8px 24px rgba(0, 0, 0, 0.45);`

### Border Philosophy
Hairline borders (`1px solid #282E3E`) are used to construct containers, inputs, and segmented controls. They prevent visual smearing across low-contrast OLED/AMOLED displays without introducing noisy dropshadows.

## Shapes

The shape hierarchy strictly enforces a 3-tier corner radius model to maintain disciplined geometric harmony throughout the application:

1. **Small (8px / `rounded-sm`)**: Form inputs, text entry fields, dropdown menus, and non-pill indicators.
2. **Medium (16px / `rounded-lg`)**: Structural cards, task items, timeline schedule containers, and the top corners of dynamic bottom sheets.
3. **Full / Circular (9999px / Pill)**: Interactive chips (`PriorityChip`, `StatusChip`), segmented control thumb indicators, the circular timer ring, and floating icon buttons.

## Components

### Buttons
- **Primary Action Button**: High-contrast fill using `primary` (`#6366F1`) with pure white text (`#FFFFFF`). Pill or 12px corner radius, minimum height of 48dp, horizontal padding of 24dp. Used for core progression (Start Session, Create Task).
- **Secondary / Outlined Button**: Transparent surface with 1px `surface-border` outline, text in `text-primary`. States highlight to `surface-container-high`.
- **Text / Ghost Button**: Zero outline, zero background. Label in `text-secondary`, transitioning to `text-primary` on press.
- **Icon Button**: Bound to strict 48x48dp interactive frame, 24dp centered Material Symbol outlined glyph.

### Chips & Badges
- **Status & Priority Chips**: Pill geometry (`roundedness: 9999px`), 32dp visual height within a 48dp touch target. 
  - Background: 10% opacity tint of semantic color.
  - Border: 1px subtle stroke of semantic color at 30% opacity.
  - Content: 12dp leading icon or colored dot glyph paired with `label-md` text in full-opacity semantic color.

### Task & Schedule Cards
- Surface: `#161922` with 1px `#282E3E` outline. 16px corner radius.
- Padding: 16dp uniform internal padding.
- Overdue State: Replaces left border with a 3px accent stroke in `semantic-feedback-overdue` (`#FB7185`).
- Active Schedule Block: Outline switches to `primary` (`#6366F1`) at 60% opacity with a subtle 5% background glow tint.

### Inputs & Form Fields
- Surface: `#161922` with 1px `#282E3E` resting outline.
- Active / Focus State: Outline transitions to `primary` (`#6366F1`) with zero offset glow.
- Error State: Outline transitions to `semantic-feedback-error` (`#F87171`) with inline error label beneath in `label-sm`.
- Masked API Field: Monospaced Inter/Space Grotesk rendering with trailing reveal icon toggle.

### Timer Ring (Hero Component)
- Track: 8dp stroke width in `#1F2430`.
- Progress Stroke: 8dp rounded stroke in `semantic-session-*` color mapped to the active mode (Focus `#6366F1`, Short Break `#06B6D4`, Long Break `#8B5CF6`).
- Central Readout: Space Grotesk `display-lg` tabular numerals, accompanied below by `label-md` current session count and status badge.

### Modals & Bottom Sheets
- Rounded top corners at 24dp; background `#161922` with a 1px top border of `#282E3E`.
- Drag handle: 32dp width, 4dp height pill in `#64748B`, positioned 8dp from top edge.