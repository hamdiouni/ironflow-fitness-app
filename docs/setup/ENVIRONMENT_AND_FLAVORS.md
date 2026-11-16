# Environment & Flavors Guide

IronFlow separates **dev**, **staging**, and **production** environments using versioned `--dart-define-from-file` configs under `config/` paired with `.firebaserc` project aliases.

## 1. Flavor Matrix

| Flag / Setting | `config/dev.json` | `config/staging.json` | `config/production.json` |
| :--- | :--- | :--- | :--- |
| `FLAVOR` | `dev` | `staging` | `production` |
| `APP_NAME` | `IronFlow Dev` | `IronFlow Staging` | `IronFlow` |
| `FIREBASE_PROJECT_ID` | `ironflow-dev` | `ironflow-staging` | `ironflow-5b79d` |
| `AI_PROXY_URL` | `http://127.0.0.1:5001/ironflow-dev/us-central1/aiGenerate` | `https://us-central1-ironflow-staging.cloudfunctions.net/aiGenerate` | `https://us-central1-ironflow-5b79d.cloudfunctions.net/aiGenerate` |
| `ENFORCE_APP_CHECK` | `false` | `false` | `false` (monitor first; flip per rollout) |
| `ENABLE_CLOUD_SYNC` | `false` | `true` | `true` |
| `USE_FIREBASE_AUTH` | `false` | `true` | `true` |
| `ALLOW_DIRECT_AI_KEYS` | `true` (debug only) | `false` | `false` |

Additional optional defines resolved by `AppConfig` / `BuildStamp`:
- `RECAPTCHA_V3_SITE_KEY`: Web App Check reCAPTCHA v3 site key (`AppCheckService`).
- `GIT_COMMIT`: Git commit SHA surfaced in diagnostics & Crashlytics custom keys.
- `BUILD_DATE`: UTC ISO-8601 timestamp surfaced in diagnostics & Crashlytics custom keys.

## 2. Running Locally

### Mobile / Emulator (Dev Flavor)
```powershell
flutter run --dart-define-from-file=config/dev.json
```

### Web (Dev or Production Flavor)
```powershell
./scripts/run_web.ps1 -Flavor dev
./scripts/run_web.ps1 -Flavor production
```

## 3. Release & Security Invariants

1. `FlavorConfig.resolve(...)` enforces that **`kReleaseMode` builds always disable local mock auth (`useFirebaseAuth = true`)** and never emit a debug `DEV`/`STAGING` banner in production.
2. `AppConfig.allowDirectAiApiKeys` evaluates to `false` in release and staging builds; AI requests route through `AI_PROXY_URL` (`functions/src/index.ts` -> `aiGenerate`).
3. `/design-preview` and `/design-gallery` routes return to `home` when `kReleaseMode` is `true` (`lib/core/router/app_router.dart`).
4. Analytics and Crashlytics stay **OFF by default** until the user explicitly grants consent in `TelemetryConsentScreen` or `PrivacySettingsScreen` (`TelemetryPreferences`).
