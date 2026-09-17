import 'package:progression_tracker/core/models/sync_operation.dart';
import 'package:progression_tracker/core/utils/hive_manager.dart';
import 'package:uuid/uuid.dart';

class SyncQueueManager {
  static const String _syncQueueKey = 'sync_queue';
  static const uuid = Uuid();

  /// Add operation to sync queue
  static Future<void> addOperation({
    required SyncOperationType type,
    required String collection,
    required String documentId,
    required Map<String, dynamic> data,
  }) async {
    try {
      final operation = SyncOperation(
        id: uuid.v4(),
        type: type,
        collection: collection,
        documentId: documentId,
        data: data,
        createdAt: DateTime.now(),
        retryCount: 0,
      );

      final box = HiveManager.getSyncQueueBox();
      await box.add(operation.toJson());
    } catch (e) {
      throw Exception('Failed to add sync operation: $e');
    }
  }

  /// Get all pending operations
  static Future<List<SyncOperation>> getPendingOperations() async {
    try {
      final box = HiveManager.getSyncQueueBox();
      final operations = <SyncOperation>[];

      for (int i = 0; i < box.length; i++) {
        final data = box.getAt(i) as Map<String, dynamic>;
        operations.add(SyncOperation.fromJson(data));
      }

      return operations;
    } catch (e) {
      throw Exception('Failed to get pending operations: $e');
    }
  }

  /// Remove operation from queue
  static Future<void> removeOperation(String operationId) async {
    try {
      final box = HiveManager.getSyncQueueBox();
      final index = _findOperationIndex(box, operationId);

      if (index != -1) {
        await box.deleteAt(index);
      }
    } catch (e) {
      throw Exception('Failed to remove sync operation: $e');
    }
  }

  /// Update operation retry count
  static Future<void> updateRetryCount(String operationId, int retryCount) async {
    try {
      final box = HiveManager.getSyncQueueBox();
      final index = _findOperationIndex(box, operationId);

      if (index != -1) {
        final data = box.getAt(index) as Map<String, dynamic>;
        final operation = SyncOperation.fromJson(data);
        final updated = operation.copyWith(retryCount: retryCount);
        await box.putAt(index, updated.toJson());
      }
    } catch (e) {
      throw Exception('Failed to update retry count: $e');
    }
  }

  /// Clear all operations
  static Future<void> clearAll() async {
    try {
      final box = HiveManager.getSyncQueueBox();
      await box.clear();
    } catch (e) {
      throw Exception('Failed to clear sync queue: $e');
    }
  }

  /// Get queue size
  static Future<int> getQueueSize() async {
    try {
      final box = HiveManager.getSyncQueueBox();
      return box.length;
    } catch (e) {
      throw Exception('Failed to get queue size: $e');
    }
  }

  static int _findOperationIndex(dynamic box, String operationId) {
    for (int i = 0; i < box.length; i++) {
      final data = box.getAt(i) as Map<String, dynamic>;
      if (data['id'] == operationId) {
        return i;
      }
    }
    return -1;
  }
}
