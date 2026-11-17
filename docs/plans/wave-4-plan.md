# Wave 4 Plan — Design Decision and UI Coherence (V2)

> **Branch:** `feat/prod-v2-wave-4` (branched from `master` at `7253415`, backed up by tag `backup/pre-prod-v2-wave-4`)  
> **Gate Rule:** Strictly **STOP at `CHECKPOINT after 4.1`** (after public-info Reference Teardown + live Design Lab + real PNG captures + per-direction READMEs + `index.html`) until the Owner selects a direction and answers the `[ASK]` questions. Zero production edits during `4.1`.

---

## Step 0 — Verified Baseline Audit (`7253415`)

### 1. What Exists Today

| Item | Exists? | Evidence (Directly Verified on `feat/prod-v2-wave-4` / `7253415`) |
|:---|:---|:---|
| Public-info Reference Teardown (`4.1`) | No (only internal UI/UX Pro Max notes) | `docs/design-research/` contains internal AI style notes (`01_ds_*`, `MASTER.md`); `docs/design-preview/` lacks a public-info competitor teardown. |
| Live Design Lab (`lib/dev/design_lab/`) | No (deleted in `5ca5877`) | `lib/dev/` currently only has `dev_routes.dart` and `design_gallery_screen.dart` (single-theme showcase reading `'STRIPE DESIGN SYSTEM'` / hidden `'MONOLITHIC SCI-FI'`). All 16 `lib/dev/design_lab/` files were deleted in `5ca5877`. |
| Design Previews (`docs/design-preview/`) | Partial / Stale (2026-11-03) | Has 4 pre-Wave-1–3 folders (`01-slate-teal`, non-gym `02-nordic-calm`, `03-kinetic-block`, `04-soft-layered`), lacks a **Current Design** baseline column, uses outdated `"Push Protocol"` copy in PNGs, and does not compare against real `7253415` screens. |
| Mixed Tokens & Leftovers (`app_colors.dart`, `app_theme_tokens.dart`) | Yes | `app_colors.dart` still holds Stripe tokens (`primary = #533AFD`, `brandDark900 = #1C1E54`, `#0D1117`/`#161B22`) alongside Direction 4 accents (`#A5B4FC`, `#6EE7B7`, `#FB923C`). `textMutedLight = #9CA3AF` & `textMutedDark = #6E7681` are low-contrast. `app_button.dart:134` and `stripe_gradient_mesh.dart` still read `AppColors.primary`. |
| Duplicate Streak Calculators (5 implementations) | Yes (5 separate bugs/logics) | 1. `ai_quick_feedback_generator.dart:92` (`_calculateConsistencyStreak`, allows 1–2 day gaps); 2. `build_ai_context_use_case.dart:355` (`_calculateWorkoutStreak`); 3. `analytics_repository_impl.dart:235`; 4. `generate_weekly_report_use_case.dart:228`; 5. `lib/features/retention/domain/entities/streak.dart:39-75` (`Streak.addWorkout`/`isActive` using raw `now.difference(...).inDays`). Also `lifts_volume_tab.dart:131` has another copy! |
| Raw `Duration(days: 7)` vs Local Midnight 7-Day Windows | Yes | `ai_provider.dart:289,296`, `global_ai_insight_helpers.dart:65,66`, `analytics_repository_impl.dart:271,357`, `analytics_screen.dart:202,474,607` subtract `Duration(days: 7)` from `DateTime.now()` instead of local midnight boundaries. |
| Units & Language in Settings UI | Backend only (missing UI) | `unitsProvider` (`lib/core/providers/units_provider.dart`) and `languageProvider` (`lib/core/providers/language_provider.dart`) exist and work in `main.dart:260`, but `lib/features/settings/` has **0** references to either provider. |
| Hardcoded `kg`/`lb`, macros & fallback weights (`75`/`80`) | Yes | `calorie_macro_sheet.dart:37,72` (`?? 75.0`, `'kg'`), `water_intake_sheet.dart:33,59` (`?? 75.0`, `'kg'`), `weight_goal_sheet.dart:34,65,91` (`?? 80.0`, `'kg'`), `one_rep_max_sheet.dart:78,156,166,222` (`'kg'`), `muscle_detail_sheet.dart:152` (`unit: 'kg'`), `lifts_volume_tab.dart:97` (`VOLUME LOAD (KG)`), `active_workout_screen.dart:45` (`WeightUnit.kg`), `ai_quick_feedback_generator.dart:244` (`kg`). |
| Localization (`lib/l10n/`) | Minimal (only `main.dart` uses it) | `app_en.arb` has 140 lines across 7 locales, and `AppLocalizations` is only imported in `lib/main.dart` + generated `app_localizations*.dart` files. |
| Custom Foods Search Integration & Save Messaging | Broken (isolated from search) | `filteredFoodProvider` (`food_providers.dart:75-98`) searches `foodsCatalogIndexProvider` only and ignores `customFoodsProvider`. `CreateCustomFoodDialog` (`create_custom_food_dialog.dart:210`) does not explain where custom foods save, and `food_search_screen.dart:61` shows misleading `'Custom fuel entry "..." logged!'` even though it saved to the custom library rather than logging a meal. |
| Exercise Sheet (`ExerciseSelectionSheet`), Catalog Counts, Tab Reset & GoRouter Detail | Broken in 4 places | `exercise_selection_sheet.dart:15-26` hardcodes 45 static strings instead of reading the **129-exercise** `exercises_catalog.json`. Hardcoded stale counts: `food_search_screen.dart:155` (`80+` vs 282 total / 82 verified + 200 supplementary), `settings_screen.dart:297` (`50+`), `workout_screen.dart:359` (`80+`). `exercise_catalog_screen.dart` doesn't reset/sync `_tabController` to persistent `exerciseFilterProvider` and pushes `MaterialPageRoute` (`line 261`) instead of GoRouter `/workout/exercise/:name`. `muscle_detail_sheet.dart:237` routes `'TRAIN THIS MUSCLE'` to `/workout` instead of `/workout/catalog`. |
| `"Phase 5"` Placeholder | Yes | `quick_feedback_bottom_sheet.dart:279`: `Text('AI Chat navigation will be implemented in Phase 5')`. |
| Brand Names (`IronFlow`) & Robotic Jargon | Yes | UI strings contain `IronFlow` (`ai_chat_screen.dart:179`, `ai_insight_metrics_calculator.dart:387`, `offline_access_section.dart:128`, `generate_weekly_report_use_case.dart:35`, `app_en.arb:3,86`, etc.) and robotic words across string literals: `telemetry` (50 non-comment lines), `protocol` (27), `initializing` (13), `monolithic` (2) + raw `workouts_this_week: 4` key visible on Home AI card (`current_home_dark_390x844.png`). |
| Light-Mode Contrast Failures (5 areas) | Yes | `ai_coach_hero_card.dart:351` (`Colors.black` on light accent), `exercise_video_player.dart:94,104,110` & `youtube_exercise_player.dart:337,430` (hardcoded dark `grey[900]`/`white38`/`white70`), `suggested_diet_plan_card.dart:256,478,485` (`Colors.black`), `ai_tts_settings_sheet.dart` (`Colors.white` 12x), `quick_feedback_bottom_sheet.dart:130,154` (`Colors.grey[300]`/`grey[700]`). |
| List Stagger, Reduced Motion & `AnimatedScaleButton` A11y | Incomplete | `food_alternatives_widget.dart:76`, `meal_suggestions_view.dart:189`, `exercise_catalog_screen.dart:268` multiply `index * duration` unboundedly; `ai_loading_state.dart:51`, `app_shimmer.dart:55`, `app_motion.dart:20` use `MediaQuery.of`/`maybeOf` instead of `MediaQuery.maybeDisableAnimationsOf`; `AnimatedScaleButton` (`motion_widgets.dart:82-157`) lacks `Semantics` and keyboard activation (`Focus`/`Actions`/`Shortcuts`). |
| Standalone `AnalyticsScreen` Merge | Duplicate remains | `ProgressScreen` Tab 0 hosts `LiftsVolumeTab`, and `/analytics` redirects to `/progress?tab=lifts`, but legacy `analytics_screen.dart` (707 lines) still exists separately and `LiftsVolumeTab` still duplicates its own `_calculateStreak` + hardcoded `(KG)`. |
| Cluttered Workout AppBar & Active Workout AppBar | Yes | `workout_screen.dart:38-118` packs 5 action icons into the AppBar; `active_workout_screen.dart` AppBar truncates to `"ACTIVE WORK..."` on `390x844` (`current_active_workout_390x844.png`). |
| Responsive `>= 900px` Two-Pane & Keyboard Shortcuts | Missing | Only `main.dart:336` handles `>= 900` (outer nav rail); no screen uses two-pane layout at `>= 900px`. **0** `Shortcuts`/`CallbackShortcuts` exist anywhere in `lib/`. |

