import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/services/sync_service.dart';
import '../../domain/entities/sync_status.dart';
import '../../data/datasources/hive_sync_queue_datasource.dart';
import '../../data/datasources/firestore_sync_datasource.dart';
import '../../../body/data/datasources/hive_body_data_source.dart';
import '../../../nutrition/data/datasources/hive_nutrition_datasource.dart';
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
  // Watching the authenticated app user rebuilds this provider when the
  // session changes. The resolver also lets connectivity/timer callbacks use
  // the latest user rather than the null value present during app startup.
  final user = ref.watch(currentUserProvider).valueOrNull;

  final service = SyncService(
    syncQueue: ref.watch(hiveSyncQueueDataSourceProvider),
    firestoreSync: ref.watch(firestoreSyncDataSourceProvider),
    hiveWorkouts: HiveWorkoutDataSource(userId: user?.id),
    hivePrograms: HiveActiveProgramDataSource(userId: user?.id),
    hiveNutrition: HiveNutritionDatasource(userId: user?.id),
    hiveBody: HiveBodyDataSource(userId: user?.id),
    userIdResolver: () async =>
        ref.read(currentUserProvider).valueOrNull?.id,
    connectivity: Connectivity(),
  );

  unawaited(service.initialize());
  ref.onDispose(service.dispose);
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
    final user = ref.read(currentUserProvider).valueOrNull;
    if (user != null) {
      await service.syncAll(userId: user.id);
    }
  };
});

// Retry failed actions
final retryFailedActionsProvider = Provider<Future<void> Function()>((ref) {
  return () async {
    final service = ref.read(syncServiceProvider);
    final user = ref.read(currentUserProvider).valueOrNull;
    if (user != null) {
      await service.retryFailedActions(user.id);
    }
  };
});

// Connectivity status
final connectivityProvider = StreamProvider<List<ConnectivityResult>>((ref) {
  return Connectivity().onConnectivityChanged;
});

// Is online
final isOnlineProvider = StreamProvider<bool>((ref) {
  return Connectivity().onConnectivityChanged.map(
    (results) => !results.contains(ConnectivityResult.none),
  );
});
