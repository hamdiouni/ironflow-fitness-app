import 'package:progression_tracker/core/models/sync_operation.dart';
import 'package:progression_tracker/core/utils/sync_queue_manager.dart';
import 'package:progression_tracker/features/sync/data/datasources/firestore_sync_datasource.dart';
import 'package:progression_tracker/features/sync/domain/repositories/sync_repository.dart';
import 'package:progression_tracker/features/sync/domain/usecases/sync_pending_operations_use_case.dart';

class SyncRepositoryImpl implements SyncRepository {
  final FirestoreSyncDataSource _dataSource;
  final SyncPendingOperationsUseCase _syncUseCase;

  SyncRepositoryImpl({
    required FirestoreSyncDataSource dataSource,
    required SyncPendingOperationsUseCase syncUseCase,
  })  : _dataSource = dataSource,
        _syncUseCase = syncUseCase;

  @override
  Future<void> syncPendingOperations() async {
    return _syncUseCase();
  }

  @override
  Future<void> queueOperation({
    required SyncOperationType type,
    required String collection,
    required String documentId,
    required Map<String, dynamic> data,
  }) async {
    return SyncQueueManager.addOperation(
      type: type,
      collection: collection,
      documentId: documentId,
      data: data,
    );
  }

  @override
  Future<int> getPendingOperationsCount() async {
    return SyncQueueManager.getQueueSize();
  }

  @override
  Future<void> clearSyncQueue() async {
    return SyncQueueManager.clearAll();
  }

  @override
  Future<SyncStatus> getSyncStatus() async {
    final count = await getPendingOperationsCount();
    return count > 0 ? SyncStatus.syncing : SyncStatus.synced;
  }
}
