import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/record_ownership.dart';
import '../../../auth/presentation/providers/auth_notifier.dart'
    show currentUserIdProvider;
import 'ai_provider.dart' show aiPreferencesRepositoryProvider;

/// Notifier managing dismissed AI insight banner IDs via [AIPreferencesRepository].
class BannerDismissalNotifier extends Notifier<Set<String>> {
  BannerDismissalNotifier({Set<String>? initial, String? userId})
      : _initial = initial,
        _injectedUserId = userId;

  final Set<String>? _initial;
  final String? _injectedUserId;
  String? _userId;
  bool _disposed = false;

  /// Account that owns these dismissals.
  String? get userId => _userId;

  @override
  Set<String> build() {
    _disposed = false;
    ref.onDispose(() {
      _disposed = true;
    });
    _userId = _injectedUserId ??
        (_initial != null
            ? null
            : (ref.watch(currentUserIdProvider) ??
                RecordOwnershipRules.guestUserId));
    _loadFromPrefs();
    return _initial ?? <String>{};
  }

  Future<void> _loadFromPrefs() async {
    try {
      final repo = ref.read(aiPreferencesRepositoryProvider);
      final loaded = await repo.loadDismissedBanners(userId: _userId);
      if (loaded != null && !_disposed) {
        state = loaded;
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
      final repo = ref.read(aiPreferencesRepositoryProvider);
      await repo.saveDismissedBanners(userId: _userId, dismissedIds: updated);
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
      final repo = ref.read(aiPreferencesRepositoryProvider);
      await repo.clearDismissedBanners(userId: _userId);
    } catch (_) {}
  }
}

/// Global provider for tracking dismissed AI insight banner IDs.
final bannerDismissalProvider =
    NotifierProvider<BannerDismissalNotifier, Set<String>>(
  BannerDismissalNotifier.new,
);
