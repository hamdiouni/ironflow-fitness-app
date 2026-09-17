import 'package:progression_tracker/core/models/sync_operation.dart';
import 'package:progression_tracker/core/utils/sync_queue_manager.dart';
import 'package:progression_tracker/features/sync/data/datasources/firestore_sync_datasource.dart';
import 'package:progression_tracker/features/sync/domain/repositories/sync_repository.dart';

class SyncPendingOperationsUseCase {
  final FirestoreSyncDataSource _dataSource;

  SyncPendingOperationsUseCase(this._dataSource);

  Future<void> call() async {
    try {
      // Get all pending operations
      final operations = await SyncQueueManager.getPendingOperations();

      if (operations.isEmpty) {
        return;
      }

      // Sync in batches of 500 (Firestore batch limit)
      const batchSize = 500;
      for (int i = 0; i < operations.length; i += batchSize) {
        final end = (i + batchSize < operations.length)
            ? i + batchSize
            : operations.length;
        final batch = operations.sublist(i, end);

        try {
          await _dataSource.syncBatch(batch);

          // Remove synced operations from queue
          for (final operation in batch) {
            await SyncQueueManager.removeOperation(operation.id);
          }
        } catch (e) {
          // Update retry count for failed operations
          for (final operation in batch) {
            await SyncQueueManager.updateRetryCount(
              operation.id,
              operation.retryCount + 1,
            );
          }

          // If retry count exceeds 3, remove from queue
          for (final operation in batch) {
            if (operation.retryCount >= 3) {
              await SyncQueueManager.removeOperation(operation.id);
            }
          }

          throw Exception('Batch sync failed: $e');
        }
      }
    } catch (e) {
      throw Exception('Sync pending operations failed: $e');
    }
  }
}
