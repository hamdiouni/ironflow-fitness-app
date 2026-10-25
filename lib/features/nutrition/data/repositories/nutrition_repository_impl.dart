import 'package:progression_tracker/core/utils/app_logger.dart';
import 'package:progression_tracker/core/utils/record_ownership.dart';
import 'package:flutter/foundation.dart';
import '../../domain/entities/entities.dart';
import '../../domain/repositories/nutrition_repository.dart';
import '../datasources/hive_nutrition_datasource.dart';
import '../models/meal_model.dart';
import '../models/nutrition_targets_model.dart';

/// Concrete implementation of [NutritionRepository].
///
/// Phase 2 (DATABASE_AND_SYNC_AUDIT F-02/F-03): this repository is
/// LOCAL-ONLY. The previous direct dual-write to
/// `users/{uid}/nutrition` (a second cloud layout whose failures were
/// swallowed, silently diverging devices) is gone; cloud sync goes
/// through the single outbox (`SyncService`) like every other
/// aggregate. The optional [onMealSaved]/[onMealDeleted]/
/// [onTargetsSaved] hooks let the composition root enqueue sync actions
/// after local writes; hook errors are swallowed so sync can never
/// break a local save.
class NutritionRepositoryImpl implements NutritionRepository {
  final HiveNutritionDatasource hiveDataSource;
  final String userId;
  final Future<void> Function(Meal meal)? onMealSaved;
  final Future<void> Function(String mealId)? onMealDeleted;
  final Future<void> Function(NutritionTargetsModel targets)? onTargetsSaved;

  NutritionRepositoryImpl({
    required this.hiveDataSource,
    required this.userId,
    this.onMealSaved,
    this.onMealDeleted,
    this.onTargetsSaved,
  });

  Future<void> _notify<T>(Future<void> Function(T)? callback, T arg) async {
    if (callback == null) return;
    try {
      await callback(arg);
    } catch (e) {
      AppLogger.debug('Sync enqueue hook failed (local save kept): $e');
    }
  }

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

  String? _ownerForSave(String? ownerId) {
    final currentUserId = _currentUserId;
    if (currentUserId == null) return ownerId ?? userId;
    return RecordOwnershipRules.isLegacyUnownedOwner(ownerId)
        ? currentUserId
        : ownerId;
  }

  String _targetOwnerForSave(String ownerId) {
    final currentUserId = _currentUserId;
    if (currentUserId == null) return ownerId;
    return RecordOwnershipRules.isLegacyUnownedOwner(ownerId)
        ? currentUserId
        : ownerId;
  }

  Future<NutritionTargetsModel?> _visibleTargetsModel() async {
    final targets = await hiveDataSource.getNutritionTargets(userId: userId);
    if (targets == null || _belongsToCurrentUser(targets.userId)) {
      return targets;
    }
    return null;
  }

  Future<List<DateTime>> _visibleMealDates() async {
    final meals = await hiveDataSource.getAllMeals();
    final dates = <DateTime>{};
    for (final meal in meals) {
      if (!_belongsToCurrentUser(meal.userId)) continue;
      final mealDate = DateTime.parse(meal.timestamp);
      dates.add(DateTime(mealDate.year, mealDate.month, mealDate.day));
    }
    return dates.toList()..sort((a, b) => b.compareTo(a));
  }

  @override
  Future<DailyNutritionSummary> getDailyNutrition(DateTime date) async {
    try {
      // Get meals from local storage first (offline-first)
      final localMeals = await hiveDataSource.getMealsByDate(date);
      final meals = localMeals
          .where((m) => _belongsToCurrentUser(m.userId))
          .map((m) => m.toEntity())
          .toList();

      // Get targets
      final targetsModel = await _visibleTargetsModel();
      final targets = targetsModel?.toEntity();

      // If we have local data, return it immediately
      if (meals.isNotEmpty || targets != null) {
        return DailyNutritionSummary(
          date: date,
          meals: meals,
          target: targets,
        );
      }

      // Local-only read; cloud data arrives via SyncService pulls into
      // the same Hive boxes (Phase 2).

      // Return local data or empty summary
      return DailyNutritionSummary(
        date: date,
        meals: meals,
        target: targets,
      );
    } catch (e) {
      if (kDebugMode) {
        AppLogger.debug('Error getting daily nutrition: $e');
      }
      rethrow;
    }
  }

  @override
  Future<void> saveMealEntry(Meal meal) async {
    try {
      if (_currentUserId != null) {
        // Never save over, claim, or enqueue another account's meal.
        if (_isForeign(meal.userId)) return;
        final existing = await hiveDataSource.getMealById(meal.id);
        if (existing != null && _isForeign(existing.userId)) return;
      }

      // Phase 1: stamp ownership + sync clock on every save.
      final stamped = meal.copyWith(
        userId: _ownerForSave(meal.userId),
        updatedAt: DateTime.now(),
      );
      final model = MealModel.fromEntity(stamped);

      // Save to local storage immediately (offline-first), then enqueue
      // the cloud write through the outbox.
      await hiveDataSource.saveMealEntry(model);
      await _notify(onMealSaved, stamped);
    } catch (e) {
      if (kDebugMode) {
        AppLogger.debug('Error saving meal entry: $e');
      }
      rethrow;
    }
  }

