# IronFlow — Database Links & Synchronization Audit

**Date:** 2026-10-21 · **Scope:** all 402 Dart files under `lib/` (~91k LOC), Hive, Firestore,
Realtime Database, Riverpod provider graph, `firestore.rules` / `storage.rules`.
**Method:** static trace of every entity → model → datasource → repository → provider → screen
chain, every Hive `openBox`/`box()` call, every Firestore `collection()` path, and every
`ref.watch/read/invalidate` cross-feature edge. Line numbers refer to commit `894392d` (master).

> **TL;DR — why "synchronization is broken in all components"**
>
> There is no single bug. The app currently has **3 database backends, 5 sync mechanisms
> (none wired end-to-end), 22 Hive boxes, 2 incompatible schemas sharing the `sync_queue`
> box, 3 different user-ID schemes plus a hardcoded `'test-user'` and *mock* authentication
> (so Firebase sees `request.auth == null` and denies essentially every cloud write),
> 5 different Firestore path layouts of which only 1 matches `firestore.rules`, no
> `userId` and no `updatedAt` on any syncable entity, exercises linked by free-text *name*
> instead of ID, and no reactive data layer at all** (zero `Box.watch()` streams — every
> screen refreshes via hand-maintained invalidate/counter calls that are repeatedly missed).
> Each feature was built with its own private copy of the truth; nothing propagates changes
> between them reliably. Any one of the Critical findings (F-01…F-05) alone produces the
> symptoms you see everywhere.

---

## 1. System inventory (what actually exists)

| Layer | What exists | Status |
|---|---|---|
| Auth | `MockAuthDataSourceImpl` + `MockUserDataSourceImpl` wired in `auth_provider.dart:26`; real `FirebaseAuthDataSourceImpl` / `FirestoreUserDataSourceImpl` exist but are **unreachable** because `AuthRepositoryImpl`'s constructor is hard-typed to the mock classes | 🔴 Fake users, no Firebase session |
| Local DB | Hive, 18 boxes opened by `HiveManager`, 22 box names referenced in code (§4) | 🟠 Partially inventoried/wiped |
| Cloud DB #1 | Cloud Firestore (nutrition, sync, foods, exercises, profile, backups) | 🔴 Paths vs rules mismatch (§5) |
| Cloud DB #2 | Firebase **Realtime Database** (`realtime_db_user_datasource.dart`) | ⚫ Dead code, never instantiated |
| Prefs | `app_settings` `Box<String>` (theme/language/units/timezone/haptics) + `SharedPreferences` + `SecureStorageManager` (never written, only wiped) — 3 separate pref stores | 🟡 |
| Sync engines | **5**: `SyncService`+`SyncAction` queue, `SyncQueueManager`+`SyncOperation` queue, `SyncOfflineDataUseCase` (stub), `BackgroundSyncService` (placeholder), `PeriodicSyncService` (unused) | 🔴 §6 |
| Catalogs | Foods: static Dart lists + Hive cache + dead Hive DS + Firestore + bundled JSON. Exercises: static Dart list + Hive + Firestore | 🟠 §7 |

---

## 2. Model link map — the "database links between models"

This is the core of the audit: for every entity, its primary key, how it links to other
entities, where it is stored, and whether the link can survive sync.

### 2.1 Intended domain graph (what the links *should* be)

```
User (1) ──< (N) Workout (1) ──< (N) Exercise (1) ──< (N) SetEntry
  │                 │                     │
  │                 └─► programDay ─┐     └─► ExerciseDefinition (catalog)
  ├─1:1─ ActiveProgram ─1:1─ WorkoutProgram ─< ProgramDay ─< ProgramExercise ─► ExerciseDefinition
  ├─1:1─ UserProfile (goal, weightKg, …) ──derives──► NutritionTargets, DietPlan, WorkoutProgram
  ├─< Meal ─► FoodItem (catalog)        ├─< BodyEntry (weight, measurements)
  └─1:1─ DietPlanState ─1:1─ DietPlan ─< DietDay ─< DietMeal
```

### 2.2 Actual link map (as implemented)

Legend: ✅ real ID link · ⚠️ string/name link · ❌ no link stored · `uid?` = has `userId` field.

| Entity (`domain/entities/`) | PK | Links **out** | Stored in (Hive box / key) | Firestore path written | uid? | updatedAt? | Verdict |
|---|---|---|---|---|---|---|---|
| `auth/User` | `id` | — | `auth_session` (session copy) | RTDB `users/{id}` (dead) | is the user | ✅ | Three ID schemes (F-01) |
| `auth/UserProfile` | `userId` | ✅ → User | **in-memory `Map` only** (`MockUserDataSourceImpl._profiles`) — lost on restart | `users/{uid}/profile/data` (DS unreachable) | ✅ | ✅ | Orphaned duplicate of onboarding profile |
| `onboarding/UserProfile` | *none* (keyed externally `profile_{uid}`) | ❌ no userId field at all | `user_profile` / `profile_{uid}` + legacy `profile` | — never synced | ❌ | ❌ | The profile every screen uses; invisible to auth/cloud |
| `workout/Workout` | `id` (UUID) | embeds `List<Exercise>`; ❌ no programId / programDayIndex / userId | `workouts` / `workout.id` | `workouts/{workoutId}` + `userId` field (sync DS) | ❌ | ❌ | F-05, F-06, F-11 |
| `workout/Exercise` | `id` (UUID **per session**) | ⚠️ → catalog by `name` string only; ❌ no `exerciseDefinitionId` | embedded in Workout JSON | embedded | ❌ | ❌ | F-05 |
| `workout/SetEntry` | `id` (UUID) | (embedded child — OK) | embedded | embedded | — | timestamp only | OK as embedded value |
| `workout/ExerciseDefinition` | `id` (catalog) | referenced by **nothing** | static `ExerciseDatabase.all`; also `exercises` box; also Firestore `exercises` | `exercises/{id}` | — | ❌ | Catalog ID space #3, unused as FK |
| `workout/WorkoutProgram` / `ProgramDay` | `id` / `dayNumber` | embeds days | embedded in ActiveProgram JSON | `programs/{programId}` (sync DS, `WorkoutProgramModel`) | ❌ | ❌ | `getActiveProgram` queries an `isActive` field this model never has → always null (F-11) |
| `workout/ProgramExercise` | *none* | ⚠️ → catalog by `exerciseName` string | embedded | embedded | ❌ | ❌ | F-05 |
| `workout/ActiveProgram` | `id` (= `millisecondsSinceEpoch` string, `active_program_providers.dart`) | embeds whole `WorkoutProgram` copy; `completedDays: Map<dayIndex, DateTime>` ❌ no workoutId | `active_program` / `current_active_program` (+ `archived_active_program`) | via `WorkoutProgramModel` only — `currentDayIndex`/`completedDays` **never synced** | ❌ | ❌ | F-06; box not in HiveManager/wiper (F-04) |
| `nutrition/Meal` | `id` (UUID) | ❌ no `foodItemId`, no quantity/unit — name + macro snapshot only | `meals` / `meal.id` | `users/test-user/nutrition/{mealId}` (live repo) **and** `nutrition/{mealId}` (sync DS) — two homes | ❌ | ❌ | F-01, F-16 |
| `nutrition/NutritionTargets` | keyed singleton | `userId` field exists but callers pass `'test-user'`/stale values | `macro_targets` / `current` | `users/{uid}/nutrition/targets` | ✅ (wrong value) | ✅ | **No live writer** (F-08) |
| `nutrition/MacroTarget` (legacy) | keyed singleton | — | `macro_targets` / `current` — **same box+key, different schema** | — | ❌ | ❌ | F-09 (latent; its DS is dead) |
| `nutrition/DietPlan`/`DietDay`/`DietMeal` | *none* | `DietMeal.toMeal()` mints new UUID + `now()` per call | embedded in DietPlanState | — | ❌ | ❌ | Never copied into NutritionTargets (F-08) |
| `nutrition/DietPlanState` | keyed singleton | embeds DietPlan | `diet_plan` / `current_diet_plan` | — never synced | ❌ | ❌ | Box not in HiveManager/wiper |
| `nutrition/FoodItem` (legacy) | `id` | — | static lists | — | — | ❌ | Parallel to FoodItemFull (F-16) |
| `nutrition/FoodItemFull` | `id` | referenced by Meal? ❌ | `foods` box, keys `foods_cache` (whole catalog as one List) + `custom_foods`; dead DS uses `food_items_full` box | `foods/{id}` (upload rewrites ids to `{id}_{n}` on collision!) | — | cache ts only | F-10, F-14 |
| `body/BodyEntry` | `id` (UUID) | ❌ no link back to profile | `body_entries` / `entry.id` | `body_progress/{id}` (sync DS, raw maps) | ❌ | ❌ | Weight never updates `profile.weightKg` (F-08) |
| `retention/Streak` | keyed singleton | ❌ stored counter, not derived from workouts | `streak` | — | ❌ | own dates | `updateAfterWorkout()` has **0 callers** (F-06) |
| `retention/Achievement` | — | derives from `streakProvider` in UI | — | — | ❌ | — | Inherits frozen streak |
| `retention/NotificationSettings` | keyed singleton | — | `notification_settings` / `settings` | — | ❌ | ❌ | **Schema collision** (F-09) |
| `notifications/ReminderSettings` | keyed singleton | — | `notification_settings` / `settings` ← same box+key! | — | ❌ | ❌ | F-09 |
| `ai/Insight`, `ai/InsightCache` | context key | ❌ no userId in key | `insight_cache` / context name | — | ❌ | expiry only | Cross-account cache reuse (F-04) |
| `ai/ChatMessage` | — | ❌ no userId | `ai_chat_history` | — | ❌ | ❌ | F-04 |
| `core/SyncOperation` | `id` | `collection`+`documentId` strings | `sync_queue` via `box.add()` (auto-int key) | `op.collection/op.documentId` verbatim | ❌ in payload only | createdAt | **Box collision** (F-03) |
| `sync/SyncAction` | `id` | `dataType` enum + `dataId` | `sync_queue` via `box.put(action.id)` ← same box | via typed methods | ❌ (passed separately, often null) | timestamp | F-03 |
| `analytics/*` (derived) | `exerciseId`, `userId` params | matches workouts by per-session `Exercise.id` | computed on read | — | (ignored) | — | Max 1 point per series (F-05) |

