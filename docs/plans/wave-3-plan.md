# Wave 3 Plan — Architecture and Data (`PLAN_ONLY: yes`)

- **Wave**: `3` (`3.1`–`3.5`: Storage safety & quarantine recovery, single `HiveManager` + tiered open + box encryption/migration + `.env`/`ThemeNotifier` boot speedups, data unification & dead/legacy cleanup, state management verification, cross-platform `dart:io` adapters & hygiene)
- **Mode**: `PLAN_ONLY: yes` (only this plan document is written; zero app, storage, pubspec, or config files modified)
- **Base Commit**: `master` at `67fda26` (merged fast-forward from `feat/prod-v2-wave-2`)
- **Recommended Execution Branch & Backup Tag**: create `backup/pre-prod-v2-wave-3` -> `67fda26`, then work sequentially (`LANES: single`) on `feat/prod-v2-wave-3`

---

## Step 0 — Current State & Claims Checked (Verified on `master` `67fda26`)

> Every item, line count, file path, symbol, and gap below was directly observed in the repository at `master` (`67fda26`).

### Step 0A — What Exists Today

| Item | Exists? | Verified Evidence on `master` (`67fda26`) |
|---|---|---|
| **Storage fail-safe & quarantine (`3.1`)** | **Gaps remain** | `lib/core/services/hive_encryption_service.dart` (`L190`, `234`, `281`) calls `await Hive.deleteBoxFromDisk(boxName)` in Case 0 (pending backup recovery), Case 1 (migration), and Case 3 (key loss / corrupted ciphertext), deleting `.hive` files outright without `.hive` header verification or moving corrupted/unreadable files into a quarantine directory with a recovery path. |
| **Single `HiveManager` & cipher/set caching (`3.2`)** | **Partial** | `HiveManager` (`lib/core/utils/hive_manager.dart`) opens 22 boxes sequentially inside `initialize()` (`L53-107`). However, **12 source files** still bypass `HiveManager` and call `Hive.openBox(...)` directly (`language_provider.dart:52,83`, `units_provider.dart:35,54`, `timezone_manager.dart:27,44`, `ai_chat_storage.dart:58`, `insight_cache_service_impl.dart:80`, `hive_diet_plan_datasource.dart:38`, `hive_food_item_full_datasource.dart:29`, `user_profile_storage.dart:22`, `local_data_wiper.dart:175,199`, `hive_sync_queue_datasource.dart:50`, `hive_active_program_datasource.dart:51`, `hive_exercise_datasource.dart:9`, `workout_state_manager.dart:34`). `HiveEncryptionService` caches `_cachedKey` (`L78`) **but reconstructs `HiveAesCipher(key)` and re-reads SecureStorage `migratedBoxesStorageKey` JSON on every `openEncryptedBox()` call (`L177-179`)**. |
| **Tier-1 / Tier-2 box split & guards (`3.2`)** | **No** | `HiveManager.initialize()` opens all 22 boxes sequentially before `runApp` (no Tier-1 concurrent open for `auth_session`, `user_profile`, `app_settings`, `active_workout_state`; no lazy Tier-2 `ensureOpen<T>` guard; getters assume `Hive.box()` is already open). |
| **Encrypted box policy (`3.2`)** | **Partial** | `HiveEncryptionService.sensitiveBoxes` (`L57-74`) covers 16 boxes, **missing** `settings`, `notification_settings`, and `food_items_full`. Custom user foods are stored unencrypted inside `'foods'` (`custom_foods_<userId>`) via `HiveFoodDataSource` rather than in their own encrypted `'custom_foods'` box. |
| **Catalog clear bug, `ThemeNotifier` delay, & `.env` load (`3.2`)** | **Unfixed** | `HiveManager.clearAll()` (`L265-266`, `286-287`) still clears `_exercisesBox` and `_foodsBox` (while `LocalDataWiper._protectedDatasetBoxes` protects them). `ThemeNotifier._loadTheme()` (`lib/core/providers/theme_provider.dart:34`) still has `await Future.delayed(const Duration(milliseconds: 500));`. `lib/main.dart:64` still executes `await dotenv.load(fileName: ".env");` on every boot even though `.env` is not in `pubspec.yaml` `assets:`. `pubspec.yaml` uses `hive: ^2.2.3` + `hive_flutter: ^1.1.0` (`hive_ce` not installed). |
| **Key-scoping rule (`3.2` / `3.7`)** | **Mostly wired (verify gaps)** | `RecordOwnershipRules.storageScope` (`record_ownership.dart:38`) is used in 13 data files, **but** `HiveDietPlanDataSource` (`L57`: `'${key}_$userId'`) and `UserProfileStorage` (`L40-64`: `'$_profileKeyPrefix$resolved'`) concatenate raw unnormalized `userId` without `RecordOwnershipRules.storageScope`. |
| **`FoodItem` vs `FoodItemFull` & asset catalogs (`3.3`)** | **Partial** | `assets/data/exercises_catalog.json` (`129` items, `103.7 KB`), `assets/data/foods_catalog.json` (`282` items, `208.1 KB`), `LazyJsonCatalogLoader` + `CatalogSearchIndex` (`catalog_search_index.dart`), `ExerciseAliasResolver`, and `DataMigration.migrateCanonicalExerciseAliases()` (`v1`) exist. **Gaps**: (a) `LazyJsonCatalogLoader` has **0 production callers** (only `catalog_search_index_test.dart`) — production use cases & UI (`search_food_use_case`, `build_suggested_meal_plan_use_case`, `get_budget_food_alternatives_use_case`, `muscle_detail_sheet`, `get_exercises_use_case`, `start_workout_use_case`, `replace_exercise_use_case`, `DataMigration`) still import `FoodCatalog` (`8` Dart shard files) & `ExerciseCatalog`; (b) `FoodItem` (`360` refs) and `FoodItemFull` (`137` refs) remain split (`food_item_conversion.dart`); (c) `verified_foods.json` (`84.8 KB`, `82` items) duplicates `foods_catalog.json`. |
| **Dead/legacy files, scripts in `lib/`, & Firestore foods (`3.3`)** | **Unfixed** | Still present in `lib/`: 8 food shard files (`supplementary_foods_part1..4.dart`, `verified_foods_part1..4.dart`), `hive_nutrition_data_source.dart` (`0` callers), `food_cache_provider.dart` (`0` callers), `food_upload_script.dart` + `food_initialization.dart`, legacy OpenAI (`ai_service.dart`, `ai_repository_impl.dart`, `ai_providers.dart`, `ai_test_screen.dart`), `ImageGenerationService` (`image_generation_service.dart`, `image_generation_provider.dart`, watched unused in `ai_chat_message_bubble.dart:162`), `design_gallery_screen.dart` + `lib/dev/dev_routes.dart`. `FirestoreFoodDatasource` (`L132-169`) uses non-null `!` / `as` casts and has no `.limit()` / cursor pagination (`getAllFoods`, `searchFoods`, `getFoodsByCategory`). |
| **Workout repo decorator, pagination index, & `_deepCast` (`3.3`)** | **Unfixed** | `WorkoutRepositoryImpl` (`workout_repository_impl.dart`) and `SyncedWorkoutRepository` (`synced_workout_repository.dart`) duplicate ownership/save/fetch logic instead of decorator wrapping. `HiveWorkoutDataSource.getWorkoutsPaginated()` (`L103-120`) deserializes & sorts **every** box entry (`O(N log N)`), with no id-to-timestamp index and no per-record `try/catch`. **8+ datasources** duplicate private `_deepCast`/`_deepCastList` helpers (`76` lines). |
| **State management & Deprecations (`3.4` & Wave 3.6 legacy)** | **Verified complete** | `architecture_hygiene_test.dart` passes (`0` `StateNotifier`/`StateNotifierProvider` remain in `lib/`, `0` `.withOpacity(` remain, `0` non-generated files > `800` lines, `domain` never imports `data`/`presentation`, screens never access `Hive`/`SharedPreferences`). `ADR-006` and `ADR-007` document lint/state-notifier decisions (note stale `"Awaiting Owner Approval"` status in `002`/`003`/`004` vs `ADR-007`/`ADR-008` duplicates). |
| **Platform adapters (`dart:io`) (`3.5`)** | **Unfixed (12 files)** | Unconditional `import 'dart:io';` exists in **12 files in `lib/`**: `hive_encryption_service.dart`, `progress_photo_comparison.dart`, `progress_photos_tab.dart`, `local_data_wiper.dart`, `backup_data_use_case.dart`, `export_all_data_use_case.dart`, `export_nutrition_use_case.dart`, `export_workouts_use_case.dart`, `import_program_use_case.dart`, `restore_data_use_case.dart`, `simple_json_export_use_case.dart`, and `export_restore_modal.dart`. |