  @override
  Future<List<DailyNutritionSummary>> getNutritionHistory(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      // Get meals from local storage first
      final localMeals = await hiveDataSource.getMealsByDateRange(
        startDate,
        endDate,
      );

      // Group meals by date
      final mealsByDate = <DateTime, List<Meal>>{};
      for (final meal in localMeals) {
        if (!_belongsToCurrentUser(meal.userId)) continue;
        final mealEntity = meal.toEntity();
        final mealDate = DateTime(
          mealEntity.timestamp.year,
          mealEntity.timestamp.month,
          mealEntity.timestamp.day,
        );
        mealsByDate.putIfAbsent(mealDate, () => []).add(mealEntity);
      }

      // Get targets
      final targetsModel = await _visibleTargetsModel();
      final targets = targetsModel?.toEntity();

      // Create summaries for each date
      final summaries = <DailyNutritionSummary>[];
      for (final date in mealsByDate.keys) {
        summaries.add(
          DailyNutritionSummary(
            date: date,
            meals: mealsByDate[date] ?? [],
            target: targets,
          ),
        );
      }

      // Sort by date descending
      summaries.sort((a, b) => b.date.compareTo(a.date));

      return summaries;
    } catch (e) {
      if (kDebugMode) {
        AppLogger.debug('Error getting nutrition history: $e');
      }
      rethrow;
    }
  }

  @override
  Future<List<DailyNutritionSummary>> getNutritionHistoryPaginated({
    int offset = 0,
    int limit = 20,
  }) async {
    try {
      // Derive dates only from meals visible to this repository's user,
      // then paginate the already ownership-filtered date list.
      final allDates = await _visibleMealDates();

      // Apply pagination
      final startIndex = offset;
      final endIndex = (offset + limit).clamp(0, allDates.length);

      if (startIndex >= allDates.length) {
        return [];
      }

      final paginatedDates = allDates.sublist(startIndex, endIndex);

      // Get targets
      final targetsModel = await _visibleTargetsModel();
      final targets = targetsModel?.toEntity();

      // Create summaries for paginated dates
      final summaries = <DailyNutritionSummary>[];
      for (final date in paginatedDates) {
        final mealEntities = await getMealsByDate(date);

        summaries.add(
          DailyNutritionSummary(
            date: date,
            meals: mealEntities,
            target: targets,
          ),
        );
      }

      return summaries;
    } catch (e) {
      if (kDebugMode) {
        AppLogger.debug('Error getting paginated nutrition history: $e');
      }
      rethrow;
    }
  }

  @override
  Future<int> getNutritionHistoryCount() async {
    try {
      final allDates = await _visibleMealDates();
      return allDates.length;
    } catch (e) {
      if (kDebugMode) {
        AppLogger.debug('Error getting nutrition history count: $e');
      }
      rethrow;
    }
  }

  @override
  Future<NutritionTargets?> getNutritionTargets() async {
    try {
      // Try local storage first
      final localTargets = await _visibleTargetsModel();
      if (localTargets != null) {
        return localTargets.toEntity();
      }

      return null;
    } catch (e) {
      if (kDebugMode) {
        AppLogger.debug('Error getting nutrition targets: $e');
      }
      rethrow;
    }
  }

  @override
  Future<void> saveNutritionTargets(NutritionTargets targets) async {
    try {
      if (_currentUserId != null) {
        if (_isForeign(targets.userId)) return;
        final existing =
            await hiveDataSource.getNutritionTargets(userId: userId);
        if (existing != null && _isForeign(existing.userId)) return;
      }

      final scopedTargets = targets.copyWith(
        userId: _targetOwnerForSave(targets.userId),
      );
      final model = NutritionTargetsModel.fromEntity(scopedTargets);

      // Save to local storage immediately, then enqueue the cloud write.
      await hiveDataSource.saveNutritionTargets(model, userId: userId);
      await _notify(onTargetsSaved, model);
    } catch (e) {
      if (kDebugMode) {
        AppLogger.debug('Error saving nutrition targets: $e');
      }
      rethrow;
    }
  }

  @override
  Future<void> deleteMealEntry(String mealId) async {
    try {
      final existing = await hiveDataSource.getMealById(mealId);
      if (existing != null && _isForeign(existing.userId)) return;

      // Delete from local storage immediately, then enqueue the cloud
      // tombstone through the outbox.
      await hiveDataSource.deleteMealEntry(mealId);
      await _notify(onMealDeleted, mealId);
    } catch (e) {
      if (kDebugMode) {
        AppLogger.debug('Error deleting meal entry: $e');
      }
      rethrow;
    }
  }

  @override
  Future<List<Meal>> getMealsByDate(DateTime date) async {
    try {
      // Get from local storage first
      final localMeals = await hiveDataSource.getMealsByDate(date);
      final meals = localMeals
          .where((m) => _belongsToCurrentUser(m.userId))
          .map((m) => m.toEntity())
          .toList();

      // If we have local data, return it
      if (meals.isNotEmpty) {
        return meals;
      }

      return meals;
    } catch (e) {
      if (kDebugMode) {
        AppLogger.debug('Error getting meals by date: $e');
      }
      rethrow;
    }
  }

  @override
  Future<void> clearAllData() async {
    try {
      await hiveDataSource.clearAllData(userId: userId);
    } catch (e) {
      if (kDebugMode) {
        AppLogger.debug('Error clearing all nutrition data: $e');
      }
      rethrow;
    }
  }
}
