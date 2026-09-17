import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:progression_tracker/core/providers/connectivity_provider.dart';
import 'package:progression_tracker/features/sync/data/datasources/firestore_sync_datasource.dart';
import 'package:progression_tracker/features/sync/data/repositories/sync_repository_impl.dart';
import 'package:progression_tracker/features/sync/domain/repositories/sync_repository.dart';
import 'package:progression_tracker/features/sync/domain/usecases/sync_pending_operations_use_case.dart';

// Data sources
final firestoreSyncDataSourceProvider = Provider<FirestoreSyncDataSource>((ref) {
  return FirestoreSyncDataSourceImpl();
});

// Use cases
final syncPendingOperationsUseCaseProvider =
    Provider<SyncPendingOperationsUseCase>((ref) {
  return SyncPendingOperationsUseCase(
    ref.watch(firestoreSyncDataSourceProvider),
  );
});

// Repository
final syncRepositoryProvider = Provider<SyncRepository>((ref) {
  return SyncRepositoryImpl(
    dataSource: ref.watch(firestoreSyncDataSourceProvider),
    syncUseCase: ref.watch(syncPendingOperationsUseCaseProvider),
  );
});

// Sync status
final syncStatusProvider = StateProvider<String>((ref) {
  return 'idle';
});

// Pending operations count
final pendingOperationsCountProvider = FutureProvider<int>((ref) async {
  return ref.watch(syncRepositoryProvider).getPendingOperationsCount();
});

// Auto-sync when online
final autoSyncProvider = FutureProvider<void>((ref) async {
  final isOnline = await ref.watch(isOnlineProvider.future);

  if (isOnline) {
    ref.read(syncStatusProvider.notifier).state = 'syncing';

    try {
      await ref.watch(syncRepositoryProvider).syncPendingOperations();
      ref.read(syncStatusProvider.notifier).state = 'synced';
    } catch (e) {
      ref.read(syncStatusProvider.notifier).state = 'error';
      throw Exception('Auto-sync failed: $e');
    }
  }
});
