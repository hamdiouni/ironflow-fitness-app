# ADR-004: Lock-Screen Rest Timer & Strength Engine (Wave 8.1 & 8.3)

## Status
Approved and Implemented in Wave 8 (`feat/prod-v2-wave-8`).

## Context
1. **Rest Timer Lock-Screen Presence (8.1):**
   - The rest timer between sets (`RestTimerService`) previously only scheduled a single inexact notification at completion time via `flutter_local_notifications` (`restTimerNotificationId = 99`), with zero visibility during the interval on Android and web.
   - Lifters frequently lock their phone or switch apps between sets. Relying solely on in-app ticking meant having to unlock the device to check remaining rest.
   - For Android, lifters requested a live countdown on the lock screen without requiring new high-risk permissions (`USE_EXACT_ALARM` / `SCHEDULE_EXACT_ALARM` triggers Play Store compliance declarations).
   - For Web, desktop lifters switching tabs required notification reminders when rest finishes.
   - For iOS, native Live Activities require Swift ActivityKit widget extensions and Xcode on macOS, which cannot be verified in this headless Windows environment.

2. **Strength Engine & Superset Linking (8.3):**
   - Estimated 1RM calculations were fragmented across multiple locations with differing formulas (e.g. `analytics_repository_impl.dart` averaged all sets including warmups with the heaviest weight; `workout_metrics.dart` applied a 10-rep cap; `one_rep_max_calculator.dart` supported Brzycki and Epley).
   - Lifters had no mechanism to group adjacent exercises into antagonist or agonist supersets (`A1`/`A2`), nor was there an automated drop-set weight calculator with rest skipping.

## Decisions

### 1. Lock-Screen Rest Timer & Browser Notifier (`8.1`)
- **RestTimerLiveSurface Domain Abstraction:**
  - Introduced `RestTimerLiveSurface` in `lib/features/workout/domain/services/rest_timer_live_surface.dart` with fire-and-forget semantics (`showRunning`, `showPaused`, `showCompleted`, `clear`).
  - `RestTimerService` notifies the surface on every state transition (`start`, `pause`, `resume`, `skip`, `sync`, and completion). If a live surface fails or is denied, the core rest timer is completely unaffected.
- **Android Live Notification (`RestTimerLiveNotification`):**
  - Uses an ongoing silent notification (`id = 98`, channel `rest_timer_live`) with Android system chronometer:
    - `usesChronometer: true`, `chronometerCountDown: true`, `when: targetEndTime.millisecondsSinceEpoch`.
    - Android OS native countdown renderer updates every second on the lock screen with **zero battery drain** and no background Dart execution.
    - Set with `onlyAlertOnce: true`, `playSound: false`, `enableVibration: false`, `ongoing: true`, `category: stopwatch`, `visibility: NotificationVisibility.public`.
    - `timeoutAfter` automatically dismisses the ongoing notification at the end timestamp even if the process dies.
    - When rest completes while the app is in the background, a heads-up alert (`id = 99`, channel `rest_timer`) is posted.
- **Web Browser Notification (`BrowserNotifier`):**
  - Uses `dart:js_interop` without adding any new package.
  - Contextually requests permission on user gesture (tapping start timer).
  - Shows notification only when the page is hidden (`document.hidden == true`).
- **iOS Live Activity:** Marked `NOT VERIFIED` (no native Swift extension or macOS build runner); standard scheduled completion alert remains active.

### 2. Strength Engine & Superset Linking (`8.3`)
- **Single Source of Truth (`E1rmEngine`):**
  - Unified e1RM calculations in `lib/features/workout/domain/services/strength_engine.dart`.
  - Implements Epley (`weight * (1 + min(reps, 10) / 30)`) and Brzycki (`weight * 36 / (37 - min(reps, 10))`).
  - 1-rep sets return exact lifted weight. Reps capped at 10 to prevent high-rep light sets from distorting strength metrics.
  - Strictly filters out warmups and drop sets (`countsForE1rm`).
  - `E1rmEngine.bestForExercise` and `E1rmEngine.trend` unify active workout display and analytics history.
- **Drop Set Planning (`DropSetPlanner`):**
  - Automated 20% stepped weight drops with rounding to standard gym plate increments (2.5 kg / lb).
  - Groups sets into `DropSetChain` for volume and rep reporting.
  - Tapping `DROP` in `ActiveExerciseCard` auto-populates the 20% drop from the prior set.
- **Superset Engine & Backward-Compatible Storage (`SupersetEngine`):**
  - Added nullable `String? supersetGroupId` to `Exercise` and `ExerciseModel`.
  - Backward compatibility: null for all pre-Wave-8 records, preserving all existing saved workouts and exports.
  - `BackupRecordCodec` serializes and deserializes `supersetGroupId`.
  - Adjacent exercises with matching `supersetGroupId` are automatically partitioned into blocks with `A1`, `A2`, `B1`, `B2`... labels.
  - In `ActiveWorkoutScreen`:
    - Shows `SupersetConnectorDivider` between consecutive exercises to link/unlink with 1 tap.
    - Displays `SS A1`, `SS A2` badges on `ActiveExerciseCard`.
    - In a superset round, automatically focuses the partner exercise and skips the rest timer until the full superset round is completed.
    - Drop sets automatically skip the rest timer.
