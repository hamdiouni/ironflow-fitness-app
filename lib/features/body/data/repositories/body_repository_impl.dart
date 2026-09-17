import '../../domain/entities/body_entry.dart';
import '../../domain/repositories/body_repository.dart';
import '../datasources/hive_body_data_source.dart';
import '../models/body_entry_model.dart';

/// Concrete implementation of [BodyRepository] backed by [HiveBodyDataSource].
class BodyRepositoryImpl implements BodyRepository {
  final HiveBodyDataSource dataSource;

  BodyRepositoryImpl(this.dataSource);

  @override
  Future<void> saveBodyEntry(BodyEntry entry) async {
    final model = BodyEntryModel.fromEntity(entry);
    await dataSource.saveBodyEntry(model);
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
  }
}
