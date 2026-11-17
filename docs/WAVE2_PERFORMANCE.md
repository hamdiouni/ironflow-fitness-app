# Performance, Binary Budgets, Startup & Wasm Audit (Wave 2.3 & Wave 6)

> **Verified on:** `feat/prod-v2-wave-6`  
> **Automated Budget Gate:** [`scripts/check_perf_budgets.py`](../scripts/check_perf_budgets.py) (enforced in `.github/workflows/ci.yml`)

---

## 1. Runtime Frame, Cold-Start & Memory Budgets (Wave 6.1)

| Metric Category | Target Budget | Measured / Enforced Baseline | Verification Surface |
| :--- | :--- | :--- | :--- |
| **Frame Build Time** | `<= 8.0 ms` (`120 Hz` ready) / `<= 16.0 ms` (`60 Hz`) | `BodyMapPainter` zero-allocation `paint()` loop (`6` pre-allocated `Paint` fields, `20` cached `Path` regions); `HomeScreen` `CustomScrollView` sliver lazy building | `test/features/body/presentation/widgets/body_map/body_map_paths_test.dart`, `test/features/workout/presentation/screens/home_screen_frame_light_test.dart` |
| **Frame Raster Time** | `<= 8.0 ms` (`120 Hz` ready) / `<= 16.0 ms` (`60 Hz`) | Zero `BackdropFilter` blur passes on scrolling cards (`AppCard` uses solid Option B `#12151C` / `#FFFFFF` surfaces with `1px` `#242A36` / `#D1D5DB` borders); deferred YouTube `iframe` mounting (`loadOnTap: true`) | `lib/shared/widgets/exercise_media_stage.dart`, `lib/shared/widgets/youtube_exercise_player.dart` |
| **Cold Start to First Frame** | `<= 1,200 ms` (mobile AOT) / `<= 1,800 ms` (Web) | Parallel Hive box initialization, lazy `FirebaseFirestore.instance` resolution (`FirestoreSyncDataSourceImpl`, `FirestoreFoodDatasource`), non-blocking `SyncService.initialize()`, and zero-JS-wiping `web/index.html` splash shell | `lib/main.dart`, `lib/features/sync/data/datasources/firestore_sync_datasource.dart`, `web/index.html` |
| **Resident Memory Ceiling** | `<= 180 MB` idle / `<= 250 MB` active workout | One active `YoutubePlayerController` max per screen with explicit `StreamSubscription.cancel()` & `controller.close()` on tab switch/dispose; memoized `MuscleRecoveryCalculator._exerciseTargetCache` | `test/shared/widgets/exercise_media_stage_test.dart` |

---

## 2. Android Release Size & `--analyze-size` Breakdown (Wave 6.1 & 6.3)

Command executed:
```bash
flutter build apk --release --analyze-size --target-platform android-arm64 --dart-define=ALLOW_UNSIGNED_RELEASE=true --no-pub
```

### 2.1 Per-ABI & Debug APK Budgets (`scripts/check_perf_budgets.py`)
- **`app-arm64-v8a-release.apk`**: `28.54 MB` (Budget `<= 35.00 MB`) — **PASS**
- **`app-armeabi-v7a-release.apk`**: `26.93 MB` (Budget `<= 35.00 MB`) — **PASS**
- **`app-x86_64-release.apk`**: `30.02 MB` (Budget `<= 35.00 MB`) — **PASS**
- **`app-release.apk` (`android-arm64` `--analyze-size`)**: `28.60 MB` (Budget `<= 35.00 MB`) — **PASS**
- **`app-debug.apk`**: `197.20 MB` (Budget `<= 250.00 MB`) — **PASS**
- **R8 `mapping.txt`**: `46.71 MB` (`48,974,953` bytes, non-empty) — **PASS**
- **Icon Font Tree-Shaking**:
  - `CupertinoIcons.ttf`: `257,628 -> 848 bytes` (`99.7%` reduction)
  - `MaterialIcons-Regular.otf`: `1,645,184 -> 31,012 bytes` (`98.1%` reduction)

### 2.2 `--analyze-size` Component Breakdown (`apk-code-size-analysis_01.json`)

