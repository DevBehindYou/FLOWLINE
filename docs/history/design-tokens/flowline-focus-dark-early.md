---
name: Flowline Focus
colors:
  surface: '#131317'
  surface-dim: '#131317'
  surface-bright: '#39393d'
  surface-container-lowest: '#0e0e12'
  surface-container-low: '#1b1b1f'
  surface-container: '#1f1f23'
  surface-container-high: '#2a292e'
  surface-container-highest: '#353439'
  on-surface: '#e4e1e7'
  on-surface-variant: '#c7c4d7'
  inverse-surface: '#e4e1e7'
  inverse-on-surface: '#303034'
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
  tertiary: '#7bd0ff'
  on-tertiary: '#00354a'
  tertiary-container: '#009bd1'
  on-tertiary-container: '#002d40'
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
  tertiary-fixed: '#c4e7ff'
  tertiary-fixed-dim: '#7bd0ff'
  on-tertiary-fixed: '#001e2c'
  on-tertiary-fixed-variant: '#004c69'
  background: '#131317'
  on-background: '#e4e1e7'
  surface-variant: '#353439'
typography:
  display-lg:
    fontFamily: Space Grotesk
    fontSize: 40px
    fontWeight: '700'
    lineHeight: 48px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Space Grotesk
    fontSize: 32px
    fontWeight: '600'
    lineHeight: 40px
    letterSpacing: -0.01em
  headline-lg-mobile:
    fontFamily: Space Grotesk
    fontSize: 26px
    fontWeight: '600'
    lineHeight: 32px
    letterSpacing: -0.01em
  headline-md:
    fontFamily: Space Grotesk
    fontSize: 22px
    fontWeight: '600'
    lineHeight: 28px
  title-lg:
    fontFamily: Space Grotesk
    fontSize: 18px
    fontWeight: '600'
    lineHeight: 24px
  title-md:
    fontFamily: Space Grotesk
    fontSize: 16px
    fontWeight: '500'
    lineHeight: 22px
  body-lg:
    fontFamily: Space Grotesk
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-md:
    fontFamily: Space Grotesk
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  body-sm:
    fontFamily: Space Grotesk
    fontSize: 12px
    fontWeight: '400'
    lineHeight: 16px
  label-lg:
    fontFamily: Space Grotesk
    fontSize: 14px
    fontWeight: '600'
    lineHeight: 20px
    letterSpacing: 0.02em
  label-md:
    fontFamily: Space Grotesk
    fontSize: 12px
    fontWeight: '500'
    lineHeight: 16px
    letterSpacing: 0.03em
  label-sm:
    fontFamily: Space Grotesk
    fontSize: 10px
    fontWeight: '500'
    lineHeight: 14px
    letterSpacing: 0.04em
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  gutter: 1rem
  gutter-sm: 0.75rem
  margin: 1rem
  margin-tablet: 1.5rem
  space-xs: 0.25rem
  space-sm: 0.5rem
  space-md: 1rem
  space-lg: 1.5rem
  space-xl: 2rem
---

## Brand & Style
The design system embodies deep focus, precision, and streamlined momentum. Built specifically for task acceleration and cognitive clarity in low-light environments, the aesthetic balances modern technical minimalism with the functional utility of Material 3's tonal foundation. 

Surfaces recede effortlessly into deep graphite and obsidian, allowing glowing indigo accents to guide attention without causing visual fatigue. The emotional quality is calm, hyper-efficient, and dependable—tailored for power users, developers, and knowledge workers engaged in focused mobile workflows.

## Colors
The palette relies on Material 3 tonal elevation logic for dark surfaces, anchored by a vibrant `#6366f1` indigo primary accent:

- **Primary (`#6366f1`)**: Key interactive drivers, focus state indicators, and primary action fills.
- **Secondary (`#818cf8`)**: Tonal chips, active state highlights, and secondary interactive framing.
- **Tertiary (`#38bdf8`)**: Progress tracking, telemetry accents, and contextual positive markers.
- **Neutral Foundation (`#121216`)**:
  - `surface`: `#121216` (Deep canvas)
  - `surface-container-lowest`: `#0a0a0d`
  - `surface-container-low`: `#18181e`
  - `surface-container`: `#1e1e26`
  - `surface-container-high`: `#262630`
  - `surface-container-highest`: `#2f2f3c`
- **Text & Content**:
  - `on-surface`: `#e2e8f0` (High emphasis)
  - `on-surface-variant`: `#94a3b8` (Medium emphasis / metadata)
  - `outline`: `#334155` (Subtle low-contrast boundaries)

