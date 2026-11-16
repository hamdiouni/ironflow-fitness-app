# Release Engineering & Signing Guide

This guide describes IronFlow's build flavors, compilation defines, Android R8 release verification, Web builds, and Crashlytics mapping symbol upload.

## 1. Environment Configuration Files

All build targets inject flavor configuration via `--dart-define-from-file`:

- **Development**: `config/dev.json` (`FLAVOR=dev`, `FIREBASE_PROJECT_ID=ironflow-dev`, `USE_FIREBASE_AUTH=false`, `ENABLE_CLOUD_SYNC=false`, `ALLOW_DIRECT_AI_KEYS=true` debug-only)
- **Staging**: `config/staging.json` (`FLAVOR=staging`, `FIREBASE_PROJECT_ID=ironflow-staging`, `USE_FIREBASE_AUTH=true`, `ENABLE_CLOUD_SYNC=true`, `ALLOW_DIRECT_AI_KEYS=false`)
- **Production**: `config/production.json` (`FLAVOR=production`, `FIREBASE_PROJECT_ID=ironflow-5b79d`, `USE_FIREBASE_AUTH=true`, `ENABLE_CLOUD_SYNC=true`, `ALLOW_DIRECT_AI_KEYS=false`)

Pass optional build-stamp metadata in release CI builds:
```bash
--dart-define=GIT_COMMIT=$(git rev-parse --short HEAD) \
--dart-define=BUILD_DATE=$(date -u +%Y-%m-%dT%H:%M:%SZ)
```

Runtime flavor behavior is resolved in `lib/core/config/flavor_config.dart` and surfaced via `BuildStamp` (`lib/core/config/build_stamp.dart`). Production release builds refuse mock auth (`useFirebaseAuth == false`) and direct AI keys.

## 2. Android Release Build & R8 Verification

`android/app/build.gradle.kts` enables R8 code shrinking (`isMinifyEnabled = true`), resource shrinking (`isShrinkResources = true`), and ProGuard keep rules (`android/app/proguard-rules.pro`). It also applies `com.google.firebase.crashlytics` (`3.0.6` in `android/settings.gradle.kts`) to upload obfuscation mapping files on Firebase-connected builds.

### Build Split-ABI Release APKs
```powershell
flutter build apk --release --split-per-abi `
  --dart-define-from-file=config/production.json `
  --dart-define=GIT_COMMIT=<sha> `
  --dart-define=BUILD_DATE=<iso8601>
```

### Build Play Store App Bundle (AAB)
```powershell
flutter build appbundle --release `
  --dart-define-from-file=config/production.json `
  --dart-define=GIT_COMMIT=<sha> `
  --dart-define=BUILD_DATE=<iso8601>
```

### Android Signing Note
In CI, without `android/key.properties`, Android falls back to the debug signing key so R8 shrinking, resource shrinking, `mapping.txt` emission, and size budgets can still be verified on every commit. **For Play Store / production distribution**, configure `android/key.properties` and a release upload keystore outside version control (`key.properties` and `*.jks`/`*.keystore` must stay untracked in `.gitignore`).

### Verify Size & R8 Mapping Budgets
```bash
python scripts/check_perf_budgets.py --require-release-apk --require-r8-mapping
```

## 3. Web Build (JS Primary + Informational Wasm)

```powershell
# Primary production JS build (checked in CI against size and zero-secret budgets)
flutter build web --release --dart-define-from-file=config/production.json

# Informational Wasm dry-run (non-blocking in Wave 2 CI)
flutter build web --wasm --dart-define-from-file=config/production.json
```

Validate Web size budgets:
```bash
python scripts/check_perf_budgets.py --require-web --require-release-apk --require-r8-mapping
```

Hosting headers (`firebase.json`):
- `Cross-Origin-Opener-Policy: same-origin-allow-popups` (keeps Google Sign-In popup flows working)
- `Cross-Origin-Resource-Policy: cross-origin`
- No `COEP: require-corp` header (would break YouTube `<iframe>` player embeds and third-party image assets)
- `/generate` rewrite routes to the `aiGenerate` Cloud Function (`ironflow-5b79d`).

## 4. iOS Build Verification

`ios-compile-check` in `.github/workflows/ci.yml` compiles `--no-codesign` on `macos-latest` on `master` pushes and manual `workflow_dispatch` runs. App Store submission requires macOS Xcode signing & provisioning certificates managed by the client.