**Headline facts about the links**

1. **No syncable entity carries `userId`** (except `NutritionTargets`, with a hardcoded
   wrong value). Ownership exists only as a Firestore path segment or an ad-hoc field added
   at sync time — local data is globally shared on the device.
2. **No syncable entity carries `updatedAt`/`version`/`deletedAt`.** Last-write-wins is
   impossible; see F-11.
3. **The exercise link is a free-text name** everywhere it matters (`ProgramExercise.exerciseName`,
   `Exercise.name`, `ExerciseDatabase.getByName`, video map, PR detection), while Analytics
   uses the per-session UUID and the catalog uses a third ID — three incompatible notions
   of "same exercise" (F-05).
4. **Workout ↔ program link does not exist in data.** "Which program day did this workout
   fulfill?" is unanswerable after the fact; day advancement is a UI side effect (F-06).
5. **Profile exists 3×** (auth profile in RAM, onboarding profile in Hive, Firestore
   profile never written) with **no synchronization between any pair** (F-01/F-08).

---

## 3. Findings register (severity-ordered, with evidence)

### F-01 🔴 Authentication is mocked; user identity is unstable — every cloud write is unauthorized

- `lib/features/auth/presentation/providers/auth_provider.dart:24-31` wires
  `MockAuthDataSourceImpl` + `MockUserDataSourceImpl`. `AuthRepositoryImpl` is *typed* to the
  mock classes, so the real Firebase datasources cannot even be injected without editing the
  repository. Firebase Auth is therefore never signed in ⇒ `FirebaseAuth.instance.currentUser`
  is `null` (e.g. `gemini_ai_service.dart:73` gets a null ID token) and **every** Firestore
  write runs with `request.auth == null` → denied by `firestore.rules`.
- Mock user IDs are not stable identities:
  - sign-up: `user_${DateTime.now().millisecondsSinceEpoch}` — new person every registration;
  - sign-in: `user_${email.hashCode}` — Dart `String.hashCode` is not a persistent identity
    (and differs from the sign-up ID for the same human);
  - Google: `google_${googleUser.id}` — a third scheme.
  Anything keyed by userId (onboarding `profile_{uid}`/`onboarded_{uid}`, targets, sync,
  Firestore paths) is orphaned on the next login path.
- `lib/features/nutrition/presentation/providers/nutrition_providers.dart:24-30`:
  `const userId = 'test-user'; // TODO: Get userId from auth provider` — **all** nutrition
  cloud traffic for **all** users targets `users/test-user/...`.
- `MockUserDataSourceImpl` stores auth `UserProfile`s in a static in-memory `Map` — profiles
  vanish on process death, while the onboarding profile (a different class) persists in Hive.

### F-02 🔴 Firestore layout vs `firestore.rules`: 5 writers, 5 layouts, 1 allowed

| Writer | Path written | Rule that must allow it | Result |
|---|---|---|---|
| `FirestoreUserDataSourceImpl` | `users/{uid}/profile/data` | `users/{userId}/profile/**` | ✅ **only match** (but DS unreachable, F-01) |
| `FirestoreSyncDataSourceImpl` | `workouts/{workoutId}`, `programs/{programId}`, `nutrition/{logId}`, `body_progress/{id}`, `sync_metadata/{uid_type}` (flat + `userId` *field*) | rules expect `workouts/{userId}/**` etc. — i.e. doc-id **is** the userId | ❌ workoutId ≠ uid → `isOwner` fails; `sync_metadata` has no rule at all |
| `FirestoreNutritionDatasource` (live nutrition repo) | `users/{uid}/nutrition/{mealId}`, `.../nutrition/targets` | only `profile/**` exists under `users/{userId}` | ❌ no rule → denied (and uid is `test-user`) |
| `BackupDataUseCase` | `users/{id}/backups/{backupId}` | none | ❌ denied |
| `FirestoreFoodDatasource` / `FirestoreExerciseDatasource` | `foods/{id}`, `exercises/{id}` | none | ❌ denied |
| `RealtimeDbUserDataSource` | RTDB `users/{uid}/workouts/...` | no `database.rules.json` in repo | ⚫ dead code anyway |

There is also **no `firebase.json`** and **no `firestore.indexes.json`**, while
`FirestoreSyncDataSourceImpl.getWorkouts/getNutritionLogs/getBodyProgress` run
`where(userId).orderBy(date).where(syncedAt >)` composite queries that require indexes →
`FAILED_PRECONDITION` even after fixing rules/auth.

### F-03 🔴 Two sync queues share one Hive box with incompatible schemas; five sync engines, zero wired

`sync_queue` box writers:
- `core/utils/sync_queue_manager.dart` — `SyncOperation{id,type,collection,documentId,data,createdAt,retryCount}` stored with `box.add()` (auto-increment integer keys), consumed by `SyncPendingOperationsUseCase` → `syncBatch()` and by `core/providers/sync_provider.dart` (`autoSyncProvider`).
- `features/sync/data/datasources/hive_sync_queue_datasource.dart` — `SyncAction{id,type,dataType,dataId,data,timestamp,status,retryCount}` stored with `box.put(action.id)`, consumed by `SyncService` (`features/sync/domain/services/sync_service.dart`).

`SyncQueueManager.getPendingOperations()` parses **every** box entry with
`SyncOperation.fromJson` and has no per-item `try/catch` — one `SyncAction` entry poisons
the entire call → auto-sync permanently errors once `SyncService` queued anything. The
reverse direction silently drops entries. This alone guarantees "sync sometimes does
nothing, sometimes errors" depending on which engine ran first.

And neither engine is actually connected to the app's writes:

- `workout_providers.dart:23-27` provides plain `WorkoutRepositoryImpl` (Hive-only).
  `SyncedWorkoutRepository` (the only writer that enqueues `SyncAction`s) is **never
  instantiated anywhere** (verified: 0 references outside its file + its test).
- `SyncService.initialize()` and `queueAction()` call `syncAll()` **without** `userId`;
  `syncAll` immediately returns on `userId == null` — so connectivity/timer/manual triggers
  via those paths are no-ops. Only `syncTriggerProvider` passes a userId, and it reads it
  from `currentUserProvider` (mock user, F-01).
