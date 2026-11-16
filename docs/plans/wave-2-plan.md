# Wave 2 Plan — Quality and CI (`PLAN_ONLY: yes`)

- **Wave**: `2` (`2.1`–`2.5`: Analyzer green, thin-area characterization tests + coverage ratchet, CI hardening & R8/Wasm/iOS/emulator/budget gates, E2E journeys + goldens + flavors + release notes, Observability & kill-switch ADR consolidation)
- **Mode**: `PLAN_ONLY: yes` (this document only; zero app/config/CI edits made)
- **Recommended Branch / Backup Tag for Execution**: branch `feat/prod-v2-wave-2` from pre-change tag `backup/pre-prod-v2-wave-2` on `master` (mirrors Wave 1's `feat/prod-v2-wave-1` / `backup/pre-prod-v2-wave-1` naming to avoid colliding with existing historical V1 `feat/prod-wave-2` / `backup/pre-prod-wave-2`).
- **Pre-Wave Cleanup Verified**: Removed unregistered leftover Windows long-path directory `C:\Users\HP\gym-app-worktrees` (`Test-Path` = `False`); `git worktree list` shows only `C:/Users/HP/OneDrive/Bureau/gym app 096e9c9 [master]`.

---

## Step 0 — Current State & Claims Checked (Verified on `master` `096e9c9`)

> All counts, file paths, symbol names, and command outputs below were directly observed on `master` (`096e9c9`). Commands/targets not executed (`flutter build ios` on macOS, `flutter build apk --release` in clean `master`, `flutter build web --wasm`, Firebase Emulator CI run) are explicitly marked **NOT VERIFIED**.

### Step 0A — What Exists Today

| Item | Exists? | Verified Evidence on `master` (`096e9c9`) |
|---|---|---|
| **Analyzer baseline (`2.1`)** | **Fails CI exit 1** | `flutter analyze --no-pub --no-fatal-infos`: **183 issues** (`0` errors, **`3` warnings**, `180` infos). `lib/` has **0 errors, 0 warnings, 0 infos**. The 3 blocking warnings are all in `test/`: `test/core/utils/retry_helper_test.dart:46:11` (`unused_local_variable` `'callCount'`), `test/features/body/presentation/body_map_view_test.dart:5:8` (`unused_import` `'muscle_recovery_status.dart'`), `test/features/body/presentation/body_map_view_test.dart:138:16` (`override_on_non_overriding_member` `toggleSoreness` vs `ManualSorenessNotifier.toggle`). The 180 infos are `176` `avoid_print` (`scripts/`, `tool/`, `integration_test/`, `test/integration/auth_preservation_property_test.dart`), `2` `unnecessary_import`, `1` `non_constant_identifier_names`, `1` `use_super_parameters`. |
| **Test suite & LCOV coverage (`2.2`)** | **Yes (Partial)** | `flutter test --no-pub --coverage --timeout=60s`: **992 passed, 0 failed**. `python scripts/check_coverage.py coverage/lcov.info`: **64.20%** (`18,962 / 29,536` lines across **375 non-generated files in LCOV**). Layers: `domain` **77.24%**, `data` **65.08%**, `core` **67.08%**, `presentation` **59.85%**, `shared` **73.85%**. **481** non-generated/non-dev files exist in `lib/`, so **106 files (`0%`, unimported by any test)** are omitted from LCOV's denominator. |
| **Thin-area coverage (`2.2`)** | **Yes (Measured)** | Real per-area LCOV: `main.dart` **32.06%** (`42/131`), `onboarding` **39.38%** (`569/1,445`), `auth` **45.59%** (`630/1,382`), `sync` **48.17%** (`302/627`), `notifications` **48.90%** (`223/456`), `settings` **72.38%** (`2,301/3,179` overall, but thin inside `backup_data_use_case.dart` 44.1%, `export_settings_screen.dart` 40.9%, `export_restore_modal.dart` 0%, `settings_dialogs.dart` 0%, `settings_providers.dart` 20.0%, `import_program_use_case.dart` 0% unimported). `lib/features/notifications/domain/services/notification_service_old.dart.bak` leftover file also exists. |
| **Coverage gate & ratchet (`2.2`)** | **Partial** | `scripts/check_coverage.py` enforces static CLI thresholds (`--min-overall 60.0`, `--min-domain 70.0`, `--min-data 60.0`) and prints feature percentages, **but has no baseline JSON comparison (`fail-on-drop` ratchet), no per-area thresholds (`auth`, `sync`, `notifications`, `onboarding`, `main.dart`), and does not report the 106 unimported `lib/` files**. |
| **CI workflow (`.github/workflows/ci.yml`) (`2.3`)** | **Partial** | Existing jobs: `secret-scan` (`gitleaks` + `pre-commit-secrets-check.sh --ci-verify`), `cloud-functions-proxy` (runs ONLY `node --test functions/test/ai_proxy.test.mjs`), `flutter-verify` (`pub get`, `pub outdated`, `analyze --no-fatal-infos`, `test --coverage`, `check_coverage.py`, `build web --release`, `nvapi-` check, `build apk --debug`, `check_perf_budgets.py`), `ios-compile-check` (`macos-latest`, `--release --no-codesign`). **Missing**: `functions` `npm ci` + `npm run build` (`tsc`), **Firebase Emulator rules job**, **Android `--release` + R8 verification**, **informational non-blocking `--wasm` build**, and **coverage drop ratchet**. |
| **Cloud Functions & Rules tests (`2.3`)** | **Partial / Path gap** | In `functions/`: `functions/node_modules` is absent on clean `master` (`npm run build` fails `'tsc' is not recognized` until `npm ci` runs); `node --test test/ai_proxy.test.mjs` passes **9/9**. `test/rules/firebase_rules.emulator.spec.mjs` exists, **but there is no root `package.json`**: ESM imports `@firebase/rules-unit-testing` which lives only in `functions/package.json` (`devDependencies`), while the spec reads `firestore.rules` relative to CWD. Rules emulator execution in CI is **NOT VERIFIED**. |
| **Size & perf budget script (`2.3`)** | **Exists (Gap)** | `scripts/check_perf_budgets.py` (123 lines) exists and passes on existing `build/` (`assets/fonts` 0.97 MB <= 1.5 MB, `assets/data` 0.38 MB <= 1.0 MB, `build/web/main.dart.js` 1.61 MB gzipped <= 2.5 MB, `build/web/assets` 2.85 MB <= 6.0 MB, `app-debug.apk` 232.00 MB <= 250.0 MB). **Gap**: release APK audit silently skips if no `*release*.apk` exists, and R8 `mapping.txt` is not checked. `test/performance/screen_frame_budget_test.dart` & `yearly_data_benchmark_test.dart` run inside `flutter test`; `integration_test/wave2_screen_performance_trace_test.dart` & `docs/WAVE2_PERFORMANCE.md` exist for profile-mode traces. |
| **Android R8 & Crashlytics (`2.3` / `2.5`)** | **Partial** | `android/app/build.gradle.kts:93-94` sets `isMinifyEnabled = true` and `isShrinkResources = true` with `android/app/proguard-rules.pro`. **Gaps**: release build on `master` not yet executed in CI (`NOT VERIFIED`); `com.google.firebase.crashlytics` Gradle plugin is **missing** from `android/settings.gradle.kts` & `android/app/build.gradle.kts`; `android/app/src/{dev,staging}/google-services.json` do not exist so `hasFlavorGoogleServices` is `false`. |
| **Wasm web build (`2.3`)** | **Not in CI / Blocked** | `pubspec.lock` contains `flutter_secure_storage` (`9.x` / `flutter_secure_storage_web`) and `flutter_tts` (`4.2.x`). `flutter build web --wasm` has **NOT VERIFIED** execution locally or in CI. |
| **iOS compile readiness (`2.3`)** | **Partial (macOS only)** | `ios/Runner/PrivacyInfo.xcprivacy` and `NSCameraUsageDescription`/`NSPhotoLibraryUsageDescription` in `Info.plist` exist. `ios/Runner/GoogleService-Info.plist` (`False`) and `ios/Podfile` (`False`) do **not** exist; bundle ID in `project.pbxproj` is `com.progressiontracker.progressionTracker`. CI job `ios-compile-check` exists (`NOT VERIFIED` on `macos-latest`). |
| **E2E journeys (`2.4`)** | **Exists (Headless)** | `test/integration/wave2_e2e_journeys_test.dart` (934 LOC, 7 journeys J1–J7 using domain/repo/Hive + in-memory fakes) & `integration_test/wave2_e2e_journeys_test.dart` (18 LOC wrapper) pass inside `flutter test`. Legacy `integration_test/{workout,nutrition,theme}_flow_logging_test.dart` initialize live `Firebase.initializeApp()` and cannot run offline. Full widget-pumped UI router E2E is minimal. |
| **Golden tests (`2.4`)** | **Exists (Minimal)** | `test/design_system/design_system_goldens_test.dart` (201 LOC) passes on Windows with 2 component goldens (`direction4_components_light.png`, `direction4_components_dark.png`) and bundled `Inter.ttf`/`SpaceGrotesk.ttf`. Cross-OS Ubuntu CI rendering is **NOT VERIFIED**. |
| **Flavors & Release docs (`2.4`)** | **Partial / Stale docs** | `config/{dev,staging,production}.json`, `FlavorConfig`, `BuildStamp`, `flavor_config_test.dart` exist. **Gaps**: `FlavorConfig.showFlavorBanner` & `FlavorConfig.current.appName` are unused in `lib/main.dart`; `scripts/run_web.ps1` omits `--dart-define-from-file`; docs conflict: `RELEASE_ENGINEERING_AND_SIGNING.md` cites `gym-app-fe50c` & `ENFORCE_APP_CHECK: true`, `STORE_RELEASE_CHECKLIST.md` cites removed `COEP: require-corp`, `ENVIRONMENT_AND_FLAVORS.md` uses obsolete `APP_CHECK_STAGE` / `DIRECT_AI_KEYS_OPT_IN`, `AI_PROXY_AND_APP_CHECK_DEPLOYMENT.md` cites `ironflow-fitness-app`, `CLIENT_PACK/README.md` says `2.0.0+6` vs `pubspec.yaml` `1.1.0+2`. |
| **Observability & Kill Switch (`2.5`)** | **Orphaned / Conflict** | `ObservabilityService` (`312` LOC) & `FeatureFlagsService` (`147` LOC) exist and pass `observability_and_feature_flags_test.dart`, **but have 0 callers in `lib/`**. `firestore.rules` has **no** rule for `app_config/*` (all reads denied!). Two duplicate ADRs exist for `005` (`005-observability-and-feature-flags.md` Proposed vs `ADR-005-observability-and-feature-flags.md` Accepted) and `006` (`006-body-map-rendering-2d-vs-3d.md` vs `ADR-006-lint-rules-and-deprecation-policy.md`). |

### Step 0B — Claims Checked Against Master Plan V2 & Prior Reports

| Claim (from Master Plan / `docs/audit/` / `docs/adr/`) | Verified? | Evidence |
|---|---|---|
| "`2.1` Fix the 5 analyzer warnings (`ai_provider.dart`, `ai_chat_screen.dart`)" | **REFUTED (3 remain, in `test/`)** | All 5 `lib/` warnings and 50 `.withOpacity` infos were already fixed (`lib/` = 0 issues). **3 warnings remain in `test/`** (`retry_helper_test.dart:46`, `body_map_view_test.dart:5,138`), still breaking CI `flutter analyze --no-fatal-infos`. |
| "`2.2` Critical domains `sync`/`settings`/`auth`/`notifications`/`onboarding`/`main` are thin" | **CONFIRMED (Except `settings` top-level)** | `main.dart` **32.06%**, `onboarding` **39.38%**, `auth` **45.59%**, `sync` **48.17%**, `notifications` **48.90%** are all under 50%. `settings` overall is **72.38%**, but core modals/usecases (`backup_data_use_case.dart` 44.1%, `export_restore_modal.dart` 0%, `settings_dialogs.dart` 0%, `import_program_use_case.dart` 0%) remain thin. |
| "`2.2` `docs/quality/TEST_STRATEGY_AND_COVERAGE_GATES.md` reflects current gate (53.5% / 62.58%)" | **STALE** | Actual `master` LCOV is **64.20%** (`18,962 / 29,536`, excluding 106 unimported `lib/` files), while `check_coverage.py` CLI gate is `60.0%` without any drop-ratchet baseline. |
| "`2.3` Size and performance budget script: verify if it exists" | **CONFIRMED (Exists, incomplete)** | `scripts/check_perf_budgets.py` exists (`W5.1`) and runs in CI, **but** silently skips missing release APKs instead of enforcing `--release` size/R8 verification. |
| "`2.3` CI runs `functions` (`npm ci`, build, test) & emulator rules tests" | **REFUTED (Missing)** | `ci.yml` runs only `node --test functions/test/ai_proxy.test.mjs` — skips `npm ci`, skips `tsc`, and runs **zero** Firebase Emulator rules tests. |
| "`2.3` iOS compile on macOS (`ASK`)" | **ALREADY IN `ci.yml` (`NOT VERIFIED`)** | `ci.yml:117-144` already defines `ios-compile-check` on `macos-latest`, unverified against the real macOS runner (and missing `GoogleService-Info.plist` / `Podfile`). Cost/trigger cadence requires `[ASK]`. |
| "`2.4` Release checklist & flavor docs are accurate (`STORE_RELEASE_CHECKLIST.md`, `RELEASE_ENGINEERING_AND_SIGNING.md`)" | **REFUTED (Stale)** | Docs contain pre-Wave-1 / contradictory project IDs (`gym-app-fe50c`, `ironflow-fitness-app`), `ENFORCE_APP_CHECK: true`, and `COEP: require-corp` (removed in Wave 1). |
| "`2.5` ADR-005 + `ObservabilityService` + `FeatureFlagsService` kill switches are wired in production" | **REFUTED (Orphaned + Rules Deny)** | `0` runtime imports in `lib/`; `firestore.rules` blocks `app_config/*`; `com.google.firebase.crashlytics` Gradle plugin missing; two competing `005` ADR files exist. |
| "`docs/audit/SCORECARD.md`: `flutter analyze` has 0 issues & Wave 2 complete (10/10)" | **REFUTED** | Full repo `flutter analyze` has **183 issues** (`3` warnings, `180` infos); CI fails on `3` warnings; several Wave 2 items remain half-wired. |

---

## Owner Questions (`[ASK]` — Reply Before Running Wave 2)

1. **`[ASK]` `ios-compile-check` on `macos-latest` (`2.3`)**:
   - Should `.github/workflows/ci.yml`'s `macos-latest` job (`flutter build ios --release --no-codesign`) run **on every PR**, **only on `master` pushes + `workflow_dispatch`** (recommended to conserve 10x macOS runner minutes), or be **disabled** until iOS is targeted?
2. **`[ASK]` Deleting Duplicate / Obsolete Files**:
   - May we **consolidate** `docs/adr/005-observability-and-feature-flags.md` + `docs/adr/ADR-005-observability-and-feature-flags.md` into **one canonical `docs/adr/005-observability-and-feature-flags.md`** and **delete** the duplicate `docs/adr/ADR-005-observability-and-feature-flags.md`?
   - Notice ADR numbering also collides on `006` (`006-body-map-rendering-2d-vs-3d.md` vs `ADR-006-lint-rules-and-deprecation-policy.md`, plus `ADR-007`, `ADR-008`, `009`). May we leave `ADR-006..008` untouched until Wave 3/9 OR normalize all ADR filenames cleanly now (`010`–`012`)?
   - May we **delete** leftover `lib/features/notifications/domain/services/notification_service_old.dart.bak`?
3. **`[ASK]` Android Crashlytics Gradle Plugin & R8 Signing in CI (`2.3` / `2.5`)**:
   - `firebase_crashlytics` Dart package is already installed, **but** `com.google.firebase.crashlytics` Gradle plugin (`3.x`) is absent from `android/settings.gradle.kts` / `android/app/build.gradle.kts`. Do you approve adding the Gradle plugin (zero new Dart packages) so release R8 stacktraces can symbolicate?
   - In CI (`ubuntu-latest`), `android/key.properties` is absent so `android/app/build.gradle.kts` falls back to debug signing while still running R8 (`isMinifyEnabled = true`, `isShrinkResources = true`). Is debug-signed `--release --split-per-abi` acceptable in public CI to verify R8 + per-ABI budgets (`<= 35 MB`), with real keystore secrets saved for manual/release workflow?
4. **`[ASK]` Analyzer Strictness on Info Lints & Golden Cross-OS Policy (`2.1` / `2.4`)**:
   - Fixing the 3 test warnings makes CI `flutter analyze --no-fatal-infos` exit `0`. Should Wave 2 also fix the **4 non-`avoid_print` `test/` infos** (`unnecessary_import`, `non_constant_identifier_names`, `use_super_parameters`) cleanly now, while keeping `avoid_print` suppressed or migrated only in tests/scripts?
   - For `design_system_goldens_test.dart`: if Ubuntu CI Skia font antialiasing differs by <0.5% from Windows-generated PNGs (`direction4_components_*.png`), do you prefer generating canonical Linux goldens inside CI/Docker or running goldens with `--tags golden` / platform check?
5. **`[ASK]` Proposed Coverage Gate Floors & Ratchet Tolerance (`2.2`)**:
   - Confirm the proposed Wave 2 gate floors (overall >= `66.0%` toward `75.0%` goal, `domain >= 77.0%`, `data >= 66.0%`, `core >= 67.0%`, `shared >= 73.5%`, `presentation >= 61.0%`, `auth >= 52.0%`, `settings >= 73.0%`, `sync >= 55.0%`, `notifications >= 58.0%`, `onboarding >= 48.0%`, `main.dart >= 45.0%`, with `0.00%` drop tolerance against `docs/quality/coverage_baseline.json`).
6. **`[ASK]` Execution Mode (`LANES: single` vs `parallel`) & Local Branch Hygiene**:
   - Confirm `LANES: single` (sequential on `feat/prod-v2-wave-2`) or switch to `LANES: parallel` (`Lane A Tests`, `Lane B CI/Docs`, `Integrator`). Optionally confirm if local Wave 1 temporary branches (`feat/prod-v2-wave-1`, `-lane-a`, `-lane-b`) can remain or be deleted locally.

---

## Ordered Execution Plan (With Tests-First & Exact File List)

### Execution Order
1. **Preflight**: Clean working tree on `master`, create local backup tag `backup/pre-prod-v2-wave-2`, create `feat/prod-v2-wave-2` (or per-lane worktrees outside OneDrive if `LANES: parallel`), re-verify baseline (`flutter analyze`, `flutter test`, `npm test` in `functions/`).
2. **`2.1` Fix Analyzer Warnings & Info Hygiene**:
   - Fix `retry_helper_test.dart:46` (`await expectLater(...)` + assert `expect(callCount, 3)` — stronger test assertion, not suppression!).
   - Fix `body_map_view_test.dart:5` (remove unused `muscle_recovery_status.dart` import) & `body_map_view_test.dart:138` (`override` -> `toggle(String regionId, bool isSore)` matching `ManualSorenessNotifier.toggle`!).
   - Clean the 4 non-`avoid_print` `test/` infos (`design_system_goldens_test.dart:2`, `body_map_paths_test.dart:1`, `profile_data_provider_test.dart:29`, `synced_workout_repository_test.dart:124`) if approved.
   - Verify `flutter analyze --no-pub --no-fatal-infos` exits **0**.
3. **`2.2` Characterization Tests for Thin Areas (Red -> Green where behavior untested; characterization first on existing code) & Coverage Ratchet**:
   - Add deterministic characterization tests (in dependency/risk order, passing on existing code before any refactor):
     1. **Auth** (`auth`): `test/features/auth/presentation/screens/signup_screen_characterization_test.dart` (covers `signup_screen.dart`, currently `0.3%` / `1/291`: form validation, password mismatch, display name submission via mock notifier/repo, loading/error states); expand `auth_provider` / `AuthNotifier` tests (`signUp`, `signInWithGoogle`, `resetPassword`, `clearError`, error recovery).
     2. **Sync** (`sync`): `test/features/sync/firestore_sync_datasource_characterization_test.dart` & `test/features/sync/sync_provider_test.dart` (covers `sync_provider.dart` `15.9%`, `hive_sync_queue_datasource.dart` `37.8%`, `firestore_sync_datasource.dart` query shaping/timestamp guard with fakes/in-memory stubs, and `SyncIndicator` widget states at `0%` -> covered).
     3. **Notifications** (`notifications`): `test/features/notifications/notification_service_characterization_test.dart` & expand `reminder_settings_screen_test.dart` (covers `ReminderSettingsRepositoryImpl` currently `0%`, `NotificationService` web/uninitialized guards + `requestExactAlarmPermission` + cancel/schedule logic, `ReminderSettingsNotifier` sound/vibration/clearSettings/meal/streak toggles, `notification_providers.dart`).
     4. **Settings & Restore** (`settings`): `test/features/settings/import_program_use_case_test.dart` (`0%` unimported today!), `test/features/settings/backup_data_use_case_test.dart` (44.1% -> test `createManualBackup`/`getAllBackups` local-only & error branches with fakes), `test/features/settings/export_restore_modal_and_dialogs_test.dart` (covers `export_restore_modal.dart` `0%` and `settings_dialogs.dart` `0%`).
     5. **Onboarding** (`onboarding`): `test/features/onboarding/presentation/widgets/onboarding_steps_characterization_test.dart` (covers `onboarding_steps_schedule.dart` `1.7%`, `onboarding_step7_diet.dart` `0%`, `onboarding_step7_summary.dart` `0%`, plus `OnboardingNotifier` & multi-step advance in `onboarding_screen.dart`).
     6. **`main.dart` (`32.06%`)**: Add `test/main_scaffold_and_boot_test.dart` testing `MainApp` & `MainScaffold` (narrow `BottomNavigationBar` vs wide `NavigationRail >= 900px` responsive navigation, `PopScope` back-to-tab-0 behavior, locale/theme switching) and extract pure boot helper if needed after characterization tests pass.
   - Update `scripts/check_coverage.py` + `docs/quality/coverage_baseline.json`:
     - Add `--baseline <json>` and `--fail-on-drop` (checks overall, every architectural layer, and every feature area; fails if any drops below its `baseline - tolerance` or configured floor).
     - Track and print `unimported_non_gen_files` count alongside LCOV coverage (so dropping files out of tests cannot game percentages).
     - Synchronize `docs/quality/TEST_STRATEGY_AND_COVERAGE_GATES.md` with real Wave 2 measured tables and `75%` long-term target.
4. **`2.3` CI Pipeline Hardening & Build Verification**:
   - Update `.github/workflows/ci.yml`:
     - **`cloud-functions-proxy` job**: run `npm ci`, `npm run build` (`tsc`), and `npm test` inside `functions/`.
     - **`firebase-emulator-rules` job**: setup Java 17 + Node 20 + `firebase-tools` + `npm ci` in `functions/`, run `firebase emulators:exec --only firestore,storage "npm --prefix functions run test:rules"` (and update `functions/package.json` + `test/rules/firebase_rules.emulator.spec.mjs` to resolve `firestore.rules`/`storage.rules` relative to repo root via `import.meta.dirname`!).
     - **`flutter-verify` job**:
       - `flutter analyze --no-fatal-infos` (strict fail on warnings/errors).
       - `flutter test --no-pub --coverage` + `python3 scripts/check_coverage.py coverage/lcov.info --baseline docs/quality/coverage_baseline.json --fail-on-drop` + upload `coverage/lcov.info` artifact.
       - Web JS release build (`--release --dart-define-from-file=config/production.json`) + `nvapi-` key grep.
       - **Web Wasm informational non-blocking job/step** (`continue-on-error: true`): `flutter build web --wasm --dart-define-from-file=config/production.json` (logs pass/fail blocker summary without blocking PRs).
       - **Android release R8 build**: `flutter build apk --release --split-per-abi --dart-define-from-file=config/production.json`, verify `build/app/outputs/mapping/release/mapping.txt` exists & is non-empty, keep `--debug` check optional or remove redundant fat debug build once `--release` passes, run `python3 scripts/check_perf_budgets.py --require-release-apk --require-web --require-r8-mapping`.
     - **`ios-compile-check` job**: adjust trigger per Owner Question #1 (`[ASK]`).
   - Update `scripts/check_perf_budgets.py`: add CLI flags `--require-release-apk`, `--require-web`, `--require-r8-mapping` (plus optional check of `mapping.txt` non-empty and benchmark test pass), fixing the current silent-skip bug when release APKs aren't built!
   - Locally run full verify: `flutter build apk --release --split-per-abi --dart-define-from-file=config/production.json`, verify R8 `mapping.txt` + per-ABI size <= 35 MB, run `check_perf_budgets.py --require-release-apk --require-web --require-r8-mapping`, run `flutter build web --wasm` to record exact real Wasm status (`NOT VERIFIED` until run).
5. **`2.4` E2E Journeys, Golden Tests, Flavors Check & Release Engineering Notes**:
   - **E2E Journeys**: Keep `wave2_e2e_journeys_test.dart` J1–J7 + add UI/router widget E2E journey (`test/integration/wave2_ui_navigation_e2e_test.dart`: unauthenticated `/home` -> `/login` -> sign up -> `/onboarding` -> `/home` -> telemetry consent opt-in toggle) with in-memory fakes; clarify legacy Firebase-coupled tests in `integration_test/README.md`.
   - **Golden Tests**: Verify `test/design_system/design_system_goldens_test.dart` clean (0 analyzer infos) + optionally add `Direction 4` form/consent/nav component golden or keep 2 light/dark goldens and confirm cross-OS Ubuntu CI status (`[ASK]`).
   - **Flavors Check**:
     - Wire `FlavorConfig.current.appName` and a subtle `DEV` / `STAGING` banner (gated by `FlavorConfig.current.showFlavorBanner`!) in `lib/main.dart`, with widget characterization tests.
     - Verify `--dart-define-from-file=config/{dev,staging,production}.json` against `FlavorConfig` + `android/app/build.gradle.kts` (`hasFlavorGoogleServices` fallback behavior documented transparently, and update `scripts/run_web.ps1` to pass `--dart-define-from-file`, `GIT_COMMIT`, and `BUILD_DATE`).
   - **Release Engineering Notes**:
     - Update `docs/release/RELEASE_ENGINEERING_AND_SIGNING.md` (fix `ironflow-5b79d`, `ENFORCE_APP_CHECK: false` monitor stage, build-stamp flags, R8 mapping retention).
     - Fix contradictory deployment/setup/checklist references in `docs/setup/ENVIRONMENT_AND_FLAVORS.md`, `docs/deployment/AI_PROXY_AND_APP_CHECK_DEPLOYMENT.md`, and `docs/CLIENT_PACK/STORE_RELEASE_CHECKLIST.md` (`COEP: require-corp` claim removed!).
6. **`2.5` Observability Decision Record & Runtime Wiring**:
   - **Tests first** (characterization + red->green):
     - Extend `test/core/services/observability_and_feature_flags_test.dart` for: `ObservabilityService` wired error handler behavior (opt-in false -> buffers locally only, opt-in true -> forwards scrubbed error + `BuildStamp` map), Firestore `FeatureFlagsService` remote fetcher adapter, `app_config/feature_flags` rules read-only / non-admin-write denied in `test/rules/firebase_rules.emulator.spec.mjs`, and runtime provider kill-switch gating tests.
   - **Consolidate ADR-005 (`[ASK]` on file delete)**:
     - Merge `005-observability-and-feature-flags.md` and `ADR-005-observability-and-feature-flags.md` into one authoritative `docs/adr/005-observability-and-feature-flags.md` covering: Crashlytics (opt-in + `BuildStamp` + PII scrub + Android Gradle plugin decision), performance spans (`ObservabilityService.traceAsync` + startup/sync spans), consented analytics (`AnalyticsService` + `TelemetryPreferences` default OFF), and remote config / kill switches (`FeatureFlagsService` + Firestore `app_config/feature_flags` + `kill_ai_coach`, `kill_cloud_sync`, `maintenance_mode`), including options/cost/risk/rollback.
   - **Wire Observability & Feature Flags into Runtime (minimal, safe, non-breaking)**:
     - Add `lib/core/providers/observability_provider.dart` (`observabilityServiceProvider`, `featureFlagsProvider`) wired to `TelemetryPreferences`, `FirebaseCrashlytics`, `FirebaseAnalytics`, and Firestore `app_config/feature_flags` (best-effort cached fallback on offline/uninitialized Firebase!).
     - Wire `ObservabilityService` + `FeatureFlagsService` initialization in `lib/main.dart` (with `BuildStamp` custom keys + PII-scrubbed zone error reporting gated by `TelemetryPreferences.crashReportingEnabled()`).
     - Add `match /app_config/{docId} { allow read: if true; allow write: if isAdmin(); }` to `firestore.rules` + emulator test coverage!
     - Wire `FeatureFlagsService` kill switches (`isAiCoachActive`, `isCloudSyncActive`, `maintenanceMode`) cleanly into AI/sync entry points with fail-open offline cached defaults.
     - Add Crashlytics Gradle plugin (`com.google.firebase.crashlytics`) to `android/settings.gradle.kts` and `android/app/build.gradle.kts` (`[ASK]` #3) and verify `--release` R8 build cleanly passes.

---

## Candidate File Touch List

### Shared / Integrator Files
- `lib/main.dart` — wire `FlavorConfig.current.appName`, `showFlavorBanner`, `ObservabilityService`, `FeatureFlagsService`.
- `firestore.rules` — add read-only `match /app_config/{docId}` (`allow read: if true; allow write: if isAdmin();`).
- `android/settings.gradle.kts` & `android/app/build.gradle.kts` — apply `com.google.firebase.crashlytics` plugin (`[ASK]`).
- `.github/workflows/ci.yml` — full Wave 2 CI pipeline fixes (`functions` `npm ci`/`build`, emulator rules job, Android release R8 verify, Wasm informational job, coverage ratchet, `check_perf_budgets.py --require-release-apk`).

### Lane A (Tests, Characterization, Goldens, Analyzer Fixes)
- `test/core/utils/retry_helper_test.dart` (`2.1` warning fix + assertion)
- `test/features/body/presentation/body_map_view_test.dart` (`2.1` two warning fixes)
- `test/design_system/design_system_goldens_test.dart` (`2.1` `unnecessary_import` info)
- `test/features/body/presentation/body_map_paths_test.dart`, `test/features/profile/presentation/providers/profile_data_provider_test.dart`, `test/features/workout/data/repositories/synced_workout_repository_test.dart` (`2.1` optional info cleanup)
- New thin-area test suites (`2.2`):
  - `test/features/auth/presentation/screens/signup_screen_characterization_test.dart`
  - `test/features/sync/sync_provider_test.dart` & `test/features/sync/firestore_sync_datasource_characterization_test.dart`
  - `test/features/notifications/notification_service_characterization_test.dart`
  - `test/features/settings/import_program_use_case_test.dart`, `test/features/settings/backup_data_use_case_test.dart`, `test/features/settings/export_restore_modal_and_dialogs_test.dart`
  - `test/features/onboarding/presentation/widgets/onboarding_steps_characterization_test.dart`
  - `test/main_scaffold_and_boot_test.dart`
- New UI E2E & Observability/Kill-Switch tests (`2.4` / `2.5`):
  - `test/integration/wave2_ui_navigation_e2e_test.dart`
  - `test/core/services/observability_and_feature_flags_test.dart` (expanded)

### Lane B (CI Scripts, Emulator Spec Path Fix, Flavors, Observability Wiring, Docs/ADRs)
- `scripts/check_coverage.py` & `docs/quality/coverage_baseline.json` (new)
- `scripts/check_perf_budgets.py` & `scripts/run_web.ps1`
- `functions/package.json` (`"test:rules"` script) & `test/rules/firebase_rules.emulator.spec.mjs` (CWD-safe `import.meta.dirname` path resolution + `app_config` rules tests)
- `lib/core/providers/observability_provider.dart` (new) & AI/Sync kill-switch checks (tiny additive checks in `sync_provider.dart` / `global_ai_provider.dart` or `gemini_ai_service.dart`)
- `docs/adr/005-observability-and-feature-flags.md` (consolidated) + `[ASK]` delete `docs/adr/ADR-005-observability-and-feature-flags.md` & `lib/features/notifications/domain/services/notification_service_old.dart.bak`
- `docs/quality/TEST_STRATEGY_AND_COVERAGE_GATES.md`, `docs/release/RELEASE_ENGINEERING_AND_SIGNING.md`, `docs/setup/ENVIRONMENT_AND_FLAVORS.md`, `docs/deployment/AI_PROXY_AND_APP_CHECK_DEPLOYMENT.md`, `docs/CLIENT_PACK/STORE_RELEASE_CHECKLIST.md`, `integration_test/README.md`

---

## Key Risks & Mitigations

| Risk | Mitigation |
|---|---|
| **Golden PNG pixel mismatch between Windows (dev) and Ubuntu (CI)** | Golden files in `test/design_system/goldens/` were generated with bundled fonts, which helps determinism, **but** Linux Skia subpixel/hinting can still differ from Windows. Verify on the first Ubuntu CI run; if pixel diffs fail, generate canonical PNGs inside Linux CI or apply documented minimal platform guard (`[ASK]` #4). |
| **Android R8 strips Crashlytics / Hive / Notification reflection targets** | Run full `flutter build apk --release --split-per-abi` locally & in CI, inspect `mapping.txt`, and verify keep rules in `android/app/proguard-rules.pro` against Crashlytics + Firebase + Hive. |
| **ESM module resolution fails in `test/rules/firebase_rules.emulator.spec.mjs` when run from repo root** | Because `@firebase/rules-unit-testing` is in `functions/node_modules` and no root `package.json` exists, invoke via `"test:rules"` inside `functions/package.json` while resolving `firestore.rules` & `storage.rules` using `import.meta.dirname` (`../../firestore.rules`). |
| **Android flavor `google-services.json` missing for `dev`/`staging`** | `android/app/build.gradle.kts` intentionally guards `applicationIdSuffix` on `hasFlavorGoogleServices`; document this clearly until Firebase projects `ironflow-dev` and `ironflow-staging` register Android apps and provide flavor `google-services.json` files. |
| **Adding `ObservabilityService` / `FeatureFlagsService` throws when offline or uninitialized in tests** | Keep every provider / boot hook best-effort (`try/catch`, checking `Firebase.apps.isNotEmpty`), defaulting `FeatureFlagsSnapshot` fail-open for local UX and storing telemetry consent default OFF. |
| **`lcov.info` ignores 106 unimported `lib/` files** | Track `unimported_non_gen_files` in `scripts/check_coverage.py` alongside `lcov.info` percentages so coverage improvements reflect genuine new tests rather than deleting imports. |

---

## Verification Matrix (Target Gate Before Wave 2 Complete)

- `flutter analyze --no-pub --no-fatal-infos` -> `0` errors, `0` warnings
- `flutter test --no-pub --coverage --timeout=60s` -> all tests pass (`>= 992 + new suites`)
- `python scripts/check_coverage.py coverage/lcov.info --baseline docs/quality/coverage_baseline.json --fail-on-drop` -> passes all layer, feature, and no-drop ratchet checks
- `cd functions && npm ci && npm run build && npm test` -> compiles (`tsc`) and passes all proxy unit tests
- `firebase emulators:exec --only firestore,storage "npm --prefix functions run test:rules"` -> passes all rules tests incl. `app_config` (`or mark NOT VERIFIED` if Firebase CLI / Java absent locally, verified in CI)
- `flutter build web --release --dart-define-from-file=config/production.json` + secret grep -> succeeds, zero keys leaked
- `flutter build web --wasm --dart-define-from-file=config/production.json` -> executed to record real Wasm status (`informational / non-blocking` in CI)
- `flutter build apk --release --split-per-abi --dart-define-from-file=config/production.json` -> succeeds, non-empty R8 `mapping.txt` verified
- `python scripts/check_perf_budgets.py --require-release-apk --require-web --require-r8-mapping` -> passes all budgets (`main.dart.js.gz <= 2.5 MB`, per-ABI release APK `<= 35.0 MB`)
- `gitleaks detect --source . --config .gitleaks.toml --no-banner` + `scripts/pre-commit-secrets-check.sh --ci-verify` -> 0 secrets
