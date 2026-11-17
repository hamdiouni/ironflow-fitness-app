# Wave 5 Plan — Body Map and Exercise Media (V2)

> **Branch:** `feat/prod-v2-wave-5` (branched from `master` at `b8be3f0`, backed up by tag `backup/pre-prod-v2-wave-5`)  
> **Gate Rule:** Strictly **STOP for Owner `[ASK]` decisions** below before deleting duplicate player files, adding packages/rigs (Rive/GLB), or incorporating external `"3D Form"` / `"Coach 2"` media assets.  
> **Wave 4 Baseline Status (Verified on `master` `b8be3f0`):**  
> - `flutter analyze --no-pub --no-fatal-infos lib test`: `0` errors, `0` warnings (`31` pre-existing `avoid_print` infos in `test/integration/auth_preservation_property_test.dart`)  
> - `flutter test --no-pub --coverage --timeout=60s`: `1,071 / 1,071` passed  
> - `python scripts/check_coverage.py --baseline docs/quality/coverage_baseline.json --fail-on-drop`: `70.60%` overall (`21,312 / 30,186` lines across `382` files); `COVERAGE GATE PASSED`  
> - `flutter build web --no-pub`: `Built build\web` (`0` errors)  
> - `flutter build apk --debug --no-pub`: `Built build\app\outputs\flutter-apk\app-debug.apk` (`0` errors)  
> - `gitleaks git --log-opts="backup/pre-prod-v2-wave-4..HEAD"`: `2` commits scanned, `no leaks found`

---

## Step 0 — Verified Baseline Audit (`b8be3f0`)

### Step 0A — What Exists Today

