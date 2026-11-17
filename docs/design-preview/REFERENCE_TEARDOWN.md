# Public-Information Gym UI Reference Teardown (Wave 4.1)

> **Source Integrity Statement:** Every observation below is derived **strictly from public information** — official product websites (`strong.app`, `hevyapp.com`, `macrofactorapp.com`), public Apple App Store / Google Play store listings and screenshots, and public UX case studies (`builtformars.com`). Zero binaries, APKs, proprietary assets, or internal schemas were inspected or extracted. All proposed IronFlow directions use 100% original layout compositions, tokens, typography, and plain English copy.

---

## 1. Public Competitor Pattern Study

| App (Public Source) | Core Strength in Public UI | Gym-Floor Ergonomic Choice | Applicable Lesson for IronFlow |
|:---|:---|:---|:---|
| **Hevy** (`hevyapp.com` / App Store listing) | **1-Screen Set Matrix + Auto-Rest Timer** | Compact row alignment (`Set | Previous | kg | Reps | ✓`) with color-coded set-type pills (`W / N / D / F`), inline rest countdown badge, and visible historical benchmark right beside input fields. | Replace IronFlow's tall stacked per-exercise logging cards and overflowing AppBar (`ACTIVE WORK...`) with an uncluttered top timer bar + scannable set matrix and sticky rest timer. |
| **Strong** (`strong.app` / public UX reviews) | **Calm, High-Contrast Speed ("Hammer" Tooling)** | Quiet slate/dark charcoal surfaces paired with one unmistakable confirmation tint; large numeric touch targets; zero decorative gradients, ambient glow halos, or sci-fi prose. | Strip decorative gradient meshes (`stripe_gradient_mesh.dart`), multi-layer glow borders, and jargon (`telemetry`, `protocol`, `initializing`, `monolithic`) so the focus stays on numbers under gym lights. |
| **MacroFactor / MacroFactor Workouts** (`macrofactor.com` / `builtformars.com`) | **Frictionless Search + Progressive Disclosure** | Single-bar unified food search mixing user custom/recent foods alongside database staples, rapid inline weight/portion steppers, and friendly natural coach phrasing instead of machine logs. | Merge custom foods directly into `filteredFoodProvider` search, state clearly where custom foods save, replace static `80+` / `50+` claims with true dynamic counts (`129` exercises, `282+` foods), and surface friendly plain-English coach guidance without leaking internal snake_case keys (`workouts_this_week`). |
| **Multi-Pane Web & Tablet Trackers** | **Widescreen Mastery** | Dedicated left navigation rail + two-column master-detail layouts (`exercise list / live log` or `lift charts / distribution`) rather than stretching a single narrow phone column across `1280 px`. | Keep mobile screens compact (tested down to `360 px` and `1.5x` text scale), and unlock structured 2-pane split layouts at `>= 900 px` plus keyboard shortcuts during active training on desktop/web. |

---

## 2. Specific Weaknesses Observed in IronFlow Today (`7253415`)

Audited directly on live commits (`feat/prod-v2-wave-4` at `7253415`) before any Wave 4 production changes:

1. **Fragmented Visual Identity:** `app_colors.dart` still mixes legacy Stripe indigo (`#533AFD`, `stripe_gradient_mesh.dart`) with low-contrast pastel periwinkle (`#A5B4FC`), while `Settings` and `DesignGalleryScreen` still mention `'MONOLITHIC SCI-FI'` and `'STRIPE DESIGN SYSTEM'`.
2. **Active Workout Overhead:** `ActiveWorkoutScreen` AppBar (`current_active_workout_390x844.png`) truncates `"ACTIVE WORK..."` on `390 px` screens, stacks heavy full-width per-card buttons, and hardcodes `WeightUnit.kg` locally instead of respecting user settings.
3. **Light Mode Contrast Failures:** Five surfaces (`ai_coach_hero_card`, video fallback overlay, `suggested_diet_plan_card`, `ai_tts_settings_sheet`, and `quick_feedback_bottom_sheet`) hardcode `Colors.black`, `Colors.white`, or fixed dark greys that break contrast when light mode is enabled (`textMutedLight = #9CA3AF` also fails AA at ~2.5:1 on white).
4. **Inconsistent Numbers & Robotic Copy:** Five separate streak calculators disagree across tabs; tools & muscle sheets hardcode `'kg'` and `75.0`/`80.0` fallback weights; Home AI Coach prints raw `workouts_this_week: 4`; and settings hides working `unitsProvider` & `languageProvider` selectors.
5. **Broken Flows:** `ExerciseSelectionSheet` hardcodes 45 exercises instead of all **129** catalog movements; `filteredFoodProvider` omits user custom foods; `MuscleDetailSheet` navigates to `/workout` instead of `/workout/catalog?muscle=...`; `QuickFeedbackBottomSheet` still shows `'AI Chat navigation will be implemented in Phase 5'`.

---

## 3. Translation Into 3 Distinct Gym-First Design Directions

Rather than offering non-gym editorial themes (such as light paper journals), Wave `4.1` evaluates **3 authentic, high-contrast gym-first directions** against **Current Design (`00-current-design`)**:

1. **`01-slate-teal` — Slate Teal Minimal**: Dark-first athletic slate (`#0B1218` / `#131D26`) with one crisp electric teal action accent (`#2DD4BF`, light `#0F766E`), calm 14 px tonal cards, zero list shadows, clean tabular numeric hierarchy (`SpaceGrotesk` figures + `Inter` labels). Best for low-glare gym calm.
2. **`02-kinetic-block` — Iron Scoreboard & Amber**: Matte rack charcoal (`#0A0B0E` / `#14171D`) paired with high-visibility Signal Amber (`#F59E0B`, light `#B45309`) for active actions & PRs and Cobalt Steel (`#60A5FA`) for secondary metrics, compact 8 px structure, oversized `42 sp` set numbers, sticky rest timer bar. Best for fast readability at arm's length.
3. **`03-soft-layered` — Warm Studio Coach**: Clean evolution of the existing Direction 4 palette (`#12131A` dark / `#F8F6F2` warm linen light) stripped of Stripe purple (`#533AFD`), glowing meshes, and sci-fi clutter — upgraded to accessible Indigo/Emerald/Amber tokens (`#818CF8` / `#4F46E5`, `#34D399` / `#059669`, `#FB923C` / `#C2410C`), safe `20 px` radii, and unified set-table ergonomics.
