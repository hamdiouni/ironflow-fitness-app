import '../entities/sync_action.dart';
import '../entities/sync_status.dart';

export 'sync_conflict_policy.dart';

/// Domain contract for the IronFlow offline-first synchronization engine.
///
/// Concrete datasource-wired implementation lives in
/// `lib/features/sync/data/services/sync_service.dart`.
abstract class SyncEngine {
  bool get isSyncEnabled;
  void setSyncEnabled(bool enabled);
  Stream<SyncStatusEntity> get syncStatus;

  Future<void> initialize();
  void dispose();

  Future<void> queueAction({
    required SyncActionType type,
    required SyncDataType dataType,
    required String dataId,
    required Map<String, dynamic> data,
  });

  Future<void> syncAll({String? userId});
  Future<SyncStatusEntity> getCurrentStatus();
  Future<void> retryFailedActions(String userId);
}
