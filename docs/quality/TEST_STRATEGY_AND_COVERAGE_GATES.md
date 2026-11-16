# Test Strategy & Coverage Gates (Wave 2)

This document defines IronFlow's automated test layers, Wave 2 quality floors, monotonic coverage ratchet, and release verification gates.

## 1. Test Pyramid & Suites

- **Unit & Domain Tests (`test/**/domain/**`, `test/core/**`)**: verify entities, use cases, validation, retry helpers, PII redaction, and feature-flag precedence (`--min-domain` floor `77.0%`).
- **Data & Sync Characterization Tests (`test/features/sync/**`, `test/**/data/**`)**: verify Hive encryption recovery, sync queue retry resets, remote delete tombstones, and cache upserts (`--min-data` floor `66.0%`).
- **Thin-Area Characterization Tests (`Wave 2.2`)**: deterministic offline tests for `auth` (`signup_screen_characterization_test.dart`), `sync` (`sync_provider_and_indicator_test.dart`), `notifications` (`notification_service_characterization_test.dart`), `settings` (`import_program_use_case_test.dart`, `backup_data_use_case_and_dialogs_test.dart`), `onboarding` (`onboarding_steps_characterization_test.dart`), and `main.dart` / `core` (`main_scaffold_and_boot_test.dart`, `error_handler_and_sampler_test.dart`).
- **Headless E2E & Golden Tests (`Wave 2.4`)**:
  - `test/integration/wave2_ui_navigation_e2e_test.dart`: verifies router redirects, signup -> onboarding -> home, default-OFF telemetry consent persistence, and flavor banner behavior.
  - `test/design_system/design_system_goldens_test.dart`: visual design-system token goldens (with platform-matched CI font rendering notes; run Linux tolerance verification cleanly in GitHub Actions).
- **Cloud Functions & Firebase Rules Tests (`functions/test/`, `test/rules/`)**: Node `node:test` suites verifying ID token & App Check checks, quota transactions/refunds, Firestore ownership rules, and Storage backup limits via Firebase Emulator Suite.

## 2. Monotonic Coverage Ratchet & Approved Floors (`docs/quality/coverage_baseline.json`)

Coverage is gated by `scripts/check_coverage.py coverage/lcov.info --baseline docs/quality/coverage_baseline.json --fail-on-drop`:
- **Overall Goal vs Wave 2 Gate**: **75.0%** long-term target (non-blocking until reached); Wave 2 measured baseline is **68.45%** (`20,424 / 29,836` lines across `378` LCOV-tracked non-generated files; `unimported_non_gen_files = 104` tracked transparently).
- **Zero-Drop Ratchet**: `max_drop_pct = 0.0` (CI fails on any coverage regression in overall, any architectural layer, or any tracked feature).
- **Wave 2 Minimum Floors**:
  - Overall: **`66.0%`** (measured `68.45%`)
  - Layers: `domain >= 77.0%` (`78.67%`), `data >= 66.0%` (`66.61%`), `core >= 67.0%` (`70.67%`), `presentation >= 61.0%` (`65.69%`), `shared >= 73.5%` (`75.03%`)
  - Tracked Thin Areas: `auth >= 52.0%` (`65.92%`), `settings >= 73.0%` (`80.69%`), `sync >= 55.0%` (`63.50%`), `notifications >= 58.0%` (`60.75%`), `onboarding >= 48.0%` (`71.14%`), `main.dart >= 45.0%` (`45.03%`)

## 3. Running Locally

```powershell
flutter analyze --no-fatal-infos
flutter test --coverage --timeout=60s
python scripts/check_coverage.py coverage/lcov.info --baseline docs/quality/coverage_baseline.json --fail-on-drop
```
