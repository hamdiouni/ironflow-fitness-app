import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/workout.dart';
import '../../domain/usecases/get_workouts_paginated_use_case.dart';
import 'workout_providers.dart';

part 'paginated_workout_provider.freezed.dart';

/// State for paginated workout loading.
@freezed
class PaginatedWorkoutState with _$PaginatedWorkoutState {
  const factory PaginatedWorkoutState({
    @Default([]) List<Workout> workouts,
    @Default(false) bool isLoading,
    @Default(false) bool isLoadingMore,
    @Default(false) bool hasReachedEnd,
    @Default(null) String? error,
    @Default(0) int totalCount,
  }) = _PaginatedWorkoutState;
}

/// Notifier for managing paginated workout loading.
class PaginatedWorkoutNotifier extends StateNotifier<PaginatedWorkoutState> {
  final GetWorkoutsPaginatedUseCase _getWorkoutsPaginated;
  final GetWorkoutCountUseCase _getWorkoutCount;
  final Ref _ref;

  static const int _pageSize = 20;

  PaginatedWorkoutNotifier(
    this._getWorkoutsPaginated,
    this._getWorkoutCount,
    this._ref,
  ) : super(const PaginatedWorkoutState());

  /// Load the first page of workouts.
  Future<void> loadInitial() async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final totalCount = await _getWorkoutCount();
      final workouts = await _getWorkoutsPaginated(
        offset: 0,
        limit: _pageSize,
      );

      state = state.copyWith(
        workouts: workouts,
        isLoading: false,
        hasReachedEnd: workouts.length < _pageSize,
        totalCount: totalCount,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Load the next page of workouts.
  Future<void> loadMore() async {
    if (state.isLoadingMore || state.hasReachedEnd || state.isLoading) return;

    state = state.copyWith(isLoadingMore: true, error: null);

    try {
      final newWorkouts = await _getWorkoutsPaginated(
        offset: state.workouts.length,
        limit: _pageSize,
      );

      final allWorkouts = [...state.workouts, ...newWorkouts];

      state = state.copyWith(
        workouts: allWorkouts,
        isLoadingMore: false,
        hasReachedEnd: newWorkouts.length < _pageSize,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingMore: false,
        error: e.toString(),
      );
    }
  }

  /// Refresh the workout list (reload from beginning).
  Future<void> refresh() async {
    state = const PaginatedWorkoutState();
    await loadInitial();
  }

  /// Listen to workout changes and refresh when needed.
  void _listenToWorkoutChanges() {
    _ref.listen(workoutRefreshCounterProvider, (previous, next) {
      if (previous != next) {
        refresh();
      }
    });
  }
}

/// Provider for paginated workout use cases.
final getWorkoutsPaginatedUseCaseProvider = Provider<GetWorkoutsPaginatedUseCase>((ref) {
  final repository = ref.watch(workoutRepositoryProvider);
  return GetWorkoutsPaginatedUseCase(repository);
});

final getWorkoutCountUseCaseProvider = Provider<GetWorkoutCountUseCase>((ref) {
  final repository = ref.watch(workoutRepositoryProvider);
  return GetWorkoutCountUseCase(repository);
});

/// Provider for paginated workout state.
final paginatedWorkoutProvider = StateNotifierProvider<PaginatedWorkoutNotifier, PaginatedWorkoutState>((ref) {
  final notifier = PaginatedWorkoutNotifier(
    ref.watch(getWorkoutsPaginatedUseCaseProvider),
    ref.watch(getWorkoutCountUseCaseProvider),
    ref,
  );
  
  // Listen to workout changes and refresh when needed
  ref.listen(workoutRefreshCounterProvider, (previous, next) {
    if (previous != next) {
      notifier.refresh();
    }
  });
  
  return notifier;
});