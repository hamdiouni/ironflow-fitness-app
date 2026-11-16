import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../data/services/sync_service.dart';
import '../../domain/entities/sync_status.dart';
import '../../data/datasources/hive_sync_queue_datasource.dart';
import '../../data/datasources/firestore_sync_datasource.dart';
import '../../../workout/data/datasources/hive_workout_data_source.dart';
import '../../../workout/data/datasources/hive_active_program_datasource.dart';
import '../../../nutrition/data/datasources/hive_nutrition_datasource.dart';
import '../../../body/data/datasources/hive_body_data_source.dart';
import '../../../auth/data/services/local_sample_data_seeder.dart';
import '../../../auth/presentation/providers/auth_notifier.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/providers/observability_provider.dart';

// Connectivity providers live in core (Phase 3, F-10): identical
// duplicates used to be defined at the bottom of this file, so widgets
// importing from here watched a *different* provider instance than
// widgets importing from core. Re-exported for existing import sites.
export '../../../../core/providers/connectivity_provider.dart';

// Data sources
final hiveSyncQueueDataSourceProvider = Provider<HiveSyncQueueDataSource>((ref) {
  return HiveSyncQueueDataSourceImpl();
});

final firestoreSyncDataSourceProvider = Provider<FirestoreSyncDataSource>((ref) {
  return FirestoreSyncDataSourceImpl();
});

// Sync service — the single sync engine (Phase 2).
final syncServiceProvider = Provider<SyncService>((ref) {
  final service = SyncService(
    syncQueue: ref.watch(hiveSyncQueueDataSourceProvider),
    firestoreSync: ref.watch(firestoreSyncDataSourceProvider),
    hiveWorkouts: HiveWorkoutDataSource(),
    hivePrograms: HiveActiveProgramDataSource(),
    hiveNutrition: HiveNutritionDatasource(),
    hiveBody: HiveBodyDataSource(),
    connectivity: Connectivity(),
    // Internal triggers (connectivity/timer/post-write) resolve the
    // signed-in user from the shared identity provider at call time.
    // Local-only offline sessions never sync to cloud backends.
    currentUserIdProvider: () {
      final uid = ref.read(currentUserIdProvider);
      return isLocalOnlyUserId(uid) ? null : uid;
    },
    // The initial full push stamps unowned local history with the
    // current uid, so only run it under real Firebase auth — never
    // under a throwaway mock uid (Phase 3; see SyncService).
    enableInitialPush: kUseFirebaseAuth,
    syncEnabled: ref.watch(
          featureFlagsSnapshotProvider.select((flags) => flags.isCloudSyncActive),
        ) &&
        SyncService.kDefaultCloudSyncEnabled,
  );

  // Initialize on creation
  service.initialize();

  // Sync immediately when a (different) cloud user signs in (Phase 3).
  ref.listen(currentUserIdProvider,
      (previous, next) {
    if (next != null &&
        next.isNotEmpty &&
        !isLocalOnlyUserId(next) &&
        next != previous) {
      service.syncAll(userId: next);
    }
  });

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
    
    if (authState != null && !isLocalOnlyUserId(authState.id)) {
      await service.syncAll(userId: authState.id);
    }
  };
});

// Retry failed actions
final retryFailedActionsProvider = Provider<Future<void> Function()>((ref) {
  return () async {
    final service = ref.read(syncServiceProvider);
    final authState = await ref.read(currentUserProvider.future);
    
    if (authState != null && !isLocalOnlyUserId(authState.id)) {
      await service.retryFailedActions(authState.id);
    }
  };
});