| Item | Exists? | Verified Evidence on `feat/prod-v2-wave-5` (`b8be3f0`) |
| :--- | :--- | :--- |
| **`MuscleRecoveryCalculator` (`5.1`)** | **Bugs found** | `lib/features/body/domain/services/muscle_recovery_calculator.dart:132-140` rounds secondary sets per exercise (`(workingSets * 0.5).round()`), losing/inflating fractional sets (e.g. `1 * 0.5 -> 1` each time). `requiredHours` (`L187-194`) uses only `sets7d` and ignores `SetEntry.rpe` (`set_entry.dart:24`) and `Workout.duration` (`workout.dart:20`). |
| **Recovery estimate labels (`5.1`)** | **Partial** | `MuscleDetailSheet._recoverySubtitle` (`muscle_detail_sheet.dart:425`) says `"Estimated $hrs hours..."`, **but** card headings/badges/accessibility percentages (`muscle_detail_sheet.dart:114-121, 338`, `body_map_view.dart:451-458`) omit explicit `"estimate"` labeling, and `muscle_detail_sheet.dart:259` still uses `tokens.canvas` instead of `tokens.onAccent` on the primary CTA. |
| **Body Map hit-test order (`5.1`)** | **Bug found** | `lib/features/body/presentation/widgets/body_map/body_map_paths.dart:200-201` registers `MuscleRegion.quads` (`lQuad`, `x: 98..144, y: 254..372`) **before** `MuscleRegion.adductors` (`lAdductor`, `x: 136..146, y: 260..324`). `lAdductor` sits mostly inside `lQuad`, so `hitTest` returns `quads` on medial thigh taps (`body_map_paths.dart:405-410`). |
| **`BodyMapPainter` Paint allocations (`5.1`)** | **Unfixed** | `lib/features/body/presentation/widgets/body_map/body_map_painter.dart:52-115` allocates `Paint()` objects inside `paint()` (`silhouetteBgPaint`, `silhouetteBorderPaint`, `borderPaint`) and **inside the 20-region loop** (`fillPaint`, `glowPaint`, `selectedBorderPaint`). |
| **`AnatomyRenderer` abstraction & Rive/GLB (`5.2`)** | **No** | `BodyMapView` (`body_map_view.dart:335-360`) directly constructs `CustomPaint(painter: BodyMapPainter(...))`. No `AnatomyRenderer` interface exists. `pubspec.yaml` has zero `rive`, `model_viewer_plus`, `.riv`, or `.glb` dependencies/assets. |
| **`"Kingfisher 3D Loop"` references (`5.2`)** | **Doc-only** | Zero occurrences in `lib/`, `test/`, or `pubspec.yaml`. Appears only in prior planning/analysis artifact (`mobile_web_full_analysis_report.md:175,200`) referring to commercial 3D anatomy exercise loop packs (Kingfisher 3D Exercises). |
| **Duplicate video players (`5.3`)** | **Yes (2 wrappers)** | Two `ExerciseVideoPlayer` classes exist: `lib/shared/widgets/exercise_video_player.dart` (imported by `exercise_detail_screen.dart:9`) and `lib/features/workout/presentation/widgets/exercise_video_player.dart` (imported by `active_exercise_card.dart`). Neither implements `ExerciseMediaStage`. |
| **`YouTubeExercisePlayer` bugs (`5.3`)** | **Unfixed (4 bugs)** | `lib/shared/widgets/youtube_exercise_player.dart`: (1) eagerly mounts iframe in `initState()` (`L60`) instead of waiting for user tap; (2) hardcodes `YoutubePlayerParams(mute: true)` (`L85`) ignoring `widget.muted`; (3) leaves `_controller!.listen(...)` subscription untracked/uncancelled (`L97`); (4) calls `setState` in async/listener callbacks (`L70, L112, L121, L133, L138`) without checking `mounted`. |
| **Step fallback on `ExerciseDetailScreen` (`5.3`)** | **Missing** | `exercise_detail_screen.dart:101-125` renders `ExerciseVideoPlayer` + progression charts **only**, never reading `ExerciseCatalog` step-by-step `instructions` even though `129 / 129` canonical exercises in `assets/data/exercises_catalog.json` include `instructions`. |
| **Video coverage & catalog parity (`5.3`)** | **53 / 129 direct** | `assets/data/exercises_catalog.json` has `129` canonical exercises (`26 / 129` have `youtube` `animationUrl`; `129 / 129` have `instructions`). `ExerciseVideoMap._videoIds` (`exercise_video_map.dart:116-171`) has `54` keys mapping to `49` unique YouTube IDs + `13` `_aliases`, matching **`53 / 129`** canonical exercises directly. `0` secondary `"Coach 2"` IDs and `0` `"3D Form"` loops exist. |
| **Body Map a11y list & tests (`5.4`)** | **Partial** | `BodyMapView._buildAccessibleListView` (`body_map_view.dart:375-478`) renders front/back muscle cards, but `body_map_paths_test.dart:56-109` hit-tests only `5` of `20` regions (`chest`, `upperAbs`, `quads`, `lats`, `glutes`) and omits `adductors` vs `quads`. |

### Step 0B — Claims Checked Against Master Plan V2

| Claim | Verified? | Evidence |
| :--- | :--- | :--- |
| "`MuscleRecoveryCalculator` rounds secondary sets early & ignores RPE/duration" | **CONFIRMED** | `muscle_recovery_calculator.dart:133,139` calls `(workingSets * 0.5).round()` inside loop; `requiredHours` (`L189-191`) uses only `sets7d`. `SetEntry.rpe` (`set_entry.dart:24`) and `Workout.duration` (`workout.dart:20`) are unused. |
| "`adductors` occluded by `quads`; `Paint` allocated in loops" | **CONFIRMED** | `body_map_paths.dart:200-201` (`quads` before `adductors`) + overlapping coordinates; `body_map_painter.dart:52-115` allocates `Paint()` in `paint()` loop. |
| "Exercise video coverage `54 of 129` claimed" | **CLARIFIED (`53 / 129`, `49` unique IDs)** | `ExerciseVideoMap._videoIds` contains `54` keys across `49` distinct YouTube IDs; matching against the `129` canonical exercises in `assets/data/exercises_catalog.json` yields `53 / 129` direct matches (`26 / 129` also carry `animationUrl` in JSON). `0` `"Coach 2"` or `"3D Form"` entries exist. |
| "Duplicate `ExerciseVideoPlayer` + `YouTubeExercisePlayer` lifecycle/mute bugs" | **CONFIRMED** | Two `ExerciseVideoPlayer` classes exist (`lib/shared/widgets/` and `lib/features/workout/presentation/widgets/`); `YouTubeExercisePlayer` (`L60, L85, L97, L70..138`) loads eagerly in `initState`, hardcodes `mute: true`, leaks stream subscription, and lacks `mounted` guards. |

