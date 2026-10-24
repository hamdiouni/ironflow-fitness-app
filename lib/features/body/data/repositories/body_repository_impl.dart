import '../../domain/entities/body_entry.dart';
import '../../domain/repositories/body_repository.dart';
import '../datasources/hive_body_data_source.dart';
import '../models/body_entry_model.dart';

/// Concrete implementation of [BodyRepository] backed by [HiveBodyDataSource].
class BodyRepositoryImpl implements BodyRepository {
  final HiveBodyDataSource dataSource;

  /// Owner stamped onto entries that don't already carry one (Phase 1).
  /// Optional so existing single-argument constructions (tests) still work.
  final String? userId;

  /// Outbox hooks (Phase 2): invoked after successful local writes so the
  /// composition root can enqueue sync actions. Errors are swallowed —
  /// sync must never break a local save. Optional; tests omit them.
  final Future<void> Function(BodyEntry entry)? onEntrySaved;
  final Future<void> Function(String entryId)? onEntryDeleted;

  BodyRepositoryImpl(
    this.dataSource, {
    this.userId,
    this.onEntrySaved,
    this.onEntryDeleted,
  });

  @override
  Future<void> saveBodyEntry(BodyEntry entry) async {
    // Stamp owner + LWW clock (Phases 1–2) on every save.
    final stamped = entry.copyWith(
      userId: entry.userId ?? userId,
      updatedAt: DateTime.now(),
    );
    final model = BodyEntryModel.fromEntity(stamped);
    await dataSource.saveBodyEntry(model);
    await _notify(onEntrySaved, stamped);
  }

  @override
  Future<List<BodyEntry>> getAllBodyEntries() async {
    final models = await dataSource.getAllBodyEntries();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<BodyEntry>> getBodyEntriesByDateRange(
      DateTime start, DateTime end) async {
    final allEntries = await getAllBodyEntries();
    // Use isAfter(start - 1ms) and isBefore(end + 1ms) to include boundary dates
    final startBoundary = start.subtract(const Duration(milliseconds: 1));
    final endBoundary = end.add(const Duration(milliseconds: 1));
    return allEntries
        .where((e) => e.date.isAfter(startBoundary) && e.date.isBefore(endBoundary))
        .toList();
  }

  @override
  Future<void> deleteBodyEntry(String id) async {
    await dataSource.deleteBodyEntry(id);
    await _notify(onEntryDeleted, id);
  }

  Future<void> _notify<T>(Future<void> Function(T)? callback, T arg) async {
    if (callback == null) return;
    try {
      await callback(arg);
    } catch (_) {
      // Best-effort: the local write already succeeded.
    }
  }
}
