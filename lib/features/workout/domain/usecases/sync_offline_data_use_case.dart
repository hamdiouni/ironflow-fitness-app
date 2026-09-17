import 'package:connectivity_plus/connectivity_plus.dart';
import '../entities/entities.dart';
import '../repositories/workout_repository.dart';

/// Represents a pending operation to be synced.
class PendingOperation {
  final String id;
  final String type; // 'workout', 'program_edit', 'diet_log'
  final Map<String, dynamic> data;
  final DateTime createdAt;
  final int retryCount;

  PendingOperation({
    required this.id,
    required this.type,
    required this.data,
    required this.createdAt,
    this.retryCount = 0,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'data': data,
        'createdAt': createdAt.toIso8601String(),
        'retryCount': retryCount,
      };

  factory PendingOperation.fromJson(Map<String, dynamic> json) =>
      PendingOperation(
        id: json['id'] as String,
        type: json['type'] as String,
        data: json['data'] as Map<String, dynamic>,
        createdAt: DateTime.parse(json['createdAt'] as String),
        retryCount: json['retryCount'] as int? ?? 0,
      );
}

/// Use case for syncing offline data when connection is restored.
///
/// Tracks pending operations and syncs them when online.
/// Handles sync conflicts using last-write-wins strategy.
class SyncOfflineDataUseCase {
  final WorkoutRepository _repository;
  final Connectivity _connectivity;

  SyncOfflineDataUseCase(this._repository, this._connectivity);

  /// Queues an operation for syncing.
  Future<void> queueOperation(PendingOperation operation) async {
    try {
      // Store operation in local queue
      // This would be persisted to Hive in a real implementation
      print('Operation queued: ${operation.id}');
    } catch (e) {
      print('Error queuing operation: $e');
      rethrow;
    }
  }

  /// Syncs all pending operations when connection is restored.
  Future<void> syncPendingOperations() async {
    try {
      final result = await _connectivity.checkConnectivity();
      if (result == ConnectivityResult.none) {
        throw Exception('No internet connection');
      }

      // Get all pending operations from queue
      // This would be retrieved from Hive in a real implementation
      final pendingOps = <PendingOperation>[];

      for (final op in pendingOps) {
        await _syncOperation(op);
      }
    } catch (e) {
      print('Error syncing operations: $e');
      rethrow;
    }
  }

  /// Syncs a single operation.
  Future<void> _syncOperation(PendingOperation operation) async {
    try {
      switch (operation.type) {
        case 'workout':
          await _syncWorkout(operation);
          break;
        case 'program_edit':
          await _syncProgramEdit(operation);
          break;
        case 'diet_log':
          await _syncDietLog(operation);
          break;
      }

      // Remove from queue after successful sync
      print('Operation synced: ${operation.id}');
    } catch (e) {
      // Increment retry count and re-queue
      final retried = PendingOperation(
        id: operation.id,
        type: operation.type,
        data: operation.data,
        createdAt: operation.createdAt,
        retryCount: operation.retryCount + 1,
      );

      if (retried.retryCount < 3) {
        await queueOperation(retried);
      } else {
        print('Operation failed after 3 retries: ${operation.id}');
      }
    }
  }

  /// Syncs a workout operation.
  Future<void> _syncWorkout(PendingOperation operation) async {
    // Implementation would sync workout data
    print('Syncing workout: ${operation.data}');
  }

  /// Syncs a program edit operation.
  Future<void> _syncProgramEdit(PendingOperation operation) async {
    // Implementation would sync program edits
    print('Syncing program edit: ${operation.data}');
  }

  /// Syncs a diet log operation.
  Future<void> _syncDietLog(PendingOperation operation) async {
    // Implementation would sync diet logs
    print('Syncing diet log: ${operation.data}');
  }

  /// Handles sync conflicts using last-write-wins strategy.
  Future<T> resolveSyncConflict<T>({
    required T local,
    required T remote,
    required DateTime localTimestamp,
    required DateTime remoteTimestamp,
  }) async {
    // Last-write-wins: return the most recently modified version
    if (localTimestamp.isAfter(remoteTimestamp)) {
      return local;
    } else {
      return remote;
    }
  }

  /// Monitors connectivity and syncs when online.
  Stream<bool> monitorConnectivity() {
    return _connectivity.onConnectivityChanged.map((result) {
      final isOnline = result != ConnectivityResult.none;
      if (isOnline) {
        // Trigger sync when connection restored
        syncPendingOperations();
      }
      return isOnline;
    });
  }
}
