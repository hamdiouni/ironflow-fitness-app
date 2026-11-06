# Changelog

All notable changes to **IronFlow** (`progression_tracker`) are documented in this file.
This project follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html) (`MAJOR.MINOR.PATCH+BUILD_NUMBER`).

---

## [1.3.0+4] — 2026-11-06

### Body Map & Gym-First Experience (Wave 4)
- **Canonical 20-Region Anatomical Model (`4.1`)**: Defined `MuscleRegion` representing 20 anatomical regions (`chest`, `front_delts`, `side_delts`, `rear_delts`, `biceps`, `triceps`, `forearms`, `upper_abs`, `lower_abs`, `obliques`, `quads`, `adductors`, `calves`, `upper_traps`, `middle_back`, `lats`, `lower_back`, `glutes`, `hamstrings`, `abductors`) with resilient ID parsing, primary/secondary exercise resolution via `ExerciseCatalog`, and DOMS soreness tracking.
- **Scientific Recovery Engine (`4.2`)**: Implemented `MuscleRecoveryCalculator` evaluating exponential recovery decay across hours since training, volume loads, 20% warm-up discounting, fatigue thresholding, and user-reported DOMS soreness overrides into 4 recovery tiers (`fresh`, `recovering`, `fatigued`, `sore`).
- **Interactive 2D Vector Body Map Canvas (`4.3`, `ADR-006`)**: Engineered high-performance `CustomPainter` vector map with zero new dependencies, normalized 300x520 anatomical coordinate paths, front & back silhouette rendering, front/back view toggle, recovery vs 7-day volume heatmap toggle, battery-optimized selection pulse, and arbitrary polygon hit-testing (<0.4ms frame render time).
- **Muscle Diagnostics & Direct Workout CTA (`4.4`)**: Implemented Direction 4 `MuscleDetailSheet` showing real-time recovery status, last trained date, 7-day sets and volume, manual DOMS toggle, and direct "Train This Muscle" action linking to exercise discovery.
- **Gym-First Integrations (`4.5`)**:
  - Integrated `BodyMapView` as 4th tab (`BODY MAP`) on `ProgressScreen` with deep link parameter support (`?tab=bodymap`).
  - Integrated live `overallBodyReadinessProvider` into `HomeScreen`'s `HeroReadinessBanner` with animated readiness percentage and 1-tap navigation to the Body Map.
  - Added `WorkoutSummaryMusclesCard` to `WorkoutSummaryScreen` highlighting stimulated muscle groups upon workout completion with direct link to Body Map.
  - Added audible gym rest timer alerts via `SystemSound.play(SystemSoundType.alert)` combined with isolated haptic feedback (`AppHaptics.restTimerComplete()`).
- **Catalog & Code Cleanup (`4.6`)**: Removed unused Riverpod code generation dependencies (`riverpod_annotation`, `riverpod_generator`) from `pubspec.yaml`, and deleted 16 obsolete prototype files in `lib/dev/design_lab/`.

---

## [1.2.0+3] — 2026-11-06

### Architecture & Data (Wave 3)
- **Toolchain & Dependency Upgrades (`3.1`)**: Upgraded `com.android.tools:desugar_jdk_libs` (`2.0.4 -> 2.1.4`) and safe non-breaking packages (`uuid 4.6.0`, `image_picker 1.2.4`, `flutter_cache_manager 3.5.0`, `flutter_svg 2.3.2`, `path_provider 2.1.6`) with `0` CVEs (`docs/architecture/WAVE3_TOOLCHAIN_AND_DEPENDENCY_UPGRADES.md`).
- **Riverpod `Notifier` Migration (`3.2`, `ADR-007`)**: Migrated all `27` `StateNotifier` files (`29` classes) in `lib/` to modern Riverpod `Notifier`, `AsyncNotifier`, and `FamilyNotifier` (`0` legacy `StateNotifier` classes remaining in `lib/`).
- **Split All Giant Files `< 800` Lines (`3.3`)**: Added characterization tests and decomposed all `21` non-generated `.dart` files over `800` lines in `lib/` into cohesive sub-widgets, bottom sheets, dialogs, catalog shards, and helper services with zero visual or behavior changes.
- **Static Catalogs, Alias Migration & Isolate Index (`3.4`, `ADR-008`)**: Deduplicated exercises (`150` raw -> `129` canonical, `0` duplicate IDs/names, Rickroll URLs stripped), added Body Map muscle regions (`primaryRegions`, `secondaryRegions`) and provenance on `ExerciseDefinition`, added `ExerciseAliasResolver` + idempotent `DataMigration` step, exported `assets/data/exercises_catalog.json` (`103.7 KB`) and `assets/data/foods_catalog.json` (`282` unique foods, `208.1 KB`), and built `CatalogSearchIndex` (`compute` isolate prefix index).
- **Architecture Hygiene & Isolation (`3.5`)**: Eliminated all `25` domain-layer boundary violations (`0` `domain -> data/presentation` imports); isolated debug/preview routes in `lib/dev/dev_routes.dart`; gated mock auth/user datasources behind `kReleaseMode` `StateError` + compile-time tree-shaking; enforced all guards in `test/architecture/architecture_hygiene_test.dart`.
- **Zero Deprecations & Stricter Lints (`3.6`, `ADR-006`)**: Replaced all `50` `.withOpacity(` calls with `.withValues(alpha: ...)`, fixed Wasm `avoid_double_and_int_checks`, replaced deprecated `SwitchListTile(activeColor:)` calls, and tightened `analysis_options.yaml` (`0` analyzer errors, `0` warnings).
- **Data Layer & Multi-User Isolation (`3.7`)**: Fixed `LocalDataWiper` (`W2-F1`) so account wipe only purges active user records without touching other local users' scoped Hive entries; added `PrivacyPreferencesRepository` and `AiPreferencesRepository` abstractions so zero screens call `Hive` or `SharedPreferences` directly.