- Body/nutrition/program/active-program writes never enqueue anything in any queue.
- Three more mechanisms are decorative: `SyncOfflineDataUseCase` (iterates a hardcoded
  empty list), `BackgroundSyncService._performBackgroundSync` (`Future.delayed(2s)` +
  TODO comments), `PeriodicSyncService` (0 callers). `test/features/sync/sync_pipeline_test.dart`
  tests the dead `SyncedWorkoutRepository` path with fakes — green tests for code that
  never runs in the app.

### F-04 🔴 No per-user isolation locally; logout/wipe leaves data behind (cross-account contamination)

- All Hive boxes are device-global and entities have no `userId` (see §2.2). `signOut()`
  (`auth_notifier.dart`, mock DS) clears **only** `auth_session`. The next account on the
  same device inherits the previous user's workouts, meals, body entries, streak, AI chat
  and insight cache (insight cache keys are context names, not user-scoped).
- `LocalDataWiper._userScopedBoxNames` includes unused boxes (`programs`, `nutrition`,
  `user`, `settings`) but **misses `active_program`, `diet_plan`, `food_items_full`,
  `active_workout_state`** — so even the explicit "delete my data" flow leaves the active
  program, diet plan and in-progress workout for the next user. It also wipes a phantom
  `user_profile_box_{userId}` box that nothing ever creates.
- `HiveManager.clearAll()` misses `user_profile`, `auth_session`, `ai_chat_history`,
  `active_program`, `diet_plan`, `active_workout_state`.

### F-05 🔴 Exercise identity is broken three ways — history, PRs, progression and analytics cannot agree

1. `StartWorkoutUseCase` creates each session `Exercise` with a fresh `Uuid().v4()`
   (`start_workout_use_case.dart:33-38`). `AnalyticsRepositoryImpl.getStrengthProgression`
   then matches `exercise.id == exerciseId`, so a "progression" series can contain at most
   **one** session, and `getAllStrengthProgressions` emits one single-point series per
   session-exercise (all named e.g. "Bench Press").
2. `WorkoutRepositoryImpl.getExerciseHistory` matches by **name, case-insensitive**, while
   `GetProgressionSuggestionUseCase` matches by **name, exact `==`** — the two disagree on
   the same data.
3. `ExerciseDefinition.id` (catalog) is stored **nowhere** on `Exercise` or
   `ProgramExercise`; renaming/swapping/localizing an exercise severs its history, PRs,
   videos (`ExerciseDatabase.getByName`, `exercise_video_map.dart`) and AI context.
4. Data loss on the same seam: `StartWorkoutUseCase` drops `ProgramExercise.sets/reps/rest/targetWeight`
   (creates empty `sets`, no suggested values), and `ExerciseModel` omits the entity's
   `suggestedReps`/`suggestedSets` fields — they are lost on **every** save/load round-trip,
   so progression suggestions always fall back to defaults (`?? 8`, `?? 3`).

### F-06 🟠 Workout completion is a non-atomic UI script; program/streak/AI links are manual and partially missing

`ActiveWorkoutScreen._finishWorkout` (`active_workout_screen.dart:347`):
**1)** `activeProgramProvider.completeCurrentDay()` (advances + persists program) runs
**before** **2)** `workoutNotifier.finish()` (saves the workout). If step 2 throws or the
app is killed between them, the program has advanced with no workout recorded — and there
is no data link to detect/repair it (Workout has no program day reference, `completedDays`
stores no workoutId). Any finish path (empty workout, repeated workout) advances the day.
Inside `finish()` (`workout_providers.dart`): saves workout → analytics → `globalAI.onWorkoutCompleted`
(the **only** AI hook with a caller) → clears `active_workout_state` → bumps
`workoutRefreshCounter`. It never updates the streak: `StreakNotifier.updateAfterWorkout()`
has **zero callers in `lib/`**, so the stored streak (and achievements derived from it) is
frozen regardless of training. Symmetrically, `GlobalAI.onMealLogged()` and
`onBodyWeightRecorded()` exist but have **zero callers**, so nutrition/body insights only
refresh via change-detection at next AI init.

### F-07 🟠 Riverpod family keyed by raw `DateTime.now()` — Home and Nutrition hold different state for "today" ✅ *fixed in this branch*

`dailyNutritionSummaryProvider` is `StateNotifierProvider.family<..., DateTime>`.
`NutritionScreen` keys it with normalized midnight (`_todayDate()`), but Home's
`_DailyFuelSummaryBar` passed raw `DateTime.now()` (time-of-day included) — a **different
provider instance and notifier on every build**, and `invalidate(...(DateTime.now()))` in
Home's pull-to-refresh and `HomeScreenNotifier.refresh()` invalidated a fresh unused key
(no-op). Adding a meal in Nutrition therefore could not update Home's fuel bar.
**Fixed here:** the 3 offending call sites now normalize to `DateTime(y, m, d)`
(`home_screen.dart`, `home_screen_provider.dart`). Long-term the family should take a
`yyyy-MM-dd` string (see roadmap).

### F-08 🟠 Nutrition targets have three competing sources and no live writer

- Source A: `onboarding/UserProfile.dailyCalorieTarget` (computed; weight frozen at
  onboarding — `BodyEntry` weight is never written back to `weightKg`, verified by tracing
  all `weightKg` writes; they occur only in onboarding/profile generation code).
- Source B: `NutritionTargets` in Hive `macro_targets/current` + Firestore. Its only
  repository caller is `NutritionNotifier.updateTargets` (`nutrition_notifier.dart:434`) —
  a notifier with **no provider and no callers**. In the running app, `summary.target` is
  therefore effectively always `null` locally, and onboarding creates a `DietPlan` but
  never a `NutritionTargets`.
- Source C: `DietPlan.dailyCalories/proteinG/...` in the `diet_plan` box — never copied
  into B.
Consumers mix them inconsistently: `home_screen_provider.dart` takes calories from A but
protein/carbs/fats from B; `HomeScreen`'s fuel bar uses A with a 2000-kcal fallback; the
nutrition use cases read B. Rings/percentages legitimately disagree between screens.

### F-09 🟠 Same Hive box + same key, two schemas (settings); latent twin in macro targets

`notification_settings` box, key `settings` is read/written by both
`retention/HiveNotificationSettingsDataSource` (`NotificationSettings`) and
`notifications/HiveReminderSettingsDatasource` (`ReminderSettings`). Last writer wins;
the other reader catches the parse failure and returns defaults/null → user-visible symptom:
notification settings randomly reset. The same pattern exists latently at
`macro_targets`/`current` (`MacroTargetModel` in dead `HiveNutritionDataSource` vs live
`NutritionTargetsModel` in `HiveNutritionDatasource`) — one import away from reactivating.

### F-10 🟠 Duplicate provider names with different implementations — what a screen sees depends on its imports

Verified duplicates: `foodRepositoryProvider` ×3, `foodSearchProvider` ×2,
`userProfileProvider` ×2 (returning **different `UserProfile` classes**),
`syncStatusProvider` ×2 (`StateProvider<String>` vs `FutureProvider<SyncStatusEntity>`),
`firestoreSyncDataSourceProvider` ×2, `connectivityProvider`/`isOnlineProvider` ×2,
plus duplicate `MealType` enums. Two of the `foodRepositoryProvider`s are runtime bombs:
`nutrition_providers.dart:38` does `repository as FoodRepository` on
`NutritionRepositoryImpl`, which does **not** implement `FoodRepository` (the interfaces
are unrelated) → `CastError` when meal-suggestion/alternative/search providers are read;
`food_providers.dart:172` repeats it `as dynamic` → `NoSuchMethodError` on first
food-repo call from `CustomFoodsNotifier`. The third (`food_cache_provider.dart`) is a real
`FoodRepositoryImpl` — so "the food catalog" is a different object (or a crash) depending
on which file a screen imported. Exercises have the same shape: catalog screen uses static
`ExerciseDatabase` via `GetExercisesUseCase`, while `exercise_provider.dart`'s
Firestore+Hive `ExerciseRepositoryImpl` stack is used by no screen.

### F-11 🟠 Sync conflict handling & pulls are structurally incapable of converging