### Step 0B — Claims Checked Against Master Plan V2

| Claim | Verified? | Evidence |
|---|---|---|
| "`3.1` Never delete a storage box on failure; pre-migration backup & header check" | **GAP FOUND** | `hive_encryption_service.dart:190,234,281` calls `Hive.deleteBoxFromDisk` with JSON-only backup (no `.hive` header validation or quarantine directory). |
| "`3.2` Direct `Hive.openBox` calls bypass `HiveManager` & `settings`/`notification_settings`/`food_items_full`/`custom_foods` unencrypted" | **CONFIRMED** | 12 files call `Hive.openBox` directly; `settings`, `notification_settings`, `food_items_full` are absent from `sensitiveBoxes`; custom foods live mixed inside `'foods'`; `ThemeNotifier` delays 500 ms; `main.dart` loads `.env`; `clearAll()` touches `exercises`/`foods`. |
| "`3.3` Merge `FoodItem` & `FoodItemFull`; load catalogs via `LazyJsonCatalogLoader`; list deletions for approval" | **CONFIRMED (Except `.bak` already deleted)** | `LazyJsonCatalogLoader` + `CatalogSearchIndex` exist only in tests; 8 food shards, `hive_nutrition_data_source.dart`, `foodCacheProvider`, OpenAI `ai_service.dart`/`ai_test_screen.dart`, `image_generation_service.dart`, and `food_upload_script.dart` remain in `lib/`. `0-byte foods.json` is absent (`verified_foods.json` 84.8 KB remains); `notification_service_old.dart.bak` was deleted in Wave 2.1. |
| "`3.3` Exercise alias migration + test; `FirestoreFoodDatasource` pagination; `O(page)` workout index; decorator; shared `deepCast`" | **PARTIAL** | `ExerciseAliasResolver` + `exercise_alias_migration_test.dart` exist & pass. `FirestoreFoodDatasource` pagination/null-safety, `O(page)` workout index, repository decorator, and shared `deepCast` are NOT yet implemented. |
| "`3.4` Move 30 `StateNotifier` classes to `Notifier`/`AsyncNotifier`" | **ALREADY DONE** | `architecture_hygiene_test.dart` confirms **0** `StateNotifier` classes remain in `lib/` (`ADR-007`). Wave 3.4 only needs regression checks (e.g., verify zero async-race delays like `ThemeNotifier` & consistent `AsyncValue` usage). |
| "`3.5` Replace unconditional `dart:io` in `lib/`; split >800 LOC files; architecture hygiene tests" | **PARTIAL** | `0` files > `800` lines and core hygiene tests exist, **but** 12 files in `lib/` still import `dart:io` unconditionally without `stub`/`io`/`web` adapters, and `architecture_hygiene_test.dart` does not yet ban direct `Hive.openBox`/`Hive.box`/`dart:io` outside adapters. |