### 2. Claims Checked

| Claim (from Prior Docs / Code Comments / UI Copy) | Verified? | Evidence |
|:---|:---|:---|
| `DESIGN_MIGRATION.md`: Direction 4 migration complete across codebase | **False (Partial)** | `app_colors.dart` retains `#533AFD` (`AppColors.primary`), `stripe_gradient_mesh.dart` still paints Stripe indigo, `settings_screen.dart:20-26` & `design_gallery_screen.dart:79,93` display `'MONOLITHIC SCI-FI'` & `'STRIPE DESIGN SYSTEM'`. |
| `food_search_screen.dart:155`: `"Search 80+ USDA verified fitness staples..."` | **Stale** | `assets/data/foods_catalog.json` actually contains `282` items (`82` verified + `200` supplementary), plus custom foods not yet merged into `filteredFoodProvider`. |
| `workout_screen.dart:359` / `settings_screen.dart:297`: `"50+"` / `"80+ exercises"` | **Stale** | `assets/data/exercises_catalog.json` contains `129` canonical exercises (`canonicalCount: 129`); `ExerciseSelectionSheet` only exposes `45` hardcoded strings. |
| `lib/dev/design_lab/` live multi-direction lab exists | **False** | Removed in `5ca5877`; only static pre-Wave-1–3 PNGs remained in `docs/design-preview/` plus `DesignGalleryScreen`. |
| `AnalyticsScreen` merged into Progress Tab 0 | **Partial** | Route `/analytics` redirects to `/progress?tab=lifts`, and `LiftsVolumeTab` exists, but duplicate `analytics_screen.dart` still exists and `LiftsVolumeTab` retains legacy stats/streak/KG bugs. |

