import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Applies the user's stored telemetry choices to Firebase SDKs.
///
/// The Privacy screen has long persisted `analytics_enabled` and
/// `crash_reporting_enabled`, but startup previously ignored those values
/// and enabled collection solely from `!kDebugMode`. This service is the
/// single bridge between the stored opt-outs and the Firebase SDK
/// collection switches:
///
/// - Debug builds never collect, regardless of preference.
/// - Profile/release builds collect only when the corresponding stored
///   preference is enabled (existing default: enabled, matching the
///   Privacy screen's historical default and store disclosure).
/// - Toggling a preference should call [applyStoredPreferences] so the
///   change takes effect immediately, not only on next launch.
class TelemetryPreferences {
  const TelemetryPreferences._();

  static const String analyticsEnabledKey = 'analytics_enabled';
  static const String crashReportingEnabledKey = 'crash_reporting_enabled';

  static Future<bool> analyticsEnabled([SharedPreferences? prefs]) async {
    final store = prefs ?? await SharedPreferences.getInstance();
    return store.getBool(analyticsEnabledKey) ?? true;
  }

  static Future<bool> crashReportingEnabled([
    SharedPreferences? prefs,
  ]) async {
    final store = prefs ?? await SharedPreferences.getInstance();
    return store.getBool(crashReportingEnabledKey) ?? true;
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
