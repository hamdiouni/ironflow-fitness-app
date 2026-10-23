import 'package:progression_tracker/core/utils/app_logger.dart';
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

  /// Per-device pull cursor for a collection (Phase 2): the `syncedAt`
  /// watermark this device has already pulled. Cursors are local-only
  /// state — storing them in the cloud (the old `sync_metadata`
  /// collection) let one device's pulls hide data from another device.
  Future<DateTime?> getCursor(String dataType);
  Future<void> setCursor(String dataType, DateTime time);
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
        // `syncing` counts as pending: an action read in that state was
        // interrupted (e.g. app killed mid-push) and must be retried,
        // not stranded forever.
        if (action.status == SyncStatus.pending ||
            action.status == SyncStatus.failed ||
            action.status == SyncStatus.syncing) {
          actions.add(action);
        }
      } catch (e) {
        AppLogger.debug('Error parsing sync action: $e');
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
          AppLogger.debug('Error parsing sync action for cleanup: $e');
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
        AppLogger.debug('Error counting pending actions: $e');
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
        AppLogger.debug('Error counting failed actions: $e');
      }
    }

    return count;
  }

  // Cursors live in the existing `app_settings` (Box<String>) under
  // prefixed keys — no new box to classify/wipe. Missing/unreadable
  // cursor = full pull, which LWW merge makes idempotent.
  static const String _settingsBox = 'app_settings';
  static String _cursorKey(String dataType) => 'sync_cursor_$dataType';

  @override
  Future<DateTime?> getCursor(String dataType) async {
    try {
      if (!Hive.isBoxOpen(_settingsBox)) return null;
      final raw = Hive.box<String>(_settingsBox).get(_cursorKey(dataType));
      return raw == null ? null : DateTime.tryParse(raw);
    } catch (e) {
      AppLogger.debug('Error reading sync cursor for $dataType: $e');
      return null;
    }
  }

  @override
  Future<void> setCursor(String dataType, DateTime time) async {
    try {
      if (!Hive.isBoxOpen(_settingsBox)) return;
      await Hive.box<String>(_settingsBox)
          .put(_cursorKey(dataType), time.toIso8601String());
    } catch (e) {
      AppLogger.debug('Error saving sync cursor for $dataType: $e');
    }
  }
}
