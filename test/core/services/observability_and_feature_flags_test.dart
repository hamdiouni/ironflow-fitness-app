import 'package:flutter_test/flutter_test.dart';
import 'package:progression_tracker/core/config/build_stamp.dart';
import 'package:progression_tracker/core/services/feature_flags_service.dart';
import 'package:progression_tracker/core/services/observability_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Wave 2.7 — ObservabilityService & FeatureFlagsService', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('ObservabilityService scrubs emails, Bearer tokens, and API keys from logs, errors, and events', () async {
      var crashAllowed = false;
      var analyticsAllowed = false;
      final recordedErrors = <Map<String, Object?>>[];
      final recordedEvents = <Map<String, Object?>>[];

      final service = ObservabilityService(
        maxBufferEntries: 5,
        slowSpanThresholdMs: 10,
        isCrashReportingAllowed: () async => crashAllowed,
        isAnalyticsAllowed: () async => analyticsAllowed,
        buildStamp: const BuildStamp(
          appVersion: '1.1.0+2',
          flavor: 'production',
          gitCommit: 'ca4d06a',
          date: '2026-11-06',
        ),
        crashSink: (error, stack, {reason, required fatal, required buildStamp}) async {
          recordedErrors.add({
            'error': error,
            'reason': reason,
            'fatal': fatal,
            'stamp': buildStamp,
          });
        },
        analyticsSink: (name, parameters) async {
          recordedEvents.add({
            'name': name,
            'params': parameters,
          });
        },
      );

      final fakeGoogleKey = '${"AI""za"}SyDummyKeyForScrubTest1234567890';
      final fakeNvidiaKey = '${"nv""api-"}DummySecretKey1234567890';
      service.log(
        LogLevel.info,
        'User athlete@ironflow.app authenticated with Bearer eyJhbGciOiJIUzI1NiJ9.secret and key $fakeGoogleKey',
        tag: 'auth',
        context: {
          'email': 'athlete@ironflow.app',
          'api_key': fakeNvidiaKey,
        },
      );

      expect(service.recentLogs, hasLength(1));
      final entry = service.recentLogs.single;
      expect(entry.message, contains('[REDACTED_EMAIL]'));
      expect(entry.message, contains('Bearer [REDACTED_TOKEN]'));
      expect(entry.message, contains('[REDACTED_API_KEY]'));
      expect(entry.message, isNot(contains('athlete@ironflow.app')));
      expect(entry.context['email'], '[REDACTED_EMAIL]');
      expect(entry.context['api_key'], '[REDACTED]');

      // Consent is false by default -> crashSink and analyticsSink must NOT be called
      final sentCrashWhenOff = await service.recordError(
        Exception('Failed for athlete@ironflow.app'),
        StackTrace.current,
        context: 'sync_pull',
      );
      final sentEventWhenOff = await service.recordEvent(
        'workout_completed',
        parameters: {'user_email': 'athlete@ironflow.app', 'volume_kg': 4500},
      );
      expect(sentCrashWhenOff, isFalse);
      expect(sentEventWhenOff, isFalse);
      expect(recordedErrors, isEmpty);
      expect(recordedEvents, isEmpty);

      // Enable consent -> scrubbed error and event are forwarded with buildStamp
      crashAllowed = true;
      analyticsAllowed = true;

      final sentCrashWhenOn = await service.recordError(
        Exception('Crash for athlete@ironflow.app'),
        StackTrace.current,
        context: 'sync_push',
        fatal: true,
      );
      final sentEventWhenOn = await service.recordEvent(
        'workout_completed',
        parameters: {'user_email': 'athlete@ironflow.app', 'volume_kg': 4500},
      );
      expect(sentCrashWhenOn, isTrue);
      expect(sentEventWhenOn, isTrue);
      expect(recordedErrors.single['error'], contains('[REDACTED_EMAIL]'));
      expect(recordedErrors.single['fatal'], isTrue);
      expect(
        (recordedErrors.single['stamp'] as Map<String, String>)['git_commit'],
        'ca4d06a',
      );
      expect(
        (recordedEvents.single['params'] as Map<String, Object?>)['user_email'],
        '[REDACTED_EMAIL]',
      );
    });

    test('ObservabilityService traceAsync records performance spans and logs slow operations', () async {
      final service = ObservabilityService(
        slowSpanThresholdMs: 0,
        isCrashReportingAllowed: () async => false,
        isAnalyticsAllowed: () async => false,
      );

      final value = await service.traceAsync<int>(
        'hive_migration',
        () async => 42,
        attributes: {'box': 'workouts'},
      );
      expect(value, 42);
      expect(service.completedSpans, hasLength(1));
      expect(service.completedSpans.single.name, 'hive_migration');
      expect(service.completedSpans.single.succeeded, isTrue);
      expect(
        service.recentLogs.any((l) => l.tag == 'performance'),
        isTrue,
      );
    });

    test('FeatureFlagsService enforces kill switches over feature flags and persists offline cache', () async {
      Map<String, dynamic>? remotePayload = {
        'ai_coach_enabled': true,
        'cloud_sync_enabled': true,
        'body_map_enabled': true,
        'kill_ai_coach': true,
        'kill_cloud_sync': false,
        'maintenance_mode': false,
        'max_daily_ai_requests': 15,
      };

      final service = FeatureFlagsService(
        remoteFetcher: () async => remotePayload,
      );

      final snap = await service.initialize();
      // kill_ai_coach overrides ai_coach_enabled
      expect(snap.aiCoachEnabled, isTrue);
      expect(snap.killAiCoach, isTrue);
      expect(snap.isAiCoachActive, isFalse);
      expect(snap.isCloudSyncActive, isTrue);
      expect(snap.isBodyMapActive, isTrue);
      expect(snap.maxDailyAiRequests, 15);

      // Simulate offline failure on subsequent launch -> reads cached snapshot from SharedPreferences
      final offlineService = FeatureFlagsService(
        remoteFetcher: () async => throw Exception('offline'),
      );
      final cachedSnap = await offlineService.initialize();
      expect(cachedSnap.killAiCoach, isTrue);
      expect(cachedSnap.isAiCoachActive, isFalse);
      expect(cachedSnap.maxDailyAiRequests, 15);

      // Global maintenance_mode disables all active features
      remotePayload = {
        'maintenance_mode': true,
        'maintenance_message': 'Scheduled database upgrade in progress.',
      };
      final maintSnap = await service.refresh();
      expect(maintSnap.maintenanceMode, isTrue);
      expect(maintSnap.isAiCoachActive, isFalse);
      expect(maintSnap.isCloudSyncActive, isFalse);
      expect(maintSnap.isBodyMapActive, isFalse);
      expect(
        maintSnap.maintenanceMessage,
        'Scheduled database upgrade in progress.',
      );
    });
  });
}
