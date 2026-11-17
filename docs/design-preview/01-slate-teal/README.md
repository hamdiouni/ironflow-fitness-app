# Direction 1: Slate Teal Minimal (`01-slate-teal`)

> **Concept:** Calm, low-glare gym minimalism — cool obsidian slate surfaces (`#0B1218` / `#131D26`), one crisp electric teal action accent (`#2DD4BF`), zero decorative shadows, and fast scannable set tables.

---

## 1. Design Tokens & Geometry

| Spec | Value |
|:---|:---|
| **Default Mode** | Dark (`#0B1218`), Crisp Slate Light alternate (`#F4F7F9`) |
| **Radii** | Card `14 px`, Button `12 px`, Padding `16 px`, Gap `14 px` |
| **Card Surface** | Flat tonal step (`#131D26` over `#0B1218`), zero drop shadows, highlight border on active workout card only |
| **Active Workout Pattern** | Uncluttered top bar (`Upper Body • 24:18`), inline `SET | PREVIOUS | KG | REPS | DONE` matrix with `+/-2.5` steppers, sticky bottom rest timer bar |
| **Typography** | Numbers & headings: `SpaceGrotesk` (700 bold, tabular figures) • Labels & body: `Inter` (`assets/fonts/`) |

---

## 2. WCAG AA+ Contrast Audit (Measured Programmatically)

### Dark Mode

| Pair | Hex Values | Ratio | Grade |
|:---|:---|:---:|:---:|
| `textPrimary` / `canvas` | `#F1F5F9` on `#0B1218` | **17.21:1** | AAA |
| `textPrimary` / `surface` | `#F1F5F9` on `#131D26` | **15.57:1** | AAA |
| `textSecondary` / `surface` | `#A7B7C9` on `#131D26` | **8.33:1** | AAA |
| `textMuted` / `surface` | `#8395A7` on `#131D26` | **5.54:1** | AA |
| `accent` / `surface` | `#2DD4BF` on `#131D26` | **9.16:1** | AAA |
| `onAccent` / `accent` | `#042F2E` on `#2DD4BF` | **7.77:1** | AAA |
| `secondaryAccent` / `surface` | `#60A5FA` on `#131D26` | **6.71:1** | AA |
| `success` / `surface` | `#4ADE80` on `#131D26` | **9.79:1** | AAA |
| `warning` / `surface` | `#FBBF24` on `#131D26` | **10.22:1** | AAA |
| `error` / `surface` | `#F87171` on `#131D26` | **6.17:1** | AA |

### Light Mode

| Pair | Hex Values | Ratio | Grade |
|:---|:---|:---:|:---:|
| `textPrimary` / `surface` | `#0F172A` on `#FFFFFF` | **17.85:1** | AAA |
| `textSecondary` / `surface` | `#334155` on `#FFFFFF` | **10.35:1** | AAA |
| `textMuted` / `surface` | `#526377` on `#FFFFFF` | **6.16:1** | AA |
| `accent` / `surface` | `#0F766E` on `#FFFFFF` | **5.47:1** | AA |
| `onAccent` / `accent` | `#FFFFFF` on `#0F766E` | **5.47:1** | AA |
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
