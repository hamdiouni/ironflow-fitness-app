import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _kDismissedBannersKey = 'ironflow_dismissed_ai_banners';

/// State notifier managing dismissed AI insight banner IDs using local [SharedPreferences].
class BannerDismissalNotifier extends StateNotifier<Set<String>> {
  BannerDismissalNotifier([Set<String>? initial]) : super(initial ?? {}) {
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList(_kDismissedBannersKey);
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
      await prefs.setStringList(_kDismissedBannersKey, updated.toList());
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
      await prefs.remove(_kDismissedBannersKey);
    } catch (_) {}
  }
}

/// Global provider for tracking dismissed AI insight banner IDs.
final bannerDismissalProvider =
    StateNotifierProvider<BannerDismissalNotifier, Set<String>>((ref) {
  return BannerDismissalNotifier();
});
