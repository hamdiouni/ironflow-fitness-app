import 'package:progression_tracker/core/models/sync_operation.dart';

abstract class SyncRepository {
  /// Sync all pending operations
  Future<void> syncPendingOperations();

  /// Add operation to sync queue
  Future<void> queueOperation({
    required SyncOperationType type,
    required String collection,
    required String documentId,
    required Map<String, dynamic> data,
  });

  /// Get pending operations count
  Future<int> getPendingOperationsCount();

  /// Clear sync queue
  Future<void> clearSyncQueue();

  /// Get sync status
  Future<SyncStatus> getSyncStatus();
}

enum SyncStatus {
  idle,
  syncing,
  synced,
  error,
}
