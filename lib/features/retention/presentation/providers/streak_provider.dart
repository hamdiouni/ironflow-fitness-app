import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../../domain/entities/streak.dart';
import '../../data/datasources/hive_streak_data_source.dart';

// ---------------------------------------------------------------------------
// Data source provider
// ---------------------------------------------------------------------------

final streakDataSourceProvider = Provider<HiveStreakDataSource>((ref) {
  return HiveStreakDataSource();
});

// ---------------------------------------------------------------------------
// Streak provider
// ---------------------------------------------------------------------------

/// Provides the current user's streak.
///
/// Watches workout history and updates streak when new workouts are logged.
final streakProvider = FutureProvider<Streak>((ref) async {
  final dataSource = ref.watch(streakDataSourceProvider);
  return dataSource.getStreak();
});

// ---------------------------------------------------------------------------
// Streak notifier
// ---------------------------------------------------------------------------

class StreakNotifier extends StateNotifier<Streak> {
  final HiveStreakDataSource _dataSource;

  StreakNotifier(this._dataSource, Streak initialStreak)
      : super(initialStreak);

  /// Updates streak after a new workout is logged
  Future<void> updateAfterWorkout() async {
    final updated = state.addWorkout();
    state = updated;
    await _dataSource.saveStreak(updated);
  }

  /// Manually resets the streak
  Future<void> resetStreak() async {
    final reset = state.reset();
    state = reset;
    await _dataSource.saveStreak(reset);
  }

  /// Checks if streak should be reset (missed a day)
  Future<void> checkAndUpdateStreak() async {
    if (!state.isActive) {
      await resetStreak();
    }
  }
}

// ---------------------------------------------------------------------------
// Streak state notifier provider
// ---------------------------------------------------------------------------

final streakNotifierProvider =
    StateNotifierProvider<StreakNotifier, Streak>((ref) {
  final dataSource = ref.watch(streakDataSourceProvider);
  return StreakNotifier(dataSource, Streak.initial());
});
