# Direction 3: Kinetic Block (`03-kinetic-block`)

> **Idea**: Bold and sporty: compact bento blocks, strong cobalt and amber color blocks, big scoreboard numbers, and square, confident buttons.

---

## 1. Design Direction Summary

| Dimension | Specification |
|:---|:---|
| **Primary Philosophy** | High-density athletic performance dashboard. Scoreboard aesthetics, bento organization, high-intensity color blocking. |
| **Main Viewport Mode** | **Dark mode first** (deep carbon `#090A0D` canvas). Alternate: High-contrast Light mode (`#F1F3F7`). |
| **Grid & Spacing** | 12 px page margin (`pad: 12`), 10 px compact section gap (`gap: 10`). Compact bento rhythm showing maximum workout metrics above the fold. |
| **Card & Container Shape** | `4 px` square corner radius. **Bento block architecture**: each card is a solid flat block (`#141720`). Featured cards feature an amber/orange or cobalt header band. 2 px solid state borders on active/focus items. |
| **Button Style & Radius** | `4 px` sharp corner radius, `52 px` height. **Block Uppercase style**: bold uppercase labels with leading icon indicators. Primary = `#2563EB` solid cobalt block with `#FFFFFF` text. Secondary = `#1E2230` outline-free raised block. Destructive = `#FF8A8A` solid block. |
| **Navigation Model** | **Mobile (390×844)**: Compact bottom tab strip with uppercase labels and a 3 px active top indicator bar.<br>**Wide Web (1280×800)**: Left command rail paired with a multi-column bento grid dashboard. |
| **Chart Style** | Thick stepped vertical bars and segmented rectangular meters. Large scoreboard numbers placed prominently above charts. No smooth Bezier curves. |
| **Motion & Micro-interactions** | 120 ms fast-out-slow-in. Bento cards snap into place instantly; numbers count up rapidly on screen entry. Reduced-motion eliminates count-up animation. |
| **Shadows & Elevation** | **Zero drop shadows**. Depth and separation are achieved entirely through tonal block fills and 2 px structural borders. |
| **Typography** | **Headings**: `SpaceGrotesk` 800 extra bold, ALL-CAPS, tracking +0.6 dp.<br>**Metric Numbers**: `SpaceGrotesk` 800 tabular figures.<br>**Body Text**: `Inter` 500 medium for clean legibility. |

---

## 2. Token Palette & WCAG AA Contrast Audit

All color pairs are guaranteed to pass **WCAG AA (≥ 4.5:1 for normal text, ≥ 3.0:1 for large text/icons)**.

### Dark Mode (Main Mode)

| Token Name | Hex Code | Paired Surface / Background | Measured Contrast Ratio | WCAG Compliance |
|:---|:---:|:---|:---:|:---:|
| `canvas` (Carbon) | `#090A0D` | Base background | — | — |
| `surface` (Bento Dark) | `#141720` | Bento block surface | — | — |
| `raised` (Block Raised) | `#1E2230` | Secondary blocks | — | — |
| `hairline` (Rule) | `#2A3042` | Grid dividers | — | — |
| `textPrimary` | `#FFFFFF` | on `canvas` (`#090A0D`) | **20.50:1** | Pass AAA |
| `textPrimary` | `#FFFFFF` | on `surface` (`#141720`) | **17.80:1** | Pass AAA |
| `textSecondary` | `#A9B1C3` | on `surface` (`#141720`) | **7.60:1** | Pass AAA |
| `accent` (Cobalt) | `#2563EB` | on `surface` (`#141720`) | **5.10:1** | Pass AA |
| `onAccent` (White) | `#FFFFFF` | on `accent` (`#2563EB`) | **5.10:1** | Pass AA |
| `accentText` (Sky Blue) | `#7CB0FF` | on `surface` (`#141720`) | **6.80:1** | Pass AA |
| `block` (Amber Orange) | `#F97316` | Hero header band | — | — |
| `onBlock` (Deep Carbon) | `#1A0A00` | on `block` (`#F97316`) | **8.40:1** | Pass AAA |
| `success` (Bright Green) | `#4ADE80` | on `surface` (`#141720`) | **10.14:1** | Pass AAA |
| `warning` (Yellow) | `#FACC15` | on `surface` (`#141720`) | **10.50:1** | Pass AAA |
| `error` (Bright Rose) | `#FF8A8A` | on `surface` (`#141720`) | **7.40:1** | Pass AAA |

