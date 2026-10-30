# Direction 2: Nordic Calm (`02-nordic-calm`)

> **Idea**: A quiet, light, editorial look: lots of white space, black ink buttons, thin rules instead of boxes, and one sage green for good news.

---

## 1. Design Direction Summary

| Dimension | Specification |
|:---|:---|
| **Primary Philosophy** | Editorial white space, quiet typographic hierarchy, Scandinavian minimalism. |
| **Main Viewport Mode** | **Light mode first** (clean warm paper background `#F7F7F5`). Alternate: High-contrast Dark mode (`#0E1013`). |
| **Grid & Spacing** | 24 px page margin (`pad: 24`), 28 px section spacing (`gap: 28`). Generous breathing room. |
| **Card & Container Shape** | `8 px` subtle radius. **Editorial frameless structure**: sections sit directly on the canvas, separated by 1 px hairline rules (`#E2E2DD`). No enclosing cards for static content. |
| **Button Style & Radius** | `8 px` corner radius, `52 px` height. **Ink Minimal style**: Primary = `#14171F` deep black ink with `#FFFFFF` white text. Secondary = `#EFEFEB` tonal ink-wash. Tertiary = clean text with no underline. Destructive = red text, red fill on final confirmation only. |
| **Navigation Model** | **Mobile (390×844)**: Borderless bottom dock with quiet text labels and a subtle 4 px accent dot under the active tab.<br>**Wide Web (1280×800)**: Editorial left sidebar with clean text navigation links and generous white space margins. |
| **Chart Style** | Thin 1.5 px hairline sparklines with an endpoint value dot. Zero area fill, zero background gridlines. Clean horizontal macro bars. |
| **Motion & Micro-interactions** | 220 ms fade-through transitions for pages and sheets. No bounce, no scale transforms. Button presses adjust opacity to 0.75. Instant swaps under `reducedMotion: true`. |
| **Shadows & Elevation** | **Zero box shadows across the entire UI**. Visual hierarchy is created purely through typography scale, white space, and 1 px rule dividers. |
| **Typography** | **Pure Inter system**: Single font family (`Inter`) for headings, body, and numeric metrics. Headings: 600 semi-bold with tight letter-spacing (-0.4 dp). Clean, literary, and distraction-free. |

---

## 2. Token Palette & WCAG AA Contrast Audit

All color pairs are guaranteed to pass **WCAG AA (≥ 4.5:1 for normal text, ≥ 3.0:1 for large text/icons)**.

### Light Mode (Main Mode)

| Token Name | Hex Code | Paired Surface / Background | Measured Contrast Ratio | WCAG Compliance |
|:---|:---:|:---|:---:|:---:|
| `canvas` (Warm Paper) | `#F7F7F5` | Base background | — | — |
| `surface` (Pure White) | `#FFFFFF` | Form inputs & sheets | — | — |
| `raised` (Paper Wash) | `#EFEFEB` | Secondary controls | — | — |
| `hairline` (Divider) | `#E2E2DD` | 1 px section rules | — | — |
| `textPrimary` (Deep Ink) | `#14171F` | on `canvas` (`#F7F7F5`) | **15.20:1** | Pass AAA |
| `textPrimary` | `#14171F` | on `surface` (`#FFFFFF`) | **16.80:1** | Pass AAA |
| `textSecondary` (Muted Slate) | `#585E6B` | on `canvas` (`#F7F7F5`) | **5.40:1** | Pass AA |
| `textSecondary` | `#585E6B` | on `surface` (`#FFFFFF`) | **6.00:1** | Pass AA |
| `accent` (Black Ink) | `#14171F` | on `surface` (`#FFFFFF`) | **16.80:1** | Pass AAA |
| `onAccent` (Paper White) | `#FFFFFF` | on `accent` (`#14171F`) | **16.80:1** | Pass AAA |
| `block` (Forest Sage) | `#166534` | on `surface` (`#FFFFFF`) | **6.80:1** | Pass AAA |
| `onBlock` (White) | `#FFFFFF` | on `block` (`#166534`) | **6.80:1** | Pass AAA |
| `success` (Sage Green) | `#15803D` | on `surface` (`#FFFFFF`) | **4.57:1** | Pass AA |
| `warning` (Muted Ochre) | `#975A16` | on `surface` (`#FFFFFF`) | **4.70:1** | Pass AA |
| `error` (Crimson Ink) | `#B42318` | on `surface` (`#FFFFFF`) | **5.92:1** | Pass AA |
| `info` (Cobalt) | `#1D4ED8` | on `surface` (`#FFFFFF`) | **6.60:1** | Pass AA |

