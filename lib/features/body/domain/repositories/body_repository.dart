import '../entities/body_entry.dart';

/// Abstract repository interface for body-tracking data persistence.
///
/// Implementations live in the data layer; the domain layer depends only
/// on this abstraction (Dependency Inversion Principle).
abstract class BodyRepository {
  /// Save a body entry to local storage.
  Future<void> saveBodyEntry(BodyEntry entry);

  /// Get all body entries sorted by date descending.
  Future<List<BodyEntry>> getAllBodyEntries();

  /// Get body entries within a date range (inclusive of [start], exclusive of [end]).
  Future<List<BodyEntry>> getBodyEntriesByDateRange(DateTime start, DateTime end);

  /// Delete a body entry by its [id].
  Future<void> deleteBodyEntry(String id);
}
