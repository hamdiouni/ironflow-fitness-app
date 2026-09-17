import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../data/datasources/hive_body_data_source.dart';
import '../../data/repositories/body_repository_impl.dart';
import '../../domain/entities/body_entry.dart';
import '../../domain/entities/weight_data_point.dart';
import '../../domain/repositories/body_repository.dart';
import '../../domain/usecases/get_body_history_use_case.dart';
import '../../domain/usecases/get_weight_trend_use_case.dart';

part 'body_providers.freezed.dart';

// ---------------------------------------------------------------------------
// DateRange value object
// ---------------------------------------------------------------------------

@freezed
class DateRange with _$DateRange {
  const factory DateRange({
    required DateTime start,
    required DateTime end,
  }) = _DateRange;
}

// ---------------------------------------------------------------------------
// Repository provider
// ---------------------------------------------------------------------------

final bodyRepositoryProvider = Provider<BodyRepository>((ref) {
  final dataSource = HiveBodyDataSource();
  return BodyRepositoryImpl(dataSource);
});

// ---------------------------------------------------------------------------
// Refresh counter — increment this to force all body providers to re-fetch.
// This is the single source of truth for cache invalidation.
// ---------------------------------------------------------------------------

final bodyRefreshCounterProvider = StateProvider<int>((ref) => 0);

// ---------------------------------------------------------------------------
// Data providers — both watch bodyRefreshCounterProvider so they rebuild
// whenever the counter is incremented after a save.
// ---------------------------------------------------------------------------

/// Full body-entry history sorted by date descending.
final bodyHistoryProvider = FutureProvider<List<BodyEntry>>((ref) async {
  // Watch the counter so this provider re-runs when counter changes.
  ref.watch(bodyRefreshCounterProvider);
  final repository = ref.watch(bodyRepositoryProvider);
  final useCase = GetBodyHistoryUseCase(repository);
  return await useCase();
});

/// Weight data points for the last 30 days.
/// Uses a fixed 30-day window — no family parameter needed.
final weightTrendProvider = FutureProvider<List<WeightDataPoint>>((ref) async {
  // Watch the counter so this provider re-runs when counter changes.
  ref.watch(bodyRefreshCounterProvider);
  final repository = ref.watch(bodyRepositoryProvider);
  final useCase = GetWeightTrendUseCase(repository);
  final now = DateTime.now();
  return await useCase(
    now.subtract(const Duration(days: 30)),
    now.add(const Duration(hours: 1)), // include today fully
  );
});