---

## Wave 4 Architecture & Execution Plan

### Phase `4.1` — Public-Info Reference Teardown & Live Design Lab *(Current Focus — HARD STOP Before `4.2`)*
1. **Baseline "Before" Screenshots (`00-current-design/` & `docs/screenshots/wave4-before/`):**
   - Render real production screens (`HomeScreen`, `ActiveWorkoutScreen`, `NutritionScreen`, `ProgressScreen`, `WorkoutScreen`, `SettingsScreen`) on `7253415` via headless Flutter widget rasterization (`assets/fonts/Inter.ttf` & `SpaceGrotesk.ttf`) so the "Current Design" column reflects exact current pixels before any Wave 4 changes.
2. **Public-Information Reference Teardown (`docs/design-preview/REFERENCE_TEARDOWN.md`):**
   - Strictly grounded in public product websites, App Store listings, and public UX analyses (zero binary inspection or private extraction): **Hevy**, **Strong**, **MacroFactor / MacroFactor Workouts**, and **Nike Training Club / WHOOP**.
   - Extracts concrete gym-floor ergonomic lessons: thumb-zone active set rows (`Set | Prev | Weight | Reps | Check`), persistent rest countdown visibility, dark-gym readability without neon glare, clean light-mode sunlight contrast, plain human fitness copy, unified custom + database search, and desktop two-pane split ergonomics.
