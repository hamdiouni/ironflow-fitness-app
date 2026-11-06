# Changelog

All notable changes to **IronFlow** (`progression_tracker`) are documented in this file.
This project follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html) (`MAJOR.MINOR.PATCH+BUILD_NUMBER`).

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
