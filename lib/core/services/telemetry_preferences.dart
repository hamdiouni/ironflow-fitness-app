import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Applies the user's stored telemetry choices to Firebase SDKs.
///
/// Wave 1 Privacy Plumbing:
/// - Debug builds never collect, regardless of preference.
/// - Profile/release builds default to **OFF (`false`)** until the user
///   explicitly opts in via the Telemetry Consent screen or Privacy Settings.
/// - Toggling a preference or recording consent calls [applyStoredPreferences]
///   so the change takes effect immediately.
class TelemetryPreferences {
  const TelemetryPreferences._();

  static const String analyticsEnabledKey = 'analytics_enabled';
  static const String crashReportingEnabledKey = 'crash_reporting_enabled';
  static const String consentPromptShownKey = 'telemetry_consent_prompt_shown';

  static Future<bool> analyticsEnabled([SharedPreferences? prefs]) async {
    final store = prefs ?? await SharedPreferences.getInstance();
    return store.getBool(analyticsEnabledKey) ?? false;
  }

  static Future<bool> crashReportingEnabled([
    SharedPreferences? prefs,
  ]) async {
    final store = prefs ?? await SharedPreferences.getInstance();
    return store.getBool(crashReportingEnabledKey) ?? false;
  }

  static Future<bool> hasShownConsentPrompt([SharedPreferences? prefs]) async {
    final store = prefs ?? await SharedPreferences.getInstance();
    return store.getBool(consentPromptShownKey) ?? false;
  }

  /// Records the user's explicit telemetry consent choice and applies it
  /// immediately to the Firebase SDKs.
  static Future<void> recordConsentDecision({
    required bool analyticsEnabled,
    required bool crashReportingEnabled,
    SharedPreferences? prefs,
  }) async {
    final store = prefs ?? await SharedPreferences.getInstance();
    await store.setBool(analyticsEnabledKey, analyticsEnabled);
    await store.setBool(crashReportingEnabledKey, crashReportingEnabled);
    await store.setBool(consentPromptShownKey, true);
    await applyStoredPreferences(prefs: store);
  }

  /// Pure policy: debug builds never collect analytics.
  static bool effectiveAnalyticsCollectionEnabled({
    required bool preferenceEnabled,
    required bool isDebugMode,
  }) {
    return preferenceEnabled && !isDebugMode;
  }

  /// Pure policy: debug builds never collect crash reports.
  static bool effectiveCrashCollectionEnabled({
    required bool preferenceEnabled,
    required bool isDebugMode,
  }) {
    return preferenceEnabled && !isDebugMode;
  }

  static Future<void> setAnalyticsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(analyticsEnabledKey, enabled);
    await applyStoredPreferences(prefs: prefs);
  }

  static Future<void> setCrashReportingEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(crashReportingEnabledKey, enabled);
    await applyStoredPreferences(prefs: prefs);
  }

  /// Applies stored preferences to Firebase Analytics/Crashlytics.
  ///
  /// Safe to call when Firebase is unavailable (tests, unsupported
  /// platforms): failures are swallowed because telemetry must never block
  /// app startup or a settings toggle.
  static Future<void> applyStoredPreferences({
    SharedPreferences? prefs,
  }) async {
    try {
      if (Firebase.apps.isEmpty) return;

      await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(
        effectiveAnalyticsCollectionEnabled(
          preferenceEnabled: await analyticsEnabled(prefs),
          isDebugMode: kDebugMode,
        ),
      );

      if (!kIsWeb) {
        await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(
          effectiveCrashCollectionEnabled(
            preferenceEnabled: await crashReportingEnabled(prefs),
            isDebugMode: kDebugMode,
          ),
        );
      }
    } catch (_) {
      // Telemetry is optional infrastructure; never fail the caller.
    }
  }
}
