# ADR-004: Static Catalogs Storage Engine (Foods & Exercises)

- **Status**: Proposed (Awaiting Owner Approval before Wave 3.4)
- **Date**: 2026-11-05
- **Wave**: Wave 3.4

## 1. Problem
`verified_foods_data.dart` (2,338 LOC), `foods_list.dart` (2,260 LOC), and `exercise_database.dart` (1,904 LOC) compile 6,502 lines of static maps into the Dart isolate heap, while `assets/data/verified_foods.json` (84.8 KB) duplicates the food data as a bundled asset.

## 2. Options Considered

| Option | Description | Pros | Cons |
| :--- | :--- | :--- | :--- |
| **Option A: Bundled Compressed Asset JSON (`assets/data/foods_catalog.json`, `assets/data/exercises_catalog.json`) + Isolate Inverted Token Index** | Load the JSON asset lazily on first access, parse and build a prefix/token inverted index inside `Isolate.run()` (or async chunk on Web), and cache the compact index in memory. | **0 new dependencies**; works identically on Android, iOS, and Web (no `sqlite3.wasm` or SharedArrayBuffer headers required); ~100 KB total asset size for ~500 foods + 130 deduplicated exercises; search time < 1.5ms for < 2,000 items. | If catalog grows beyond 50,000 items in the future, in-memory inverted index uses more RAM than on-disk SQLite FTS5. |
| **Option B: Read-Only Bundled SQLite Asset with FTS5 (`sqflite` + `sqlite3_flutter_libs`)** | Pre-build a `.db` file in CI with FTS5 virtual tables and query from disk. | Scales to 500,000+ rows with near-zero RAM. | Requires native SQLite binaries (+2.5 MB APK size) and `sqflite_common_ffi_web` (`sqlite3.wasm` + Web Worker setup) on Web. |
| **Option C: Drift ORM (`drift` + `drift_flutter`)** | Full reactive SQLite ORM with code generation. | Type-safe SQL queries and migrations. | Heavy setup on Web (`sqlite3.wasm` + `drift_worker.js`), adds 2 runtime + 1 dev dependency, overkill for read-only catalogs of ~650 items. |

## 3. Recommendation
- **Option A (Lazy Asset JSON + `Isolate.run` Token Index)** for the current ~500 foods and 130 canonical exercises, benchmarked in Wave 3.4 on Android and Web against cold-start time, heap memory, and search latency.
- Keep a clean `FoodCatalogDataSource` / `ExerciseCatalogDataSource` interface so Option B (SQLite FTS5) can be swapped in transparently if an Open Food Facts 100k+ offline pack is added in Wave 6.
- **New Runtime Dependencies**: **0**.
- **Rollback**: Keep old Dart files until parity tests (100% ID, macro, and muscle mapping match) pass.
