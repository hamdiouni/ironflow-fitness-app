import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../data/datasources/hive_body_data_source.dart';
import '../../data/repositories/body_repository_impl.dart';
import '../../domain/entities/body_entry.dart';
import '../../domain/entities/weight_data_point.dart';
import '../../domain/repositories/body_repository.dart';
import '../../domain/usecases/get_body_history_use_case.dart';
import '../../domain/usecases/get_weight_trend_use_case.dart';
import '../../../auth/presentation/providers/auth_notifier.dart';
import '../../data/models/body_entry_model.dart';
import '../../../sync/domain/entities/sync_action.dart';
import '../../../../core/utils/record_ownership.dart';
import '../../../sync/presentation/providers/sync_provider.dart';

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

/// The single Hive body data source instance for the provider layer
/// (Phase 3): repository and reactive stream share it.
final hiveBodyDataSourceProvider = Provider<HiveBodyDataSource>((ref) {
  return HiveBodyDataSource();
});

final bodyRepositoryProvider = Provider<BodyRepository>((ref) {
  final dataSource = ref.watch(hiveBodyDataSourceProvider);
  // Phase 1: new entries are stamped with the signed-in owner.
  final userId = ref.watch(currentUserIdProvider);
  // Phase 2: saves/deletes enqueue to the single outbox.
  final syncService = ref.watch(syncServiceProvider);
  return BodyRepositoryImpl(
    dataSource,
    userId: userId,
    onEntrySaved: (entry) => syncService.queueAction(
      type: SyncActionType.update,
      dataType: SyncDataType.bodyProgress,
      dataId: entry.id,
      data: BodyEntryModel.fromEntity(entry).toJson(),
    ),
    onEntryDeleted: (entryId) => syncService.queueAction(
      type: SyncActionType.delete,
      dataType: SyncDataType.bodyProgress,
      dataId: entryId,
      data: {'id': entryId, 'userId': userId},
    ),
  );
});

// ---------------------------------------------------------------------------
// Reactive stream (Phase 3, F-12) — replaces bodyRefreshCounterProvider.
// Screens no longer bump a counter after saving; the Hive box-watch
// stream re-emits on every write (UI, sync pull, restore).
// ---------------------------------------------------------------------------

/// Reactive stream of all body entries, newest first.
final bodyEntriesStreamProvider = StreamProvider<List<BodyEntry>>((ref) {
  final dataSource = ref.watch(hiveBodyDataSourceProvider);
  final userId = ref.watch(currentUserIdProvider);
  return dataSource.watchAllBodyEntries().map(
        (models) => models
            .where(
              (m) => RecordOwnershipRules.belongsToCurrentUser(
                ownerId: m.userId,
                currentUserId: userId,
              ),
            )
            .map((m) => m.toEntity())
            .toList(),
      );
});

// ---------------------------------------------------------------------------
// Data providers — both watch bodyEntriesStreamProvider so they rebuild
// whenever the body box changes.
// ---------------------------------------------------------------------------

/// Full body-entry history sorted by date descending.
final bodyHistoryProvider = FutureProvider<List<BodyEntry>>((ref) async {
  ref.watch(bodyEntriesStreamProvider);
  final repository = ref.watch(bodyRepositoryProvider);
  final useCase = GetBodyHistoryUseCase(repository);
  return await useCase();
});

/// Weight data points for the last 30 days.
/// Uses a fixed 30-day window — no family parameter needed.
final weightTrendProvider = FutureProvider<List<WeightDataPoint>>((ref) async {
  ref.watch(bodyEntriesStreamProvider);
  final repository = ref.watch(bodyRepositoryProvider);
  final useCase = GetWeightTrendUseCase(repository);
  final now = DateTime.now();
  return await useCase(
    now.subtract(const Duration(days: 30)),
    now.add(const Duration(hours: 1)), // include today fully
  );
});
