# Baseline (`00-current-design`): Current App State (`7253415`)

> **Role in Wave 4.1:** Live baseline captures of the real production codebase (`feat/prod-v2-wave-4` at `7253415`) before any Wave 4 design or coherence edits. Every design direction (`01`–`03`) is evaluated directly against these screens.

---

## Observed Visual & Coherence Issues on `7253415`

| Area | What Today's Screens Show |
|:---|:---|
| **Mixed Color System** | `app_colors.dart` combines legacy Stripe indigo (`#533AFD`, `stripe_gradient_mesh.dart`) with low-contrast pastel periwinkle (`#A5B4FC`). |
| **Truncated AppBar & Tall Active Workout Cards** | `ActiveWorkoutScreen` AppBar truncates `"ACTIVE WORK..."` on `390 px` screens and repeats full-width logging buttons inside tall stacked cards. |
| **Light-Mode Contrast Failures** | `ai_coach_hero_card.dart`, video fallbacks, `suggested_diet_plan_card.dart`, `ai_tts_settings_sheet.dart`, and `quick_feedback_bottom_sheet.dart` hardcode `Colors.black`, `Colors.white`, or fixed dark greys; `textMutedLight = #9CA3AF` fails WCAG AA on white. |
| **Missing Settings & Hardcoded Units** | `unitsProvider` and `languageProvider` are absent from `SettingsScreen`; multiple sheets hardcode `'kg'` and `75.0`/`80.0` fallbacks. |
| **Raw / Robotic Copy** | Home AI Card prints raw `workouts_this_week: 4`; settings/food/workout copy uses `'telemetry'`, `'protocol'`, `'MONOLITHIC SCI-FI'`, stale `'80+'`/`'50+'` counts, and a `'Phase 5'` placeholder. |
| **Desktop / Wide Web** | Only the outer shell adapts at `>= 900 px`; individual screen bodies remain single-column stretches without keyboard shortcuts during workouts. |

---

## Captured Baseline Files

- `today_main_390x844.png` — Real `HomeScreen` (Dark, `390x844`)
- `today_alt_390x844.png` — Real `HomeScreen` (Light, `390x844`)
- `today_wide_1280x800.png` — Real `HomeScreen` (Dark Wide, `1280x800`)
- `active_workout_390x844.png` — Real `ActiveWorkoutScreen` (Dark, `390x844`)
- `fuel_daily_390x844.png` — Real `NutritionScreen` (Dark, `390x844`)
- `progress_charts_390x844.png` — Real `ProgressScreen` (Dark, `390x844`)
- `progress_charts_wide_1280x800.png` — Real `ProgressScreen` (Dark Wide, `1280x800`)
- `settings_390x844.png` — Real `SettingsScreen` (Dark, `390x844`)
