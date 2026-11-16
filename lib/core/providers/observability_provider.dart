import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/build_stamp.dart';
import '../services/feature_flags_service.dart';
import '../services/observability_service.dart';

/// Builds the default [ObservabilityService] backed by Firebase Crashlytics and
/// Analytics when Firebase is initialized and user opt-in consent is granted.
ObservabilityService createRuntimeObservabilityService({
  BuildStamp? buildStamp,
}) {
  return ObservabilityService(
    buildStamp: buildStamp ?? BuildStamp.current,
    crashSink: (
      error,
      stackTrace, {
      String? reason,
      required bool fatal,
      required Map<String, String> buildStamp,
    }) async {
      if (kIsWeb || Firebase.apps.isEmpty) return;
      final crashlytics = FirebaseCrashlytics.instance;
      for (final entry in buildStamp.entries) {
        await crashlytics.setCustomKey(entry.key, entry.value);
      }
      await crashlytics.recordError(
        error,
        stackTrace,
        reason: reason,
        fatal: fatal,
      );
    },
    analyticsSink: (name, parameters) async {
      if (Firebase.apps.isEmpty) return;
      await FirebaseAnalytics.instance.logEvent(
        name: name,
        parameters: parameters.map((k, v) => MapEntry(k, v ?? '')),
      );
    },
  );
}

/// Builds a [FeatureFlagsService] reading public read-only configuration from
/// Firestore `app_config/feature_flags` with offline [SharedPreferences] fallback.
FeatureFlagsService createRuntimeFeatureFlagsService() {
  return FeatureFlagsService(
    remoteFetcher: () async {
      if (Firebase.apps.isEmpty) return null;
      final snap = await FirebaseFirestore.instance
          .collection('app_config')
          .doc('feature_flags')
          .get();
      return snap.data();
    },
  );
}

/// Shared runtime observability service (logs, spans, opt-in crash/analytics).
final observabilityServiceProvider = Provider<ObservabilityService>((ref) {
  return createRuntimeObservabilityService();
});

/// Shared feature-flag & emergency kill-switch manager.
final featureFlagsServiceProvider = Provider<FeatureFlagsService>((ref) {
  return createRuntimeFeatureFlagsService();
});

/// Active immutable snapshot of remote feature flags and kill switches.
final featureFlagsSnapshotProvider = Provider<FeatureFlagsSnapshot>((ref) {
  return ref.watch(featureFlagsServiceProvider).current;
});
