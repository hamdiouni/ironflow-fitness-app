# ADR-005: Observability, Consent-Gated Telemetry, and Remote Feature Flags / Kill Switches

## Status
Accepted (Wave 2.7 — 2026-11-06)

## Context
To sell and operate IronFlow in production with confidence, the application needs:
1. **Structured Logging with Levels & PII Scrubbing**: Raw `debugPrint` calls do not carry severity levels, structured context, or automatic redaction of emails, tokens, or API keys.
2. **Consent-Gated Crash & Analytics Reporting**: Per Wave 1 privacy rules (`PRV-01`), Analytics and Crashlytics must default to `false` (opt-in only) and never transmit in debug builds.
3. **Performance Spans**: Critical operations (cold start, Hive box migration, workout save, sync cycle, AI proxy round-trip) need lightweight latency spans without adding new native SDK dependencies.
4. **Remote Feature Flags & Emergency Kill Switches**: The operator must be able to disable the AI Coach (`kill_ai_coach`), pause Cloud Sync (`kill_cloud_sync`), or enable Maintenance Mode (`maintenance_mode`) remotely without requiring a new store binary or adding a new pub package.

## Decision
1. **`ObservabilityService` (`lib/core/services/observability_service.dart`)**:
   - Implements structured logging with 5 severity levels (`debug`, `info`, `warning`, `error`, `critical`) and a bounded 200-entry in-memory ring buffer for local diagnostics.
   - Scrubs all messages, context maps, and error strings via `ObservabilityService.scrubSensitiveText` (redacting email addresses, `Bearer` tokens, Google `AIza...` keys, and `nvapi-...` keys) before storing or forwarding.
   - Enforces strict opt-in consent gating: crash reports are forwarded to the crash sink (`FirebaseCrashlytics`) only when `isCrashReportingAllowed()` is `true`, and analytics events are forwarded to the analytics sink (`FirebaseAnalytics`) only when `isAnalyticsAllowed()` is `true`.
   - Provides `startSpan` and `traceAsync` to measure operation latency in milliseconds and flag slow operations (`>= 500ms`).
2. **`FeatureFlagsService` (`lib/core/services/feature_flags_service.dart`)**:
   - Uses existing `SharedPreferences` for offline-first persistence and an injectable remote JSON/Firestore document fetcher (`app_config/feature_flags`) so zero new pub packages are required.
   - Supports kill switches (`kill_ai_coach`, `kill_cloud_sync`, `maintenance_mode`) that take precedence over feature flags (`ai_coach_enabled`, `cloud_sync_enabled`, `body_map_enabled`).

## Consequences
- **Positive**: Zero new third-party dependencies; 100% deterministic unit testability via injectable sinks and fetchers; strict GDPR/App Store privacy compliance; instant operational kill switches for cloud-cost-bearing features (AI proxy and Firestore sync).
- **Negative**: Firestore-backed remote config polling happens on app launch / foreground refresh rather than push websockets, which is sufficient for kill-switch and feature-flag cadences.

