# Direction 3: Warm Studio Coach (`03-soft-layered`)

> **Concept:** Cleaned, gym-first evolution of the current Direction 4 palette — deep midnight charcoal (`#12131A`) and warm linen light (`#F8F6F2`), accessible Indigo (`#818CF8` / `#4F46E5`) + Emerald Mint (`#34D399` / `#047857`), with all legacy Stripe hexes (`#533AFD`), sci-fi meshes, and contrast failures removed.

---

## 1. Design Tokens & Geometry

| Spec | Value |
|:---|:---|
| **Default Mode** | Dark (`#12131A`), Warm Linen Light alternate (`#F8F6F2`) |
| **Radii** | Card `20 px` (safe on `360 px` viewports), Button `999 px` capsule pills, Padding `18 px`, Gap `16 px` |
| **Card Surface** | Soft layered elevation (`#1C1E28` dark / `#FFFFFF` light) with subtle drop shadow (no scrolling list blur) |
| **Why It Evolves Today Cleanly** | Lowest visual shock & fastest production rollout if keeping soft capsule warmth, while fixing every Wave 4 contrast, truncation, and copy issue |
| **Typography** | Numbers & headings: `SpaceGrotesk` (700 bold, tabular figures) • Labels & body: `Inter` (`assets/fonts/`) |

---

## 2. WCAG AA+ Contrast Audit (Measured Programmatically)

### Dark Mode

| Pair | Hex Values | Ratio | Grade |
|:---|:---|:---:|:---:|
| `textPrimary` / `canvas` | `#F4F6FB` on `#12131A` | **17.13:1** | AAA |
| `textPrimary` / `surface` | `#F4F6FB` on `#1C1E28` | **15.34:1** | AAA |
| `textSecondary` / `surface` | `#AAB2C5` on `#1C1E28` | **7.81:1** | AAA |
| `textMuted` / `surface` | `#848DA3` on `#1C1E28` | **4.99:1** | AA |
| `accent` / `surface` | `#818CF8` on `#1C1E28` | **5.56:1** | AA |
| `onAccent` / `accent` | `#0D1126` on `#818CF8` | **6.26:1** | AA |
| `secondaryAccent` / `surface` | `#34D399` on `#1C1E28` | **8.63:1** | AAA |
| `success` / `surface` | `#34D399` on `#1C1E28` | **8.63:1** | AAA |
| `warning` / `surface` | `#FB923C` on `#1C1E28` | **7.33:1** | AAA |
| `error` / `surface` | `#FB7185` on `#1C1E28` | **6.16:1** | AA |

### Light Mode

| Pair | Hex Values | Ratio | Grade |
|:---|:---|:---:|:---:|
| `textPrimary` / `surface` | `#181C24` on `#FFFFFF` | **17.07:1** | AAA |
| `textSecondary` / `surface` | `#3F4654` on `#FFFFFF` | **9.48:1** | AAA |
| `textMuted` / `surface` | `#565E6E` on `#FFFFFF` | **6.52:1** | AA |
| `accent` / `surface` | `#4F46E5` on `#FFFFFF` | **6.29:1** | AA |
| `onAccent` / `accent` | `#FFFFFF` on `#4F46E5` | **6.29:1** | AA |
| `secondaryAccent` / `surface` | `#047857` on `#FFFFFF` | **5.48:1** | AA |
| `success` / `surface` | `#047857` on `#FFFFFF` | **5.48:1** | AA |
| `warning` / `surface` | `#C2410C` on `#FFFFFF` | **5.18:1** | AA |
| `error` / `surface` | `#BE123C` on `#FFFFFF` | **6.29:1** | AA |

---

## 3. Rendered Flutter Captures (`lib/dev/design_lab/`)

- `today_main_390x844.png` / `today_alt_390x844.png` / `today_wide_1280x800.png`
- `active_workout_390x844.png`
- `fuel_daily_390x844.png`
- `progress_charts_390x844.png` / `progress_charts_wide_1280x800.png`
- `component_sheet_390x844.png` / `component_sheet_light_390x844.png`
