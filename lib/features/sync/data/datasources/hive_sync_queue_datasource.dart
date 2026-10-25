import 'package:progression_tracker/core/utils/app_logger.dart';
import 'package:progression_tracker/core/utils/record_ownership.dart';
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

  /// Per-device, per-user pull cursor for a collection: the `syncedAt`
  /// watermark this device has already pulled for [userId]. Cursors are
  /// local-only state — storing them in the cloud (the old
  /// `sync_metadata` collection) let one device's pulls hide data from
  /// another device, and a device-global cursor would let one account's
  /// pull hide another account's cloud changes on the same device.
  Future<DateTime?> getCursor(String dataType, {required String userId});
  Future<void> setCursor(
    String dataType,
    DateTime time, {
    required String userId,
  });

  /// Whether the one-time initial full-push has already been performed
  /// for [userId] on this device (Phase 3): on first sign-in, all local
  /// records the user owns (or that are unowned/guest) are enqueued so
  /// pre-account local history reaches the cloud exactly once.
  Future<bool> hasCompletedInitialPush(String userId);
  Future<void> markInitialPushComplete(String userId);
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
  // per-user prefixed keys — no new box to classify/wipe. Missing or
  // unreadable cursor = full pull, which LWW merge makes idempotent.
  // The old device-global `sync_cursor_<dataType>` key is deliberately
  // not adopted: it cannot be attributed to either account safely, so
  // each account starts with one safe full pull instead.
  static const String _settingsBox = 'app_settings';
  static String _cursorKey(String dataType, String userId) =>
      'sync_cursor_${dataType}_${RecordOwnershipRules.storageScope(userId)}';

  @override
  Future<DateTime?> getCursor(
    String dataType, {
    required String userId,
  }) async {
    try {
      if (!Hive.isBoxOpen(_settingsBox)) return null;
      final raw =
          Hive.box<String>(_settingsBox).get(_cursorKey(dataType, userId));
      return raw == null ? null : DateTime.tryParse(raw);
    } catch (e) {
      AppLogger.debug('Error reading sync cursor for $dataType: $e');
      return null;
    }
  }

  @override
  Future<void> setCursor(
    String dataType,
    DateTime time, {
    required String userId,
  }) async {
    try {
      if (!Hive.isBoxOpen(_settingsBox)) return;
      await Hive.box<String>(_settingsBox)
          .put(_cursorKey(dataType, userId), time.toIso8601String());
    } catch (e) {
      AppLogger.debug('Error saving sync cursor for $dataType: $e');
    }
  }

  // Initial-push markers live alongside cursors in `app_settings`,
  // one key per user, storing the completion timestamp.
  static String _initialPushKey(String userId) =>
      'sync_initial_push_done_${RecordOwnershipRules.storageScope(userId)}';

  @override
  Future<bool> hasCompletedInitialPush(String userId) async {
    try {
      if (!Hive.isBoxOpen(_settingsBox)) return false;
      return Hive.box<String>(_settingsBox)
          .containsKey(_initialPushKey(userId));
    } catch (e) {
      AppLogger.debug('Error reading initial-push marker: $e');
      return false;
    }
  }

  @override
  Future<void> markInitialPushComplete(String userId) async {
    try {
      if (!Hive.isBoxOpen(_settingsBox)) return;
      await Hive.box<String>(_settingsBox).put(
        _initialPushKey(userId),
        DateTime.now().toIso8601String(),
      );
    } catch (e) {
      AppLogger.debug('Error saving initial-push marker: $e');
    }
  }
}