- No `updatedAt` anywhere (§2.2); `SyncService._pullCloudChanges` compares
  `Workout.date` (session *start*) to decide winners — editing a past workout can never
  win or lose correctly. Program pull **unconditionally** overwrites the local program
  definition with the cloud one.
- Deletes don't propagate: `_syncNutritionAction`/`_syncBodyProgressAction` `delete` cases
  are empty `break;` — deleted meals/body entries resurrect on next pull.
- `FirestoreSyncDataSourceImpl.getActiveProgram` filters `where('isActive', isEqualTo: true)`
  on `WorkoutProgramModel` documents that never contain `isActive` → always empty → active
  program progress (day index, completed days) never leaves the device.
- `NutritionRepositoryImpl.getDailyNutrition` returns local data if **any** local meal
  exists that day and never merges cloud data (same pattern in `getMealsByDate`); history
  sync only *adds missing ids* (never updates/deletes). Two devices diverge permanently.
- Pull writes go straight to Hive datasources, bypassing Riverpod — even a successful pull
  is invisible to mounted screens until something else invalidates them.

### F-12 🟡 No reactive data layer — manual invalidation is the only propagation mechanism, and it's routinely missed

There is not a single `Box.watch()`/`listenable()` subscription in `lib/`. Propagation
relies on: `workoutRefreshCounterProvider` / `bodyRefreshCounterProvider` integer bumps,
scattered `ref.invalidate(...)` calls, load-once notifiers (`HomeScreenNotifier` does
`ref.read` in its constructor; `activeProgramProvider` loads once), and explicit AI hooks.
Verified misses include F-06 (streak, AI nutrition/body) and: `finish()` doesn't refresh
analytics providers; program-editor must remember to invalidate `activeProgramProvider`
in 4 separate places; `homeScreenProvider` itself is defined but watched by **no** screen
(`home_screen.dart` watches the primitive providers directly) — two parallel "home" data
paths. With ~40 providers and no single source of truth, every new writer must know every
reader; the 200+ `docs/development/*FIX*` files are largely this failure mode recurring.

### F-13 🟡 Backup/Export/Restore is a fourth serialization dialect

`RestoreDataUseCase._parseWorkout` hand-parses snake_case keys (`duration_minutes`,
`total_volume`…) instead of using `WorkoutModel`, drops `SetEntry.type`
(warmup/drop/failure → normal), and fabricates IDs (`set_${idx+1}` — colliding across
exercises within a workout; `meal_${milliseconds}`) when keys are missing. Export writes
its own JSON shape; cloud backup targets a rules-denied path (F-02). A backup→restore
round-trip is therefore lossy in ways unrelated to the Hive schema.

### F-14 🟡 Catalogs: 4–5 sources of truth each, with ID rewriting on upload

Foods: (1) `FoodDatabase.foods` = `verified_foods_data.dart` + legacy `foods_list.dart`
merged by id+name dedupe, (2) Hive `foods/foods_cache` (entire catalog under one key +
TTL/version), (3) dead `food_items_full` box datasource, (4) Firestore `foods`,
(5) `assets/data/verified_foods.json`. Exercises: static `ExerciseDatabase.all`, Hive
`exercises`, Firestore `exercises`. Both Firestore upload datasources silently rewrite
colliding ids to `{id}_{n}` and store the rewritten id inside the document — cloud and
local catalogs then disagree on IDs for the same item.

### F-15 🟡 Meals are unlinked snapshots; `FoodItem` vs `FoodItemFull` parallel models

`Meal` stores only `name` + nutrient snapshot: no `foodItemId`, quantity or unit. Custom-food
edits can't be traced to logged meals; "recent foods" dedupes by name string;
`DietMeal.toMeal()` fabricates identity per call. The codebase maintains both `FoodItem`
(static lists, suggestions) and `FoodItemFull` (repositories) with conversions scattered
across use cases — another seam where fields (micros/tags/budget) are dropped silently.

### F-16 ⚪ Build hygiene that masks all of the above

`*.g.dart`/`*.freezed.dart` are gitignored (0 committed), yet `.github/workflows/ci.yml`
runs `flutter analyze`/`flutter test` **without a `build_runner` step** — CI as configured
cannot pass on a clean checkout, so there is no trustworthy automated signal for exactly
the cross-file contract breaks catalogued here.

---

## 4. Hive box inventory (22 names; HiveManager opens 18)

| Box | Opened by | Type | Written/read by | In `HiveManager.clearAll` | In `LocalDataWiper` | Notes |
|---|---|---|---|---|---|---|
| `workouts` | HiveManager | `Box<Map>` | `HiveWorkoutDataSource` | ✅ | ✅ | |
| `exercises` | HiveManager | `Box<Map>` | `HiveExerciseDatasource` (via `openBox` getter) | ✅ | protected | catalog cache |
| `active_program` | datasource getter | `Box<Map>` | `HiveActiveProgramDataSource` | ❌ | ❌ | **leaks across accounts/wipe** |
| `active_workout_state` | `WorkoutStateManager.init` | `Box<dynamic>` | in-progress workout + rest timer | ❌ | ❌ | **leaks**; ghost-workout restores |
| `programs` | HiveManager | `Box<Map>` | **nothing** | ✅ | ✅ | dead box |
| `meals` | HiveManager | `Box<Map>` | `HiveNutritionDatasource` (+ dead twin DS) | ✅ | ✅ | |
| `macro_targets` | HiveManager | `Box<Map>` | `HiveNutritionDatasource` (key `current`) | ✅ | ✅ | latent schema twin (F-09) |
| `diet_plan` | datasource getter | `Box<Map>` | `HiveDietPlanDataSource` | ❌ | ❌ | **leaks** |
| `foods` | HiveManager | `Box<dynamic>` | `HiveFoodDataSource` (`foods_cache`, `custom_foods`, ts, version) | ✅ | protected | custom *user* foods in a "protected" box — never wiped per-user |
| `food_items_full` | dead DS only | `Box<Map>` | `HiveFoodItemFullDataSource` (0 callers) | ❌ | ❌ | dead |
| `nutrition` | HiveManager | `Box<Map>` | **nothing** (nutrition uses `meals`/`macro_targets`) | ✅ | ✅ | dead box; name collides with Firestore collection |
| `body_entries` | HiveManager | `Box<Map>` | `HiveBodyDataSource` | ✅ | ✅ | |
| `streak` | HiveManager | `Box<Map>` | `HiveStreakDataSource` | ✅ | ✅ | value frozen (F-06) |
| `user_profile` | HiveManager | `Box<dynamic>` | `UserProfileStorage` | ❌ | ✅ | |
| `auth_session` | HiveManager | `Box<dynamic>` | `AuthSessionStorage` | ❌ | conditional | session store #1 |
| `user` | HiveManager | `Box<Map>` | **nothing** | ✅ | ✅ | dead box |
| `settings` | HiveManager | `Box<Map>` | **nothing** (prefs use `app_settings`) | ✅ | ✅ | dead box |
| `app_settings` | HiveManager | `Box<String>` | theme/language/units/timezone/haptics | ✅ | ❌ (device prefs — arguably correct) | |
| `app_state` | **nobody** | — | constants + wiper only | — | conditional | phantom |
| `sync_queue` | HiveManager | `Box<Map>` | **two schemas** (F-03) | ✅ | ✅ | 🔴 collision |
| `notification_settings` | HiveManager | `Box<Map>` | **two schemas, same key** (F-09) | ✅ | ✅ | 🔴 collision |
| `insight_cache` | HiveManager | `Box<Map>` | `InsightCacheServiceImpl` (own `openBox` too) | ✅ | ✅ | not user-scoped |
| `ai_chat_history` | HiveManager | `Box<dynamic>` | `AiChatStorage` | ❌ | ✅ | not user-scoped |

Box names are string literals duplicated in ≥4 places (`HiveManager`, `AppConstants`,
each datasource, `LocalDataWiper`) with no shared constants class actually used by the
datasources — which is how the wiper/manager inventories drifted from reality.

## 5. Firestore path map (writers vs readers vs rules)

See F-02 table. Summary: the *sync* datasource uses flat top-level collections keyed by
entity id + `userId` field; the *nutrition* datasource uses `users/{uid}/nutrition`
subcollections; *rules* expect `users/{uid}/profile/**` and `{collection}/{userId}/**`;
backup uses `users/{id}/backups`. No two subsystems agree on where a meal or workout lives
in the cloud, so even with auth+rules permissive, writer A could not be read by reader B.

