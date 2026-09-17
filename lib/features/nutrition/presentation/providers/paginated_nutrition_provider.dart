import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/entities.dart';
import '../../domain/usecases/get_nutrition_history_paginated_use_case.dart';
import 'nutrition_providers.dart';

part 'paginated_nutrition_provider.freezed.dart';

/// State for paginated nutrition history loading.
@freezed
class PaginatedNutritionState with _$PaginatedNutritionState {
  const factory PaginatedNutritionState({
    @Default([]) List<DailyNutritionSummary> nutritionHistory,
    @Default(false) bool isLoading,
    @Default(false) bool isLoadingMore,
    @Default(false) bool hasReachedEnd,
    @Default(null) String? error,
    @Default(0) int totalCount,
  }) = _PaginatedNutritionState;
}

/// Notifier for managing paginated nutrition history loading.
class PaginatedNutritionNotifier extends StateNotifier<PaginatedNutritionState> {
  final GetNutritionHistoryPaginatedUseCase _getNutritionHistoryPaginated;
  final GetNutritionHistoryCountUseCase _getNutritionHistoryCount;
  final Ref _ref;

  static const int _pageSize = 20;

  PaginatedNutritionNotifier(
    this._getNutritionHistoryPaginated,
    this._getNutritionHistoryCount,
    this._ref,
  ) : super(const PaginatedNutritionState());

  /// Load the first page of nutrition history.
  Future<void> loadInitial() async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final totalCount = await _getNutritionHistoryCount();
      final nutritionHistory = await _getNutritionHistoryPaginated(
        offset: 0,
        limit: _pageSize,
      );

      state = state.copyWith(
        nutritionHistory: nutritionHistory,
        isLoading: false,
        hasReachedEnd: nutritionHistory.length < _pageSize,
        totalCount: totalCount,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Load the next page of nutrition history.
  Future<void> loadMore() async {
    if (state.isLoadingMore || state.hasReachedEnd || state.isLoading) return;

    state = state.copyWith(isLoadingMore: true, error: null);

    try {
      final newHistory = await _getNutritionHistoryPaginated(
        offset: state.nutritionHistory.length,
        limit: _pageSize,
      );

      final allHistory = [...state.nutritionHistory, ...newHistory];

      state = state.copyWith(
        nutritionHistory: allHistory,
        isLoadingMore: false,
        hasReachedEnd: newHistory.length < _pageSize,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingMore: false,
        error: e.toString(),
      );
    }
  }

  /// Refresh the nutrition history (reload from beginning).
  Future<void> refresh() async {
    state = const PaginatedNutritionState();
    await loadInitial();
  }
}

/// Provider for paginated nutrition use cases.
final getNutritionHistoryPaginatedUseCaseProvider = 
    Provider<GetNutritionHistoryPaginatedUseCase>((ref) {
  final repository = ref.watch(nutritionRepositoryProvider);
  return GetNutritionHistoryPaginatedUseCase(repository);
});

final getNutritionHistoryCountUseCaseProvider = 
    Provider<GetNutritionHistoryCountUseCase>((ref) {
  final repository = ref.watch(nutritionRepositoryProvider);
  return GetNutritionHistoryCountUseCase(repository);
});

/// Provider for paginated nutrition state.
final paginatedNutritionProvider = 
    StateNotifierProvider<PaginatedNutritionNotifier, PaginatedNutritionState>((ref) {
  return PaginatedNutritionNotifier(
    ref.watch(getNutritionHistoryPaginatedUseCaseProvider),
    ref.watch(getNutritionHistoryCountUseCaseProvider),
    ref,
  );
});
