import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/entities/sync_action.dart';

/// Data source for managing sync queue in Hive
abstract class HiveSyncQueueDataSource {
  Future<void> addAction(SyncAction action);
  Future<List<SyncAction>> getPendingActions();
  Future<void> updateActionStatus(String id, SyncStatus status, {String? error});
  Future<void> deleteAction(String id);
  Future<void> clearCompleted();
  Future<int> getPendingCount();
  Future<int> getFailedCount();
}

class HiveSyncQueueDataSourceImpl implements HiveSyncQueueDataSource {
  static const String _boxName = 'sync_queue';
  Box<Map>? _box;

  Future<Box<Map>> get _syncBox async {
    if (_box == null || !_box!.isOpen) {
      _box = await Hive.openBox<Map>(_boxName);
    }
    return _box!;
  }

  @override
  Future<void> addAction(SyncAction action) async {
    final box = await _syncBox;
    await box.put(action.id, action.toJson());
  }

  @override
  Future<List<SyncAction>> getPendingActions() async {
    final box = await _syncBox;
    final actions = <SyncAction>[];

    for (final entry in box.values) {
      try {
        final action = SyncAction.fromJson(Map<String, dynamic>.from(entry));
        if (action.status == SyncStatus.pending || action.status == SyncStatus.failed) {
          actions.add(action);
        }
      } catch (e) {
        print('Error parsing sync action: $e');
      }
    }

    // Sort by timestamp (oldest first)
    actions.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return actions;
  }

  @override
  Future<void> updateActionStatus(
    String id,
    SyncStatus status, {
    String? error,
  }) async {
    final box = await _syncBox;
    final actionData = box.get(id);

    if (actionData != null) {
      final action = SyncAction.fromJson(Map<String, dynamic>.from(actionData));
      final updated = action.copyWith(
        status: status,
        error: error,
        retryCount: status == SyncStatus.failed ? action.retryCount + 1 : action.retryCount,
      );
      await box.put(id, updated.toJson());
    }
  }

  @override
  Future<void> deleteAction(String id) async {
    final box = await _syncBox;
    await box.delete(id);
  }

  @override
  Future<void> clearCompleted() async {
    final box = await _syncBox;
    final keysToDelete = <String>[];

    for (final key in box.keys) {
      final actionData = box.get(key);
      if (actionData != null) {
        try {
          final action = SyncAction.fromJson(Map<String, dynamic>.from(actionData));
          if (action.status == SyncStatus.completed) {
            keysToDelete.add(key.toString());
          }
        } catch (e) {
          print('Error parsing sync action for cleanup: $e');
        }
      }
    }

    for (final key in keysToDelete) {
      await box.delete(key);
    }
  }

  @override
  Future<int> getPendingCount() async {
    final box = await _syncBox;
    int count = 0;

    for (final entry in box.values) {
      try {
        final action = SyncAction.fromJson(Map<String, dynamic>.from(entry));
        if (action.status == SyncStatus.pending) {
          count++;
        }
      } catch (e) {
        print('Error counting pending actions: $e');
      }
    }

    return count;
  }

  @override
  Future<int> getFailedCount() async {
    final box = await _syncBox;
    int count = 0;

    for (final entry in box.values) {
      try {
        final action = SyncAction.fromJson(Map<String, dynamic>.from(entry));
        if (action.status == SyncStatus.failed) {
          count++;
        }
      } catch (e) {
        print('Error counting failed actions: $e');
      }
    }

    return count;
  }
}
