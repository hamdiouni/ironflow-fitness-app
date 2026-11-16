# ADR-005: Observability, Crash Reporting, Analytics & Remote Kill Switches

- **Status**: Accepted & Implemented (Wave 2.5)
- **Date**: 2026-11-17
- **Wave**: Wave 2.5

## 1. Problem

IronFlow needs production crash reporting, structured diagnostics, timed boot/critical-path spans, opt-in product analytics, and server-side kill switches (`kill_ai_coach`, `kill_cloud_sync`, `kill_body_map`, `maintenance_mode`, `max_daily_ai_requests`) before client handoff. At the same time:
- Wave 1.5 privacy rules mandate that Analytics and Crashlytics stay **OFF by default** until the user explicitly opts in via `TelemetryConsentScreen` or `PrivacySettingsScreen`.
- Sensitive health/auth strings (emails, JWTs, bearer tokens, raw meal/body/workout records) must never leak into logs or crash keys.
- Wave 2 keeps dependency bloat and boot latency low (`0` new client runtime Dart packages).

## 2. Options Considered

| Option | Description | Pros | Cons / Cost |
| :--- | :--- | :--- | :--- |
| **Option A: Existing FlutterFire (`firebase_crashlytics`, `firebase_analytics`, `cloud_firestore` `app_config/feature_flags`) + `ObservabilityService` + Gradle Crashlytics plugin** | Use `firebase_crashlytics` (`^4.1.3`, resolved `4.3.10`), `firebase_analytics` (`^11.3.3`, resolved `11.6.0`), and `cloud_firestore` (`^5.0.0`) already in `pubspec.yaml`; cache remote flags in `shared_preferences`; scrub PII & track spans in `ObservabilityService`; apply build-time `com.google.firebase.crashlytics` (`3.0.6`) Gradle plugin for Android R8 symbol/mapping upload. | Zero new Dart runtime dependencies; reuses Firestore rules (`isAdmin()` writes) and offline cache; respects `TelemetryPreferences` opt-in gate; immediate emergency kill switch without app store review. | Requires 1 Firestore read on app boot when Firebase is initialized (`app_config/feature_flags`), with offline cache fallback; Crashlytics remains native-only (`!kIsWeb`). |
| **Option B: Add `firebase_remote_config` + `firebase_performance` (or Sentry)** | Add Firebase Remote Config SDK (`latest 6.5.6`, `BSD-3-Clause`), Firebase Performance Monitoring SDK, or third-party Sentry SDK for spans and feature toggles. | Built-in percentage rollouts, A/B testing, and automatic network trace instrumentation. | Adds additional native/web plugin weight, increases cold-start initialization complexity, introduces another dashboard/vendor or config pipeline, and adds build-time dependency churn. |

## 3. Recommendation & Implemented Architecture

Adopt **Option A**:

1. **Structured Observability & PII Scrubbing (`lib/core/services/observability_service.dart`, `lib/core/providers/observability_provider.dart`, `lib/main.dart`)**:
   - Captures `FlutterError.onError`, `PlatformDispatcher.instance.onError`, and `runZonedGuarded` top-level exceptions through `ObservabilityService.recordError`.
   - Attaches `BuildStamp.current.asMetadataMap()` (`flavor`, `environment`, `gitCommit`, `buildDate`) and scrubs emails, bearer tokens, JWTs, and API keys before dispatching to sinks.
   - Dispatches crashes to `FirebaseCrashlytics.instance` (`!kIsWeb && Firebase.apps.isNotEmpty`) and analytics events to `FirebaseAnalytics.instance` (`Firebase.apps.isNotEmpty`) **only** when `TelemetryPreferences` opt-in is enabled.
   - Records timed spans (`startSpan(name).finish()`, e.g., `app.boot`) and buffered ring-buffer breadcrumbs in memory.
2. **Remote Kill Switches & Config (`lib/core/services/feature_flags_service.dart`, `firestore.rules`)**:
   - Reads public read-only document `app_config/feature_flags` (`allow read: if true; allow write: if isAdmin();` enforced in `firestore.rules` and emulator tests) after `Firebase.initializeApp`, persisting the last-known snapshot to `SharedPreferences` for offline cold starts.
   - Gates `geminiAIServiceProvider` (`GeminiAIService` throws typed `FEATURE_DISABLED` before issuing network requests when `isAiCoachActive` is `false`) and `syncEnabledProvider`.
3. **Android Mapping / Symbol Upload (`android/settings.gradle.kts`, `android/app/build.gradle.kts`)**:
   - Applies build-time Gradle plugin `com.google.firebase.crashlytics` version `3.0.6` (verified compatible with AGP `8.11.1` and `com.google.gms.google-services` `4.4.2`).

## 4. Package Metadata, Cost, Risk & Rollback

- **Packages & Licenses (verified in `pubspec.lock` / `pub.dev` / Maven)**:
  - `firebase_crashlytics` (`4.3.10`, `BSD-3-Clause`) — already present in `pubspec.yaml`.
  - `firebase_analytics` (`11.6.0`, `BSD-3-Clause`) — already present in `pubspec.yaml`.
  - `com.google.firebase:firebase-crashlytics-gradle` (`3.0.6`, released `2025-08-07`, `Apache-2.0`) — build-time Android Gradle plugin only.
- **App Binary Impact**: **`+0 KB`** Dart dependency delta (no new client runtime plugins added; Gradle plugin affects only R8 mapping upload during release builds).
- **Monetary Cost**: **\$0** incremental tooling cost (Crashlytics and Analytics are free-tier Firebase products; `app_config/feature_flags` adds at most 1 Firestore document read per cold start when online).
- **Risks**:
  - Misconfigured admin `app_config/feature_flags` document could set `maintenance_mode: true` or `kill_*: true` globally; mitigated by explicit defaults (`false` kill switches) and `isAdmin()` Firestore write restriction.
  - Web builds skip `FirebaseCrashlytics.instance` (`!kIsWeb`) and capture Web diagnostics via `ObservabilityService` ring logs + zoned error hooks.
- **Rollback**:
  - Remote flags: delete or revert fields on `app_config/feature_flags` (`kill_ai_coach`, `kill_cloud_sync`, `kill_body_map`, `maintenance_mode`).
  - Native Crashlytics plugin: remove `id("com.google.firebase.crashlytics")` from `android/settings.gradle.kts` and `android/app/build.gradle.kts`.