3. **Live Design Lab (`lib/dev/design_lab/` + `/design-preview` debug route only):**
   - Strictly isolated under `lib/dev/design_lab/`, gated behind `if (!kDebugMode)` and `buildDebugRoutes()` (`includeDebugRoutes: !kReleaseMode`).
   - Showcases **3 distinct gym-first directions** (both **Dark & Light**, `360x800`, `390x844`, and `1280x800` responsive 2-pane) powered by clean fake workout/nutrition/progress data:
     - **Direction 1 (`01-slate-teal`): Slate Teal Minimal** — calm dark slate (`#0B1218` / `#131D26`), electric teal CTA (`#2DD4BF` / `#0F766E` light), `14 px` tonal cards, zero list shadows.
     - **Direction 2 (`02-kinetic-block`): Iron Scoreboard & Amber** — matte rack charcoal (`#0A0B0E` / `#14171D`), signal amber CTA (`#F59E0B` / `#B45309` light) + cobalt secondary (`#60A5FA` / `#2563EB`), `8 px` sharp geometry, oversized scoreboard set counters & sticky rest timer bar.
     - **Direction 3 (`03-soft-layered`): Warm Studio Coach** — cleaned evolution of current Direction 4 (`#12131A` dark / `#F8F6F2` warm linen light, `#818CF8` -> `#4F46E5` indigo + `#34D399` emerald + `#FB923C` amber, `20 px` safe radii, Stripe hexes & sci-fi meshes removed).
4. **Fresh PNG Captures, Per-Direction `README.md`, and `docs/design-preview/index.html`:**
   - Generate fresh Flutter widget PNG renders for Current (`00-current-design`) + Directions 1–3 (`01-slate-teal`, `02-kinetic-block`, `03-soft-layered`), removing stale non-gym `02-nordic-calm` and old mismatched PNGs so every preview matches the actual live `lib/dev/design_lab/` code.
   - Write per-direction `README.md` with WCAG AA contrast tables, token manifests, and engineering effort/risk notes, plus unified `docs/design-preview/index.html` side-by-side comparison.
   - Run `flutter analyze`, `architecture_hygiene_test.dart`, `release_safety_characterization_test.dart`, `ai_debug_gate_test.dart`, `design_gallery_screen_test.dart`, new `design_lab_screen_test.dart`, and `gitleaks`.
   - **STOP at `CHECKPOINT after 4.1` and await Owner's direction choice + `[ASK]` answers.**

---

### Phase `4.2` — Tokens-Only Build & Coherence Fixes *(Runs ONLY After Owner Approval of `4.1`)*
1. **Apply Chosen Direction Tokens Strictly (Zero Ad-Hoc Colors/Radii):**
   - Refactor `app_colors.dart`, `app_typography.dart`, `app_theme_tokens.dart`, `app_theme.dart`, `app_button.dart`, and delete/replace `stripe_gradient_mesh.dart` so all UI uses chosen tokens only and passes WCAG AA in both Dark and Light modes.
   - Fix light-mode contrast in `ai_coach_hero_card.dart`, `exercise_video_player.dart`, `youtube_exercise_player.dart`, `suggested_diet_plan_card.dart`, `ai_tts_settings_sheet.dart`, and `quick_feedback_bottom_sheet.dart`.
2. **Domain Math & Coherence:**
   - Introduce single canonical `WorkoutStreakCalculator` (using local calendar dates `DateTime(y, m, d)`) and replace all 5+ streak copies (`ai_quick_feedback_generator.dart`, `build_ai_context_use_case.dart`, `analytics_repository_impl.dart`, `generate_weekly_report_use_case.dart`, `streak.dart`, `lifts_volume_tab.dart`).
   - Replace raw `Duration(days: 7)` windows with local midnight window helper across `ai_provider.dart`, `global_ai_insight_helpers.dart`, `analytics_repository_impl.dart`, and `lifts_volume_tab.dart`.
   - Wire `unitsProvider` & `languageProvider` selectors into `SettingsScreen`; eliminate hardcoded `kg`/`lbs`/macros and hardcoded `75.0`/`80.0` fallback weights across tools sheets, body/muscle sheets, active workout, AI generator, and progress charts.
   - Complete `lib/l10n/*.arb` & wire `AppLocalizations` into main user-facing UI surfaces.
3. **Catalogs, Food Search, Navigation & Copy Cleanup:**
   - Merge `customFoodsProvider` into `filteredFoodProvider`; clarify where custom foods save (`CreateCustomFoodDialog` & snackbar); fix dynamic food/exercise catalog counts (`129` exercises, `282+` foods).
   - Wire `ExerciseSelectionSheet` to `exercisesCatalogIndexProvider` / full catalog; sync & reset `ExerciseCatalogScreen` tabs; route exercise detail via GoRouter `/workout/exercise/:name`; wire `MuscleDetailSheet` CTA to `/workout/catalog?muscle=...`.
   - Replace `quick_feedback_bottom_sheet.dart:279` `"Phase 5"` placeholder with real `/ai-chat` navigation.
   - Delete legacy standalone `AnalyticsScreen` after verifying all features live cleanly in `LiftsVolumeTab` (`ProgressScreen` Tab 0).
   - Remove hardcoded `"IronFlow"` in copy (or apply chosen Owner brand preference) & eliminate `"telemetry"`, `"protocol"`, `"initializing"`, `"monolithic"`, and raw snake_case variable strings (`workouts_this_week`) from user-visible text.
