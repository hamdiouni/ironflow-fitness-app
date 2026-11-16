# Store Release Checklist (Android & Web / iOS Handoff)

Use this checklist before shipping an IronFlow release candidate.

## 1. Automated CI Gates (`.github/workflows/ci.yml`)

- [ ] `secret-scan`: `gitleaks detect` returns 0 findings across git history and working tree.
- [ ] `cloud-functions-proxy`: `npm ci`, `npm run build` (`tsc`), and `npm test` pass under `functions/`.
- [ ] `firebase-emulator-rules`: `firebase emulators:exec --only firestore,storage "npm --prefix functions run test:rules"` passes all Firestore & Storage owner isolation, validation, and delete tests.
- [ ] `flutter-verify`:
  - `flutter analyze --no-fatal-infos` exits 0 with zero warnings/errors.
  - `flutter test --coverage` passes 100% of unit, characterization, navigation E2E, and widget tests.
  - `python3 scripts/check_coverage.py coverage/lcov.info --baseline docs/quality/coverage_baseline.json --fail-on-drop` exits 0 (no regressions; meets Wave 2 area floors toward 75% overall goal).
  - `flutter build web --release --dart-define-from-file=config/production.json` succeeds and contains zero leaked key strings in `build/web/`.
  - `flutter build apk --release --split-per-abi --dart-define-from-file=config/production.json` succeeds with R8 `mapping.txt` generated.
  - `python3 scripts/check_perf_budgets.py --require-release-apk --require-web --require-r8-mapping` passes size & R8 verification.
- [ ] `ios-compile-check`: `flutter build ios --release --no-codesign --dart-define-from-file=config/production.json` compiles cleanly on `macos-latest` (`master` / `workflow_dispatch`).

## 2. Security, Privacy & Telemetry

- [ ] Release flavor config (`config/production.json`) uses Firebase project `ironflow-5b79d`, `USE_FIREBASE_AUTH: true`, `ENABLE_CLOUD_SYNC: true`, and `ALLOW_DIRECT_AI_KEYS: false`.
- [ ] Analytics and Crashlytics default to **OFF** (`TelemetryPreferences`); explicit opt-in modal (`TelemetryConsentScreen`) is presented after onboarding.
- [ ] Notification permissions are requested in context (never forced on cold app launch).
- [ ] `/design-preview` and `/design-gallery` routes remain unreachable in release builds (`kReleaseMode`).
- [ ] Account deletion completes local wipe + Firestore recursive subcollection cleanup + Storage folder deletion (`users/{uid}/ai_usage` excluded from direct client write and purged cleanly).

## 3. Manual Pre-Submission Checks (On Physical Devices / Managed Accounts)

- [ ] **Android Signing**: Release upload keystore configured via `android/key.properties` (never committed to git); signed `.aab` tested on physical Android device via internal track.
- [ ] **Google Sign-In / Auth**: Verify SHA-1 & SHA-256 Play App Signing fingerprints are registered in Firebase Console (`ironflow-5b79d`) and Web Google Sign-In popup works under `Cross-Origin-Opener-Policy: same-origin-allow-popups`.
- [ ] **Emergency Kill Switch Drill**: Verify `app_config/feature_flags` (`kill_ai_coach`, `kill_cloud_sync`, `maintenance_mode`) toggles safely in staging Firebase (`ironflow-staging`) before store release.
- [ ] **Google Play Data Safety & Privacy Policy**: Disclose optional opt-in Crashlytics/Analytics and Firebase cloud sync accurately in Play Console & App Store Connect.