---

## Wave 5 Implementation Plan (`5.1`–`5.4`)

### Phase `5.1` — Accurate Muscle Recovery Model, Labels & 2D Painter Fixes
- **`lib/features/body/domain/services/muscle_recovery_calculator.dart`:**
  - Accumulate secondary working sets as `double` (`0.5` per secondary working set) across all workouts in the window and round only **once** at aggregation (`sets7dMap`, `sets30dMap`).
  - Factor session **RPE** (`SetEntry.rpe`, normalized intensity multiplier around RPE 7 baseline when logged) and **session duration** (`Workout.duration.inMinutes`) smoothly into fatigue / required recovery hours without breaking existing non-RPE / standard-duration test baselines.
- **`lib/features/body/presentation/widgets/body_map/body_map_view.dart` & `muscle_detail_sheet.dart`:**
  - Label readiness percentage & recovery projection explicitly as an estimate (`"ESTIMATED RECOVERY"`, `"Estimated readiness"`, tooltip/sublabel) across `BodyMapView` list rows and `MuscleDetailSheet`.
  - Fix primary CTA foreground contrast in `muscle_detail_sheet.dart:259` (`tokens.onAccent`).
- **`lib/features/body/presentation/widgets/body_map/body_map_paths.dart` & `body_map_painter.dart`:**
  - Move `MuscleRegion.adductors` **before** `MuscleRegion.quads` in `_frontRegionPaths` (and inspect any other nested regions such as `obliques`/`abs`, `abductors`/`glutes`) so small overlapping front/back muscles always hit-test before larger outer groups.
  - Pre-allocate reusable `Paint` objects in `BodyMapPainter` (mutating `.color`, `.strokeWidth`, `.maskFilter` rather than constructing new `Paint` objects inside `paint()` or per-region loops).

### Phase `5.2` — `AnatomyRenderer` Interface & Improved 2D Default Renderer
- **New `lib/features/body/presentation/widgets/body_map/anatomy_renderer.dart`:**
  - Define an `AnatomyRenderer` interface (`AnatomyRenderConfig` + widget builder contract covering `isFront`, `recoveryMap`, `selectedRegion`, `highlightedRegions`, `isHeatmapMode`, `pulseValue`, `tokens`, `onRegionSelected`).
  - Implement `Vector2DAnatomyRenderer` wrapping the improved `BodyMapPainter` + `BodyMapPaths.hitTest` and wire `BodyMapView` to render through `AnatomyRenderer` cleanly (keeping the accessible semantic list view toggle intact).
  - Rive renderer & ADR remain gated on Owner decision `[ASK Q1/Q2]`; `.glb` remains propose-only.