---

## Planned Implementation Order & Files Touched

### Phase A — `3.1` & `3.2`: Storage Fail-Safe, `HiveManager`, Box Encryption & Migrations (Storage Lane First)
1. **Fail-Safe Quarantine & Backup Storage Engine (`lib/core/services/hive_encryption_service.dart`, `lib/core/services/box_quarantine_io.dart` / `_stub.dart` / `_web.dart`)**:
   - Add pre-migration `.hive` + `.lock` binary backup directory (`<appDocs>/ironflow_migrations/pre_migration/<timestamp>/`) and quarantine directory (`<appDocs>/ironflow_migrations/quarantine/<timestamp>_<boxName>/`).
   - Verify `.hive` file header sanity (file non-empty, header page readability check) before opening/migrating a box.
   - Replace every `Hive.deleteBoxFromDisk(boxName)` failure path with **move/copy to quarantine** (`QuarantineResult` exposing `quarantinedPath`, `reason`, `recoveredAt`) + surface a non-fatal recovery notice state/callback so corrupt/key-lost user files are never silently destroyed.
   - Cache `_cachedKey`, `_cachedCipher` (`HiveAesCipher`), and `_migratedBoxesCache` (`Set<String>?`) in memory (avoiding repeated SecureStorage JSON decoding on lazy box opens).
