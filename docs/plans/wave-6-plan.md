# Wave 6 Plan — Performance, Platforms, Wasm, Accessibility & Languages (V2)

> **Branch:** `feat/prod-v2-wave-6` (branched from `master` at `3f0ea99`, backed up by tag `backup/pre-prod-v2-wave-6`)  
> **Wave 5 Baseline Status (Verified on `master` `3f0ea99`):**  
> - `flutter analyze --no-pub --no-fatal-infos lib test`: `0` errors, `0` warnings  
> - `flutter test --no-pub --coverage --timeout=60s`: `1,078 / 1,078` passed (`0` failed, `0` skipped)  
> - `python scripts/check_coverage.py --baseline docs/quality/coverage_baseline.json --fail-on-drop`: `70.72%` overall (`21,620 / 30,570` lines across `382` files); `COVERAGE GATE PASSED`  
> - `python scripts/check_perf_budgets.py`: `All performance, size, & R8 checks PASSED`  
> - `gitleaks git --log-opts="backup/pre-prod-v2-wave-5..HEAD"`: `2` commits scanned, `no leaks found`

---

## Step 0 — Verified Baseline Audit (`3f0ea99`)

### Step 0A — What Exists Today

| Item | Exists? | Verified Evidence on `feat/prod-v2-wave-6` (`3f0ea99`) |
| :--- | :--- | :--- |
| **`6.1` Size & R8 budget script (`scripts/check_perf_budgets.py`)** | **Partial** | `scripts/check_perf_budgets.py:1-169` checks asset budgets (`assets/fonts`: `0.97 MB <= 1.5 MB`, `assets/data`: `0.30 MB <= 1.0 MB`), web bundle (`main.dart.js`: `5.68 MB` raw / `1.61 MB` gzipped `<= 2.5 MB`, `build/web/assets`: `2.77 MB <= 6.0 MB`), split release APKs (`arm64-v8a`: `28.54 MB`, `armeabi-v7a`: `26.93 MB`, `x86_64`: `30.02 MB <= 35.0 MB`), debug APK (`197.20 MB <= 250.0 MB`), and R8 `mapping.txt` (`46.71 MB`). Missing `--analyze-size` breakdown and runtime frame/memory/startup budget benchmarks. |
| **`6.2` Legacy Web interop in `lib/`** | **Clean (`0` matches)** | `lib/` contains **0** imports of `dart:html`, `dart:js`, `dart:js_util`, `package:js`, or `package:web`. `lib/core/platform/platform_file_ops_web.dart` (`L1-2`) and `platform_image_web.dart` (`L1`) use pure Dart (`dart:convert`, `dart:typed_data`) and `package:flutter/widgets.dart`. |
| **`6.2` Transitive Wasm dry-run blockers** | **2 plugins** | `flutter build web` Wasm dry-run reports: (1) `flutter_secure_storage_web: 1.2.1` (from `flutter_secure_storage: ^9.2.2`, resolved `9.2.4`) importing `dart:html`, `dart:js_util`, `package:js` (pub.dev has `flutter_secure_storage: 11.2.0` / `flutter_secure_storage_web: 2.1.1`, which is a 2-major-version storage jump); (2) `flutter_tts: 4.2.5` (already latest on pub.dev) emitting `invalid_runtime_check_with_js_interop_types` in `flutter_tts_web.dart:104-107`. JS remains default in `.github/workflows/ci.yml:118-120` with Wasm as an informational non-blocking step (`ci.yml:160-166`). |
| **`6.2` `web/index.html` cache wipe & splash** | **Unfixed** | `web/index.html:35-51` runs an inline script that calls `navigator.serviceWorker.getRegistrations()` -> `r.unregister()` and `caches.keys()` -> `caches.delete(k)` on every page load, defeating offline PWA caching. `web/index.html:53-59` uses `#12131A` background without an Option B Iron Scoreboard (`#0A0B0E` dark / `#F3F4F6` light / `#F59E0B` amber) themed loading splash or build stamp indicator. |
| **`6.2` `web/manifest.json` theme colors** | **Outdated** | `web/manifest.json:6-7` still uses `"background_color": "#12131A"` and `"theme_color": "#A5B4FC"` (legacy indigo) instead of Option B Iron Scoreboard `#0A0B0E` / `#F59E0B`. |
| **`6.3` `android/app/build.gradle.kts` hygiene** | **3 issues found** | (1) `L63-65` uses deprecated `kotlinOptions { jvmTarget = JavaVersion.VERSION_17.toString() }`; (2) `L100-105` silently falls back to `signingConfigs.getByName("debug")` on release builds when `key.properties` is missing without requiring an explicit unsigned/CI verification flag; (3) `L117-124` declares explicit `firebase-bom:34.13.0`, `firebase-analytics`, `firebase-auth`, and `firebase-firestore` dependencies that duplicate FlutterFire Gradle plugin dependency management (`firebase_analytics` is not even a Dart dependency in `pubspec.yaml`). |
| **`6.3` `android/app/proguard-rules.pro` no-op rules** | **Found** | `android/app/proguard-rules.pro:20-22` keeps `io.hive.**` and `io.hive.TypeAdapter`. Hive is pure Dart (no `io.hive.*` JVM classes exist), making those rules a no-op. |
| **`6.3` `ios/` directory & `Podfile`** | **Missing `Podfile`** | `ios/Runner/Info.plist` (`L1-67`) and `ios/Runner/PrivacyInfo.xcprivacy` (`L1-61`) exist, and `.github/workflows/ci.yml:168-196` defines `ios-compile-check`, **but `ios/Podfile` is missing from `ios/`**. `ios/Runner/Info.plist` also lacks `ITSAppUsesNonExemptEncryption = false`. |
| **`6.4` Accessibility, RTL & 7-locale coverage** | **Partial** | `test/accessibility/text_scale_and_semantics_test.dart` (`L1-156`) tests `HomeScreen`, `NutritionScreen`, and `ActiveWorkoutScreen` at `2.0x` text scale in LTR only. All 7 ARB files (`app_{de,en,es,fr,ja,pt,zh}.arb`) have `122` keys each (`0` missing, `0` empty), but automated RTL (`TextDirection.rtl`) multi-screen layout tests and 7-locale ARB placeholder/resolution tests are missing. |

