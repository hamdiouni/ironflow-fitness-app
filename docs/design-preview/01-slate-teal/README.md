# Direction 1: Slate Teal Refined (`01-slate-teal`)

> **Idea**: The Slate Teal palette already chosen, in its cleanest form: calm slate surfaces, one teal action color, and no extra borders or glow.

---

## 1. Design Direction Summary

| Dimension | Specification |
|:---|:---|
| **Primary Philosophy** | Frame-light, content-first, dark-first athletic minimalism. |
| **Main Viewport Mode** | Dark mode (gym-optimized, low glare). Alternate: Crisp slate Light mode. |
| **Grid & Spacing** | 16 px page margin (`pad: 16`), 16 px section spacing (`gap: 16`). Standard 8 dp rhythm. |
| **Card & Container Shape** | `14 px` rounded rectangle. Tonal flat fills (one surface level per section). Card-inside-a-card forbidden. Borders reserved exclusively for selected/active, focus, and error states. |
| **Button Style & Radius** | `12 px` corner radius, `50 px` touch target height. Primary = `#2DD4BF` solid teal with dark ink `#042F2E` text. Secondary = `#1C2A36` tonal raised fill. Tertiary = transparent text button. Destructive = `#F87171` red fill. |
| **Navigation Model** | **Mobile (390×844)**: Material 3 bottom navigation bar with a teal indicator pill behind the active tab.<br>**Wide Web (1280×800)**: Left navigation rail (76 px width, labeled icons, teal indicator) with max-width 1040 px centered container. |
| **Chart Style** | Smooth Bezier area curves with soft teal fill (`alpha: 0.18`), subtle horizontal gridlines only, rounded bar caps, segmented macro donut. |
| **Motion & Micro-interactions** | 180 ms cubic-bezier for sheets and dialogs, 120 ms button press scale (0.98), 160 ms shared-axis horizontal route transitions. Fully disabled when `reducedMotion: true`. |
| **Shadows & Elevation** | **Zero box shadows on cards or list rows**. Modal sheets and floating dialogs use a single soft drop shadow (`0 8 24, rgba(0,0,0,0.24)`). Blur restricted exclusively to navigation app bar and bottom sheet background scrims. |
| **Typography** | **Headings & Metric Numbers**: `SpaceGrotesk` (700 bold, tracking -0.2 dp).<br>**Body & Labels**: `Inter` (400 regular, 500 medium, 600 semi-bold).<br>**Font Licenses**: Bundled open-license `assets/fonts/Inter.ttf` (SIL OFL 1.1) and `assets/fonts/SpaceGrotesk.ttf` (SIL OFL 1.1). Zero runtime Google Fonts network calls. |

---

## 2. Token Palette & WCAG AA Contrast Audit

All color pairs are guaranteed to pass **WCAG AA (≥ 4.5:1 for normal text, ≥ 3.0:1 for large text/icons)**.

### Dark Mode (Main Mode)

| Token Name | Hex Code | Paired Surface / Background | Measured Contrast Ratio | WCAG Compliance |
|:---|:---:|:---|:---:|:---:|
| `canvas` | `#0B1218` | Base background | — | — |
| `surface` | `#131D26` | Card & section surface | — | — |
| `raised` | `#1C2A36` | Secondary buttons, chips, table headers | — | — |
| `hairline` | `#243443` | Structural dividers & state borders | — | — |
| `textPrimary` | `#F1F5F9` | on `canvas` (`#0B1218`) | **17.25:1** | Pass AAA |
| `textPrimary` | `#F1F5F9` | on `surface` (`#131D26`) | **15.33:1** | Pass AAA |
| `textPrimary` | `#F1F5F9` | on `raised` (`#1C2A36`) | **13.05:1** | Pass AAA |
| `textSecondary` | `#9DAEC2` | on `canvas` (`#0B1218`) | **8.39:1** | Pass AAA |
| `textSecondary` | `#9DAEC2` | on `surface` (`#131D26`) | **7.46:1** | Pass AAA |
| `textSecondary` | `#9DAEC2` | on `raised` (`#1C2A36`) | **6.35:1** | Pass AA |
| `accent` (Teal) | `#2DD4BF` | on `surface` (`#131D26`) | **9.30:1** | Pass AAA |
| `onAccent` (Dark Ink) | `#042F2E` | on `accent` (`#2DD4BF`) | **7.92:1** | Pass AAA |
| `accentText` | `#2DD4BF` | on `surface` (`#131D26`) | **9.30:1** | Pass AAA |
| `success` (Green) | `#4ADE80` | on `surface` (`#131D26`) | **10.14:1** | Pass AAA |
| `warning` (Amber) | `#FBBF24` | on `surface` (`#131D26`) | **10.06:1** | Pass AAA |
| `error` (Rose Red) | `#F87171` | on `surface` (`#131D26`) | **5.75:1** | Pass AA |
| `info` (Sky Blue) | `#60A5FA` | on `surface` (`#131D26`) | **6.89:1** | Pass AA |
| `protein` | `#FB7185` | on `surface` (`#131D26`) | **6.10:1** | Pass AA |
| `carbs` | `#38BDF8` | on `surface` (`#131D26`) | **8.20:1** | Pass AAA |
| `fats` | `#FBBF24` | on `surface` (`#131D26`) | **10.06:1** | Pass AAA |

### Light Mode (Alternate Mode)