2. **Unified `HiveManager` Tier-1 / Tier-2 & Policy (`lib/core/utils/hive_manager.dart`, `lib/main.dart`)**:
   - Expand `HiveEncryptionService.sensitiveBoxes` (subject to `[ASK 2]`) to include `'settings'`, `'notification_settings'`, `'food_items_full'`, and `'custom_foods'`.
   - Split boxes into **Tier-1** (`auth_session`, `user_profile`, `app_settings`, `active_workout_state`) opened **concurrently** (`Future.wait`) in `HiveManager.initialize()` before `runApp` (after loading/caching cipher once), and **Tier-2** (remaining 19 boxes) opened **lazily** via idempotent `Future<Box<E>> ensureOpen<E>(String boxName)` (coalescing concurrent opens via an in-flight `Future` map so two simultaneous callers never race).
   - Add typed getters/async `ensure*` helpers for every box and replace all 12 direct `Hive.openBox` / raw `Hive.box` callers across datasources, notifiers, and managers (`language_provider.dart`, `units_provider.dart`, `timezone_manager.dart`, `ai_chat_storage.dart`, `insight_cache_service_impl.dart`, `hive_diet_plan_datasource.dart`, `hive_food_item_full_datasource.dart`, `user_profile_storage.dart`, `local_data_wiper.dart`, `hive_sync_queue_datasource.dart`, `hive_active_program_datasource.dart`, `hive_exercise_datasource.dart`, `workout_state_manager.dart`).
   - Protect static catalogs (`exercises`, `foods`) from `HiveManager.clearAll()` (clear only user/app state boxes, mirroring `LocalDataWiper._protectedDatasetBoxes`).
   - Remove the 500 ms `Future.delayed` in `ThemeNotifier` (`theme_provider.dart`), read `app_settings` synchronously in `ThemeNotifier`/`LanguageNotifier`/`UnitsNotifier` when Tier-1 is open (or await `HiveManager.ensureAppSettingsBox()`), and remove `dotenv.load(fileName: ".env")` from `lib/main.dart` (since `.env` is never bundled).
3. **Versioned Migrations & Ownership Scoping (`lib/core/utils/data_migration.dart`, `hive_diet_plan_datasource.dart`, `user_profile_storage.dart`, `hive_food_datasource.dart`, `custom_foods` box)**:
   - Migrate legacy `'custom_foods'` / `'custom_foods_<userId>'` entries out of unencrypted `'foods'` into the dedicated encrypted `'custom_foods'` box (scoped via `RecordOwnershipRules.storageScope`), keeping backup before removing legacy keys and updating `LocalDataWiper`, `BackupDataUseCase`, and `RestoreDataUseCase`.
   - Normalize `HiveDietPlanDataSource` (`current_diet_plan_<scope>`) and `UserProfileStorage` (`profile_<scope>`, `onboarded_<scope>`, `draft_*_<scope>`) using `RecordOwnershipRules.storageScope` (with one-time adoption of raw pre-normalization mixed-case uid keys so no existing user loses data).
   - Advance `DataMigration.currentSchemaVersion` (`v3 -> v4` with explicit migration runner steps + backup/old-format fixture tests).

