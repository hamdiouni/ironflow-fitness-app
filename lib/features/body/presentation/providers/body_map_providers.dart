import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:progression_tracker/core/utils/record_ownership.dart';
import 'package:progression_tracker/features/auth/presentation/providers/auth_notifier.dart'
    show currentUserIdProvider;
import 'package:progression_tracker/features/body/domain/entities/muscle_recovery_status.dart';
import 'package:progression_tracker/features/body/domain/entities/muscle_region.dart';
import 'package:progression_tracker/features/body/domain/services/muscle_recovery_calculator.dart';
import 'package:progression_tracker/features/workout/presentation/providers/workout_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ── Manual Soreness Notifier ────────────────────────────────────────────────

class ManualSorenessNotifier extends Notifier<Set<String>> {
  static const String _prefPrefix = 'ironflow_manual_soreness';
  bool _disposed = false;

  String get _storageKey {
    final userId = ref.watch(currentUserIdProvider);
    final scope = RecordOwnershipRules.storageScope(userId);
    return scope == null ? _prefPrefix : '${_prefPrefix}_$scope';
  }

  @override
  Set<String> build() {
    _disposed = false;
    ref.onDispose(() => _disposed = true);
    _loadFromPrefs();
    return const {};
  }

  Future<void> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_disposed) return;
      final stored = prefs.getStringList(_storageKey);
      if (stored != null) {
        state = stored.toSet();
      }
    } catch (_) {}
  }

  Future<void> toggle(String regionId, bool isSore) async {
    final next = Set<String>.from(state);
    if (isSore) {
      next.add(regionId);
    } else {
      next.remove(regionId);
    }
    state = next;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_storageKey, next.toList());
    } catch (_) {}
  }

  Future<void> clearAll() async {
    state = const {};
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_storageKey);
    } catch (_) {}
  }
}

final manualSorenessProvider =
    NotifierProvider<ManualSorenessNotifier, Set<String>>(
  ManualSorenessNotifier.new,
);

// ── Body Map UI Control Providers ───────────────────────────────────────────

class BodyMapViewModeNotifier extends Notifier<bool> {
  @override
  bool build() => true; // true = Front, false = Back

  void setFront() => state = true;
  void setBack() => state = false;
  void toggle() => state = !state;
}

final bodyMapViewModeProvider =
    NotifierProvider<BodyMapViewModeNotifier, bool>(
  BodyMapViewModeNotifier.new,
);

class BodyMapHeatmapModeNotifier extends Notifier<bool> {
  @override
  bool build() => false; // false = Recovery tier, true = Volume heatmap

  void toggle() => state = !state;
  void setMode(bool isHeatmap) => state = isHeatmap;
}

final bodyMapHeatmapModeProvider =
    NotifierProvider<BodyMapHeatmapModeNotifier, bool>(
  BodyMapHeatmapModeNotifier.new,
);

class SelectedMuscleRegionNotifier extends Notifier<MuscleRegion?> {
  @override
  MuscleRegion? build() => null;

  void select(MuscleRegion? region) => state = region;
  void clear() => state = null;
}

final selectedMuscleRegionProvider =
    NotifierProvider<SelectedMuscleRegionNotifier, MuscleRegion?>(
  SelectedMuscleRegionNotifier.new,
);

// ── Muscle Recovery Telemetry Provider ──────────────────────────────────────

final muscleRecoveryCalculatorProvider =
    Provider<MuscleRecoveryCalculator>((ref) {
  return const MuscleRecoveryCalculator();
});

/// Comprehensive muscle recovery map calculated reactively across all user workouts.
final muscleRecoveryProvider =
    Provider<AsyncValue<Map<MuscleRegion, MuscleRecoveryData>>>((ref) {
  final workoutsAsync = ref.watch(workoutsStreamProvider);
  final manualSoreness = ref.watch(manualSorenessProvider);
  final calculator = ref.watch(muscleRecoveryCalculatorProvider);

  return workoutsAsync.when(
    data: (workouts) {
      final map = calculator.calculate(
        workouts: workouts,
        manualSoreRegionIds: manualSoreness,
      );
      return AsyncValue.data(map);
    },
    loading: () => const AsyncValue.loading(),
    error: (err, stack) => AsyncValue.error(err, stack),
  );
});

/// Overall body readiness score (0.0 to 1.0) averaged across all major muscle groups.
final overallBodyReadinessProvider = Provider<double>((ref) {
  final recoveryAsync = ref.watch(muscleRecoveryProvider);
  return recoveryAsync.maybeWhen(
    data: (map) {
      if (map.isEmpty) return 1.0;
      final sum = map.values.fold<double>(0.0, (acc, r) => acc + r.score);
      return (sum / map.length).clamp(0.0, 1.0);
    },
    orElse: () => 0.92, // Default aesthetic primed score when loading
  );
});
