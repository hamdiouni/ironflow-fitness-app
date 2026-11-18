# Wave 8 — Approved Features (Plan & Report)

Branch: `feat/prod-v2-wave-8` (branched from `master` at `dbe340a`, backup tag `backup/pre-prod-v2-wave-8`).

Rule for this wave: **one batch per approved decision record (ADR)**. Only approved features
were scheduled and built.

## Step 0 — Decisions & Scope

| Candidate | Status | Reason / ADR |
| :--- | :--- | :--- |
| **8.1 Lock-screen rest timer** | **APPROVED & DONE** | ADR-004: Android system chronometer lock-screen notification + Web browser notifications. (iOS Live Activity marked NOT VERIFIED). |
| **8.2 Barcode scanner + Open Food Facts** | **APPROVED & DONE** | ADR-008: `OpenFoodFactsService` (GS1 GTIN check-digit validation, offline verified gym catalog, Open Food Facts API v2 JSON parser under ODbL v1.0) + `BarcodeScannerSheet` integrated into `FoodSearchScreen` with auto-caching to custom foods. |
| **8.3 e1RM engine + superset & drop sets** | **APPROVED & DONE** | ADR-004: Unified `E1rmEngine`, `DropSetPlanner`, `SupersetEngine`, backward-compatible `supersetGroupId` on `Exercise` and `ExerciseModel`, auto-rotation, UI indicators, and rest-timer integration. |
| **8.4 Health Connect / HealthKit** | **APPROVED & DONE** | ADR-008: `HealthSyncService` (MET active calorie estimation, 5-minute timestamp deduplication) + `MethodChannelHealthGateway` (`com.ironflow.app/health_sync` with cross-platform simulation bridge) + `HealthSyncSettingsSheet` in `SettingsScreen`. |
| **8.5 Remote config upgrade** | **APPROVED & DONE** | ADR-005 (Wave 2.7): Firestore-backed feature flags & emergency kill switches (`kill_ai_coach`, `kill_cloud_sync`, `maintenance_mode`). |

## Batch 8.1: Lock-Screen Rest Timer & Browser Notifier (`ADR-004`)
- Created `RestTimerLiveSurface` domain contract (`lib/features/workout/domain/services/rest_timer_live_surface.dart`).
- Upgraded `RestTimerService` (`lib/features/workout/domain/services/rest_timer_service.dart`) with fire-and-forget live surface dispatching.
- Implemented `RestTimerLiveNotification` (`lib/features/notifications/data/services/rest_timer_live_notification.dart`):
  - **Android:** Ongoing silent notification (`id = 98`, channel `rest_timer_live`) with `usesChronometer: true`, `chronometerCountDown: true`, `timeoutAfter: remainingMs`, `category: stopwatch`, `visibility: public`.
  - Background completion heads-up alert (`id = 99`, channel `rest_timer`).
  - **Web:** `BrowserNotifier` (`lib/core/platform/browser_notifier.dart`, `browser_notifier_web.dart`) with `dart:js_interop` requesting permission contextually on user gesture and notifying when tab is hidden.
  - **iOS:** Marked `NOT VERIFIED` (no native widget extension / macOS build).
- Wired `restTimerLiveSurfaceProvider` into `restTimerServiceProvider`.

## Batch 8.3: Strength Engine, Drop Set Planner & Superset Linking (`ADR-004`)
- Implemented `E1rmEngine`, `DropSetPlanner`, `SupersetEngine` (`lib/features/workout/domain/services/strength_engine.dart`):
  - `E1rmEngine`: Epley and Brzycki formulas with 10-rep cap, 1-rep identity, strictly filtering warmups/drop sets.
  - `DropSetPlanner`: 20% stepped weight drops rounded down to 2.5 kg/lb gym plate increments, grouping sets into chains.
  - `SupersetEngine`: Partitioning exercises into ordered blocks with `A1`, `A2`, `B1`, `B2`... labels, adjacent linking/unlinking, auto-rotation between partner exercises, and rest condition checking.
- Backward-compatible storage:
  - Added nullable `supersetGroupId` to `Exercise` and `ExerciseModel`.
  - Serialized/deserialized in `ExerciseModel.g.dart` and `BackupRecordCodec`.
- Active Workout UI Integration:
  - `ActiveWorkoutScreen`: rendered `SupersetConnectorDivider` between cards to link/unlink supersets with 1 tap; auto-rotates active exercise within superset blocks.
  - `ActiveExerciseCard`: displays `SS A1`/`SS A2` badges, current best e1RM for the exercise, and auto-populates 20% drop weight when selecting `DROP`.
  - Rest timer skips for drop sets and during superset transition rounds.