### Phase B — `3.3` Data Unification, Catalog Migration, Pagination & Approved Cleanup
1. **Shared `deepCast` Helper (`lib/core/utils/hive_json_utils.dart`)**:
   - Extract one tested `deepCastMap` / `deepCastList` helper and remove the 8 private duplicated `_deepCast` implementations across `hive_workout_data_source`, `hive_body_data_source`, `hive_diet_plan_datasource`, `hive_food_datasource`, `hive_food_item_full_datasource`, `hive_nutrition_datasource`, `insight_cache_service_impl`, and `hive_nutrition_data_source` (deleted if approved).
2. **`FoodItem` + `FoodItemFull` Unification & Lazy JSON Asset Catalogs (`LazyJsonCatalogLoader` + `CatalogSearchIndex`)**:
   - Wire `LazyJsonCatalogLoader.loadFoodsIndex()` & `loadExercisesIndex()` into production Riverpod/repository providers so UI search/exercise/nutrition paths load `assets/data/foods_catalog.json` & `assets/data/exercises_catalog.json` lazily in `compute` isolates rather than eagerly compiling 8 Dart food shards.
   - Unify `FoodItem` and `FoodItemFull` cleanly per `[ASK 3]` answer (single canonical domain entity keeping nullable measured micronutrients, provenance `source`/`fdcId`, `servingUnit`/`servingWeightGrams`/`servingDescription`, `budgetTier`, plus JSON model adapters preserving backward compatibility with stored `food_items_full`, `custom_foods`, `BackupDataUseCase`/`RestoreDataUseCase`, and Firestore `foods` docs).
   - Prove 100% parity (count, IDs, macros, measured micros, search results) via automated parity tests **before** removing the 8 Dart food shard files + `verified_foods.json` (if approved).
3. **`FirestoreFoodDatasource` Null-Safety & Cursor Pagination (`lib/features/nutrition/data/datasources/firestore_food_datasource.dart`, `food_repository_impl.dart`)**:
   - Safely parse every Firestore field (`Map` type checks, `(num?)?.toDouble() ?? 0.0`, safe string/list defaults, per-doc error handling instead of `doc.data()!` / unsafe `as` throws).
   - Add cursor pagination (`getFoodsPage({int limit = 50, DocumentSnapshot? startAfter})`, bounded `.limit(...)` on `searchFoods`, `getFoodsByCategory`, `getFoodsByTags`).
4. **Workout Pagination Index (`O(page)`) & Repository Decorator (`hive_workout_data_source.dart`, `workout_repository_impl.dart`, `synced_workout_repository.dart`, `workout_providers.dart`)**:
   - Maintain a lightweight sorted index entry (`__workout_time_index__`: `List<{id, dateIso, userId}>` rebuilt lazily if absent/corrupt) in `workouts` so `getWorkoutsPaginated(offset, limit, {userId})` reads only the slice of `limit` IDs (`O(page)`), wrapping each record decode in `try/catch` (logging & skipping corrupt entries without crashing the list).
   - Refactor `SyncedWorkoutRepository` into a clean **Decorator** over `WorkoutRepository` (`WorkoutRepositoryImpl` owns local Hive persistence, ownership checks, and `O(page)` reads; `SyncedWorkoutRepository` delegates CRUD/reads to the inner `WorkoutRepository` and only stamps `updatedAt`/`owner` + enqueues `SyncAction`s on writes/deletes).
