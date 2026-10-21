import 'package:flutter/foundation.dart';
import '../../domain/entities/entities.dart';
import '../../domain/repositories/nutrition_repository.dart';
import '../datasources/firestore_nutrition_datasource.dart';
import '../../../sync/domain/entities/sync_action.dart';
import '../../../sync/domain/services/sync_service.dart';
import '../datasources/hive_nutrition_datasource.dart';
import '../models/meal_model.dart';
import '../models/nutrition_targets_model.dart';

/// Concrete implementation of [NutritionRepository]
/// Implements offline-first caching with Firestore as source of truth
///
/// Architecture:
/// - Local operations saved to Hive immediately for offline access
/// - Cloud sync uses the queued outbox when a signed-in user is available.
/// - Conflict resolution uses last-write-wins strategy
/// - Sync queue integration for offline operations
class NutritionRepositoryImpl implements NutritionRepository {
  final FirestoreNutritionDatasource? firestoreDataSource;
  final HiveNutritionDatasource hiveDataSource;
  final String userId;
  final SyncService? syncService;

  NutritionRepositoryImpl({
    required this.firestoreDataSource,
    required this.hiveDataSource,
    required this.userId,
    this.syncService,
  });

  @override
  Future<DailyNutritionSummary> getDailyNutrition(DateTime date) async {
    try {
      final mealModels = await hiveDataSource.getMealsByDate(date);
      final mealsById = <String, Meal>{
        for (final model in mealModels) model.id: model.toEntity(),
      };
      var targetModel = await hiveDataSource.getNutritionTargets();

      // Always check the cloud when signed in. Returning Hive data immediately
      // when it is non-empty was hiding new records from other devices.
      final remote = firestoreDataSource;
      if (remote != null && userId.isNotEmpty) {
        try {
          final remoteMeals = await remote.getMealsByDate(userId, date);
          for (final model in remoteMeals) {
            mealsById[model.id] = model.toEntity();
            await hiveDataSource.saveMealEntry(model);
          }

          final remoteTargets = await remote.getNutritionTargets(userId);
          if (remoteTargets != null) {
            targetModel = remoteTargets;
            await hiveDataSource.saveNutritionTargets(remoteTargets);
          }
        } catch (e) {
          if (kDebugMode) {
            print('Could not refresh daily nutrition from Firestore: $e');
          }
        }
      }

      return DailyNutritionSummary(
        date: date,
        meals: mealsById.values.toList()
          ..sort((a, b) => a.timestamp.compareTo(b.timestamp)),
        target: targetModel?.toEntity(),
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

      final sync = syncService;
      if (sync != null && userId.isNotEmpty) {
        final data = model.toJson()..['userId'] = userId;
        await sync.queueAction(
          type: SyncActionType.create,
          dataType: SyncDataType.nutrition,
          dataId: meal.id,
          data: data,
        );
      } else if (firestoreDataSource != null && userId.isNotEmpty) {
        try {
          await firestoreDataSource!.saveMealEntry(userId, model);
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
      final mealsById = <String, MealModel>{
        for (final model in await hiveDataSource.getMealsByDateRange(
          startDate,
          endDate,
        ))
          model.id: model,
      };

      final remote = firestoreDataSource;
      if (remote != null && userId.isNotEmpty) {
        try {
          final remoteMeals = await remote.getMealsByDateRange(
            userId,
            startDate,
            endDate,
          );
          for (final model in remoteMeals) {
            mealsById[model.id] = model;
            await hiveDataSource.saveMealEntry(model);
          }
        } catch (e) {
          if (kDebugMode) {
            print('Could not sync nutrition history from Firestore: $e');
          }
        }
      }

      final targets = (await getNutritionTargets());
      final mealsByDate = <DateTime, List<Meal>>{};
      for (final model in mealsById.values) {
        final meal = model.toEntity();
        final mealDate = DateTime(
          meal.timestamp.year,
          meal.timestamp.month,
          meal.timestamp.day,
        );
        mealsByDate.putIfAbsent(mealDate, () => []).add(meal);
      }

      final summaries = [
        for (final entry in mealsByDate.entries)
          DailyNutritionSummary(
            date: entry.key,
            meals: entry.value,
            target: targets,
          ),
      ]..sort((a, b) => b.date.compareTo(a.date));
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
    if (offset < 0) throw ArgumentError.value(offset, 'offset', 'must not be negative');
    if (limit <= 0) return [];

    try {
      // Merge the complete local and cloud history before paging. Paging only
      // Hive dates made cloud-only records invisible until another read path
      // happened to cache them locally.
      final history = await getNutritionHistory(
        DateTime(1970),
        DateTime.now().add(const Duration(days: 1)),
      );
      if (offset >= history.length) return [];
      final endIndex = (offset + limit).clamp(0, history.length);
      return history.sublist(offset, endIndex);
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
      final history = await getNutritionHistory(
        DateTime(1970),
        DateTime.now().add(const Duration(days: 1)),
      );
      return history.length;
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
      var targets = await hiveDataSource.getNutritionTargets();
      final remote = firestoreDataSource;
      if (remote != null && userId.isNotEmpty) {
        try {
          final cloudTargets = await remote.getNutritionTargets(userId);
          if (cloudTargets != null) {
            targets = cloudTargets;
            await hiveDataSource.saveNutritionTargets(cloudTargets);
          }
        } catch (e) {
          if (kDebugMode) {
            print('Could not fetch nutrition targets from Firestore: $e');
          }
        }
      }
      return targets?.toEntity();
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
      await hiveDataSource.saveNutritionTargets(model);

      final sync = syncService;
      if (sync != null && userId.isNotEmpty) {
        final data = model.toJson()
          ..['id'] = 'targets'
          ..['_syncKind'] = 'targets';
        data['userId'] = userId;
        await sync.queueAction(
          type: SyncActionType.update,
          dataType: SyncDataType.nutrition,
          dataId: 'targets',
          data: data,
        );
      } else if (firestoreDataSource != null && userId.isNotEmpty) {
        try {
          await firestoreDataSource!.saveNutritionTargets(userId, model);
        } catch (e) {
          if (kDebugMode) {
            print('Could not sync nutrition targets, saved locally: $e');
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
      await hiveDataSource.deleteMealEntry(mealId);

      final sync = syncService;
      if (sync != null && userId.isNotEmpty) {
        await sync.queueAction(
          type: SyncActionType.delete,
          dataType: SyncDataType.nutrition,
          dataId: mealId,
          data: {'id': mealId, 'userId': userId},
        );
      } else if (firestoreDataSource != null && userId.isNotEmpty) {
        try {
          await firestoreDataSource!.deleteMealEntry(userId, mealId);
        } catch (e) {
          if (kDebugMode) {
            print('Could not delete meal from Firestore: $e');
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
      final localModels = await hiveDataSource.getMealsByDate(date);
      final mealsById = <String, MealModel>{
        for (final model in localModels) model.id: model,
      };

      final remote = firestoreDataSource;
      if (remote != null && userId.isNotEmpty) {
        try {
          final cloudMeals = await remote.getMealsByDate(userId, date);
          for (final model in cloudMeals) {
            mealsById[model.id] = model;
            await hiveDataSource.saveMealEntry(model);
          }
        } catch (e) {
          if (kDebugMode) {
            print('Could not fetch meals from Firestore: $e');
          }
        }
      }

      return mealsById.values.map((model) => model.toEntity()).toList()
        ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
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