### Step 0B — Claims Checked Against Master Plan V2

| Claim | Verified? | Evidence |
| :--- | :--- | :--- |
| "`web/index.html` wipes service workers and caches on every load" | **CONFIRMED** | `web/index.html:35-51` unregisters all service workers and deletes all `caches` entries unconditionally before loading `flutter_bootstrap.js`. |
| "`flutter_secure_storage_web` and `flutter_tts` block `--wasm` while `lib/` has zero legacy web imports" | **CONFIRMED** | `lib/` has `0` `dart:html` / `dart:js*` / `package:js` imports; Wasm dry-run flags only `flutter_secure_storage_web: 1.2.1` and `flutter_tts: 4.2.5`. |
| "`android/app/build.gradle.kts` has deprecated `kotlinOptions`, silent debug-signed release fallback, and duplicate Firebase BoM deps" | **CONFIRMED** | Verified at `android/app/build.gradle.kts:63-65`, `L100-105`, and `L117-124`. |
| "`android/app/proguard-rules.pro` contains no-op `io.hive.**` rules" | **CONFIRMED** | Verified at `android/app/proguard-rules.pro:20-22`. |
| "`ios/Podfile` is missing despite CI `ios-compile-check` referencing CocoaPods" | **CONFIRMED** | `ios/` contains `Flutter/`, `Runner/`, `Runner.xcodeproj/`, `Runner.xcworkspace/`, `RunnerTests/`, `.gitignore`, `ExportOptions.plist`, but no `Podfile`. |

---

## Wave 6 Implementation Plan (`6.1`–`6.4`)

### Phase `6.1` — Budgets & Measurement (`docs/WAVE2_PERFORMANCE.md`, `scripts/check_perf_budgets.py`)
- Run `flutter build apk --release --analyze-size --target-platform android-arm64` (with explicit CI/local verification flag) to generate the AOT size analysis JSON and record package/section breakdown in `docs/WAVE2_PERFORMANCE.md`.
- Record frame build/raster budget targets (`<= 8.0 ms` build / `<= 8.0 ms` raster for 60/120 Hz), cold-start stages, memory ceiling checks, Android per-ABI APK sizes, R8 mapping verification, and Web raw/gzipped bundle budgets in `docs/WAVE2_PERFORMANCE.md` and `scripts/check_perf_budgets.py`.

