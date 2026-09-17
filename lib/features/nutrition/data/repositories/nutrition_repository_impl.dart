import 'package:flutter/foundation.dart';
import '../../domain/entities/entities.dart';
import '../../domain/repositories/nutrition_repository.dart';
// import '../datasources/firestore_nutrition_datasource.dart'; // Firebase disabled
import '../datasources/hive_nutrition_datasource.dart';
import '../models/meal_model.dart';
import '../models/nutrition_targets_model.dart';

/// Concrete implementation of [NutritionRepository]
/// Implements offline-first caching with Firestore as source of truth
///
/// Architecture:
/// - Local operations saved to Hive immediately for offline access
/// - Cloud sync happens when online via Firestore (DISABLED)
/// - Conflict resolution uses last-write-wins strategy
/// - Sync queue integration for offline operations
class NutritionRepositoryImpl implements NutritionRepository {
  final dynamic firestoreDataSource; // Made nullable for Firebase-disabled mode
  final HiveNutritionDatasource hiveDataSource;
  final String userId;

  NutritionRepositoryImpl({
    required this.firestoreDataSource,
    required this.hiveDataSource,
    required this.userId,
  });

  @override
  Future<DailyNutritionSummary> getDailyNutrition(DateTime date) async {
    try {
      // Get meals from local storage first (offline-first)
      final localMeals = await hiveDataSource.getMealsByDate(date);
      final meals = localMeals.map((m) => m.toEntity()).toList();

      // Get targets
      final targetsModel = await hiveDataSource.getNutritionTargets();
      final targets = targetsModel?.toEntity();

      // If we have local data, return it immediately
      if (meals.isNotEmpty || targets != null) {
        return DailyNutritionSummary(
          date: date,
          meals: meals,
          target: targets,
        );
      }

      // If offline or no local data, try to fetch from Firestore (DISABLED)
      // Firebase is disabled, skip Firestore sync
      if (firestoreDataSource != null) {
        try {
          final firestoreMeals = await firestoreDataSource.getMealsByDate(
            userId,
            date,
          );
          final syncedMeals = firestoreMeals.map((m) => m.toEntity()).toList();

          // Cache the meals locally
          for (final meal in firestoreMeals) {
            await hiveDataSource.saveMealEntry(meal);
          }

          // Get targets from Firestore if not in local storage
          NutritionTargets? syncedTargets;
          if (targets == null) {
            final targetsModel = await firestoreDataSource.getNutritionTargets(
              userId,
            );
            if (targetsModel != null) {
              syncedTargets = targetsModel.toEntity();
              await hiveDataSource.saveNutritionTargets(targetsModel);
            }
          }

          return DailyNutritionSummary(
            date: date,
            meals: syncedMeals,
            target: syncedTargets ?? targets,
          );
        } catch (e) {
          if (kDebugMode) {
            print('Error fetching from Firestore, using local data: $e');
          }
        }
      }
      
      // Return local data or empty summary
      return DailyNutritionSummary(
        date: date,
        meals: meals,
        target: targets,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error getting daily nutrition: $e');
      }
      rethrow;
    }
  }

  @override
  Future<void> saveMealEntry(Meal meal) async {
    try {
      final model = MealModel.fromEntity(meal);

      // Save to local storage immediately (offline-first)
      await hiveDataSource.saveMealEntry(model);

      // Try to sync to Firestore if online (DISABLED - Firebase not available)
      if (firestoreDataSource != null) {
        try {
          await firestoreDataSource.saveMealEntry(userId, model);
        } catch (e) {
          if (kDebugMode) {
            print('Could not sync meal to Firestore, saved locally: $e');
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error saving meal entry: $e');
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
        final mealEntity = meal.toEntity();
        final mealDate = DateTime(
          mealEntity.timestamp.year,
          mealEntity.timestamp.month,
          mealEntity.timestamp.day,
        );
        mealsByDate.putIfAbsent(mealDate, () => []).add(mealEntity);
      }

      // Get targets
      final targetsModel = await hiveDataSource.getNutritionTargets();
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

      // Try to fetch from Firestore to sync any missing data (DISABLED)
      if (firestoreDataSource != null) {
        try {
          final firestoreMeals = await firestoreDataSource.getMealsByDateRange(
            userId,
            startDate,
            endDate,
          );

          // Cache any new meals locally
          for (final meal in firestoreMeals) {
            final existing = await hiveDataSource.getMealById(meal.id);
            if (existing == null) {
              await hiveDataSource.saveMealEntry(meal);
            }
          }
        } catch (e) {
          if (kDebugMode) {
            print('Could not sync history from Firestore: $e');
          }
        }
      }

      return summaries;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting nutrition history: $e');
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
      // Get all unique dates with meals from local storage
      final allDates = await hiveDataSource.getAllMealDates();
      
      // Sort dates descending (most recent first)
      allDates.sort((a, b) => b.compareTo(a));
      
      // Apply pagination
      final startIndex = offset;
      final endIndex = (offset + limit).clamp(0, allDates.length);
      
      if (startIndex >= allDates.length) {
        return [];
      }
      
      final paginatedDates = allDates.sublist(startIndex, endIndex);
      
      // Get targets
      final targetsModel = await hiveDataSource.getNutritionTargets();
      final targets = targetsModel?.toEntity();
      
      // Create summaries for paginated dates
      final summaries = <DailyNutritionSummary>[];
      for (final date in paginatedDates) {
        final meals = await hiveDataSource.getMealsByDate(date);
        final mealEntities = meals.map((m) => m.toEntity()).toList();
        
        summaries.add(
          DailyNutritionSummary(
            date: date,
            meals: mealEntities,
            target: targets,
          ),
        );
      }
      
      // Try to sync with Firestore in background (DISABLED)
      if (firestoreDataSource != null) {
        try {
          if (paginatedDates.isNotEmpty) {
            final startDate = paginatedDates.last;
            final endDate = paginatedDates.first.add(const Duration(days: 1));
            
            final firestoreMeals = await firestoreDataSource.getMealsByDateRange(
              userId,
              startDate,
              endDate,
            );

            // Cache any new meals locally
            for (final meal in firestoreMeals) {
              final existing = await hiveDataSource.getMealById(meal.id);
              if (existing == null) {
                await hiveDataSource.saveMealEntry(meal);
              }
            }
          }
        } catch (e) {
          if (kDebugMode) {
            print('Could not sync paginated history from Firestore: $e');
          }
        }
      }
      
      return summaries;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting paginated nutrition history: $e');
      }
      rethrow;
    }
  }

  @override
  Future<int> getNutritionHistoryCount() async {
    try {
      final allDates = await hiveDataSource.getAllMealDates();
      return allDates.length;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting nutrition history count: $e');
      }
      rethrow;
    }
  }

