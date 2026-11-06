import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Immutable snapshot of remote feature flags and operational kill switches
/// (Wave 2.7 — ADR-005).
///
/// Emergency kill switches (`killAiCoach`, `killCloudSync`, `maintenanceMode`)
/// always override feature-enable flags so operators can immediately halt
/// cloud-cost-bearing traffic without shipping a new binary.
@immutable
class FeatureFlagsSnapshot {
  const FeatureFlagsSnapshot({
    this.aiCoachEnabled = true,
    this.cloudSyncEnabled = true,
    this.bodyMapEnabled = true,
    this.killAiCoach = false,
    this.killCloudSync = false,
    this.maintenanceMode = false,
    this.maintenanceMessage = '',
    this.maxDailyAiRequests = 30,
  });

  final bool aiCoachEnabled;
  final bool cloudSyncEnabled;
  final bool bodyMapEnabled;
  final bool killAiCoach;
  final bool killCloudSync;
  final bool maintenanceMode;
  final String maintenanceMessage;
  final int maxDailyAiRequests;

  /// Effective state of the AI Coach after applying emergency kill switches.
  bool get isAiCoachActive =>
      !maintenanceMode && !killAiCoach && aiCoachEnabled;

  /// Effective state of Cloud Sync after applying emergency kill switches.
  bool get isCloudSyncActive =>
      !maintenanceMode && !killCloudSync && cloudSyncEnabled;

  /// Effective state of the Body Map feature.
  bool get isBodyMapActive => !maintenanceMode && bodyMapEnabled;

  factory FeatureFlagsSnapshot.fromJson(Map<String, dynamic> json) {
    return FeatureFlagsSnapshot(
      aiCoachEnabled: _boolOr(json['ai_coach_enabled'], true),
      cloudSyncEnabled: _boolOr(json['cloud_sync_enabled'], true),
      bodyMapEnabled: _boolOr(json['body_map_enabled'], true),
      killAiCoach: _boolOr(json['kill_ai_coach'], false),
      killCloudSync: _boolOr(json['kill_cloud_sync'], false),
      maintenanceMode: _boolOr(json['maintenance_mode'], false),
      maintenanceMessage:
          (json['maintenance_message'] as String?)?.trim() ?? '',
      maxDailyAiRequests: _intOr(json['max_daily_ai_requests'], 30).clamp(0, 500),
    );
  }

  Map<String, dynamic> toJson() => {
        'ai_coach_enabled': aiCoachEnabled,
        'cloud_sync_enabled': cloudSyncEnabled,
        'body_map_enabled': bodyMapEnabled,
        'kill_ai_coach': killAiCoach,
        'kill_cloud_sync': killCloudSync,
        'maintenance_mode': maintenanceMode,
        'maintenance_message': maintenanceMessage,
        'max_daily_ai_requests': maxDailyAiRequests,
      };

  static bool _boolOr( Object? value, bool fallback) {
    if (value is bool) return value;
    if (value is String) {
      final lower = value.trim().toLowerCase();
      if (lower == 'true') return true;
      if (lower == 'false') return false;
    }
    return fallback;
  }

  static int _intOr(Object? value, int fallback) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value.trim()) ?? fallback;
    return fallback;
  }
}

/// Service managing feature flags and operational kill switches with
/// `SharedPreferences` offline persistence and injectable remote fetching.
class FeatureFlagsService {
  FeatureFlagsService({
    Future<Map<String, dynamic>?> Function()? remoteFetcher,
  }) : _remoteFetcher = remoteFetcher;

  static const String cachePreferenceKey = 'ironflow_feature_flags_v1';

  final Future<Map<String, dynamic>?> Function()? _remoteFetcher;
  FeatureFlagsSnapshot _current = const FeatureFlagsSnapshot();

  /// Active in-memory snapshot of feature flags and kill switches.
  FeatureFlagsSnapshot get current => _current;

  /// Loads cached flags from [SharedPreferences] and optionally refreshes from
  /// the remote source. Never throws; falls back to cached or safe defaults.
  Future<FeatureFlagsSnapshot> initialize({bool refreshRemote = true}) async {
    await _loadFromCache();
    if (refreshRemote) {
      await refresh();
    }
    return _current;
  }

  Future<void> _loadFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(cachePreferenceKey);
      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw);
        if (decoded is Map<String, dynamic>) {
          _current = FeatureFlagsSnapshot.fromJson(decoded);
        }
      }
    } catch (_) {}
  }

  /// Fetches the latest remote flags and updates the local cache.
  /// If the remote fetch fails or returns null, retains the current snapshot.
  Future<FeatureFlagsSnapshot> refresh() async {
    final fetcher = _remoteFetcher;
    if (fetcher == null) return _current;

    try {
      final remoteMap = await fetcher();
      if (remoteMap != null) {
        _current = FeatureFlagsSnapshot.fromJson(remoteMap);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(
          cachePreferenceKey,
          jsonEncode(_current.toJson()),
        );
      }
    } catch (_) {
      // Offline or remote error: keep cached/default snapshot.
    }
    return _current;
  }
}

