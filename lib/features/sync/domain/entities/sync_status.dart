import 'package:freezed_annotation/freezed_annotation.dart';

part 'sync_status.freezed.dart';
part 'sync_status.g.dart';

/// Represents the overall sync status
@freezed
class SyncStatusEntity with _$SyncStatusEntity {
  const factory SyncStatusEntity({
    required bool isSyncing,
    required DateTime? lastSyncTime,
    required int pendingActions,
    required int failedActions,
    String? error,
  }) = _SyncStatusEntity;

  factory SyncStatusEntity.fromJson(Map<String, dynamic> json) =>
      _$SyncStatusEntityFromJson(json);

  factory SyncStatusEntity.initial() => const SyncStatusEntity(
        isSyncing: false,
        lastSyncTime: null,
        pendingActions: 0,
        failedActions: 0,
      );
}
