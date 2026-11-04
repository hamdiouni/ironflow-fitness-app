# IronFlow Design Reset: Redesign Gap Report

**Audit Date**: November 4, 2026  
**Target Branch**: `feat/design-reset`  
**Baseline Build**: `1.1.0+2` (Commit: `a0d01f7`, Date: 2026-11-04)  
**Target Level**: L4 across all primary screens and component groups

---

## 1. Executive Summary & Diagnosis

The previous iteration updated theme tokens, palette colors, and typography (Stripe-inspired minimal hairlines, tabular numerals, and muted neutral panels). However, the app **still looks and feels like the original monolithic design** because:

1. **Shared Skeleton Monotony**: 14 of 18 screens share the exact same skeleton:
   `[AppHeader / Title + Icon] -> [Vertical SingleChildScrollView] -> [Stack of 3-6 bordered AppCards] -> [Sticky Full-Width Primary AppButton]`.
2. **Excessive Nested Frames**: Cards frequently contain nested containers, chip rows with background fills, and sub-panels, producing a heavy, box-inside-a-box visual hierarchy.
3. **Verbose Text**: Screens carry explanatory paragraphs (30-80 words per card) rather than concise telemetry and glanceable data.
4. **Lack of Motion Personality**: Animations are limited to default page switches or static layout rendering. Missing count-up data transitions, smooth tab sliding indicators, chart draw-in animations, tactile button compression feedback, and progressive disclosure sheets.

---

## 2. Maturity Level Definitions

| Level | Name | Description |
|---|---|---|
| **L0** | Untouched | Legacy design, hardcoded colors, unmigrated styles. |
| **L1** | Colors Only | Raw colors replaced with theme tokens; layouts and components untouched. |
| **L2** | Shared Components Swapped | Swapped into generic design system components (`AppButton`, `AppCard`) but retaining the legacy skeleton and frame hierarchy. |
| **L3** | Structure Changed | Brand-new layout pattern (e.g. Bento grid, focused split hero, sticky progress dock, contextual actions) replacing the card stack. |
| **L4** | Structure + Motion + Short Text | New structure + purposeful micro-motion (count-ups, chart draw-in, springs, tactile states) + strict short-text budget (title ≤ 3 words, helper ≤ 12 words, button ≤ 3 words). |

---

## 3. Screen-by-Screen Gap Audit

### 3.1 Primary Navigation Shell

| Screen | File Path | Current Level | Layout Pattern (Skeleton) | Nested Frames | Word Count | Motion State | Target Level |
|---|---|---|---|---|---|---|---|
| **Today (Home)** | `lib/features/workout/presentation/screens/home_screen.dart` | **L2** | AppHeader + Hero Card + Stack of Cards (Consistency, Workout, Nutrition, Quick Actions) | 4 levels | ~340 words | Static cards, standard refresh | **L4** |
| **Active Workout** | `lib/features/workout/presentation/screens/active_workout_screen.dart` | **L2** | Timer Banner + Exercise Card Stack + Set Input Matrix + Complete Button | 4 levels | ~220 words | Basic timer tick, no set completion spring | **L4** |
| **Workout Summary** | `lib/features/workout/presentation/screens/workout_summary_screen.dart` | **L2** | Celebration Hero + Volume Stats Card + Exercise List Card Stack + Done Button | 3 levels | ~190 words | Confetti/lottie, no stat count-up | **L4** |
| **Workout Hub** | `lib/features/workout/presentation/screens/workout_screen.dart` | **L2** | Segmented Control + List of Program/Workout Cards + Big Floating Action | 3 levels | ~280 words | Static tab switch | **L4** |
| **Workout History** | `lib/features/workout/presentation/screens/workout_history_screen.dart` | **L2** | Month Filter Bar + Infinite Scroll Card List | 3 levels | ~160 words | Standard list scroll | **L4** |
| **Exercise Catalog** | `lib/features/workout/presentation/screens/exercise_catalog_screen.dart` | **L2** | Search Bar + Horizontal Muscle Chips + 2-Column Grid of Cards | 3 levels | ~210 words | Chip selection fade | **L4** |
| **Exercise Detail** | `lib/features/workout/presentation/screens/exercise_detail_screen.dart` | **L2** | Video/Header + Muscle Map Card + Instructions Card Stack + Add Button | 4 levels | ~410 words | Video player controls | **L4** |
| **Fuel / Nutrition** | `lib/features/nutrition/presentation/screens/nutrition_screen.dart` | **L2** | Date Scroller + Macro Progress Ring + 4 Meal Cards (Breakfast, Lunch, Dinner, Snacks) | 4 levels | ~310 words | Static progress bars | **L4** |
| **Food Search & Log** | `lib/features/nutrition/presentation/screens/food_search_screen.dart` | **L2** | Search Field + Filter Chips + Food Tile List + Floating Scanner CTA | 3 levels | ~180 words | List item filter | **L4** |
| **Progress / Telemetry** | `lib/features/body/presentation/screens/progress_screen.dart` | **L2** | 3-Tab Header (Lifts, Weight, Body) + Big FL Chart Card + History Table Card | 4 levels | ~290 words | Chart default hover tooltip | **L4** |
| **Profile** | `lib/features/auth/presentation/screens/profile_screen.dart` | **L2** | Avatar Card + Biometrics Card Stack + Account Settings Action Stack | 3 levels | ~150 words | None | **L4** |
| **Settings** | `lib/features/settings/presentation/screens/settings_screen.dart` | **L2** | 7-Section List of grouped tiles + About Section | 3 levels | ~460 words | Toggle switches | **L4** |

