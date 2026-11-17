# Direction 2: Iron Scoreboard (`02-kinetic-block`)

> **Concept:** High-contrast gym scoreboard — matte rack charcoal (`#0A0B0E` / `#14171D`), Signal Amber primary actions (`#F59E0B`), Cobalt Steel timers (`#60A5FA`), crisp `8 px` bordered blocks, and uppercase tactile CTAs readable at arm's length.

---

## 1. Design Tokens & Geometry

| Spec | Value |
|:---|:---|
| **Default Mode** | Dark (`#0A0B0E`), Crisp Slate-Gray Light alternate (`#F3F4F6`) |
| **Radii** | Card `8 px`, Button `6 px`, Padding `12 px`, Gap `10 px` |
| **Card Surface** | High-contrast `#14171D` with `1 px` crisp structural border (`#2D3340`), zero drop shadows |
| **Active Workout Pattern** | Bold tabular weights/reps (`16–17 sp` compact grid + `24 sp` 1RM scoreboard on desktop), Signal Amber active-row emphasis, Cobalt Steel rest timer |
| **Typography** | Numbers & headings: `SpaceGrotesk` (700 bold, tabular figures) • Labels & body: `Inter` (`assets/fonts/`) |

---

## 2. WCAG AA+ Contrast Audit (Measured Programmatically)

### Dark Mode

| Pair | Hex Values | Ratio | Grade |
|:---|:---|:---:|:---:|
| `textPrimary` / `canvas` | `#F8FAFC` on `#0A0B0E` | **18.81:1** | AAA |
| `textPrimary` / `surface` | `#F8FAFC` on `#14171D` | **17.15:1** | AAA |
| `textSecondary` / `surface` | `#B3BCC9` on `#14171D` | **9.36:1** | AAA |
| `textMuted` / `surface` | `#8A94A3` on `#14171D` | **5.85:1** | AA |
| `accent` / `surface` | `#F59E0B` on `#14171D` | **8.36:1** | AAA |
| `onAccent` / `accent` | `#111216` on `#F59E0B` | **8.72:1** | AAA |
| `secondaryAccent` / `surface` | `#60A5FA` on `#14171D` | **7.06:1** | AAA |
| `success` / `surface` | `#4ADE80` on `#14171D` | **10.30:1** | AAA |
| `warning` / `surface` | `#FBBF24` on `#14171D` | **10.75:1** | AAA |
| `error` / `surface` | `#F87171` on `#14171D` | **6.49:1** | AA |

### Light Mode

| Pair | Hex Values | Ratio | Grade |
|:---|:---|:---:|:---:|
| `textPrimary` / `surface` | `#111827` on `#FFFFFF` | **17.74:1** | AAA |
| `textSecondary` / `surface` | `#374151` on `#FFFFFF` | **10.31:1** | AAA |
| `textMuted` / `surface` | `#4B5563` on `#FFFFFF` | **7.56:1** | AAA |
| `accent` / `surface` | `#C2410C` on `#FFFFFF` | **5.18:1** | AA |
| `onAccent` / `accent` | `#FFFFFF` on `#C2410C` | **5.18:1** | AA |
| `secondaryAccent` / `surface` | `#1D4ED8` on `#FFFFFF` | **6.70:1** | AA |
| `success` / `surface` | `#15803D` on `#FFFFFF` | **5.02:1** | AA |
| `warning` / `surface` | `#B45309` on `#FFFFFF` | **5.02:1** | AA |
| `error` / `surface` | `#B91C1C` on `#FFFFFF` | **6.47:1** | AA |

---

## 3. Rendered Flutter Captures (`lib/dev/design_lab/`)

- `today_main_390x844.png` / `today_alt_390x844.png` / `today_wide_1280x800.png`
- `active_workout_390x844.png`
- `fuel_daily_390x844.png`
- `progress_charts_390x844.png` / `progress_charts_wide_1280x800.png`
- `component_sheet_390x844.png` / `component_sheet_light_390x844.png`
