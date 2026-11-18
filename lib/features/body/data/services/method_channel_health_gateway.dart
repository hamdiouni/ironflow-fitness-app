import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../../domain/services/health_sync_service.dart';

/// Platform-channel implementation of [HealthPlatformGateway] for Android Health Connect
/// and Apple HealthKit, with automatic fallback to a deterministic local simulation
/// store when native health SDK plugins are absent (e.g. Web, Desktop, or headless CI).
class MethodChannelHealthGateway implements HealthPlatformGateway {
  MethodChannelHealthGateway({
    MethodChannel? channel,
    this.useNativeChannel = false,
    TargetPlatform? debugPlatformOverride,
    List<HealthWeightSample>? initialSimulatedRemoteWeights,
  })  : _explicitChannel = channel,
        _platformOverride = debugPlatformOverride,
        _simulatedWeights = List<HealthWeightSample>.from(
          initialSimulatedRemoteWeights ??
              [
                HealthWeightSample(
                  id: 'hc_seed_1',
                  timestamp: DateTime(2026, 11, 17, 7, 30),
                  weightKg: 78.4,
                  bodyFatPercent: 14.2,
                  source: 'HealthStore Smart Scale',
                ),
              ],
        );

  static const String channelName = 'com.ironflow.app/health_sync';

  final MethodChannel? _explicitChannel;
  final bool useNativeChannel;
  final TargetPlatform? _platformOverride;
  final List<HealthWeightSample> _simulatedWeights;
  final List<HealthWorkoutRecord> _simulatedWorkouts = [];
  HealthPermissionStatus _simulatedPermission = HealthPermissionStatus.granted;

  MethodChannel get _channel =>
      _explicitChannel ?? const MethodChannel(channelName);

  bool get _hasNativeBridge => _explicitChannel != null || useNativeChannel;

  List<HealthWeightSample> get simulatedWeights =>
      List.unmodifiable(_simulatedWeights);

  List<HealthWorkoutRecord> get simulatedWorkouts =>
      List.unmodifiable(_simulatedWorkouts);

  @override
  HealthPlatformType get platformType {
    if (kIsWeb && _platformOverride == null) {
      return HealthPlatformType.simulatedBridge;
    }
    final platform = _platformOverride ?? defaultTargetPlatform;
    switch (platform) {
      case TargetPlatform.android:
        return HealthPlatformType.androidHealthConnect;
      case TargetPlatform.iOS:
        return HealthPlatformType.appleHealthKit;
      default:
        return HealthPlatformType.simulatedBridge;
    }
  }

  @override
  Future<HealthPermissionStatus> checkPermissions() async {
    if (_hasNativeBridge) {
      try {
        final raw = await _channel.invokeMethod<String>('checkPermissions');
        if (raw != null) {
          return _parsePermission(raw);
        }
      } on MissingPluginException {
        // Fall back to local simulation bridge when native channel is unbound.
      } on PlatformException {
        return HealthPermissionStatus.unavailable;
      }
    }
    return _simulatedPermission;
  }

  @override
  Future<HealthPermissionStatus> requestPermissions({
    required bool readWeight,
    required bool writeWeight,
    required bool writeWorkouts,
  }) async {
    if (_hasNativeBridge) {
      try {
        final raw = await _channel.invokeMethod<String>('requestPermissions', {
          'readWeight': readWeight,
          'writeWeight': writeWeight,
          'writeWorkouts': writeWorkouts,
        });
        if (raw != null) {
          return _parsePermission(raw);
        }
      } on MissingPluginException {
        _simulatedPermission = HealthPermissionStatus.granted;
      } on PlatformException {
        return HealthPermissionStatus.denied;
      }
    }
    return _simulatedPermission;
  }

  @override
  Future<List<HealthWeightSample>> readWeightSamples({
    required DateTime since,
  }) async {
    if (_hasNativeBridge) {
      try {
        final rawList = await _channel.invokeListMethod<Map<Object?, Object?>>(
          'readWeightSamples',
          {'sinceMs': since.millisecondsSinceEpoch},
        );
        if (rawList != null) {
          return rawList.map(HealthWeightSample.fromMap).toList();
        }
      } on MissingPluginException {
        // Use simulated bridge store.
      } on PlatformException {
        return const [];
      }
    }
    return _simulatedWeights
        .where((s) => !s.timestamp.isBefore(since))
        .toList();
  }

  @override
  Future<int> writeWeightSamples(List<HealthWeightSample> samples) async {
    if (samples.isEmpty) return 0;
    if (_hasNativeBridge) {
      try {
        final count = await _channel.invokeMethod<int>(
          'writeWeightSamples',
          {'samples': samples.map((s) => s.toMap()).toList()},
        );
        if (count != null) return count;
      } on MissingPluginException {
        // Fall back to simulated bridge store.
      } on PlatformException {
        return 0;
      }
    }
    for (final s in samples) {
      _simulatedWeights.removeWhere((existing) => existing.id == s.id);
      _simulatedWeights.add(s);
    }
    return samples.length;
  }

  @override
  Future<int> writeWorkouts(List<HealthWorkoutRecord> workouts) async {
    if (workouts.isEmpty) return 0;
    if (_hasNativeBridge) {
      try {
        final count = await _channel.invokeMethod<int>(
          'writeWorkouts',
          {'workouts': workouts.map((w) => w.toMap()).toList()},
        );
        if (count != null) return count;
      } on MissingPluginException {
        // Fall back to simulated bridge store.
      } on PlatformException {
        return 0;
      }
    }
    for (final w in workouts) {
      _simulatedWorkouts.removeWhere((existing) => existing.id == w.id);
      _simulatedWorkouts.add(w);
    }
    return workouts.length;
  }

  HealthPermissionStatus _parsePermission(String raw) {
    switch (raw) {
      case 'granted':
        return HealthPermissionStatus.granted;
      case 'denied':
        return HealthPermissionStatus.denied;
      case 'notDetermined':
        return HealthPermissionStatus.notDetermined;
      default:
        return HealthPermissionStatus.unavailable;
    }
  }
}