  @override
  Future<NutritionTargets?> getNutritionTargets() async {
    try {
      // Try local storage first
      final localTargets = await hiveDataSource.getNutritionTargets();
      if (localTargets != null) {
        return localTargets.toEntity();
      }

      // Try Firestore (DISABLED)
      if (firestoreDataSource != null) {
        try {
          final firestoreTargets = await firestoreDataSource.getNutritionTargets(
            userId,
          );
          if (firestoreTargets != null) {
            // Cache locally
            await hiveDataSource.saveNutritionTargets(firestoreTargets);
            return firestoreTargets.toEntity();
          }
        } catch (e) {
          if (kDebugMode) {
            print('Could not fetch targets from Firestore: $e');
          }
        }
      }

      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting nutrition targets: $e');
      }
      rethrow;
    }
  }

  @override
  Future<void> saveNutritionTargets(NutritionTargets targets) async {
    try {
      final model = NutritionTargetsModel.fromEntity(targets);

      // Save to local storage immediately
      await hiveDataSource.saveNutritionTargets(model);

      // Try to sync to Firestore (DISABLED)
      if (firestoreDataSource != null) {
        try {
          await firestoreDataSource.saveNutritionTargets(userId, model);
        } catch (e) {
          if (kDebugMode) {
            print('Could not sync targets to Firestore, saved locally: $e');
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error saving nutrition targets: $e');
      }
      rethrow;
    }
  }

  @override
  Future<void> deleteMealEntry(String mealId) async {
    try {
      // Delete from local storage immediately
      await hiveDataSource.deleteMealEntry(mealId);

      // Try to delete from Firestore (DISABLED)
      if (firestoreDataSource != null) {
        try {
          await firestoreDataSource.deleteMealEntry(userId, mealId);
        } catch (e) {
          if (kDebugMode) {
            print('Could not delete meal from Firestore, deleted locally: $e');
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting meal entry: $e');
      }
      rethrow;
    }
  }

  @override
  Future<List<Meal>> getMealsByDate(DateTime date) async {
    try {
      // Get from local storage first
      final localMeals = await hiveDataSource.getMealsByDate(date);
      final meals = localMeals.map((m) => m.toEntity()).toList();

      // If we have local data, return it
      if (meals.isNotEmpty) {
        return meals;
      }

      // Try to fetch from Firestore (DISABLED)
      if (firestoreDataSource != null) {
        try {
          final firestoreMeals = await firestoreDataSource.getMealsByDate(
            userId,
            date,
          );
          final syncedMeals = firestoreMeals.map((m) => m.toEntity()).toList();

          // Cache locally
          for (final meal in firestoreMeals) {
            await hiveDataSource.saveMealEntry(meal);
          }

          return syncedMeals;
        } catch (e) {
          if (kDebugMode) {
            print('Could not fetch meals from Firestore: $e');
          }
        }
      }
      
      return meals;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting meals by date: $e');
      }
      rethrow;
    }
  }

  @override
  Future<void> clearAllData() async {
    try {
      await hiveDataSource.clearAllData();
    } catch (e) {
      if (kDebugMode) {
        print('Error clearing all nutrition data: $e');
      }
      rethrow;
    }
  }
}
