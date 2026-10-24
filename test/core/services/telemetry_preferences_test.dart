import 'package:flutter_test/flutter_test.dart';
import 'package:progression_tracker/core/services/telemetry_preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('TelemetryPreferences', () {
    test('stored opt-outs default to enabled for existing installs',
        () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      expect(await TelemetryPreferences.analyticsEnabled(prefs), isTrue);
      expect(
        await TelemetryPreferences.crashReportingEnabled(prefs),
        isTrue,
      );
    });

    test('stored opt-out values are read back', () async {
      SharedPreferences.setMockInitialValues({
        TelemetryPreferences.analyticsEnabledKey: false,
        TelemetryPreferences.crashReportingEnabledKey: false,
      });
      final prefs = await SharedPreferences.getInstance();

      expect(await TelemetryPreferences.analyticsEnabled(prefs), isFalse);
      expect(
        await TelemetryPreferences.crashReportingEnabled(prefs),
        isFalse,
      );
    });

    test('setters persist and tolerate Firebase being unavailable',
        () async {
      SharedPreferences.setMockInitialValues({});
      await TelemetryPreferences.setAnalyticsEnabled(false);
      await TelemetryPreferences.setCrashReportingEnabled(false);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool(TelemetryPreferences.analyticsEnabledKey), false);
      expect(
        prefs.getBool(TelemetryPreferences.crashReportingEnabledKey),
        false,
      );
    });

    test('debug builds never collect even when preferences are enabled', () {
      expect(
        TelemetryPreferences.effectiveAnalyticsCollectionEnabled(
          preferenceEnabled: true,
          isDebugMode: true,
        ),
        isFalse,
      );
      expect(
        TelemetryPreferences.effectiveCrashCollectionEnabled(
          preferenceEnabled: true,
          isDebugMode: true,
        ),
        isFalse,
      );
    });

    test('release collection requires an enabled preference', () {
      expect(
        TelemetryPreferences.effectiveAnalyticsCollectionEnabled(
          preferenceEnabled: true,
          isDebugMode: false,
        ),
        isTrue,
      );
      expect(
        TelemetryPreferences.effectiveAnalyticsCollectionEnabled(
          preferenceEnabled: false,
          isDebugMode: false,
        ),
        isFalse,
      );
      expect(
        TelemetryPreferences.effectiveCrashCollectionEnabled(
          preferenceEnabled: true,
          isDebugMode: false,
        ),
        isTrue,
      );
      expect(
        TelemetryPreferences.effectiveCrashCollectionEnabled(
          preferenceEnabled: false,
          isDebugMode: false,
        ),
        isFalse,
      );
    });
  });
}