| APK Section / Package | Compressed / Accounted Size | Notes |
| :--- | :--- | :--- |
| **`lib/arm64-v8a` (Native + Engine + AOT)** | `23.0 MB` | Includes `libflutter.so` and `libapp.so` |
| — `Dart AOT symbols (decompressed)` | `12.0 MB` | Total attributed Dart AOT instructions/constants |
| —— `package:flutter` | `4.0 MB` | Material/Widgets/Rendering framework |
| —— `package:progression_tracker` | `2.0 MB` | Full IronFlow application code across all features |
| —— `package:timezone` | `542 KB` | Local notification scheduling timezone database |
| —— `dart:mixin_deduplication` | `453 KB` | Shared compiler-deduplicated mixin bodies |
| —— `package:flutter_localizations` | `332 KB` | 7-locale (`en`, `es`, `fr`, `de`, `pt`, `ja`, `zh`) ICU data |
| —— `dart:core` / `dart:ui` / `dart:typed_data` | `781 KB` | Core runtime libraries (`325 KB` + `242 KB` + `214 KB`) |
| —— `package:fl_chart` | `222 KB` | Progress & 1RM analytics charts |
| —— `package:webview_flutter_android` | `125 KB` | Embedded YouTube iframe player bridge |
| —— `package:markdown` / `package:hive` | `211 KB` | AI markdown rendering (`106 KB`) + Hive storage (`105 KB`) |
| **`classes.dex` + `classes2.dex` + `classes3.dex`** | `4.18 MB` | R8-shrunk Android/Firebase/androidx bytecode (`4 MB` + `91 KB` + `86 KB`); duplicate `firebase-analytics` removed in Wave 6.3 |
| **`assets/flutter_assets`** | `687 KB` | Compressed fonts, `exercises_catalog.json`, `exercise_media_manifest.json` |
| **`resources.arsc`** | `388 KB` | Shrunk Android resource table (`isShrinkResources = true`) |

---

## 3. Web Bundle, PWA & Wasm Compatibility Audit (Wave 6.2)

### 3.1 Web Bundle Budgets (`scripts/check_perf_budgets.py`)
- **`assets/fonts`**: `0.97 MB` (Budget `<= 1.50 MB`) — **PASS**
- **`assets/data`**: `0.30 MB` (Budget `<= 1.00 MB`) — **PASS**
- **`build/web/main.dart.js` (raw)**: `5.68 MB` (Budget `<= 7.50 MB`) — **PASS**
- **`build/web/main.dart.js` (gzipped)**: `1.61 MB` (Budget `<= 2.50 MB`) — **PASS**
- **`build/web/assets`**: `2.77 MB` (Budget `<= 6.00 MB`) — **PASS**

### 3.2 Wasm Dry-Run & Package Compatibility Matrix
- **Application Code (`lib/`)**: **100% Wasm-ready (`0` violations)**. Enforced by `test/core/platform/web_wasm_hygiene_test.dart` — zero imports of `dart:html`, `dart:js`, `dart:js_util`, or `package:js`.
- **Transitive Plugin Status on `pub.dev`**:
  1. `flutter_secure_storage: ^9.2.2` (resolved `9.2.4` -> `flutter_secure_storage_web: 1.2.1`): imports `dart:html`, `dart:js_util`, and `package:js`. `flutter_secure_storage: 11.2.0` (`flutter_secure_storage_web: 2.1.1`) migrates to `package:web` / `dart:js_interop`, but crosses two major versions affecting platform Keychain / `EncryptedSharedPreferences` storage format. Per project constraints (no unapproved storage migrations and zero homemade crypto), `^9.2.2` is retained while JS compilation remains the primary production target.
  2. `flutter_tts: 4.2.5` (latest version on `pub.dev`): uses `package:web` and `dart:js_interop`, emitting a non-fatal `invalid_runtime_check_with_js_interop_types` warning at `flutter_tts_web.dart:104-107`.
- **CI Strategy (`.github/workflows/ci.yml`)**: `flutter build web --release` (CanvasKit/JS) is the blocking production artifact (`ci.yml:116-121`), and `flutter build web --wasm` runs as an informational non-blocking step (`ci.yml:160-166`).