## 6. Sync engine inventory

| # | Engine | Queue / trigger | Connected to app writes? |
|---|---|---|---|
| 1 | `features/sync SyncService` | `sync_queue` (`SyncAction`), connectivity + 5-min timer + manual | ❌ only dead `SyncedWorkoutRepository` enqueues; triggers call `syncAll()` w/o userId |
| 2 | `core SyncQueueManager` + `SyncPendingOperationsUseCase` | `sync_queue` (`SyncOperation`), `autoSyncProvider`, `SyncRepositoryImpl.addToSyncQueue` (0 callers found in features) | ❌ |
| 3 | `SyncOfflineDataUseCase` (workout) | none (hardcoded empty list) | ❌ stub |
| 4 | `BackgroundSyncService` (workmanager) | periodic task → `Future.delayed` placeholder | ❌ never initialized in `main.dart` |
| 5 | `PeriodicSyncService` | 15-min timer | ❌ 0 callers |
| — | Direct dual-write in `NutritionRepositoryImpl` | Hive then Firestore try/catch-swallow | ⚠️ live, but uid=`test-user`, path rules-denied, failures swallowed → silent divergence |

**Net effect today:** the app is effectively **local-only** (Hive), with cloud writes that
fail silently. "Sync problems in all components" at the UI level are then produced by
F-05…F-12 (local link/propagation breaks), which is why fixing any single screen never
sticks.

## 7. Dead / duplicate code that actively causes mis-wiring

Verified 0 references outside their own file (excluding tests): `SyncedWorkoutRepository`,
`HiveNutritionDataSource` (twin), `HiveFoodItemFullDataSource`, `RealtimeDbUserDataSource`,
`FirebaseAuthDataSourceImpl`, `FirestoreUserDataSourceImpl`, `SyncOfflineDataUseCase`,
`PeriodicSyncService`, `BackgroundSyncService`(+Manager), `ResilientWorkoutRepository`,
`homeScreenProvider`/`HomeScreenNotifier`, `NutritionNotifier` (no provider),
`MacroTargetModel` chain. Duplicated-by-name providers/enums: see F-10. This matters
because every new feature (human or AI-generated) has ~a coin flip's chance of wiring into
a dead copy — the probable origin of several findings above.

---

## 8. Target architecture (recommended end state)

**Principles:** one identity, one local source of truth per aggregate, one outbox, one
cloud layout, links by ID, derived data derived (not stored), propagation via watched
streams instead of remembered invalidations.

1. **Identity:** real Firebase Auth; `AuthRepositoryImpl` depends on abstract
   `FirebaseAuthDataSource`/`FirestoreUserDataSource` (mocks only as test doubles).
   A single `currentUserIdProvider` (from `authStateChanges`) is injected into every
   repository; the string `'test-user'` and mock ID schemes are deleted. Merge the two
   `UserProfile` classes into one entity stored at `users/{uid}` (cloud) + `user_profile`
   box (local, key `profile_{uid}` during transition, then simply the uid-namespaced box).
2. **Entity link fixes (schema v2):**
   - Add to every syncable entity+model: `userId`, `createdAt`, `updatedAt`, `deletedAt?` (tombstone).
   - `Workout`: + `programId?`, `programDayIndex?`, `activeProgramId?`.
   - `Exercise`: + `exerciseDefinitionId` (keep `name` as display snapshot); restore
     `suggestedReps/suggestedSets` in `ExerciseModel`; `StartWorkoutUseCase` must carry
     sets/reps/rest/targetWeight from `ProgramExercise` (which also gains `exerciseDefinitionId`).
   - `Meal`: + `foodItemId?`, `quantity`, `unit` (keep snapshot macros for history integrity).
   - Unify `FoodItem`/`FoodItemFull` → one model; catalog is read-only reference data.
   - `Streak`: delete the stored counter; compute from workout dates (cache if needed, but
     workouts are the truth). Achievements derive from the same computation.
   - `NutritionTargets`: single writer `TargetsService` recomputed from profile on
     onboarding / profile edit / (product decision) new body-weight entry; manual overrides
     stored as explicit fields on the same document — one document every screen reads.
3. **Local DB:** keep Hive (no need to migrate engines), but: one `BoxNames` constants
   class used by *everyone*; open all boxes once in `HiveManager` (including
   `active_program`, `diet_plan`, `active_workout_state`); delete dead boxes
   (`programs`, `nutrition`, `user`, `settings`, `food_items_full`, `app_state`); split the
   colliding boxes (`sync_queue` → single schema; `notification_settings` →
   `reminder_settings` + delete the retention settings or rename its key/box); generate
   clear/wipe lists **from** the same inventory (add a test that fails when a box is
   registered but not classified user-scoped vs catalog vs device).
4. **Cloud layout (one):** `users/{uid}` doc = profile; subcollections
   `users/{uid}/workouts/{id}`, `…/meals/{id}`, `…/bodyEntries/{id}`,
   `…/activeProgram/current`, `…/nutritionTargets/current`, `…/dietPlan/current`,
   `…/backups/{id}`; top-level read-only `foods`, `exercises`. Rewrite `firestore.rules`
   to match exactly, add `firebase.json` + `firestore.indexes.json`, add rules tests.
   Delete the RTDB datasource and `firebase_database` dependency.
5. **One sync engine (outbox):** repositories write Hive + append one outbox row
   (surviving `SyncAction` *or* `SyncOperation` schema — pick one, delete the other and
   clear the legacy box via a one-time migration) in the same method. A single
   `SyncService` (triggered by connectivity, app-resume, post-write debounce, manual)
   pushes the outbox and pulls with `updatedAt` cursors per collection, LWW on
   `updatedAt`, tombstones for deletes, and writes pull results **through the
   repositories** so providers update. Delete engines #2–#5 in §6 and the direct
   dual-write in `NutritionRepositoryImpl`.
6. **Reactive UI:** expose `Stream`/watched providers per aggregate
   (e.g. repositories backed by `box.watch()`), replace refresh counters; key the nutrition
   day family by `yyyy-MM-dd` string; make Home a pure composition of watched providers
   (delete load-once `HomeScreenNotifier` path); finish-workout becomes one use case:
   `CompleteWorkoutUseCase` = save workout → advance program → recompute streak → notify
   AI, called by the screen in one step. Wire `onMealLogged`/`onBodyWeightRecorded`
   (or replace with the same watched-stream change detection).
7. **Dedupe:** one `foodRepositoryProvider` (backed by unified food repo), one
   `userProfileProvider`, one sync-status/connectivity provider file, one `MealType`;
   delete the dead files in §7. Export/restore must serialize via the real `*Model.toJson`
   (delete hand parsers).
8. **Migration:** one-time local migration on upgrade: stamp existing Hive rows with the
   signed-in uid + `updatedAt = date/timestamp`, backfill `exerciseDefinitionId` by exact
   catalog-name match (log misses), clear `sync_queue`, split `notification_settings`,
   then full push. Commit generated files **or** add `build_runner` to CI before
   analyze/test.

## 9. Phased remediation roadmap

**Phase 0 — stop the corruption (days, no schema change)** — implemented 2026-10-23, see §10.
- [x] Normalize `dailyNutritionSummaryProvider` keys (F-07, done in this branch).
- [~] Pick ONE sync queue schema (F-03) — *partial:* legacy reader now tolerates foreign
      entries and workout writes are wired into the `SyncAction` outbox; deleting the legacy
      `SyncOperation` pipeline remains (Phase 2).
- [x] Split `notification_settings` schemas into distinct keys (F-09).
- [x] Wire `StreakNotifier.updateAfterWorkout`, `GlobalAI.onMealLogged/onBodyWeightRecorded`
      at the single choke points (`WorkoutNotifier.finish`, `DailyNutritionNotifier.addMeal`,
      body save) and reorder `_finishWorkout` to save-then-advance (F-06).
- [x] Remove `'test-user'`: inject `authNotifierProvider` user id; stable mock ids (F-01 partial).
- [~] Add missing boxes to `LocalDataWiper`/`HiveManager.clearAll` (F-04) — done; *clear on
      sign-out deliberately deferred* until cloud sync is real (see §10 note).
