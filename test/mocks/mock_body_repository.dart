import 'package:progression_tracker/features/body/domain/entities/body_entry.dart';
import 'package:progression_tracker/features/body/domain/repositories/body_repository.dart';

/// Simple weight history entry for testing
class WeightHistoryEntry {
  final DateTime date;
  final double weight;
  final String? note;
  final double? bodyFatPercentage;
  final double? muscleMass;

  WeightHistoryEntry({
    required this.date,
    required this.weight,
    this.note,
    this.bodyFatPercentage,
    this.muscleMass,
  });
}

/// Mock implementation of BodyRepository for testing
/// 
/// Note: This mock extends the interface with additional methods
/// (getWeightHistory, getGoalWeight) that are called by the analytics
/// repository but not yet in the official interface.
class MockBodyRepository implements BodyRepository {
  List<BodyEntry> _entries = [];
  List<WeightHistoryEntry> _weightHistory = [];
  double? _goalWeight;

  void setWeightHistory(List<WeightHistoryEntry> history) {
    _weightHistory = history;
  }

  void setGoalWeight(double? goalWeight) {
    _goalWeight = goalWeight;
  }

  /// Extended method for analytics - not in base interface
  Future<List<WeightHistoryEntry>> getWeightHistory({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    return _weightHistory.where((entry) {
      return entry.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
          entry.date.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();
  }

  /// Extended method for analytics - not in base interface
  Future<double?> getGoalWeight() async {
    return _goalWeight;
  }

  @override
  Future<void> saveBodyEntry(BodyEntry entry) async {
    _entries.add(entry);
  }

  @override
  Future<List<BodyEntry>> getAllBodyEntries() async {
    return _entries;
  }

  @override
  Future<List<BodyEntry>> getBodyEntriesByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    return _entries.where((entry) {
      return entry.date.isAfter(start.subtract(const Duration(days: 1))) &&
          entry.date.isBefore(end.add(const Duration(days: 1)));
    }).toList();
  }

  @override
  Future<void> deleteBodyEntry(String id) async {
    _entries.removeWhere((e) => e.id == id);
  }
}
