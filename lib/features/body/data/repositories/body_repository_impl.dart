import '../../../../core/utils/record_ownership.dart';
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

  String? get _currentUserId =>
      RecordOwnershipRules.normalizeUserId(userId);

  bool _belongsToCurrentUser(String? ownerId) {
    return RecordOwnershipRules.belongsToCurrentUser(
      ownerId: ownerId,
      currentUserId: _currentUserId,
    );
  }

  bool _isForeign(String? ownerId) {
    return RecordOwnershipRules.isForeignToCurrentUser(
      ownerId: ownerId,
      currentUserId: _currentUserId,
    );
  }

  Future<BodyEntryModel?> _findExistingEntry(String id) async {
    for (final model in await dataSource.getAllBodyEntries()) {
      if (model.id == id) return model;
    }
    return null;
  }

  String? _ownerForSave(String? ownerId) {
    final currentUserId = _currentUserId;
    if (currentUserId == null) return ownerId ?? userId;
    return RecordOwnershipRules.isLegacyUnownedOwner(ownerId)
        ? currentUserId
        : ownerId;
  }

  @override
  Future<void> saveBodyEntry(BodyEntry entry) async {
    if (_currentUserId != null) {
      // Never save over, claim, or enqueue another account's entry.
      if (_isForeign(entry.userId)) return;
      final existing = await _findExistingEntry(entry.id);
      if (existing != null && _isForeign(existing.userId)) return;
    }

    // Stamp owner + LWW clock (Phases 1–2) on every save.
    final stamped = entry.copyWith(
      userId: _ownerForSave(entry.userId),
      updatedAt: DateTime.now(),
    );
    final model = BodyEntryModel.fromEntity(stamped);
    await dataSource.saveBodyEntry(model);
    await _notify(onEntrySaved, stamped);
  }

  @override
  Future<List<BodyEntry>> getAllBodyEntries() async {
    final models = await dataSource.getAllBodyEntries();
    return models
        .where((m) => _belongsToCurrentUser(m.userId))
        .map((m) => m.toEntity())
        .toList();
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
    final existing = await _findExistingEntry(id);
    if (existing != null && _isForeign(existing.userId)) return;
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