---

### 3.2 Secondary Sheets, Tools & Modals

| Screen / Component | File Path | Current Level | Layout Pattern (Skeleton) | Nested Frames | Word Count | Motion State | Target Level |
|---|---|---|---|---|---|---|---|
| **Plate Calculator** | `.../widgets/plate_calculator_sheet.dart` | **L2** | Barbell Graphic + Weight Input + Plate Breakdown List + Apply Button | 3 levels | ~95 words | None | **L4** |
| **Quantity Sheet** | `.../presentation/widgets/quantity_sheet.dart` | **L2** | Title + Stepper Row + Quick Portion Chips + Log Button | 3 levels | ~65 words | Quick chip tap | **L4** |
| **Program Editor** | `.../presentation/screens/program_editor_screen.dart` | **L2** | Header + 7-Day Matrix Card + Exercise Stack + Save Button | 4 levels | ~320 words | Reorder list drag | **L4** |
| **AI Coach Chat** | `.../features/ai/presentation/screens/ai_chat_screen.dart` | **L2** | Message Bubble Stream + Quick Suggestion Pills + Input Bar | 2 levels | Dynamic | Typing indicator dots | **L4** |
| **Login / Sign In** | `.../features/auth/presentation/screens/login_screen.dart` | **L2** | Header Mesh Badge + Form Card (Email, Password) + Social Sign-in Stack | 3 levels | ~140 words | Mesh gradient shimmer | **L4** |
| **Onboarding Step 1** | `.../features/onboarding/presentation/screens/onboarding_screen.dart` | **L2** | Step Indicator + Big Illustration + Choice Chips + Next Button | 3 levels | ~110 words | Page transition slide | **L4** |

---

## 4. Component Group Audit

| Component Group | Current Style | Deficiencies | L4 Target Requirements |
|---|---|---|---|
| **Buttons (`AppButton`)** | Flat pill with subtle border | No physical compression feel on press, text sometimes wraps, icons poorly aligned | Micro-spring bounce on press, strict 3-word limit, crisp icon-to-text optical balance |
| **Surfaces (`AppCard`)** | Bordered panel with borderSubtle | Nested cards create visually cluttered depth; borders used defensively everywhere | Frame-light surface architecture (single surface level per section, zero nested cards, hairlines for active/selected only) |
| **Inputs (`TextFormField`)** | Outlined rounded pill with borderSubtle | Focus border transitions are harsh; validation error text jumps abruptly | Smooth 150ms focus aura expansion, inline animated error reflow |
| **Chips & Toggles** | Pill chips with background fill | Too dense, poor touch target spacing, relies primarily on background color | Wrapping auto-flow layout, distinct checkmark icon + color for accessibility, min 44pt hit targets |
| **Charts (`ProgressChart`, `MacroChart`)** | Default `fl_chart` line/bar | Abrupt static appearance on screen open; no draw-in; small touch targets | Staggered bezier path draw-in animation (400ms ease-out), glowing active scrub cursor, tabular numeral popover |
| **Typography & Numerals** | Inter + Space Grotesk | Long sentences, small body text inside cards, numerals not aligned tabularly | Tabular numbers for all weights/reps/calories, strict short text budget across all views |

---

## 5. Structural Breakdown: The "Card Stack" Problem

Currently, **78% of the application's primary views** share this exact nested layout:

```
┌──────────────────────────────────────────────┐
│ Header (Title + Subtitle + Action Icon)      │
├──────────────────────────────────────────────┤
│ ┌──────────────────────────────────────────┐ │
│ │ Card 1: Status / Hero Metric             │ │
│ │   ┌────────────────────────────────────┐ │ │  <- 3-4 nested frames!
│ │   │ Nested Container / Progress Bar    │ │ │
│ │   └────────────────────────────────────┘ │ │
│ └──────────────────────────────────────────┘ │
│ ┌──────────────────────────────────────────┐ │
│ │ Card 2: Main Activity / List             │ │
│ └──────────────────────────────────────────┘ │
│ ┌──────────────────────────────────────────┐ │
│ │ Card 3: Secondary Telemetry              │ │
│ └──────────────────────────────────────────┘ │
│ [ Big Full-Width Bottom Action Button ]      │
└──────────────────────────────────────────────┘
```

### Required Structural Shifts for L4
1. **Direction A (Stripe Refined)**: Clean hairline dividers, single background elevation, flush edge-to-edge modular sections, zero nested cards.
2. **Direction B (Bento Dashboard)**: Asymmetric bento grid with proportional visual weight (2x2 hero block + 1x2 secondary metrics + compact micro-dials).
3. **Direction C (Nordic Calm / Soft Layered)**: Soft tonal surfaces, generous negative space, floating action pills, serene progress curves.
4. **Direction D (Kinetic Athletic / High Performance)**: Dynamic angled headers, bold numerical focal points, high-contrast energetic accents, tactile bottom dock.

---

## 6. Action Plan to Reach L4 Across All Views

1. **Step 3 (Research)**: Execute UI UX Pro Max domain and design system runs; extract tokens and motion specs into `docs/design-research/`.
2. **Step 4 (Design Lab & 4 Directions)**: Implement Directions A, B, C, D in `lib/dev/design_lab/main_design_lab.dart` with fake data, working motion (count-up, chart draw-in, page transitions, sheet expansion), and side-by-side screenshots.
3. **Step 5 (Full App Migration)**: Apply the chosen design system across all screens, dismantling the card-in-card hierarchy, enforcing short English text, and adding micro-motion.