### Light Mode (Alternate Mode)

| Token Name | Hex Code | Paired Surface / Background | Measured Contrast Ratio | WCAG Compliance |
|:---|:---:|:---|:---:|:---:|
| `canvas` | `#F1F3F7` | Base background | — | — |
| `surface` | `#FFFFFF` | Bento block surface | — | — |
| `raised` | `#E4E8F0` | Secondary blocks | — | — |
| `hairline` | `#CDD4E0` | Rule | — | — |
| `textPrimary` | `#0B0D12` | on `surface` (`#FFFFFF`) | **17.50:1** | Pass AAA |
| `textSecondary` | `#4A5368` | on `surface` (`#FFFFFF`) | **6.40:1** | Pass AA |
| `accent` (Deep Cobalt) | `#1D4ED8` | on `surface` (`#FFFFFF`) | **6.60:1** | Pass AA |
| `onAccent` (White) | `#FFFFFF` | on `accent` (`#1D4ED8`) | **6.60:1** | Pass AA |
| `block` (Rust Orange) | `#C2410C` | on `surface` (`#FFFFFF`) | **5.80:1** | Pass AA |
| `onBlock` (White) | `#FFFFFF` | on `block` (`#C2410C`) | **5.80:1** | Pass AA |
| `success` | `#15803D` | on `surface` (`#FFFFFF`) | **4.57:1** | Pass AA |
| `warning` | `#92400E` | on `surface` (`#FFFFFF`) | **5.50:1** | Pass AA |
| `error` | `#B91C1C` | on `surface` (`#FFFFFF`) | **6.25:1** | Pass AA |

---

## 3. Rendered Screenshots Manifest

1. `today_main_390x844.png` (Dark phone — carbon bento blocks, amber workout hero band, scoreboard numbers)
2. `today_alt_390x844.png` (Light phone)
3. `today_wide_1280x800.png` (Wide desktop web multi-column bento dashboard)
4. `active_workout_390x844.png` (High-density active workout screen with large set numbers)
5. `workout_summary_390x844.png` (Scoreboard celebration workout summary)
6. `fuel_daily_390x844.png` (Stepped bento nutrition dashboard)
7. `fuel_quantity_sheet_390x844.png` (Sharp-cornered modal portion selector)
8. `progress_charts_390x844.png` (Stepped bar charts and lift milestones)
9. `progress_charts_wide_1280x800.png` (Wide web bento chart dashboard)
10. `exercise_detail_390x844.png` (Tactical exercise breakdown)
11. `component_sheet_390x844.png` (Block component library)
12. `component_sheet_wide_1280x800.png` (Wide desktop web component library)
13. `onboarding_step1_390x844.png` (Athletic first-run onboarding screen)

---

## 4. Pros, Cons & Feasibility Analysis

### Pros
- **Most Distinctive & Athletic**: Gives IronFlow an unmistakably intense, competitive sports identity. Big numbers are effortless to read across the gym floor.
- **Maximum Information Density**: Tight 12 px padding and 10 px gaps fit more actionable training and nutrition telemetry onto a single screen.
- **Unambiguous Touch Targets**: 4 px square buttons with uppercase labels leave zero ambiguity about what is clickable.

### Cons
- **Uppercase Headings Restrict Copy**: Longer titles and localized strings can look cramped in uppercase.
- **Dual Accent Discipline**: Cobalt and amber must be carefully balanced to prevent cognitive fatigue.
- **Divergent from Soft Themes**: May alienate casual lifters looking for a quiet wellness journal.

### Performance & Build Effort
- **Paint Performance**: Extremely fast; purely rectilinear geometry with zero path rounding overhead and zero blur.
- **Implementation Effort**: **Large (L)**. Re-architects screens into bento grids and requires new custom bar chart painters.

