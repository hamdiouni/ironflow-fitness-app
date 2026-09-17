import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../domain/services/sync_service.dart';
import '../../domain/entities/sync_status.dart';
import '../../data/datasources/hive_sync_queue_datasource.dart';
import '../../data/datasources/firestore_sync_datasource.dart';
import '../../../workout/data/datasources/hive_workout_data_source.dart';
import '../../../workout/data/datasources/hive_active_program_datasource.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

// Data sources
final hiveSyncQueueDataSourceProvider = Provider<HiveSyncQueueDataSource>((ref) {
  return HiveSyncQueueDataSourceImpl();
});

final firestoreSyncDataSourceProvider = Provider<FirestoreSyncDataSource>((ref) {
  return FirestoreSyncDataSourceImpl();
});

// Sync service
final syncServiceProvider = Provider<SyncService>((ref) {
  final service = SyncService(
    syncQueue: ref.watch(hiveSyncQueueDataSourceProvider),
    firestoreSync: ref.watch(firestoreSyncDataSourceProvider),
    hiveWorkouts: HiveWorkoutDataSourceImpl(),
    hivePrograms: HiveActiveProgramDataSourceImpl(),
    connectivity: Connectivity(),
  );

  // Initialize on creation
  service.initialize();

  // Dispose on provider disposal
  ref.onDispose(() {
    service.dispose();
  });

  return service;
});

// Sync status stream
final syncStatusStreamProvider = StreamProvider<SyncStatusEntity>((ref) {
  final service = ref.watch(syncServiceProvider);
  return service.syncStatus;
});

// Current sync status
final syncStatusProvider = FutureProvider<SyncStatusEntity>((ref) async {
  final service = ref.watch(syncServiceProvider);
  return service.getCurrentStatus();
});

// Sync trigger
final syncTriggerProvider = Provider<Future<void> Function()>((ref) {
  return () async {
    final service = ref.read(syncServiceProvider);
    final authState = await ref.read(currentUserProvider.future);
    
    if (authState != null) {
      await service.syncAll(userId: authState.id);
    }
  };
});

// Retry failed actions
final retryFailedActionsProvider = Provider<Future<void> Function()>((ref) {
  return () async {
    final service = ref.read(syncServiceProvider);
    final authState = await ref.read(currentUserProvider.future);
    
    if (authState != null) {
      await service.retryFailedActions(authState.id);
    }
  };
});

// Connectivity status
final connectivityProvider = StreamProvider<ConnectivityResult>((ref) {
  return Connectivity().onConnectivityChanged;
});

// Is online
final isOnlineProvider = StreamProvider<bool>((ref) {
  return Connectivity().onConnectivityChanged.map(
    (result) => result != ConnectivityResult.none,
  );
});
