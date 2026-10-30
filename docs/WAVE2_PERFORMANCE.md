# Wave 2 Performance Verification & Trace Runbook

## Scope

This runbook documents how to capture and compare **Wave 2** frame-build and frame-raster performance metrics across the migrated Slate Teal / frame-light screens:

1. **Home (`HomeScreen`)**
2. **Train (`WorkoutScreen`)**
3. **Active Workout (`ActiveWorkoutScreen`)**
4. **Workout Summary (`WorkoutSummaryScreen`)**
5. **Fuel (`NutritionScreen`)**
6. **Food Search (`FoodSearchScreen`)**
7. **Progress (`ProgressScreen`)**
8. **Exercise Catalog (`ExerciseCatalogScreen`)**
9. **AI Chat (`GlobalAIChatScreen`)**

---

## Trace Harness Location

- **Integration Test**: `integration_test/wave2_screen_performance_trace_test.dart`
- **Report Keys**:
  - `wave2_home_screen_timeline`
  - `wave2_train_workout_screen_timeline`
  - `wave2_active_workout_screen_timeline`
  - `wave2_workout_summary_screen_timeline`
  - `wave2_nutrition_fuel_screen_timeline`
  - `wave2_food_search_screen_timeline`
  - `wave2_progress_screen_timeline`
  - `wave2_exercise_catalog_screen_timeline`
  - `wave2_ai_chat_screen_timeline`

---

## How to Run in Profile Mode

> **Important**: Always collect frame timings in `--profile` mode on a physical Android/iOS device or desktop target. Debug-mode widget tests validate functional execution of the harness but do not reflect release/profile GPU rasterization timings.

### 1. Android / iOS Device

```bash
flutter test integration_test/wave2_screen_performance_trace_test.dart \
  --profile \
  -d <device-id>
```

### 2. Windows Desktop Target

```bash
flutter test integration_test/wave2_screen_performance_trace_test.dart \
  --profile \
  -d windows
```

---

## Target Frame Budgets (60 Hz / 16.67 ms)

| Metric | Target |
|---|---|
| `average_frame_build_time_millis` | `<= 8.0 ms` |
| `90th_percentile_frame_build_time_millis` | `<= 12.0 ms` |
| `average_frame_rasterizer_time_millis` | `<= 8.0 ms` |
| `90th_percentile_frame_rasterizer_time_millis` | `<= 16.0 ms` |
| `missed_frame_build_budget_count` | `0` |

---

## Wave 2 Frame-Light Optimizations Applied

- **Single Surface Level per Section**: Migrated section containers on Home, Train, Active Workout, Summary, Fuel (`NutritionScreen`, `MacroWheelChart`), Food Search (`FoodSearchScreen`), Progress (`ProgressScreen`), and Exercise Catalog (`ExerciseCatalogScreen`) to shared `AppCard` surfaces.
- **Removed Nested Borders & Competing Glows**: Eliminated inner card borders on telemetry rows/chips and removed the competing accent border/glow from `AiCoachHeroCard` so at most one primary accent glow is rasterized on Home.
- **Restricted Backdrop Blur**: Kept blur effects limited to app bar / modal bottom sheet chrome rather than scrolling list items.

