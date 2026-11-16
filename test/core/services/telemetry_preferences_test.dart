import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:progression_tracker/core/constants/app_theme.dart';
import 'package:progression_tracker/core/services/analytics_service.dart';
import 'package:progression_tracker/core/services/telemetry_preferences.dart';
import 'package:progression_tracker/core/widgets/telemetry_consent_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _SpyFirebaseAnalytics extends Fake implements FirebaseAnalytics {
  final List<String> calls = <String>[];

  @override
  Future<void> logEvent({
    required String name,
    Map<String, Object>? parameters,
    AnalyticsCallOptions? callOptions,
  }) async {
    calls.add('logEvent:$name');
  }

  @override
  Future<void> logSignUp({
    required String signUpMethod,
    Map<String, Object>? parameters,
  }) async {
    calls.add('logSignUp:$signUpMethod');
  }

  @override
  Future<void> logLogin({
    String? loginMethod,
    Map<String, Object>? parameters,
    AnalyticsCallOptions? callOptions,
  }) async {
    calls.add('logLogin:$loginMethod');
  }

  @override
  Future<void> logScreenView({
    String? screenClass,
    String? screenName,
    Map<String, Object>? parameters,
    AnalyticsCallOptions? callOptions,
  }) async {
    calls.add('logScreenView:$screenName');
  }

  @override
  Future<void> setUserId({
    String? id,
    AnalyticsCallOptions? callOptions,
  }) async {
    calls.add('setUserId:$id');
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('TelemetryPreferences', () {
    test('unconfigured installs default to OFF (disabled) until explicit consent',
        () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      expect(await TelemetryPreferences.analyticsEnabled(prefs), isFalse);
      expect(
        await TelemetryPreferences.crashReportingEnabled(prefs),
        isFalse,
      );
      expect(await TelemetryPreferences.hasShownConsentPrompt(prefs), isFalse);
    });

    test('recordConsentDecision persists opt-in choices and marks consent prompt shown',
        () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      await TelemetryPreferences.recordConsentDecision(
        analyticsEnabled: true,
        crashReportingEnabled: true,
        prefs: prefs,
      );

      expect(await TelemetryPreferences.analyticsEnabled(prefs), isTrue);
      expect(await TelemetryPreferences.crashReportingEnabled(prefs), isTrue);
      expect(await TelemetryPreferences.hasShownConsentPrompt(prefs), isTrue);
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

    test('AnalyticsService skips Firebase Analytics calls when analytics preference is false and logs when true', () async {
      final spy = _SpyFirebaseAnalytics();
      var enabled = false;
      final service = AnalyticsService.forTesting(
        analytics: spy,
        isAnalyticsEnabled: () async => enabled,
      );

      await service.logAppOpened();
      await service.logSignUp('email');
      await service.logLogin('email');
      await service.logScreenView(screenName: 'Home');
      await service.setUserId('uid_1');
      expect(spy.calls, isEmpty);

      enabled = true;
      await service.logAppOpened();
      await service.logSignUp('email');
      await service.logLogin('email');
      await service.logScreenView(screenName: 'Home');
      await service.setUserId('uid_1');
      expect(
        spy.calls,
        <String>[
          'logEvent:app_opened',
          'logSignUp:email',
          'logLogin:email',
          'logScreenView:Home',
          'setUserId:uid_1',
        ],
      );
    });

    testWidgets('TelemetryConsentScreen.showIfNeeded prompts once and remembers decision', (tester) async {
      SharedPreferences.setMockInitialValues({});

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark().copyWith(
            extensions: [AppThemeTokens.dark],
          ),
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () => TelemetryConsentScreen.showIfNeeded(context),
                child: const Text('OPEN CONSENT'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('OPEN CONSENT'));
      await tester.pumpAndSettle();

      expect(find.text('Privacy & Diagnostics Consent'), findsOneWidget);
      await tester.tap(find.text('KEEP ALL OFF'));
      await tester.pumpAndSettle();

      expect(find.text('Privacy & Diagnostics Consent'), findsNothing);
      expect(await TelemetryPreferences.hasShownConsentPrompt(), isTrue);

      // Re-invoking showIfNeeded after choice is recorded stays suppressed
      await tester.tap(find.text('OPEN CONSENT'));
      await tester.pumpAndSettle();
      expect(find.text('Privacy & Diagnostics Consent'), findsNothing);
    });
  });
}
