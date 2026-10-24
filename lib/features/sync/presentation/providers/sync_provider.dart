import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../domain/services/sync_service.dart';
import '../../domain/entities/sync_status.dart';
import '../../data/datasources/hive_sync_queue_datasource.dart';
import '../../data/datasources/firestore_sync_datasource.dart';
import '../../../workout/data/datasources/hive_workout_data_source.dart';
import '../../../workout/data/datasources/hive_active_program_datasource.dart';
import '../../../nutrition/data/datasources/hive_nutrition_datasource.dart';
import '../../../body/data/datasources/hive_body_data_source.dart';
import '../../../auth/data/datasources/auth_session_storage.dart';
import '../../../auth/presentation/providers/auth_notifier.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

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
  final sessionStorage = AuthSessionStorage();
  final service = SyncService(
    syncQueue: ref.watch(hiveSyncQueueDataSourceProvider),
    firestoreSync: ref.watch(firestoreSyncDataSourceProvider),
    hiveWorkouts: HiveWorkoutDataSource(),
    hivePrograms: HiveActiveProgramDataSource(),
    hiveNutrition: HiveNutritionDatasource(),
    hiveBody: HiveBodyDataSource(),
    connectivity: Connectivity(),
    // Internal triggers (connectivity/timer/post-write) resolve the
    // signed-in user from the stored session at call time.
    currentUserIdProvider: sessionStorage.getUserId,
    // The initial full push stamps unowned local history with the
    // current uid, so only run it under real Firebase auth — never
    // under a throwaway mock uid (Phase 3; see SyncService).
    enableInitialPush: kUseFirebaseAuth,
  );

  // Initialize on creation
  service.initialize();

  // Sync immediately when a (different) user signs in (Phase 3). With
  // real auth, the first such sync performs the one-time initial full
  // push of local history; later sign-ins just drain/pull. This is an
  // accelerator only — the marker check inside syncAll guarantees the
  // initial push happens on whatever trigger fires first.
  ref.listen(authNotifierProvider.select((s) => s.user?.id),
      (previous, next) {
    if (next != null && next.isNotEmpty && next != previous) {
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
