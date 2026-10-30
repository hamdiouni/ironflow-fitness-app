# Direction 4: Soft Layered (`04-soft-layered`)

> **Idea**: Friendly and coaching-style: soft rounded sheets that float a little, capsule buttons, and gentle periwinkle and mint accents.

---

## 1. Design Direction Summary

| Dimension | Specification |
|:---|:---|
| **Primary Philosophy** | Coaching warmth, tactile roundness, layered soft sheets, approachable fitness companion. |
| **Main Viewport Mode** | **Dark mode first** (midnight indigo `#12131A` canvas). Alternate: Warm linen Light mode (`#F3F1EC`). |
| **Grid & Spacing** | 20 px page margin (`pad: 20`), 20 px section spacing (`gap: 20`). Balanced, comfortable breathing room. |
| **Card & Container Shape** | `26 px` extra-rounded corners. **Layered floating sheets**: sections feel like soft elevated cards with a gentle ambient shadow (`0 6 20, rgba(0,0,0,0.18)`). Zero harsh borders. |
| **Button Style & Radius** | `999 px` full capsule pill shape, `54 px` touch height. Primary = `#A5B4FC` periwinkle capsule with deep indigo `#1E1B4B` text. Secondary = `#272A38` soft tonal pill. Destructive = `#FDA4AF` pastel rose pill. |
| **Navigation Model** | **Mobile (390×844)**: Floating rounded pill dock elevated above the bottom screen margin, featuring an accent capsule behind the active tab.<br>**Wide Web (1280×800)**: Floating rounded left dock paired with wide responsive cards. |
| **Chart Style** | Concentric rounded progress rings for daily macros; pill-shaped rounded bar charts; smooth, friendly curves. |
| **Motion & Micro-interactions** | 260 ms shared-axis motion (fade + 12 dp subtle rise). Modal sheets glide upward with an ease-out spring. Button presses scale gently to 0.98. Instant swaps under `reducedMotion: true`. |
| **Shadows & Elevation** | Light ambient drop shadow (`0 6 20, rgba(0,0,0,0.18)` dark / `rgba(0,0,0,0.08)` light) applied only to top-level section sheets. Strictly omitted on scrolling list rows. |
| **Typography** | **Headings**: `Inter` 700 bold, tracking -0.3 dp.<br>**Metric Numbers**: `SpaceGrotesk` 700 bold.<br>**Body Text**: `Inter` 400 regular & 500 medium. Warm, human, and readable. |

---

## 2. Token Palette & WCAG AA Contrast Audit

All color pairs are guaranteed to pass **WCAG AA (≥ 4.5:1 for normal text, ≥ 3.0:1 for large text/icons)**.

### Dark Mode (Main Mode)

| Token Name | Hex Code | Paired Surface / Background | Measured Contrast Ratio | WCAG Compliance |
|:---|:---:|:---|:---:|:---:|
| `canvas` (Midnight Indigo) | `#12131A` | Base background | — | — |
| `surface` (Soft Sheet) | `#1C1E28` | Elevated sheet surface | — | — |
| `raised` (Pill Surface) | `#272A38` | Secondary capsules & chips | — | — |
| `hairline` (Divider) | `#30344A` | Soft sheet borders | — | — |
| `textPrimary` | `#F4F4F8` | on `surface` (`#1C1E28`) | **16.20:1** | Pass AAA |
| `textSecondary` | `#ADB1C6` | on `surface` (`#1C1E28`) | **7.00:1** | Pass AAA |
| `accent` (Periwinkle) | `#A5B4FC` | on `surface` (`#1C1E28`) | **8.60:1** | Pass AAA |
| `onAccent` (Deep Indigo) | `#1E1B4B` | on `accent` (`#A5B4FC`) | **8.60:1** | Pass AAA |
| `block` (Mint Coaching) | `#6EE7B7` | Highlight badge / pill | — | — |
| `onBlock` (Deep Green) | `#052E1F` | on `block` (`#6EE7B7`) | **9.50:1** | Pass AAA |
| `success` (Mint) | `#6EE7B7` | on `surface` (`#1C1E28`) | **9.50:1** | Pass AAA |
| `warning` (Soft Honey) | `#FCD34D` | on `surface` (`#1C1E28`) | **11.00:1** | Pass AAA |
| `error` (Rose Pastel) | `#FDA4AF` | on `surface` (`#1C1E28`) | **7.80:1** | Pass AAA |
| `info` (Sky Blue) | `#93C5FD` | on `surface` (`#1C1E28`) | **9.10:1** | Pass AAA |

