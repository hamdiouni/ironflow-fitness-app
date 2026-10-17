import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

/// Central abstraction for tactile and haptic feedback across IronFlow.
///
/// Widgets must never call [HapticFeedback] directly. All haptic feedback
/// is dispatched through semantic methods on this service, respecting the
/// user's persisted haptic feedback toggle.
class AppHaptics {
  bool isEnabled;
  final Set<String> _triggeredMilestones;

  AppHaptics({
    this.isEnabled = true,
    Set<String>? triggeredMilestones,
  }) : _triggeredMilestones = triggeredMilestones ?? <String>{};

  static AppHaptics? _sharedInstance;

  /// Global shared instance for non-consumer widgets (e.g., AppButton).
  static AppHaptics get shared {
    return _sharedInstance ??= AppHaptics();
  }

  /// Sets the global shared instance (primarily for tests).
  @visibleForTesting
  static set shared(AppHaptics instance) {
    _sharedInstance = instance;
  }

  /// Feedback when an exercise set is logged (light impact).
  Future<void> setLogged() async {
    if (!isEnabled) return;
    await HapticFeedback.lightImpact();
  }

  /// Feedback when the rest timer reaches 00:00 (medium impact).
  Future<void> restTimerComplete() async {
    if (!isEnabled) return;
    await HapticFeedback.mediumImpact();
  }

  /// Feedback when a daily target milestone (protein, calories, carbs, fats)
  /// is achieved. Fires at most ONCE per milestone per calendar day.
  Future<void> milestoneReached({required String milestoneId, DateTime? date}) async {
    if (!isEnabled) return;
    final targetDate = date ?? DateTime.now();
    final dateKey =
        '${targetDate.year}-${targetDate.month.toString().padLeft(2, '0')}-${targetDate.day.toString().padLeft(2, '0')}_$milestoneId';
    if (_triggeredMilestones.contains(dateKey)) return;
    _triggeredMilestones.add(dateKey);
    await HapticFeedback.mediumImpact();
  }

  /// Feedback when switching bottom navigation tabs or selectors (selection click).
  Future<void> selectionChanged() async {
    if (!isEnabled) return;
    await HapticFeedback.selectionClick();
  }

  /// Feedback when an interactive button is tapped (light impact).
  Future<void> buttonPress() async {
    if (!isEnabled) return;
    await HapticFeedback.lightImpact();
  }

  /// Feedback when an error, validation failure, or critical alert occurs (heavy impact).
  Future<void> error() async {
    if (!isEnabled) return;
    await HapticFeedback.heavyImpact();
  }

  /// Resets daily milestone tracking (useful for unit tests).
  void clearMilestones() {
    _triggeredMilestones.clear();
  }
}

/// State notifier managing the persisted haptic feedback setting.
class HapticsNotifier extends StateNotifier<bool> {
  static const String _boxName = 'app_settings';
  static const String _hapticsKey = 'haptics_enabled';

  HapticsNotifier() : super(true) {
    _loadPreference();
  }

  void _loadPreference() {
    try {
      if (Hive.isBoxOpen(_boxName)) {
        final box = Hive.box<String>(_boxName);
        final val = box.get(_hapticsKey);
        if (val != null) {
          state = val == 'true';
          AppHaptics.shared.isEnabled = state;
        }
      }
    } catch (_) {
      // Default remains true on storage error
    }
  }

  Future<void> toggle(bool value) async {
    state = value;
    AppHaptics.shared.isEnabled = value;
    try {
      if (Hive.isBoxOpen(_boxName)) {
        final box = Hive.box<String>(_boxName);
        await box.put(_hapticsKey, value ? 'true' : 'false');
      }
    } catch (_) {}
  }
}

/// Provider managing the enabled/disabled state of haptics.
final hapticsEnabledProvider = StateNotifierProvider<HapticsNotifier, bool>((ref) {
  return HapticsNotifier();
});

/// Riverpod provider exposing the central [AppHaptics] service.
final appHapticsProvider = Provider<AppHaptics>((ref) {
  final isEnabled = ref.watch(hapticsEnabledProvider);
  final haptics = AppHaptics.shared;
  haptics.isEnabled = isEnabled;
  return haptics;
});