---

## [1.1.0+2] — 2026-11-06

### Security & Backend (Wave 1)
- **Firestore & Storage Rules**: Restricted `users/{uid}` update rules to prevent ownership/protected field tampering (`SEC-05`); hardened Firebase Storage delete rules; added composite indexes (`firestore.indexes.json`) and emulator rule tests.
- **Release Auth & Route Safety**: Enforced real Firebase Authentication in `production` / `staging` and all release builds (`SEC-02`); stripped `/design-preview` and `/design-gallery` from release builds (`SEC-03`); validated post-auth redirects (`SEC-04`).
- **Privacy & Telemetry Consent**: Changed Analytics and Crashlytics default collection to `false` (opt-in only) in Dart (`TelemetryPreferences`), Android (`AndroidManifest.xml`), and iOS (`Info.plist`), backed by `TelemetryConsentScreen` (`PRV-01`).
- **Account Deletion**: Added recursive Firebase Storage prefix deletion and typed `RemotePurgeException` in `RemoteDataPurgerImpl` (`BKD-03`); fixed `LocalDataWiper` to clear open `Box<Map>` boxes (`workouts`, `meals`, `macro_targets`) safely.
- **Cloud Functions AI Proxy & App Check**: Added `functions/` Firebase Cloud Functions proxy (`aiGenerate`) with ID token verification, App Check verification, per-UID Firestore rate limiting, and `AiTransport` abstraction (`SEC-01`, `ADR-001`).
- **Hive At-Rest Encryption**: Added `HiveEncryptionService` with 256-bit `HiveAesCipher`, hardware-backed `flutter_secure_storage` key management, pre-migration safety backup, and corrupted-box recovery (`SEC-07`, `ADR-002`).
- **Sync Correctness**: Added outbox coalescing (`create`+`update`, `create`+`delete`, `update`+`delete`), unpushed local edit protection during cloud pull, and deterministic equal-timestamp tie-breaking (`BKD-02`).

### Quality, CI & Release Engineering (Wave 2)
- **Characterization & E2E Journeys**: Added characterization suites for auth/onboarding gate, backup/restore, analytics math (`WorkoutMetrics` 10-rep 1RM cap, warm-up exclusion), and nutrition math (`MacroCalculator`), plus 7 end-to-end journeys (`test/integration/wave2_e2e_journeys_test.dart` & `integration_test/wave2_e2e_journeys_test.dart`).
- **Design System Golden Tests**: Added Light and Dark golden tests for Direction 4 ("Soft & Layered") components rendered with bundled `Inter` and `SpaceGrotesk` fonts (`test/design_system/design_system_goldens_test.dart`).
- **CI & Coverage Gate**: Added `scripts/check_coverage.py` enforcing per-layer minimum line coverage (`domain`, `data`, `core`, `overall`) in `.github/workflows/ci.yml` alongside Gitleaks secret scanning, Cloud Functions proxy tests, dependency audit, Web/Android artifact builds, and macOS iOS `--no-codesign` compilation.
- **Flavors & Build Stamp**: Added `config/dev.json`, `config/staging.json`, `config/production.json`, `FlavorConfig`, and `BuildStamp`.
- **Observability & Feature Flags**: Added `ObservabilityService` (structured logging, PII scrubbing, consent-gated crash/performance spans) and `FeatureFlagsService` (remote kill switches and feature flags, `ADR-005`).
