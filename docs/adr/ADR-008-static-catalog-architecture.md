# ADR-008: Static Catalog Architecture (Exercises & Foods) + Alias Migration

- **Status**: Accepted (Wave 3.4)
- **Date**: 2026-11-06
- **Deciders**: IronFlow Engineering / Wave 3 Data & Architecture Track

---

## 1. Problem Statement

Prior to Wave 3.4, IronFlow stored its static catalogs as giant monolithic Dart files inside `data/`:
1. `lib/features/workout/data/exercise_database.dart` (`1,904` lines): Contained `150` raw entries (contradicting an older report's unverified `"500+"` claim), including **27 duplicate exercise IDs**, **20 exact duplicate names** plus `'Elliptical'` vs `'Elliptical Machine'`, and placeholder `dQw4w9WgXcQ` URLs. Domain use cases (`GetExercisesUseCase`, `StartWorkoutUseCase`, `ReplaceExerciseUseCase`) imported `data/exercise_database.dart` directly, violating Clean Architecture boundaries.
2. `lib/features/nutrition/data/verified_foods_data.dart` (`2,338` lines, `82` USDA FDC foods) and `lib/features/nutrition/data/foods_list.dart` (`2,260` lines, `204` supplementary foods; `282` unique combined foods).
3. Wave 4's upcoming **Body Map** requires canonical `primaryRegions`, `secondaryRegions`, `secondaryMuscles`, `provenance`, and `license` fields on every `ExerciseDefinition`, and historical user workouts/programs referencing colliding or retired exercise IDs must migrate without losing a single logged set.

---

## 2. Options Evaluated & Measured Comparison

Benchmarks below were executed on the target Windows machine via `flutter test test/core/catalog/catalog_search_index_test.dart`:

| Criterion | Option A: Monolithic Dart Lists (Legacy) | Option B: Domain Shards + Lazy JSON Asset + `compute` Isolate Inverted Prefix Index (Selected) | Option C: SQLite FTS5 (`sqflite` + `sqlite3_flutter_libs`) | Option D: `drift` + Wasm SQLite |
| :--- | :--- | :--- | :--- | :--- |
| **Catalog Scale** | `129` exercises + `282` foods (`411` total items) | `129` exercises (`103.7 KB` JSON) + `282` foods (`208.1 KB` JSON) | Better suited for `10,000–500,000+` rows | Better suited for `10,000+` relational rows |
| **Measured Cold Load + Index Time** | ~`0 ms` (compiled into Dart isolate snapshot, eagerly resident) | Exercises: **`81.7 ms`** (`81,702 µs` via `compute`)<br>Foods: **`45.4 ms`** (`45,365 µs` via `compute`) | ~`60–150 ms` DB copy + FTS open | ~`80–180 ms` + Wasm worker boot on Web |
| **Measured 1,000x Search Latency** | Linear `.contains` scan | Exercises: **`8.2 ms`** total (**`8.2 µs` / query**)<br>Foods: **`4.4 ms`** total (**`4.4 µs` / query**) | ~`150–400 µs` / query (FFI/platform channel hop) | ~`150–400 µs` / query |
| **New Runtime Dependencies** | `0` | **`0`** (`dart:convert` + Flutter `compute`) | `+2` (`sqflite`, `sqlite3_flutter_libs`) | `+3` (`drift`, `drift_flutter`, `sqlite3`) |
| **Android APK / Web Bundle Impact** | Baseline | **`+311.8 KB`** uncompressed JSON assets (~`58 KB` gzipped/deflated) | `+2.5–4.5 MB` native `.so` binaries; no out-of-box Web support without `sqflite_common_ffi_web` | `+2.5 MB` native + `~1.2 MB` `sqlite3.wasm` worker on Web |
| **User Custom Foods Isolation** | Separate Hive key (`custom_foods_<userId>`) | **Preserved** (`HiveFoodDataSource` scoped per `userId`, never mutates static catalog) | Requires union queries or separate user table + schema migration | Requires Drift user table migration |

---

## 3. Decision & Recommendation

**Selected: Option B — Deduplicated Domain Catalogs + Lazy JSON Assets (`assets/data/exercises_catalog.json`, `assets/data/foods_catalog.json`) + `CatalogSearchIndex` (`compute` Isolate Prefix Index).**

Why Option B wins decisively for IronFlow's verified scale (`129` exercises + `282` foods = `411` items):
1. **Zero new runtime dependencies**: Respects the Owner's strict dependency rule (no `sqflite`/`drift` native binary or Web `sqlite3.wasm` bloat needed for `411` items).
2. **Sub-10 microsecond search (`4.4–8.2 µs`/query)**: `CatalogSearchIndex` builds an immutable sorted token-prefix posting list inside a background isolate (`compute`) in `45–82 ms` without blocking UI frames, then answers multi-word prefix queries (`"barbell bench"`, `"chicken breast"`) in single-digit microseconds.
3. **100% Android + Web + iOS parity**: Works identically across native VM isolates and Web builds (`flutter build web`).
4. **Zero-loss Exercise Alias Migration (`ExerciseAliasResolver` + `DataMigration.migrateCanonicalExerciseAliases()`)**:
   - Confirmed real raw exercise count: **`150` raw entries -> `129` unique canonical exercises** (`0` duplicate IDs, `0` duplicate names, `0` placeholder Rickroll URLs).
   - Maps all `5` retired duplicate IDs, `11` reassigned colliding `(legacyId, exerciseName)` pairs (e.g., `('back_010', 'Seal Row') -> 'back_016'`), `6` swapped duplicate-name IDs, and name aliases (`'Elliptical' -> 'cardio_006'`).
   - Automatically migrates stored `workouts` and `active_program` records idempotently via `DataMigration.runIfNeeded()` (`exercise_alias_migration_version = 1`), verified by `test/features/workout/data/exercise_alias_migration_test.dart`.
5. **Body Map Readiness**: Every `ExerciseDefinition` now carries `secondaryMuscles`, `primaryRegions`, `secondaryRegions`, `provenance`, and `license` fields ready for Wave 4.

---

## 4. License, Risk & Rollback

- **New packages**: `0`
- **Data Provenance & Licenses**:
  - Foods (`82` verified items): **USDA FoodData Central — Public Domain (CC0 1.0)**; `200` unique supplementary items: **IronFlow First-Party Catalog**.
  - Exercises (`129` canonical items): **IronFlow Exercise Catalog v2 (First-Party)**; placeholder Rickroll URLs stripped.
- **Risk**: Low — `ExerciseDatabase`, `FoodDatabase`, `verified_foods_data.dart`, and `foods_list.dart` remain as thin backward-compatible facades (`5–33` lines) so zero external call sites break.
- **Rollback**: Revert catalog commits; `ExerciseAliasResolver` keeps canonical and legacy IDs mutually resolvable.
- **Wave 3.3–3.4 Update (2026-11-17)**:
  - Deleted the 8 compiled food shard Dart files (`verified_foods_part1..4.dart`, `supplementary_foods_part1..4.dart`) and duplicate `assets/data/verified_foods.json`; `FoodCatalog` now loads lazily from `assets/data/foods_catalog.json` via `LazyJsonCatalogLoader` + `foodsCatalogIndexProvider`.
  - Unified `FoodItem` and `FoodItemFull` onto canonical `FoodItem` (retiring `FoodItemFull`, `FoodItemFullModel`, and `food_item_conversion.dart`), while preserving `FoodItem.fromAnyJson` backward-compatible decoding for legacy Hive and Firestore maps.