5. **Approved Dead-Code & Admin-Script Cleanup (`[ASK 1]`)**:
   - Move `food_upload_script.dart` & `food_initialization.dart` from `lib/` to `tool/seed/`.
   - Remove approved dead files (`hive_nutrition_data_source.dart`, `food_cache_provider.dart`, legacy OpenAI `ai_service.dart` / `ai_repository_impl.dart` / `ai_providers.dart` / `ai_test_screen.dart`, HuggingFace `image_generation_service.dart` / `image_generation_provider.dart`, and 8 Dart food shards / `verified_foods.json` once parity passes; legacy design-gallery per `[ASK 4]`).

### Phase C — `3.4` & `3.5`: Platform Adapters (`dart:io` Elimination) & Hygiene Guards
1. **Cross-Platform Storage / File Adapters (`lib/core/platform/` — `file_ops.dart`, `file_ops_stub.dart`, `file_ops_io.dart`, `file_ops_web.dart`)**:
   - Replace all **12** unconditional `import 'dart:io';` imports in `lib/`:
     - Pre-migration backup & quarantine adapter (`hive_encryption_service.dart`, `local_data_wiper.dart`) — filesystem on `dart.library.io`, Web-safe no-op / IndexedDB/memory recovery metadata on `dart.library.js_interop`.
     - Export / backup / restore / import adapters (`backup_data_use_case.dart`, `export_all_data_use_case.dart`, `export_nutrition_use_case.dart`, `export_workouts_use_case.dart`, `import_program_use_case.dart`, `restore_data_use_case.dart`, `simple_json_export_use_case.dart`, `export_restore_modal.dart`) returning cross-platform bytes / filenames / Web download or `share_plus` XFile bridges instead of `dart:io` `File`.
     - Progress photo widget image adapter (`progress_photo_comparison.dart`, `progress_photos_tab.dart`) abstracting local image rendering cleanly (`Image.file` on IO vs `Image.network`/bytes fallback on Web) without `dart:io`.
2. **State Management Verification (`3.4`)**:
   - Confirm 0 `StateNotifier` regressions, eliminate any remaining async init races/delays (e.g. `ThemeNotifier`, `LanguageNotifier`, `UnitsNotifier`), and standardize `AsyncValue` error/loading states cleanly.
3. **Architecture & Hygiene Guards (`test/architecture/architecture_hygiene_test.dart`)**:
   - Add automated tests enforcing:
     - Zero direct `Hive.openBox(` or raw `Hive.box(` calls outside `lib/core/utils/hive_manager.dart` and `lib/core/services/hive_encryption_service.dart` (after migrating datasources/notifiers).
     - Zero unconditional `import 'dart:io';` outside designated `*_io.dart` platform adapter files.
     - Verify `.g.dart` / `.freezed.dart` build_runner consistency if any model changes (`FoodItem` unification), zero non-generated files > `800` lines, zero `.withOpacity`, zero `StateNotifier`, and `domain` purity.
4. **Consolidate ADRs & Update Wave 3 Baseline**:
   - Re-verify `ADR-002`/`003`/`004` vs `006`/`007`/`008` status markers cleanly without introducing duplicate numbering conflicts.
   - Re-run coverage and update `docs/quality/coverage_baseline.json` (ensure >= `68.45%` overall and zero drops).

---

## Tests to Write First (Characterization, Parity & Old-Format Fixtures)

1. **`test/core/security/hive_quarantine_and_tier_test.dart`** (write BEFORE modifying `HiveEncryptionService`/`HiveManager`):
   - Seed old-format v1/v2/v3 fixture boxes (corrupt `.hive` header, wrong AES key, plaintext `settings`/`notification_settings`/`food_items_full` + mixed `'custom_foods'` inside `'foods'`).
   - Prove failed open moves `.hive` into `quarantine/<timestamp>_<box>/` instead of deleting bytes from disk, and surfaces the quarantine path.
   - Prove Tier-2 box access fails or awaits `ensureOpen` cleanly (never throwing "Box not open" or silently opening unencrypted) and concurrent `initialize()` opens all 4 Tier-1 boxes before `runApp`.
   - Prove `HiveManager.clearAll()` preserves `exercises` & `foods` static data while clearing user boxes.