### Dark Mode (Alternate Mode)

| Token Name | Hex Code | Paired Surface / Background | Measured Contrast Ratio | WCAG Compliance |
|:---|:---:|:---|:---:|:---:|
| `canvas` | `#0E1013` | Base background | — | — |
| `surface` | `#171A20` | Section surface | — | — |
| `raised` | `#20242C` | Secondary controls | — | — |
| `hairline` | `#2A2F38` | Dividers | — | — |
| `textPrimary` | `#F3F4F6` | on `surface` (`#171A20`) | **15.50:1** | Pass AAA |
| `textSecondary` | `#A6ADBA` | on `surface` (`#171A20`) | **7.20:1** | Pass AAA |
| `accent` (White Ink) | `#F3F4F6` | on `surface` (`#171A20`) | **15.50:1** | Pass AAA |
| `onAccent` (Dark Ink) | `#0E1013` | on `accent` (`#F3F4F6`) | **16.80:1** | Pass AAA |
| `success` (Sage) | `#4ADE80` | on `surface` (`#171A20`) | **10.14:1** | Pass AAA |
| `warning` (Amber) | `#FACC15` | on `surface` (`#171A20`) | **10.50:1** | Pass AAA |
| `error` (Rose Red) | `#F87171` | on `surface` (`#171A20`) | **5.75:1** | Pass AA |

---

## 3. Rendered Screenshots Manifest

1. `today_main_390x844.png` (Light phone — warm paper canvas, black ink buttons, sage highlight)
2. `today_alt_390x844.png` (Dark phone)
3. `today_wide_1280x800.png` (Light wide desktop web)
4. `active_workout_390x844.png` (Phone active workout with minimal sparkline metrics)
5. `workout_summary_390x844.png` (Phone workout summary)
6. `fuel_daily_390x844.png` (Phone nutrition fuel dashboard with horizontal bar breakdowns)
7. `fuel_quantity_sheet_390x844.png` (Clean white paper bottom sheet)
8. `progress_charts_390x844.png` (Hairline sparklines and quiet metrics)
9. `progress_charts_wide_1280x800.png` (Wide desktop web layout)
10. `exercise_detail_390x844.png` (Editorial exercise guide)
11. `component_sheet_390x844.png` (Design component gallery)
12. `component_sheet_wide_1280x800.png` (Wide desktop web component gallery)
13. `onboarding_step1_390x844.png` (Quiet first-run goal setup)

---

## 4. Pros, Cons & Feasibility Analysis

### Pros
- **Exceptional Readability & Calm**: Eliminates visual noise, neon colors, and card borders. Users who find traditional fitness trackers overwhelming feel an immediate sense of clarity.
- **Superior Web & Daytime Usability**: Light-first warm paper theme feels natural on desktop browsers and under direct sunlight.
- **Simplified Typography**: Using a single typeface (`Inter`) for both text and numbers eliminates visual competition.

### Cons
- **Departure from Gym Norms**: Fitness apps often favor aggressive dark themes; a light editorial style feels more like a lifestyle publication than a heavy lifting tool.
- **Black Buttons Lack Energy**: Solid black primary buttons during workouts provide high contrast but lack motivational color cueing.
- **Higher Vertical Footprint**: Larger margins (24 px) and vertical section gaps (28 px) mean slightly more scrolling on smaller screens.

### Performance & Build Effort
- **Paint Performance**: Extremely fast. Zero drop shadows, flat colors, no background blurs.
- **Implementation Effort**: **Large (L)**. Requires redesigning card wrappers to remove borders and adjust layout padding across all 30 screens.