4. **Layout, Motion, Accessibility & Desktop/Keyboard:**
   - Declutter `WorkoutScreen` & `ActiveWorkoutScreen` AppBars (no `"ACTIVE WORK..."` truncation).
   - Implement two-pane responsive layouts (`>= 900px`) on primary screens (`HomeScreen`, `ProgressScreen`, `NutritionScreen`, `ActiveWorkoutScreen`).
   - Add keyboard shortcuts (`CallbackShortcuts` / `Shortcuts`) in `ActiveWorkoutScreen` (`Space`/Enter log set, `R` rest timer toggle/skip, `+/-` weight step).
   - Cap list stagger at 8 items, switch all reduced-motion checks to `MediaQuery.maybeDisableAnimationsOf(context)`, and restore `Semantics` + keyboard activation (`FocusableActionDetector` / InkWell / Intent) on `AnimatedScaleButton`.

### Phase `4.3` — Wave 4 Verification & Goldens *(Runs After `4.2`)*
- Unit tests: `WorkoutStreakCalculator` (DST/midnight/same-day/gap edge cases), local-midnight 7-day window calculator, `UnitsConverter` & tool sheet conversions.
- Widget/A11y tests: `AnimatedScaleButton` semantics & keyboard Space/Enter activation, `ExerciseSelectionSheet` reading 129 exercises, `filteredFoodProvider` merging custom foods, light-mode contrast spot checks, `360px` & `>= 900px` 2-pane & `1.5x` `textScaler` overflow-free layout checks.
- Golden tests (`test/design_system/`) + full before (`wave4-before/`) vs after (`wave4-after/`) screenshot captures across dark, light, mobile, and desktop `1280x800`.

### Key Risks & Mitigations
- **Risk 1: Existing tests asserting legacy copy** (e.g., `design_gallery_screen_test.dart:22` expects `'MONOLITHIC SCI-FI'`; possible AI/feedback tests expect `'Phase 5'`). **Mitigation:** Update those test expectations alongside the `4.2` cleanup commits and search `test/` before editing strings.
- **Risk 2: AppBar / Layout changes causing pixel overflows at `360px` or `1.5x` text scale.** **Mitigation:** Include `360x800` + `MediaQuery.withClampedTextScaling` / `1.5x` tests in both the Design Lab (`4.1`) and Wave `4.3` test suite.
- **Risk 3: Hive/Intl initialization during headless PNG captures.** **Mitigation:** Use riverpod provider overrides (pattern already proven in `home_screen_frame_light_test.dart` & `nutrition_screen_test.dart`) + explicit bundled font loader (`Inter.ttf`, `SpaceGrotesk.ttf`).

---

## Owner Questions (`[ASK]` — Answer at `CHECKPOINT after 4.1`)
1. **Design Direction (`4.1`):** After opening `docs/design-preview/index.html` or testing `/design-preview` in the app, which direction should be built for Wave `4.2`?
   - **Option A:** `01-slate-teal` (Calm Athletic Slate & Electric Teal)
   - **Option B:** `02-kinetic-block` (Iron Scoreboard Charcoal & Signal Amber)
   - **Option C:** `03-soft-layered` (Warm Studio Coach — cleaned Indigo/Mint/Warm-Linen evolution)
2. **App / Brand Name in Copy (`4.2`):** The plan calls for removing `"brand names and robotic words"`. For user-facing UI text where `"IronFlow"` currently appears (welcome card, coach greetings, report title, settings), should we replace `"IronFlow"` with generic phrasing (e.g., `"Your Workout Tracker"`, `"Coach"`) or keep/use a specific app name you prefer?
3. **Default Mode & Scope (`4.2`):** Should Dark mode remain the default on first launch (with clean Light mode toggle in Settings), or Light mode default?
