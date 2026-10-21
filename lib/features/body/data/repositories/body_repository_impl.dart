import '../../domain/entities/body_entry.dart';
import '../../domain/repositories/body_repository.dart';
import '../../../sync/domain/entities/sync_action.dart';
import '../../../sync/domain/services/sync_service.dart';
import '../datasources/hive_body_data_source.dart';
import '../models/body_entry_model.dart';

/// Concrete body repository backed by Hive with an optional cloud outbox.
class BodyRepositoryImpl implements BodyRepository {
  final HiveBodyDataSource dataSource;
  final SyncService? _syncService;
  final String? _userId;

  BodyRepositoryImpl(
    this.dataSource, {
    SyncService? syncService,
    String? userId,
  })  : _syncService = syncService,
        _userId = userId;

  @override
  Future<void> saveBodyEntry(BodyEntry entry) async {
    final model = BodyEntryModel.fromEntity(entry);
    await dataSource.saveBodyEntry(model);

    final syncService = _syncService;
    final userId = _userId;
    if (syncService == null || userId == null || userId.isEmpty) return;

    final data = model.toJson()..['userId'] = userId;
    // A device-local path is not a portable cloud reference. Keep it in Hive
    // on this device; syncing the measurements must not advertise a path that
    // cannot be opened on another device. Cloud photo upload needs Storage URL.
    if (model.photoPath != null) data['photoPath'] = null;
    await syncService.queueAction(
      type: SyncActionType.create,
      dataType: SyncDataType.bodyProgress,
      dataId: entry.id,
      data: data,
    );
  }

  @override
  Future<List<BodyEntry>> getAllBodyEntries() async {
    final models = await dataSource.getAllBodyEntries();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<BodyEntry>> getBodyEntriesByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    final allEntries = await getAllBodyEntries();
    // Include measurements exactly on the supplied boundaries.
    final startBoundary = start.subtract(const Duration(milliseconds: 1));
    final endBoundary = end.add(const Duration(milliseconds: 1));
    return allEntries
        .where((e) =>
            e.date.isAfter(startBoundary) && e.date.isBefore(endBoundary))
        .toList();
  }

  @override
  Future<void> deleteBodyEntry(String id) async {
    await dataSource.deleteBodyEntry(id);

    final syncService = _syncService;
    final userId = _userId;
    if (syncService == null || userId == null || userId.isEmpty) return;

    await syncService.queueAction(
      type: SyncActionType.delete,
      dataType: SyncDataType.bodyProgress,
      dataId: id,
      data: {'id': id, 'userId': userId},
    );
  }
}