### Phase `5.3` — Unified `ExerciseMediaStage` & Media Safety
- **Consolidate into ONE `lib/shared/widgets/exercise_media_stage.dart`:**
  - Replace both callers (`exercise_detail_screen.dart:9` and `active_exercise_card.dart`) with `ExerciseMediaStage` and remove the duplicate wrapper files upon Owner approval (`[ASK Q3]`).
  - **Modes (`"3D Form"`, `"Coach 1"`, `"Coach 2"` + Step Fallback):**
    - `"3D Form"` loop manifest schema (`assets/data/exercise_media_manifest.json`, naming convention `<exerciseId>_loop.{mp4,webm}` + `<exerciseId>_poster.webp` with `video_player` + `flutter_cache_manager` offline cache), enabled only when Owner-supplied loops exist; otherwise falls back cleanly without faking loops.
    - `"Coach 1"` & `"Coach 2"` curated YouTube IDs (backed by a Python/Dart oEmbed validation helper `scripts/verify_youtube_oembed.py` checking `https://www.youtube.com/oembed?url=https://www.youtube.com/watch?v=<id>&format=json` and official `youtube_player_iframe` embed only; zero invented IDs).
  - **Lifecycle & Theme Fixes in Player (`lib/shared/widgets/youtube_exercise_player.dart` / `exercise_media_stage.dart`):**
    - **Tap-to-load (`_hasRequestedPlayback`)**: render cached/network poster + accessible play CTA before mounting any `YoutubePlayerController` / iframe until the user taps.
    - Track `StreamSubscription?`, cancel on tab switch / exercise change / `dispose()`, close `YoutubePlayerController` cleanly, and guard every async/`listen` `setState` with `if (!mounted) return;`.
    - Pass `mute: widget.muted` cleanly (not hardcoded `true`).
    - Ensure light-mode surface/contrast tokens (`tokens.panel`, `tokens.textPrimary`, `tokens.kineticAccent`, `tokens.onAccent`) across poster overlay, controls, and fallback state.
    - **Fallback to Steps:** Update `ExerciseDetailScreen` (`exercise_detail_screen.dart`) to resolve the matching `ExerciseDefinition` from `ExerciseCatalog` and render a clear step-by-step `"FORM STEPS"` card when video/3D media is missing or offline (plus accessible on `"Steps"` / fallback).

### Phase `5.4` — Tests, Coverage & Proof
- Update/add unit & widget tests:
  - `test/features/body/domain/muscle_recovery_calculator_test.dart`: fractional secondary sets sum-before-round (`0.5 + 0.5 + 0.5 -> 2`), RPE impact, duration impact.
  - `test/features/body/presentation/body_map_paths_test.dart`: hit-test assertions for **all 20 `MuscleRegion` values** (front & back), explicitly verifying `adductors` before `quads`, plus out-of-bounds null checks.
  - `test/features/body/presentation/body_map_view_test.dart`: verifies `AnatomyRenderer` integration, `"ESTIMATED RECOVERY"` labeling, semantic list view rendering across all front & back regions.
  - `test/shared/widgets/exercise_media_stage_test.dart` & updated `youtube_exercise_player_test.dart`: verifies tap-to-load (no controller/WebView created before tap), `muted` flag honored, tab-switch controller disposal, `mounted` safety on early dispose, light-mode fallback contrast, and step-by-step instruction fallback for unmapped exercises.
  - Real media coverage test/report verifying exact counts against `assets/data/exercises_catalog.json` (`129` canonical exercises, `53 / 129` direct map matches from `54` keys / `49` unique YouTube IDs, `129 / 129` step instructions).

---

## Files Proposed for Deletion (`[ASK]` — Owner Approval Required)
1. `lib/shared/widgets/exercise_video_player.dart` (superseded by `lib/shared/widgets/exercise_media_stage.dart`)
2. `lib/features/workout/presentation/widgets/exercise_video_player.dart` (duplicate wrapper superseded by `lib/shared/widgets/exercise_media_stage.dart`)

---