2. **`test/core/utils/data_migration_v4_test.dart`** (write BEFORE migration runner updates):
   - Old-format fixture test: mixed-case `userId` keys in `user_profile` & `diet_plan`, plus legacy `'custom_foods'` / `'custom_foods_Alice'` inside `'foods'` -> verifies 100% lossless migration into normalized `RecordOwnershipRules.storageScope` keys & encrypted `'custom_foods'` box, keeping pre-migration backups.
3. **`test/features/nutrition/catalog_parity_and_pagination_test.dart`** (write BEFORE retiring Dart shards or modifying Firestore datasource):
   - Parity assertion: `LazyJsonCatalogLoader.loadFoodsIndex()` matches legacy `FoodCatalog.foods` (`282` items, identical IDs, macros, verified provenance, dietary tags) and custom foods stay isolated in `'custom_foods'`.
   - `FirestoreFoodDatasource` null-safety & pagination tests (malformed docs without `macros`/`vitamins` don't crash; `startAfterDocument` / `limit` pagination works).
4. **`test/features/workout/workout_index_pagination_and_decorator_test.dart`** (write BEFORE changing workout datasource/repo):
   - `HiveWorkoutDataSource.getWorkoutsPaginated` returns exact descending pages using index (`O(page)`), skips corrupted Hive entries cleanly via per-record `try/catch`, and `SyncedWorkoutRepository` delegates cleanly to `WorkoutRepository` without duplicating logic.
5. **`test/core/platform/platform_adapter_web_compat_test.dart`**:
   - Characterization tests for backup/export/import/quarantine behavior through the platform adapter abstraction (ensuring Web compatibility with zero `dart:io` dependency in business/UI layers).
6. **Updated `test/architecture/architecture_hygiene_test.dart`** guards (banning direct `Hive.openBox` outside `HiveManager`/`HiveEncryptionService` and unconditional `dart:io` outside `*_io.dart` adapters).

---

## Risks & Mitigations

- **Data loss during new box encryptions (`settings`, `notification_settings`, `food_items_full`, `custom_foods`)**: mitigated by full binary `.hive` + JSON pre-migration backup directory, `.hive` header verification, strict item-count parity assertions before clearing legacy keys, and quarantine-on-error (zero destructive `deleteBoxFromDisk`).
- **Breaking legacy unit/widget tests that mock `Hive` or assume synchronous open**: mitigated by keeping clean `@visibleForTesting` / constructor-injected `HiveEncryptionService` & adapter hooks, updating tests via characterization first, and running the full test suite (`1,025+` tests) + Web build (`flutter build web --release`) + Android APK release build after every sub-phase.
- **Unifying `FoodItem` / `FoodItemFull` touches 360+ callsites**: mitigated by completing parity tests first, updating `build_runner` freezed/json models in one clean commit, and verifying `flutter analyze` + `flutter build web` + Android R8 release immediately after.

---

## Lane Split Recommendation

- **`LANES: single`** (branch `feat/prod-v2-wave-3` from `backup/pre-prod-v2-wave-3` -> `67fda26`).
  - Reason: Master Plan V2 specifies *"single lane for storage"*, and `HiveManager`, `HiveEncryptionService`, `DataMigration`, `LocalDataWiper`, `RecordOwnershipRules`, and `FoodItem` unification form a tightly coupled dependency chain across shared files (`main.dart`, `pubspec.yaml`, `data_migration.dart`, `architecture_hygiene_test.dart`).

---

## Owner Questions (`[ASK]` — Confirm Before Running Wave 3)

1. **`[ASK 1]` Approval to Delete / Move Obsolete & Dead Files (`3.3` / `3.5`)**:
   Do you approve deleting/moving the following verified files (no code will be deleted until parity/replacement tests pass)?
   - **Delete (dead / unused, 0 active callers)**:
     - `lib/features/nutrition/data/datasources/hive_nutrition_data_source.dart` (dead duplicate of `hive_nutrition_datasource.dart`)
     - `lib/features/nutrition/presentation/providers/food_cache_provider.dart` (0 callers)
     - Legacy OpenAI stack (no callers outside `/ai-test`): `lib/features/ai/data/datasources/ai_service.dart`, `lib/features/ai/data/repositories/ai_repository_impl.dart`, `lib/features/ai/presentation/providers/ai_providers.dart`, `lib/features/ai/presentation/screens/ai_test_screen.dart` (+ its dead `/ai-test` route & `ai_repository_impl_test.dart`)
     - Unused HuggingFace image generator: `lib/features/ai/data/services/image_generation_service.dart`, `lib/features/ai/presentation/providers/image_generation_provider.dart` (and remove unused `ref.watch(imageGenerationProvider)` in `ai_chat_message_bubble.dart`)
   - **Delete AFTER asset JSON parity tests pass & production callers migrate to `LazyJsonCatalogLoader`**:
     - The 8 Dart food shard files: `lib/features/nutrition/domain/services/supplementary_foods_part1..4.dart` & `verified_foods_part1..4.dart` (and redundant `assets/data/verified_foods.json`, since `foods_catalog.json` holds all 282 foods including the 82 USDA verified items; note `0-byte foods.json` does not exist and `notification_service_old.dart.bak` was already deleted in Wave 2.1).
   - **Move out of `lib/` to `tool/seed/`**:
     - `lib/features/nutrition/data/datasources/food_upload_script.dart`
     - `lib/features/nutrition/data/datasources/food_initialization.dart`
2. **`[ASK 2]` Storage Encryption & Engine Decisions (`3.1` & `3.2`)**:
   - Confirm encrypting `settings`, `notification_settings`, and `food_items_full`, and moving `custom_foods` out of unencrypted `'foods'` into its own encrypted `'custom_foods'` box (with pre-migration backups, old-format fixture tests, and quarantine-on-failure replacing `deleteBoxFromDisk`).
   - Confirm **keeping `hive: ^2.2.3` + `hive_flutter: ^1.1.0`** for Wave 3 (avoiding unrequested storage package churn), OR tell me if you want an ADR + swap to `hive_ce` now.
3. **`[ASK 3]` Canonical Food Model Direction (`3.3`)**:
   - Confirm unifying `FoodItem` and `FoodItemFull` onto **one domain `FoodItem` entity** (extending it with optional nullable vitamin/mineral breakdown `FoodMicros`, serving info, `budgetTier`, and USDA provenance, while keeping Hive/Firestore DTO parsing backward-compatible with stored `FoodItemFullModel` JSON Maps), and retiring `FoodItemFull` + `food_item_conversion.dart`?
4. **`[ASK 4]` Legacy Design-System Reference (`3.5` / `Wave 4` transition)**:
   - Should `lib/features/design_system/presentation/screens/design_gallery_screen.dart` (currently isolated to debug `/design-gallery` + Settings debug button) be **deleted now in Wave 3**, OR **moved cleanly under `lib/dev/`** until Wave 4.1's Design Lab preview finishes?
5. **`[ASK 5]` `.env` Boot Removal & `.gitleaks` Follow-Up (`3.2` / Wave 2 leftover)**:
   - Confirm removing `dotenv.load(fileName: ".env")` from `lib/main.dart` (leaving `flutter_dotenv` unused or removing it per preference — clarify if you want `flutter_dotenv` removed from `pubspec.yaml` now or later) and running Wave 3 sequentially (`LANES: single`).
   - From Wave 2 checkpoint: should we keep `.gitleaks.toml` untouched for now or add public Firebase client `gcp-api-key` path allowlists + verified-revoked pre-Wave-1 commit fingerprints to `.gitleaksignore`?