- [x] Replace the two invalid-cast `foodRepositoryProvider`s with real implementations (F-10).

**Phase 1 — identity & links (schema v2 + migration)** — items 1–2 of §8, F-01/F-05/F-08/F-15.
Implemented 2026-10-23, see §11.

**Phase 2 — one cloud layout + one sync engine** — items 3–5 of §8, F-02/F-03/F-11/F-14.
Implemented 2026-10-23, see §12.

**Phase 3 — reactive propagation & dedupe** — items 6–7 of §8, F-06/F-10/F-12/F-13; add
`build_runner` to CI (F-16). Implemented 2026-10-23, see §13.

**Regression tests to add with each phase:** entity↔model JSON round-trip equality for
every model (catches F-05.4-class loss); single-schema outbox test (fails if a second
writer appears); box-inventory classification test (§8.3); Firestore rules tests (emulator);
finish-workout atomicity test (workout saved ⟺ day advanced ⟺ streak moved); cross-account
isolation test (sign-out → sign-in as user B → user A's data invisible); two-device
convergence test for meals/workouts incl. deletes; provider-family key test (Home vs
Nutrition same instance); export→restore round-trip via real models.

---

*Applied in this branch alongside this report:* F-07 key normalization (3 call sites, see
§3/F-07). Everything else above is analysis + plan; no other behavior was changed, because
the remaining fixes are schema/identity changes that must land together with the migration
in §8.8 rather than piecemeal.

---

## 10. Phase 0 implementation log (applied 2026-10-23, this branch)

Static verification only (no Flutter SDK in the audit environment) — run
`flutter pub get && dart run build_runner build --delete-conflicting-outputs && flutter analyze && flutter test`
locally. Codegen is required for the `ExerciseModel` change (steps 8).

| # | Finding | Change | Files |
|---|---|---|---|
| 1 | F-04 | `HiveManager` now opens `active_program`, `diet_plan`, `food_items_full` (Box<Map>) and `active_workout_state` (Box<dynamic>) centrally; `clearAll()` also clears `auth_session`, `user_profile`, `ai_chat_history` + the four above | `core/utils/hive_manager.dart` |
| 2 | F-04 | `LocalDataWiper` user-scoped list += `active_program`, `diet_plan`, `food_items_full`, `active_workout_state` | `settings/domain/services/local_data_wiper.dart` |
| 3 | F-09 | Retention notification settings moved from key `settings` → `retention_settings` (ends the ReminderSettings schema collision) | `retention/data/datasources/hive_notification_settings_data_source.dart` |
| 4 | F-03 | `SyncQueueManager`: entries keyed by operation id (`put`) instead of auto-int (`add`); `getPendingOperations` skips foreign `SyncAction` entries and per-item parse failures instead of poisoning the whole call | `core/utils/sync_queue_manager.dart` |
| 5 | F-03 | `workoutRepositoryProvider` now returns `SyncedWorkoutRepository` when a user is signed in (rebuilt on auth-id change via `select`), plain Hive repo otherwise — workout writes finally enqueue sync actions | `workout/presentation/providers/workout_providers.dart` |
| 6 | F-01* | Mock sign-up/sign-in now derive a **stable** id (`stableUserIdForEmail`, FNV-1a) — same email ⇒ same id on every path/restart. Nutrition repo userId comes from `authNotifierProvider` (`'local-user'` fallback); `'test-user'` deleted | `auth/data/datasources/mock_auth_datasource.dart`, `nutrition/presentation/providers/nutrition_providers.dart` |
| 7 | F-10 | Both invalid-cast `foodRepositoryProvider`s replaced with real `FoodRepositoryImpl(Firestore + Hive)` | `nutrition/presentation/providers/nutrition_providers.dart`, `nutrition/presentation/providers/food_providers.dart` |
| 8 | F-05* | `ExerciseModel` persists `suggestedReps/suggestedSets` (nullable ⇒ old JSON loads); `StartWorkoutUseCase` carries program `sets` + first rep count into the session; Analytics progression groups/matches by exercise **name** (id kept as exact-match fallback); progression suggestions now case-insensitive like `getExerciseHistory` | `workout/data/models/exercise_model.dart`, `workout/domain/usecases/start_workout_use_case.dart`, `analytics/data/repositories/analytics_repository_impl.dart`, `workout/domain/usecases/get_progression_suggestion_use_case.dart` |
| 9 | F-06 | `_finishWorkout` reordered: **save workout → advance program → maybe dialog** (+ `mounted` guard for the post-navigation race). Fixes the "generate new program loses the final workout" bug. `WorkoutNotifier.finish` updates streak (best-effort) via fixed `StreakNotifier.updateAfterWorkout` (now loads persisted streak first) and invalidates `streakProvider` | `workout/presentation/screens/active_workout_screen.dart`, `workout/presentation/providers/workout_providers.dart`, `retention/presentation/providers/streak_provider.dart` |
| 10 | F-06 | `DailyNutritionNotifier.addMeal` calls `GlobalAI.onMealLogged`; weight-log dialog calls `GlobalAI.onBodyWeightRecorded` (both previously 0 callers) | `nutrition/presentation/providers/nutrition_providers.dart`, `body/presentation/screens/progress_screen.dart` |
| 11 | F-08* | Onboarding now writes profile-derived `NutritionTargets` (macros from `UserProfile` computed targets; micros/vitamins/minerals = standard RDA constants) via optional `nutritionRepository` param (existing 5-arg test constructions unaffected). Logging a body weight updates `profile.weightKg` + invalidates `userProfileProvider`, so derived kcal/protein targets stop freezing at onboarding weight | `onboarding/presentation/providers/onboarding_provider.dart`, `body/presentation/screens/progress_screen.dart` |
| 12 | F-02* | Added `firebase.json` + `firestore.indexes.json` (composite indexes for the sync queries); rewrote `firestore.rules` to allow the layouts the code actually writes (per-user subtree `users/{uid}/**`, flat collections with `userId`-field ownership, `sync_metadata`, public-read catalogs) while keeping the legacy nested layout | repo root |
| 13 | F-16 | CI gains a `build_runner build` step before analyze/test | `.github/workflows/ci.yml` |

**Deliberately NOT done in Phase 0 (need device testing / schema migration — Phase 1/2):**

- *F-01 real Firebase Auth flip.* `AuthRepositoryImpl` is typed to the mocks; swapping to
  Firebase blind could lock every existing (mock) user out and orphan their locally-stored
  data before any cloud copy exists. Mock IDs are now at least stable (§10.6). Flip auth
  on a device against the real Firebase project, then migrate local rows to the Firebase uid.
  Until then `request.auth` is still null, so the new rules (§10.12) are *ready* but cloud
  writes remain denied — failures stay swallowed/local-only by design of the repositories.
- *F-04 wipe-on-sign-out.* With cloud sync still unauthorized, Hive is the only copy of user
  data; wiping on sign-out would destroy it unrecoverably. Enable only after Phase 2 sync
  is verified end-to-end. (Explicit delete-account/data flows now wipe completely — §10.1/2.)
- *F-05 `exerciseDefinitionId`, F-11 `userId/updatedAt/deletedAt` on entities, single sync
  schema, single Firestore layout.* Schema-v2 changes requiring the §8.8 migration +
  codegen across ~40 files. Analytics now groups by name (same convention as history/PR)
  as the bridge.
- *F-03 queue growth note:* with §10.5 wired, workout `SyncAction`s now enqueue for real.
  While auth is mock, pushes will fail, retry-capped (3) and remain in `sync_queue` as
  failed entries — harmless locally, and they will drain once Phase 1/2 lands. Watch queue
  size in debug logs (`hiveSyncQueueDataSourceProvider`).
- *F-07 follow-up (unchanged):* family key is normalized `DateTime(y,m,d)` at all call
  sites; migrating the family to a `yyyy-MM-dd` string key remains Phase 3.

---

## 11. Phase 1 implementation log (applied 2026-10-23, this branch)

Static verification only (no Flutter SDK in the audit environment) — run
`flutter pub get && dart run build_runner build --delete-conflicting-outputs && flutter analyze && flutter test`
locally. **Codegen is required**: most entities/models changed.

**Schema v2 — every new field is nullable/optional**, so pre-v2 stored JSON loads
unchanged and no existing constructor call breaks. Fields landed:

| Entity | New fields | Model mirrors |
|---|---|---|
| `Workout` | `userId`, `programId`, `programDayIndex`, `updatedAt` | `WorkoutModel` (`updatedAt` ISO string) |
| `Exercise` | `exerciseDefinitionId` | `ExerciseModel` |
| `ActiveProgram` | `userId` | `ActiveProgramModel` |
| `WorkoutProgram` | `userId` (ctor + copyWith) | `WorkoutProgramModel` |
| `ProgramExercise` | `exerciseDefinitionId` (ctor + copyWith) | `ProgramExerciseModel` |
| `Meal` | `userId`, `foodItemId`, `updatedAt` (+ `foodItemId` in `Meal.create`) | `MealModel` |
| `BodyEntry` | `userId` | `BodyEntryModel` |

**Population (links are stamped at the source, not left to callers):**

- `DeterministicExerciseSelector` → `SelectedSlotExercise.exerciseDefinitionId` (all 3
  return paths) → `SplitScheduleBuilder` writes it into `ProgramExercise`. Generated
  programs are now linked by catalog id.
- `StartWorkoutUseCase`: `Exercise.exerciseDefinitionId = pe.exerciseDefinitionId ??
  ExerciseDatabase.getByName(pe.exerciseName)?.id`; `Workout` records
  `programId`/`programDayIndex`/`userId` (from the active program) + `updatedAt`.
- Save-time stamping: `WorkoutRepositoryImpl` (`updatedAt`),
  `SyncedWorkoutRepository` (`userId ??= owner`, `updatedAt` — the old payload-only
  `data['userId']` injection is gone; the entity itself carries it now),
  `NutritionRepositoryImpl.saveMealEntry` (`userId`, `updatedAt`),
  `BodyRepositoryImpl` + `ActiveProgramRepositoryImpl` (optional `userId` constructor
  arg, wired from `authNotifierProvider` in their providers; existing single-arg
  constructions in tests still compile).
- `foodItemId` wired at the three `Meal.create` sites that start from a catalog food
  (food search, budget-swap replacement, recent-meal re-log).
- Preservation fixes found along the way: 5 manual `WorkoutProgram(...)` rebuilds
  (reorder/replace/update use cases + program editor + workout summary) were silently
  dropping split/hybrid metadata (and would now drop `userId`) — all switched to
  `program.copyWith(days: …)`. `ReplaceExercise` resolves the replacement's definition
  id by name; `UpdateExerciseParameters`/`ReplaceExercise` no longer drop
  `targetWeight`; `repeatWorkout` carries definition id + plan hints.

**Analytics (F-05 closure):** `AnalyticsRepositoryImpl` matches/groups by
`exerciseDefinitionId` when present, name (case-insensitive) as fallback, exact
instance id for direct lookups. Both `getExerciseHistory` implementations accept a
definition id as well as a name. The name-based bridge from Phase 0 remains for
unlinked custom exercises.

**Migration (`lib/core/utils/data_migration.dart`, new):** one-time, version-stamped
(`schema_version = '2'` in `app_settings`), idempotent, never throws, runs in `main()`
after `HiveManager.initialize()` + pending-wipe check. Works on raw stored maps
(deep-copied; put-back only when changed): backfills `userId` from the stored auth
session, `updatedAt` from the record's own date/timestamp, and `exerciseDefinitionId`
by catalog name lookup across `workouts`, `meals`, `body_entries`, and both
`active_program` records (incl. nested program days). Historical
`programId`/`programDayIndex` are not recoverable and stay null (documented in code).
Failure leaves the version stamp untouched → retries next launch.

**Identity seam (F-01):** `USE_FIREBASE_AUTH` dart-define, **default `false`** — no
behavior change unless explicitly enabled. `FirebaseAuthDataSourceImpl` also implements
`MockAuthDataSource` (the two interfaces are method-identical; verified), and
`FirestoreUserDataSourceImpl` also implements `MockUserDataSource` (`createUserProfile`
→ `saveUserProfile` alias — the only naming difference). `authRepositoryProvider`
selects the pair by flag; `AuthRepositoryImpl` is untouched. The two Firebase files had
never been in the compile graph (their imports were commented out); they were fully
read and their APIs checked against `firebase_auth ^5.1.0` / `sign_in_with_apple
^6.1.1` — they use only current APIs, but **they are the first thing to watch on the
first local build**. Before enabling the flag: Google sign-in in the Firebase impl
still throws "temporarily disabled" (google_sign_in 7.x TODO), `firebase deploy --only
firestore:rules,firestore:indexes` must have run, and uids change from mock `user_<hash>`
to real Firebase uids (treat as a fresh account or migrate deliberately).

**Deferred (unchanged from §10, still deliberate):** flipping the auth default;
mock→Firebase uid data migration; wipe-on-sign-out (waits for verified Phase 2 sync);
single sync schema/Firestore layout consolidation, tombstones (Phase 2); `box.watch()`
reactive layer and full provider dedupe (Phase 3); `deletedAt`/tombstone fields wait
for Phase 2's sync design rather than being added now and ignored.

---

## 12. Phase 2 implementation log (applied 2026-10-23, this branch)

Static verification only (no Flutter SDK in the audit environment) — run
`flutter pub get && dart run build_runner build --delete-conflicting-outputs && flutter analyze && flutter test`
locally, and `firebase deploy --only firestore:rules,firestore:indexes` for the rules
changes. **Codegen is required** (entities/models/SyncAction enum changed).

**One engine (F-03).** Survivor: `features/sync` `SyncService` + the `SyncAction`
outbox. Deleted (all verified zero live references first): `core/utils/sync_queue_manager.dart`,
`core/models/sync_operation.dart`, `core/providers/sync_provider.dart` (also removes the
duplicated `firestoreSyncDataSourceProvider`/`syncStatusProvider` definitions),
`sync_repository.dart` + impl, `sync_pending_operations_use_case.dart`,
`periodic_sync_service.dart`, `background_sync_service.dart` (workmanager stub),
`sync_offline_data_use_case.dart` (stub), the two dead widgets bound to the legacy
provider (`shared/widgets/sync_status_widget.dart`, `shared/widgets/offline_indicator.dart`
— note the live `core/widgets/offline_indicator.dart` is a different file and stays),
`realtime_db_user_datasource.dart`; `firebase_database` + `workmanager` removed from
pubspec. `DataMigration` v3 purges non-`SyncAction` entries from `sync_queue` so the
box has one schema; the outbox also retries actions stuck in `syncing` (crash mid-push).

**One layout (F-02).** `FirestoreSyncDataSource` rewritten as the single cloud layout
(flat collections, `userId` field, server `syncedAt`): `workouts/{id}`,
`programs/{activeProgramId}` (full `ActiveProgramModel` — the old pull filtered on an
`isActive` field its own payload never contained and reset progress to day 0),
`nutrition/{mealId}`, `body_progress/{id}`, `nutrition_targets/{userId}` (singleton).
`users/{uid}/…` remains only for auth profile + backups. `NutritionRepositoryImpl`'s
direct dual-write (and `FirestoreNutritionDatasource`) deleted — meals/targets sync via
outbox callbacks from the provider. Bodies and programs gained the same outbox hooks
(`onEntrySaved/Deleted`, `onProgramSaved`); program actions had never been enqueued by
anything before. Rules tightened to match (legacy nested matches + `sync_metadata`
removed, `nutrition_targets` added); nutrition index field fixed (`date`→`timestamp`).
`RemoteDataPurgerImpl` now also purges the flat collections — account deletion previously
would have left all synced records behind.

**Convergence (F-11).** Tombstones: `deletedAt` added to Workout/Meal/BodyEntry
(+models); cloud deletes merge `{deletedAt, syncedAt}` instead of removing docs; pulls
apply them as local deletes (stub tombstones for never-synced records are skipped on
parse). LWW on `updatedAt` everywhere (`BodyEntry`/`ActiveProgram` gained `updatedAt`,
stamped in their repositories) with record-date fallback for legacy rows. Pulls now cover
all aggregates (meals/body/targets previously never pulled), each leg isolated so one
failure can't block the rest. Cursors moved from the cloud `sync_metadata` doc to
per-device local storage (`app_settings` keys) with a 5-minute safety overlap — a shared
cloud cursor let one device's pull hide data from another. Invalid Firestore queries
fixed (`where(syncedAt >)` + `orderBy(date)` is rejected by Firestore; nutrition ordered
by a nonexistent field). Triggers fixed: `SyncService` resolves the current user via a
provider callback, so connectivity/timer/post-write syncs actually run (they previously
called `syncAll()` with no userId, which no-oped by design); the re-entrancy guard is now
set before the first await. Push skips other accounts' queued actions on shared devices.

**Catalogs (F-14, partial).** Both Firestore catalog uploaders no longer rewrite duplicate
IDs (`id_1`, `id_2`…) — that forked cloud identity from the `exerciseDefinitionId`/
`foodItemId` links added in Phase 1. Duplicates now fail loudly; uploads chunk under the
500-op batch limit. The deeper `FoodItem`/`FoodItemFull` unification remains Phase 3.

**Also fixed in passing:** 12 files under `lib/shared/presentation/components/` imported
`../../../../core/constants/app_theme.dart` (one `../` too many — resolves outside `lib/`,
so those files could not compile); corrected to `../../../core/...`. Pre-existing, found
by the repo-wide import check (now zero unresolvable imports).

**Test updates:** `sync_pipeline_test.dart` refreshed to the consolidated interfaces; the
legacy-pipeline test group was removed with the pipeline; the program-pull test now asserts
cursor plumbing through the per-device store and that day-index progress survives a pull.

**Deferred / known limits:** pull writes still go straight to Hive datasources (provider
freshness via invalidation — reactive `box.watch()` is Phase 3); no initial "full push on
first sign-in" backfill for records created while signed out (Phase 3); archived-program
restore doesn't enqueue a sync action yet; tombstones are never garbage-collected
(retention policy TBD); pre-Phase-2 queued *program* actions, if any existed with the old
payload shape, fail parsing and exhaust retries (nothing enqueued them, so this is
theoretical); everything still becomes live only when `USE_FIREBASE_AUTH=true` + rules are
deployed — with mock auth, pushes are denied by rules and actions accumulate retry-capped,
exactly as after Phase 1.

---

## 13. Phase 3 implementation log (applied 2026-10-23, this branch)

Static verification only (no Flutter SDK in the audit environment) — run
`flutter pub get && dart run build_runner build --delete-conflicting-outputs && flutter analyze && flutter test`
locally before merging. No Phase 3 change alters a generated model shape, but the
repository still requires codegen on a clean checkout.

**Reactive propagation (F-12, F-07 residual).** The Hive workout, body-entry and
active-program data sources now expose `box.watch()`-backed snapshot streams, and nutrition
exposes a monotonically increasing change-tick stream over the meals + targets boxes.
`workoutsStreamProvider`, `bodyEntriesStreamProvider`, `activeProgramStreamProvider` and
`nutritionChangesProvider` feed history/home/paginated, body history/trend, the active
program, day summaries and recent foods. `workoutRefreshCounterProvider` and
`bodyRefreshCounterProvider` are deleted, including the app-resume bump in `main.dart`; the
paginated workout provider's duplicate refresh subscription is also gone.
`ActiveProgramNotifier.adoptExternalState` lets the existing notifier absorb repository or
sync-pull writes without echoing its own. `dailyNutritionSummaryProvider` is now keyed by
the `yyyy-MM-dd` string returned by `nutritionDayKey()` / `todayNutritionDayKey()`, so Home
and Nutrition cannot create different notifiers for the same day. Production `HomeScreen`
already composed the underlying providers directly; `homeScreenProvider` remains only for
existing exploration tests and is documented as not for new UI.

**Workout completion (F-06 residual).** New `CompleteWorkoutUseCase` is the single
persistence path used by `WorkoutNotifier.finish()`: it saves the workout first, then
advances the active program only when the workout's stamped `programId` and
`programDayIndex` still match the program's current day. Custom, repeated, legacy or
different-program workouts no longer advance the program (the screen's unconditional
`completeCurrentDay()` call was removed). This is ordered and idempotently retryable, not
a cross-box Hive transaction: if advancement fails after save, retrying re-saves the same
workout id and re-attempts advancement. Streak, analytics and GlobalAI side effects remain
immediately after the use case inside `WorkoutNotifier.finish()` because they need Riverpod
`Ref`; the screen now has exactly one finish call, but those provider effects were not
moved into the domain use case.

**Provider / enum dedupe (F-10).** `food_repository_provider.dart` now contains the only
`foodRepositoryProvider`; the nutrition providers, food search/custom-food providers and
cache providers all use that canonical `FoodRepositoryImpl`, and `CustomFoodsNotifier` is
statically typed instead of `dynamic`. The query-result family was renamed to
`foodSearchResultsProvider`, leaving `foodSearchProvider` as the single search-state
notifier. Connectivity providers have one definition in core and are re-exported by the
sync provider file for existing imports. The unused auth profile family was renamed to
`authUserProfileProvider`, leaving onboarding's live `userProfileProvider` as the only
provider with that name; the two different `UserProfile` entity classes remain a deferred
identity refactor. `MealType` is defined once, in `diet_plan.dart`.

**Initial full push (Phase 2 deferral).** `SyncService.syncAll` gains a Step 0 backed by a
per-user `sync_initial_push_done_<uid>` marker in `app_settings`: on the first sync for a
user on a device it scans workouts, the active program, meals, nutrition targets and body
entries; stamps unowned/`local-user` records to that uid; skips other accounts' records;
suppresses duplicates already in the outbox; enqueues live records as updates and
tombstones as deletes; and writes the marker only after a successful scan, so a failure
retries safely. `syncServiceProvider` also triggers a sync when the signed-in uid changes.
The scan is deliberately gated by `USE_FIREBASE_AUTH`: under mock auth it is disabled so
the whole local history is not bulk-stamped with a throwaway mock uid (which would make it
foreign-owned when a real Firebase uid arrives). It becomes active with the real-auth seam.

**Export / restore (F-13).** New exports and restore safety snapshots are
`export_version: '2.0'` and serialize workouts, meals and body entries through
`WorkoutModel` / `MealModel` / `BodyEntryModel.toJson()`, preserving the Phase 1/2 identity
and link fields. Restore parses canonical v2 records model-first; the old hand parsers are
retained strictly as fallbacks for legacy backups (deliberately detected so that, e.g., a
legacy body entry's `photo_path` is not dropped by the model parser). The hand-written
snake_case dialect is no longer produced.

**Food conversion safety (F-15, partial).** The 158-line dynamic converter in
`food_upload_script.dart` — which fabricated vitamin/mineral values from category
heuristics — was deleted. Conversions now live in `food_item_conversion.dart`:
`FoodItem.toFoodItemFull()` copies only measured values and represents unmeasured required
nutrients as `0` = unknown (upload consumers must treat those as missing data, not true
zeroes), while `FoodItemFull.toFoodItem()` is explicitly documented as lossy. Fully
unifying `FoodItem` and `FoodItemFull` is still deferred: the static suggestion catalogs
genuinely lack several `FoodItemFull` nutrients, so merging the models first requires
nullable nutrient fields and a sweep of the catalog / suggestion / upload surfaces.

**Tests added/updated:** initial-full-push coverage (guest stamping, owned dedupe,
foreign skip, tombstone delete, one-time marker, and the disabled-under-mock gate);
`CompleteWorkoutUseCase` advancement matching/non-matching cases; measured-only food
conversion tests; a v2 canonical restore test asserting schema-v2 links survive; and
String day-key updates in the nutrition/AI widget tests.

**Deferred / known limits:** `FoodItem`/`FoodItemFull` and the dual `UserProfile` classes
are not yet unified; streak/AI/analytics remain notifier side effects after
`CompleteWorkoutUseCase`; `homeScreenProvider` was retained for tests rather than deleted;
legacy restore parsers remain for old backups; the initial push is dormant (and cloud
sync cannot succeed) until `USE_FIREBASE_AUTH=true` and rules/indexes are deployed; mock →
Firebase uid data migration and wipe-on-sign-out remain out of scope pending supervised
real-auth enablement. Static checks performed here: all project imports resolve, targeted
provider/enum symbols have single definitions, changed-file delimiter balance passes, and
`git diff --check` is clean; compilation and test execution still require a local Flutter
SDK.