## Owner Questions (`[ASK]` — Confirm Before Wave 5 Implementation)
1. **`"Kingfisher 3D Loop"` vs `"3D Form"` Mode (`5.2`/`5.3`):** Earlier design notes mentioned commercial 3D anatomy loops (`"Kingfisher 3D Loop"` / Kingfisher 3D Exercises). Should we **drop** external 3D loops for now (shipping the `"3D Form"` manifest/offline-cache spec ready for future loops, while active UI shows `"Coach 1"`, `"Coach 2"` when available, and step-by-step form instructions by default), OR are you supplying licensed loop files now?
2. **`AnatomyRenderer` (`5.2`):** Confirm shipping the improved **2D vector `AnatomyRenderer` first** (zero new dependencies, Wasm-safe) while leaving Rive paused unless you provide/approve a licensed `.riv` anatomical rig (with ADR + Wasm verification).
3. **Curated YouTube IDs & Duplicate File Deletion (`5.3`):**
   - Approve using the existing `49` unique YouTube IDs (`53 / 129` canonical catalog exercises via `54` keys in `ExerciseVideoMap`) verified via oEmbed for `"Coach 1"` (with `"Coach 2"` populated only where you supply/approve IDs, and step instructions shown cleanly for unmapped exercises)?
   - Approve deleting the 2 duplicate wrapper files listed above (`lib/shared/widgets/exercise_video_player.dart` and `lib/features/workout/presentation/widgets/exercise_video_player.dart`) after migrating `ExerciseDetailScreen` and `ActiveExerciseCard` to `ExerciseMediaStage`?

---

## Owner Decisions & Wave 5 Outcome
- **Confirmed Decisions:**
  1. **3D Form Loops (`A1`):** Dropped `"Kingfisher 3D Loop"`; shipped the `"3D Form"` manifest/cache spec (`assets/data/exercise_media_manifest.json` + `ExerciseMediaLoopSpec`) alongside `"Coach 1"`, `"Coach 2"`, and automatic `"Steps"` fallback.
  2. **`AnatomyRenderer` (`A2`):** Shipped the pluggable `AnatomyRenderer` interface and `Vector2DAnatomyRenderer` (`lib/features/body/presentation/widgets/body_map/anatomy_renderer.dart`, zero extra dependencies, Wasm-safe).
  3. **Curated YouTube IDs & Duplicate Wrapper Deletion (`A3`):** Deleted both duplicate `ExerciseVideoPlayer` files (`lib/shared/widgets/exercise_video_player.dart` and `lib/features/workout/presentation/widgets/exercise_video_player.dart`), consolidated into `ExerciseMediaStage` (`lib/shared/widgets/exercise_media_stage.dart`), and verified all active YouTube IDs via `scripts/verify_youtube_oembed.py --strict` (`40 / 40` HTTP 200; pruned `10` dead `404` IDs from `ExerciseVideoMap` and blocked `20` dead `404` catalog `animationUrl` IDs).
- **Measured Media Coverage (`129` canonical exercises in `assets/data/exercises_catalog.json`):**
  - `Coach 1` (verified HTTP 200 YouTube IDs): **`43 / 129`** (`33.3%`, backed by `45` active map entries across `40` unique verified YouTube IDs).
  - `Coach 2` (secondary verified YouTube ID): **`3 / 129`** (`Deadlift`, `Barbell Deadlift`, `Conventional Deadlift` -> `r4MzxtBKyNE`).
  - `3D Form` loops: **`0 / 129`** (manifest spec ready at `assets/data/exercise_media_manifest.json`; never faked).
  - `Steps` fallback (`ExerciseCatalog` instructions): **`129 / 129`** (`100%`; `86 / 129` unmapped exercises fall back directly to numbered execution steps).
- **Verification Results:**
  - `flutter analyze --no-pub --no-fatal-infos lib test`: `0` errors, `0` warnings (`31` pre-existing `avoid_print` infos in `test/integration/auth_preservation_property_test.dart`).
  - `flutter test --no-pub --coverage --timeout=60s`: `1,078` tests passed (`0` failures, `0` skipped).
  - `python scripts/check_coverage.py --baseline docs/quality/coverage_baseline.json --fail-on-drop`: `70.72%` overall (`21,620 / 30,570` lines across `382` files); `COVERAGE GATE PASSED`.
  - `python scripts/verify_youtube_oembed.py --strict`: `40 / 40` active unique YouTube IDs returned HTTP `200`.
