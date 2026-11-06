import 'dart:convert';

/// Pure domain conflict-resolution policy for Last-Write-Wins (LWW) cloud sync.
///
/// Rules:
/// 1. Newer `updatedAt` timestamp wins.
/// 2. When timestamps are equal and local has an unpushed edit in the outbox,
///    local always wins so unsynced user edits are never clobbered.
/// 3. When timestamps are equal and both copies are clean, deterministic
///    canonical JSON lexicographical comparison breaks ties identically on all
///    devices.
class SyncConflictPolicy {
  const SyncConflictPolicy._();

  static final DateTime epoch = DateTime.fromMillisecondsSinceEpoch(0);

  static DateTime? parseIso(String? iso) =>
      iso == null ? null : DateTime.tryParse(iso);

  static bool isAfter(DateTime? a, DateTime? b) =>
      (a ?? epoch).isAfter(b ?? epoch);

  static DateTime? maxClock(DateTime? a, DateTime? b) {
    if (a == null) return b;
    if (b == null) return a;
    return a.isAfter(b) ? a : b;
  }

  static bool shouldAcceptCloud({
    required DateTime? cloudClock,
    required DateTime? localClock,
    Map<String, dynamic>? cloudJson,
    Map<String, dynamic>? localJson,
    bool hasUnpushedLocalEdit = false,
  }) {
    final c = cloudClock ?? epoch;
    final l = localClock ?? epoch;
    if (c.isAfter(l)) return true;
    if (c.isBefore(l)) return false;

    if (hasUnpushedLocalEdit) return false;

    if (cloudJson != null && localJson != null) {
      final canonicalCloud = canonicalizeJson(cloudJson);
      final canonicalLocal = canonicalizeJson(localJson);
      return canonicalCloud.compareTo(canonicalLocal) > 0;
    }
    return false;
  }

  static String canonicalizeJson(Map<String, dynamic> map) {
    final sortedKeys = map.keys.toList()..sort();
    final ordered = <String, dynamic>{
      for (final k in sortedKeys) k: map[k],
    };
    return jsonEncode(ordered);
  }
}

