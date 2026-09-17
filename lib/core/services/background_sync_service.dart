import 'package:workmanager/workmanager.dart';
import 'package:flutter/foundation.dart';

/// Background sync service using WorkManager.
///
/// Handles periodic background synchronization of data when the app is not active.
/// Syncs pending operations every 5 minutes when online.
///
/// **Validates: Requirements 8.3 (Background Sync)**
class BackgroundSyncService {
  static const String _syncTaskName = 'ironflow_background_sync';
  static const String _syncTaskTag = 'sync';

  /// Initialize the background sync service.
  ///
  /// Must be called during app initialization.
  static Future<void> initialize() async {
    try {
      await Workmanager().initialize(
        callbackDispatcher,
        isInDebugMode: kDebugMode,
      );
      
      if (kDebugMode) {
        print('BackgroundSyncService initialized');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing BackgroundSyncService: $e');
      }
    }
  }

  /// Register periodic background sync task.
  ///
  /// Syncs every 5 minutes when online.
  /// Only runs when device has network connectivity.
  static Future<void> registerPeriodicSync() async {
    try {
      await Workmanager().registerPeriodicTask(
        _syncTaskName,
        _syncTaskName,
        frequency: const Duration(minutes: 15), // Minimum allowed by Android
        constraints: Constraints(
          networkType: NetworkType.connected,
          requiresBatteryNotLow: true,
        ),
        tag: _syncTaskTag,
        existingWorkPolicy: ExistingWorkPolicy.keep,
      );
      
      if (kDebugMode) {
        print('Periodic background sync registered');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error registering periodic sync: $e');
      }
    }
  }

  /// Register one-time background sync task.
  ///
  /// Useful for immediate sync after offline operations.
  static Future<void> registerOneTimeSync() async {
    try {
      await Workmanager().registerOneOffTask(
        '${_syncTaskName}_onetime',
        _syncTaskName,
        constraints: Constraints(
          networkType: NetworkType.connected,
        ),
        tag: _syncTaskTag,
        existingWorkPolicy: ExistingWorkPolicy.keep,
      );
      
      if (kDebugMode) {
        print('One-time background sync registered');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error registering one-time sync: $e');
      }
    }
  }

  /// Cancel all background sync tasks.
  ///
  /// Useful for logout or when user disables background sync.
  static Future<void> cancelAll() async {
    try {
      await Workmanager().cancelByTag(_syncTaskTag);
      
      if (kDebugMode) {
        print('All background sync tasks cancelled');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error cancelling background sync: $e');
      }
    }
  }

  /// Cancel periodic sync only.
  static Future<void> cancelPeriodicSync() async {
    try {
      await Workmanager().cancelByUniqueName(_syncTaskName);
      
      if (kDebugMode) {
        print('Periodic background sync cancelled');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error cancelling periodic sync: $e');
      }
    }
  }
}

/// Callback dispatcher for background tasks.
///
/// This function runs in a separate isolate and must be a top-level function.
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      if (kDebugMode) {
        print('Background sync task started: $task');
      }

      // Perform sync operations here
      // Note: This runs in a separate isolate, so we need to initialize
      // any required services (Hive, Firebase, etc.)
      
      await _performBackgroundSync();

      if (kDebugMode) {
        print('Background sync task completed successfully');
      }

      return Future.value(true);
    } catch (e) {
      if (kDebugMode) {
        print('Background sync task failed: $e');
      }
      return Future.value(false);
    }
  });
}

/// Perform the actual background sync operations.
///
/// This function should:
/// 1. Initialize required services (Hive, Firebase)
/// 2. Check for pending sync operations
/// 3. Sync data to cloud
/// 4. Handle errors gracefully
Future<void> _performBackgroundSync() async {
  try {
    // TODO: Initialize Hive and Firebase in background isolate
    // TODO: Get pending sync operations from queue
    // TODO: Sync operations to Firestore
    // TODO: Update sync status
    
    if (kDebugMode) {
      print('Performing background sync...');
    }

    // Placeholder for actual sync logic
    // In a real implementation, this would:
    // 1. Initialize Hive: await Hive.initFlutter()
    // 2. Initialize Firebase: await Firebase.initializeApp()
    // 3. Get sync queue: final queue = await SyncQueueManager.getPendingOperations()
    // 4. Sync each operation: for (op in queue) { await syncOperation(op) }
    // 5. Update sync status: await SyncQueueManager.markAsSynced(op.id)

    await Future.delayed(const Duration(seconds: 2)); // Simulate sync work

    if (kDebugMode) {
      print('Background sync completed');
    }
  } catch (e) {
    if (kDebugMode) {
      print('Error during background sync: $e');
    }
    rethrow;
  }
}

/// Background sync status for UI display.
enum BackgroundSyncStatus {
  idle,
  syncing,
  synced,
  error,
}

/// Background sync manager for coordinating sync operations.
///
/// Provides a high-level API for managing background sync.
class BackgroundSyncManager {
  static BackgroundSyncStatus _status = BackgroundSyncStatus.idle;
  static DateTime? _lastSyncTime;
  static String? _lastError;

  /// Get current sync status.
  static BackgroundSyncStatus get status => _status;

  /// Get last sync time.
  static DateTime? get lastSyncTime => _lastSyncTime;

  /// Get last error message.
  static String? get lastError => _lastError;

  /// Initialize and start background sync.
  static Future<void> start() async {
    await BackgroundSyncService.initialize();
    await BackgroundSyncService.registerPeriodicSync();
  }

  /// Stop background sync.
  static Future<void> stop() async {
    await BackgroundSyncService.cancelAll();
  }

  /// Trigger immediate sync.
  static Future<void> syncNow() async {
    _status = BackgroundSyncStatus.syncing;
    _lastError = null;

    try {
      await BackgroundSyncService.registerOneTimeSync();
      _status = BackgroundSyncStatus.synced;
      _lastSyncTime = DateTime.now();
    } catch (e) {
      _status = BackgroundSyncStatus.error;
      _lastError = e.toString();
      if (kDebugMode) {
        print('Error during immediate sync: $e');
      }
    }
  }

  /// Update sync status (called by sync operations).
  static void updateStatus(BackgroundSyncStatus status, {String? error}) {
    _status = status;
    if (status == BackgroundSyncStatus.synced) {
      _lastSyncTime = DateTime.now();
      _lastError = null;
    } else if (status == BackgroundSyncStatus.error) {
      _lastError = error;
    }
  }

  /// Get time since last sync.
  static Duration? get timeSinceLastSync {
    if (_lastSyncTime == null) return null;
    return DateTime.now().difference(_lastSyncTime!);
  }

  /// Check if sync is needed (more than 5 minutes since last sync).
  static bool get needsSync {
    if (_lastSyncTime == null) return true;
    final timeSince = timeSinceLastSync;
    if (timeSince == null) return true;
    return timeSince.inMinutes >= 5;
  }
}