### Phase `6.2` — Wasm Audit & Web PWA (`web/index.html`, `web/manifest.json`)
- Document exact Wasm blocker matrix (`flutter_secure_storage_web: 1.2.1` vs `2.1.1` in `flutter_secure_storage: 11.2.0`, and `flutter_tts: 4.2.5` `flutter_tts_web.dart:104-107` `invalid_runtime_check_with_js_interop_types`). Keep `pubspec.yaml` storage packages stable (`^9.2.2`, zero homemade crypto, JS default in `ci.yml` with informational `--wasm` step).
- Add an automated test (`test/core/platform/web_wasm_hygiene_test.dart`) enforcing zero `dart:html`, `dart:js`, `dart:js_util`, or `package:js` imports anywhere in `lib/` and verifying `web/index.html` and `web/manifest.json` invariants.
- Replace the cache-wiping script in `web/index.html:35-51` with versioned service worker lifecycle handling + an Option B Iron Scoreboard (`#0A0B0E` dark / `#F3F4F6` light, `#F59E0B` amber) initial loading shell that displays a subtle build/version indicator and cleanly removes itself on `flutter-first-frame`.
- Update `web/manifest.json` to Option B Iron Scoreboard colors (`"background_color": "#0A0B0E"`, `"theme_color": "#F59E0B"`).

### Phase `6.3` — Android Gradle Cleanup & iOS Provisioning
- **`android/app/build.gradle.kts`:**
  - Migrate `kotlinOptions { jvmTarget = ... }` (`L63-65`) to modern `compilerOptions { jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17) }`.
  - Fail fast with `GradleException` when a release build task (`Release` in requested task names) is invoked without `android/key.properties`, **unless** `ALLOW_UNSIGNED_RELEASE=true` (env var) or `-PallowUnsignedRelease=true` (Gradle property) is explicitly supplied for CI/local R8 verification builds. Update `.github/workflows/ci.yml` R8 verification step to pass `-PallowUnsignedRelease=true`.
  - Remove duplicate explicit `firebase-bom`, `firebase-analytics`, `firebase-auth`, and `firebase-firestore` dependencies (`L117-124`) so FlutterFire plugins remain the single source of truth.
- **`android/app/proguard-rules.pro`:**
  - Remove no-op `-keep class io.hive.**` and `-keep class * extends io.hive.TypeAdapter` rules (`L20-22`).
- **`ios/`:**
  - Create standard Flutter `ios/Podfile` targeting `platform :ios, '15.0'` with `use_frameworks!` and `use_modular_headers!` required by Firebase iOS SDKs and `flutter_additional_ios_build_settings(target)`.
  - Update `ios/Runner/Info.plist` to declare `<key>ITSAppUsesNonExemptEncryption</key><false/>` so App Store / TestFlight builds do not stall on export compliance prompts.

### Phase `6.4` — Accessibility, RTL Testing, 7-Locale String Coverage & Resilience
- Expand `test/accessibility/` with:
  - **`test/accessibility/rtl_and_localization_test.dart`**:
    - Wraps `HomeScreen`, `ActiveWorkoutScreen`, `NutritionScreen`, `SettingsScreen`, and `BodyMapView` in `Directionality(textDirection: TextDirection.rtl, ...)` at both `1.0x` and `2.0x` text scale factors, asserting zero `FlutterError` / RenderFlex overflows and verifying directional geometry.
    - Verifies all 7 ARB files (`en`, `es`, `fr`, `de`, `pt`, `ja`, `zh`) have identical key sets (`122` keys), non-empty strings, matching `{placeholder}` tokens, and valid `AppLocalizations` resolution across all 7 `AppLocalizations.supportedLocales`.
    - Verifies resilience under corrupted/empty local payloads and web PWA manifest/index invariants.
