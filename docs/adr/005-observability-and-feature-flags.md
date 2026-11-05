# ADR-005: Observability, Consent-Gated Telemetry, and Feature Flags

- **Status**: Proposed (Awaiting Owner Approval before Wave 2.7)
- **Date**: 2026-11-05
- **Wave**: Wave 2.7

## 1. Problem
1. `TelemetryPreferences` currently defaults `analytics_enabled` and `crash_reporting_enabled` to `true` (opt-out) instead of `false` (opt-in consent).
2. `firebase_crashlytics` is in `pubspec.yaml`, but the Android Gradle plugin (`com.google.firebase.crashlytics`) is missing.
3. There is no remote feature-flag or kill-switch mechanism to disable `cloud_sync` or `ai_proxy` in production without shipping an app update.

## 2. Options Considered

| Option | Description | Pros | Cons |
| :--- | :--- | :--- | :--- |
| **Option A: Firestore Public Config Document (`app_config/flags`) + Local Cached Defaults (Zero new packages)** | Read a single public read-only/admin-write Firestore document (`app_config/runtime_flags`) with a 1-hour local TTL cache (`SharedPreferences`) and compile-time defaults (`cloud_sync_enabled`, `ai_proxy_enabled`, `body_map_enabled`, `min_supported_version`). | **0 new dependencies** (uses existing `cloud_firestore` and `shared_preferences`); works identically on Android, iOS, and Web; instant kill-switch updates in Firebase Console. | 1 Firestore document read per user per hour when online. |
| **Option B: Add `firebase_remote_config` + `firebase_performance`** | Add official Firebase Remote Config and Performance Monitoring SDKs. | Native Firebase Console UI for percentage rollouts and A/B tests. | Adds 2 new native Firebase SDKs (~1.5 MB APK size impact). |

## 3. Recommendation
- **Option A (`app_config/runtime_flags` + local defaults)** for zero-dependency feature flags and kill switches, OR **Option B** if the Owner wants Firebase Performance Monitoring traces in the Firebase Console.
- Flip `TelemetryPreferences` defaults to **`false` (strict opt-in consent)** and disable auto-initialization in `AndroidManifest.xml` / `Info.plist`.
