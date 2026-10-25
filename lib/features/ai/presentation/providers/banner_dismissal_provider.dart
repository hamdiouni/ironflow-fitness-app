import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/utils/record_ownership.dart';
import '../../../auth/presentation/providers/auth_notifier.dart'
    show currentUserIdProvider;

const String _kDismissedBannersKey = 'ironflow_dismissed_ai_banners';

String _dismissedBannersKeyForUser(String? userId) {
  final scopeUserId = RecordOwnershipRules.storageScope(userId);
  return scopeUserId == null
      ? _kDismissedBannersKey
      : '${_kDismissedBannersKey}_$scopeUserId';
}

/// State notifier managing dismissed AI insight banner IDs using local [SharedPreferences].
class BannerDismissalNotifier extends StateNotifier<Set<String>> {
  /// Account that owns these dismissals. Direct constructions without a
  /// user keep using the legacy preference key.
  final String? userId;

  BannerDismissalNotifier({Set<String>? initial, this.userId})
      : super(initial ?? {}) {
    _loadFromPrefs();
  }

  String get _storageKey => _dismissedBannersKeyForUser(userId);

  Future<void> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      var list = prefs.getStringList(_storageKey);

      if (list == null && _storageKey != _kDismissedBannersKey) {
        // One-time adoption of pre-scoping dismissals, only when no
        // account-scoped dismissal list exists yet.
        final hasScopedDismissals = prefs
            .getKeys()
            .any((key) => key.startsWith('${_kDismissedBannersKey}_'));
        final legacyList = prefs.getStringList(_kDismissedBannersKey);
        if (!hasScopedDismissals && legacyList != null) {
          list = legacyList;
          await prefs.setStringList(_storageKey, legacyList);
          await prefs.remove(_kDismissedBannersKey);
        }
      }

      if (list != null && mounted) {
        state = list.toSet();
      }
    } catch (_) {
      // Gracefully fall back to in-memory state on error (e.g., in unit tests without prefs mock)
    }
  }

  /// Dismiss an insight by ID and persist the choice.
  Future<void> dismiss(String insightId) async {
    if (state.contains(insightId)) return;
    final updated = {...state, insightId};
    state = updated;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_storageKey, updated.toList());
    } catch (_) {
      // In-memory state already updated
    }
  }

  /// Check whether an insight is marked as dismissed.
  bool isDismissed(String insightId) => state.contains(insightId);

  /// Reset dismissed IDs (useful for testing or profile resets).
  Future<void> reset() async {
    state = {};
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_storageKey);
    } catch (_) {}
  }
}

/// Global provider for tracking dismissed AI insight banner IDs.
final bannerDismissalProvider =
    StateNotifierProvider<BannerDismissalNotifier, Set<String>>((ref) {
  final userId =
      ref.watch(currentUserIdProvider) ?? RecordOwnershipRules.guestUserId;
  return BannerDismissalNotifier(userId: userId);
});