## Typography
Space Grotesk provides a technical, geometric cadence across all typographic roles. Its idiosyncratic alternate shapes inject deliberate character into headers, while its open apertures maintain crisp readability on dark OLED mobile panels. 

All sizes 24px and above leverage tighter letter spacing to create dense, impactful headers. Lower levels (`body-sm`, `label-sm`) expand tracking slightly to eliminate optical crowding against glowing surface backgrounds.

## Layout & Spacing
The layout follows a mobile-first fluid grid structured on an 8-point base rhythm:

- **Mobile Viewports (<600px)**: 4 fluid columns, 16px (`1rem`) outer margins, and 16px (`1rem`) gutters. Content stays tightly grouped to prioritize one-handed thumb interaction.
- **Tablet / Large Mobile Viewports (600px–840px)**: 8 fluid columns, 24px (`1.5rem`) outer margins, and 16px gutters.
- **Component Padding Scale**: Internal spacing strictly uses multiples of 4px and 8px:
  - `space-xs` (4px): Micro-gaps between tag icons and text.
  - `space-sm` (8px): Compact element spacing, input field inline padding.
  - `space-md` (16px): Card internal padding and list item separation.
  - `space-lg` (24px): Sectional breaks and modal dialog insets.
  - `space-xl` (32px): Primary screen block separations.

## Elevation & Depth
In line with Material 3 dark theme standards, visual elevation is primarily achieved via **tonal layering** rather than drop shadows:

1. **Surface 0 (Canvas)**: `#121216` base background.
2. **Surface 1 (Resting Cards, List Rows)**: `#18181e` (`surface-container-low`) with a 1px ghost border (`#334155` at 40% opacity).
3. **Surface 2 (Floating Action Elements, Top Bars)**: `#1e1e26` (`surface-container`).
4. **Surface 3 (Dialogs, Popovers, Menus)**: `#262630` (`surface-container-high`) paired with a concentrated ambient shadow: `0 8px 24px rgba(0, 0, 0, 0.45)`.
5. **Active Focus Glow**: Focused inputs or activated interactive states receive a direct tonal perimeter: `0 0 0 2px #6366f1`.

## Shapes
All standard UI boundaries conform to a base 8px (`0.5rem`) radius, delivering a consistent, precision-engineered geometric appearance:

- **Containers & Cards**: Fixed 8px corner radius.
- **Inputs & Buttons**: Fixed 8px corner radius.
- **Chips & Status Tags**: 8px corner radius (avoiding full pill rounding to retain the technical, structured aesthetic).
- **Modals & Bottom Sheets**: 16px (`1rem`) corner radius along exposed upper edges.

## Components

### Buttons
- **Filled Primary**: `#6366f1` background, `#ffffff` text, 8px radius, height 44px (minimum touch target). Active tap scales to `0.98`.
- **Tonal Secondary**: `#262630` background, `#818cf8` text, 1px `#334155` border.
- **Ghost/Text**: Transparent background, `#818cf8` text, 8px internal focus ring.

### Chips & Filter Tags
- Height: 32px.
- Radius: 8px.
- Inactive: `#18181e` surface, `#94a3b8` label, subtle 1px `#334155` outline.
- Active: `#262630` surface with `#6366f1` 1px border and `#6366f1` text.

### Lists
- Built on `surface-container-low` (`#18181e`).
- Minimum row height: 56px.
- Separators: 1px divider using `#1e1e26`.
- Leading icons/avatars encased in 8px rounded `#262630` containers.

### Checkboxes & Radio Buttons
- Checkbox: 20x20px square with 4px inner radius. Unchecked has a 1.5px `#334155` border; checked fills with `#6366f1` and `#ffffff` checkmark.
- Radio: 20x20px circle. Unchecked has a 1.5px `#334155` ring; checked features an outer `#6366f1` ring with a centered 10px `#6366f1` core.

### Input Fields
- Height: 48px.
- Background: `#18181e`.
- Border: 1px `#334155` in resting state; transitions to 2px `#6366f1` on focus.
- Placeholder: `#94a3b8` text set in `Space Grotesk` `body-md`.
- Radius: 8px.

### Cards
- Resting: `#18181e` surface fill, 1px outline in `#262630`, 8px radius, 16px internal padding.
- Interactive/Tappable: Elevates on touch to `#1e1e26` with a border color change to `#6366f1` at 50% opacity.

### Timer & Focus Trackers (System Specific)
- Circular progress indicators built with `#262630` background tracks and `#6366f1` stroke indicators.
- Metrics display using `Space Grotesk` `display-lg` tabular figures for flicker-free countdown updates.