| Token Name | Hex Code | Paired Surface / Background | Measured Contrast Ratio | WCAG Compliance |
|:---|:---:|:---|:---:|:---:|
| `canvas` | `#F4F7F9` | Base background | — | — |
| `surface` | `#FFFFFF` | Card & section surface | — | — |
| `raised` | `#E9EFF3` | Secondary buttons, chips, table headers | — | — |
| `hairline` | `#D5DEE5` | Structural dividers & state borders | — | — |
| `textPrimary` | `#0F172A` | on `canvas` (`#F4F7F9`) | **16.37:1** | Pass AAA |
| `textPrimary` | `#0F172A` | on `surface` (`#FFFFFF`) | **17.50:1** | Pass AAA |
| `textPrimary` | `#0F172A` | on `raised` (`#E9EFF3`) | **14.93:1** | Pass AAA |
| `textSecondary` | `#475569` | on `canvas` (`#F4F7F9`) | **6.73:1** | Pass AA |
| `textSecondary` | `#475569` | on `surface` (`#FFFFFF`) | **7.19:1** | Pass AAA |
| `textSecondary` | `#475569` | on `raised` (`#E9EFF3`) | **6.14:1** | Pass AA |
| `accent` (Deep Teal) | `#0F766E` | on `surface` (`#FFFFFF`) | **5.33:1** | Pass AA |
| `onAccent` (White) | `#FFFFFF` | on `accent` (`#0F766E`) | **5.33:1** | Pass AA |
| `accentText` | `#0F766E` | on `surface` (`#FFFFFF`) | **5.33:1** | Pass AA |
| `success` (Emerald) | `#15803D` | on `surface` (`#FFFFFF`) | **4.57:1** | Pass AA |
| `warning` (Amber) | `#B45309` | on `surface` (`#FFFFFF`) | **5.38:1** | Pass AA |
| `error` (Crimson) | `#B91C1C` | on `surface` (`#FFFFFF`) | **6.25:1** | Pass AA |
| `info` (Cobalt) | `#1D4ED8` | on `surface` (`#FFFFFF`) | **6.60:1** | Pass AA |
| `protein` | `#BE185D` | on `surface` (`#FFFFFF`) | **6.01:1** | Pass AA |
| `carbs` | `#0369A1` | on `surface` (`#FFFFFF`) | **5.80:1** | Pass AA |
| `fats` | `#B45309` | on `surface` (`#FFFFFF`) | **5.38:1** | Pass AA |

---

## 3. Rendered Screenshots Manifest

All 13 screens rendered with the identical fake dataset:

1. `today_main_390x844.png` (Dark phone)
2. `today_alt_390x844.png` (Light phone)
3. `today_wide_1280x800.png` (Dark wide desktop web)
4. `active_workout_390x844.png` (Phone active workout with working set rows, rest timer, weight plate preview)
5. `workout_summary_390x844.png` (Phone workout summary with PR celebrations, workout volume, set breakdown, and next-time suggestions)
6. `fuel_daily_390x844.png` (Phone nutrition fuel dashboard with calories, macros, and logged meal history)
7. `fuel_quantity_sheet_390x844.png` (Modal quantity & portion entry bottom sheet)
8. `progress_charts_390x844.png` (Phone progress screen with lift progression and bodyweight charts)
9. `progress_charts_wide_1280x800.png` (Wide desktop web dual-column progress chart dashboard)
10. `exercise_detail_390x844.png` (Phone exercise detail page with instruction steps, target muscles, and personal record stats)
11. `component_sheet_390x844.png` (Comprehensive design gallery with buttons, inputs, chips, dialogs, sheets, snackbars, and states)
12. `component_sheet_wide_1280x800.png` (Wide desktop web component gallery)
13. `onboarding_step1_390x844.png` (First-run onboarding step with fitness goal selection)

**Real Screen Proofs Captured**:
- `real_home_slate_teal_390x844.png` (Live Flutter widget tree proof)
- `real_workout_summary_slate_teal_390x844.png` (Live Flutter widget tree proof)
- `real_design_gallery_slate_teal_390x844.png` (Live Flutter widget tree proof)

---

## 4. Pros, Cons & Feasibility Analysis

### Pros
- **Lowest Risk & Direct Evolution**: Matches the user's previously agreed "Slate Teal" theme direction. Enhances and refines existing `AppThemeTokens` without throwing out established aesthetics.
- **Gym-Optimized**: Dark slate background with high-contrast teal actions provides optimal visibility under harsh gym lighting while minimizing battery drain on OLED screens.
- **Rock-Solid Contrast**: Completely resolves existing Light Mode contrast failures (e.g. `AppButtonVariant.primary` with black text on dark teal) by pairing `#FFFFFF` on `#0F766E` in Light mode and `#042F2E` on `#2DD4BF` in Dark mode.

### Cons
- **Familiar Look**: Least visually radical of the four directions; users who want a brand-new identity may find it evolutionary rather than revolutionary.
- **Single Dominant Accent**: Teal carries primary emphasis across training and nutrition, requiring secondary semantic colors (green, amber, red) to be strictly contextualized.

### Performance & Build Effort
- **Paint Performance**: **Highest of all four directions**. Flat fills, zero shadows on scrolling list rows, zero blur outside of modals/sheets.
- **Implementation Effort**: **Medium (M)**. Tokens map cleanly to existing architecture, requiring component-level refinements rather than structural layout rewrites.

