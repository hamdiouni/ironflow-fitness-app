# Integration & E2E Tests

This directory holds device-targeted integration tests plus helper guidance for running IronFlow's end-to-end test suites.

## Automated Headless CI E2E Journey (`test/integration/`)

Fast, deterministic widget-router E2E journeys live under `test/integration/` so they run reliably in `flutter test` and GitHub Actions without requiring emulators or external network access:

- `test/integration/wave2_ui_navigation_e2e_test.dart`: verifies unauthenticated `/home -> /login -> /signup -> /onboarding -> /home`, telemetry opt-in modal (`KEEP ALL OFF` / default off persistence), and `MainApp` flavor badge isolation (`dev` / `staging` vs `production`).
- `test/integration/auth_preservation_property_test.dart`: auth regression/preservation checks.

Run them with:

```powershell
flutter test test/integration/
```

## Device / Emulator Integration Tests (`integration_test/`)

Device-level integration tests (requiring an Android emulator, iOS simulator, or ChromeDriver session) run with:

```powershell
flutter test integration_test/ --dart-define-from-file=config/dev.json
```

### Troubleshooting

- **"Box not open" errors**: Ensure `HiveManager.initialize()` / tier-1 box opens run in `setUpAll()` before pumping screens that read Hive directly.
- **Firebase errors in device runs**: Verify `firebase_options.dart` and `--dart-define-from-file=config/dev.json` are passed, or run Firebase Emulators (`firebase emulators:start`) when testing live auth/sync paths.