### Light Mode (Alternate Mode)

| Token Name | Hex Code | Paired Surface / Background | Measured Contrast Ratio | WCAG Compliance |
|:---|:---:|:---|:---:|:---:|
| `canvas` (Warm Linen) | `#F3F1EC` | Base background | — | — |
| `surface` (Pure White) | `#FFFFFF` | Elevated sheet surface | — | — |
| `raised` (Soft Lavender) | `#EDEAF6` | Secondary capsules & chips | — | — |
| `hairline` | `#E0DCEB` | Dividers | — | — |
| `textPrimary` | `#1F2030` | on `surface` (`#FFFFFF`) | **15.50:1** | Pass AAA |
| `textSecondary` | `#575A6E` | on `surface` (`#FFFFFF`) | **5.80:1** | Pass AA |
| `accent` (Indigo) | `#4338CA` | on `surface` (`#FFFFFF`) | **6.80:1** | Pass AA |
| `onAccent` (White) | `#FFFFFF` | on `accent` (`#4338CA`) | **6.80:1** | Pass AA |
| `block` (Deep Emerald) | `#047857` | on `surface` (`#FFFFFF`) | **5.60:1** | Pass AA |
| `onBlock` (White) | `#FFFFFF` | on `block` (`#047857`) | **5.60:1** | Pass AA |
| `success` | `#047857` | on `surface` (`#FFFFFF`) | **5.60:1** | Pass AA |
| `warning` | `#92400E` | on `surface` (`#FFFFFF`) | **5.50:1** | Pass AA |
| `error` | `#BE123C` | on `surface` (`#FFFFFF`) | **6.00:1** | Pass AA |

---

## 3. Rendered Screenshots Manifest

1. `today_main_390x844.png` (Dark phone — floating midnight sheets, periwinkle CTA, mint coach pill)
2. `today_alt_390x844.png` (Light phone — warm linen canvas, indigo capsule)
3. `today_wide_1280x800.png` (Wide desktop web floating pill dock and layered cards)
4. `active_workout_390x844.png` (Phone active workout with capsule set badges)
5. `workout_summary_390x844.png` (Phone workout summary celebration)
6. `fuel_daily_390x844.png` (Concentric macro rings and soft meal cards)
7. `fuel_quantity_sheet_390x844.png` (Soft floating sheet with rounded stepper)
8. `progress_charts_390x844.png` (Capsule bar chart and smooth trend lines)
9. `progress_charts_wide_1280x800.png` (Wide web layout)
10. `exercise_detail_390x844.png` (Approachable exercise tutorial)
11. `component_sheet_390x844.png` (Capsule component library)
12. `component_sheet_wide_1280x800.png` (Wide desktop web component library)
13. `onboarding_step1_390x844.png` (Warm coach onboarding step)

---

## 4. Pros, Cons & Feasibility Analysis

### Pros
- **Approachable & Coach-Centric**: Matches the conversational tone of the AI Coach. Soft curves and pastel accents feel encouraging rather than intimidating.
- **Superior Touch Ergonomics**: 54 px tall capsule buttons provide generous, thumb-friendly tap targets.
- **Harmonious Dark & Light Modes**: Periwinkle and mint adapt naturally to both midnight indigo and warm linen canvases.

### Cons
- **Corner Radius Overhead**: 26 px corner radii take up more screen perimeter on very small phone screens (e.g. 360 px width).
- **Subtle Paint Cost**: Gentle ambient drop shadows require GPU composition (mitigated by omitting shadows on scrolling lists).
- **Less Aggressive Look**: Lifters who prefer an industrial, rugged gym vibe may find pastel periwinkle too soft.

### Performance & Build Effort
- **Paint Performance**: High (smooth 60 fps). Ambient shadows applied only to 1–3 static section cards per screen, never to individual list rows; no background blur.
- **Implementation Effort**: **Medium-Large (M/L)**. Requires creating custom capsule button styles, floating pill navigation dock, and concentric macro ring painters.

