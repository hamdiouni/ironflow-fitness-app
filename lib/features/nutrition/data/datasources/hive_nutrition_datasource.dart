import 'dart:async';

import 'package:hive/hive.dart';
import 'package:progression_tracker/core/utils/app_logger.dart';
import 'package:progression_tracker/core/utils/hive_json_utils.dart';
import 'package:progression_tracker/core/utils/hive_manager.dart';
import 'package:progression_tracker/core/utils/record_ownership.dart';
import '../models/meal_model.dart';
import '../models/nutrition_targets_model.dart';

/// Hive datasource for local nutrition data storage.
///
/// Provides offline-first caching for:
/// - Meal entries
/// - Nutrition targets
/// - Sync queue operations
///
/// All data is persisted locally for offline access and synced to cloud when online.
class HiveNutritionDatasource {
  static const String mealsBoxName = HiveManager.mealsBox;
  static const String targetsBoxName = HiveManager.macroTargetsBox;
  static const String targetsKey = 'current';

  Future<Box<Map>> _ensureMealsBox() => HiveManager.ensureMealsBox();

  Future<Box<Map>> _ensureTargetsBox() => HiveManager.ensureMacroTargetsBox();

  String _targetsKeyForUser(String userId) =>
      '${targetsKey}_${RecordOwnershipRules.storageScope(userId)}';

  NutritionTargetsModel? _decodeTargets(Map? json) {
    if (json == null) return null;
    return NutritionTargetsModel.fromJson(deepCastMap(json));
  }

  /// Emits an increasing tick whenever meals or nutrition targets
  /// change (Phase 3, F-12), starting at 0 so subscribers load their
  /// first snapshot through the same path. Nutrition state is filtered
  /// by day, so consumers re-run their own queries on each tick rather
  /// than receiving a full snapshot here. Ticks (not `void`) matter:
  /// Riverpod dedupes equal `AsyncValue`s, so a `void` ping stream
  /// would only ever notify listeners once.
  Stream<int> watchNutritionChanges() {
    return Stream<int>.multi((controller) {
      var tick = 0;
      var cancelled = false;
      StreamSubscription<BoxEvent>? mealsSub;
      StreamSubscription<BoxEvent>? targetsSub;

      controller.onCancel = () async {
        cancelled = true;
        await mealsSub?.cancel();
        await targetsSub?.cancel();
      };

      Future.wait([_ensureMealsBox(), _ensureTargetsBox()]).then(
        (boxes) {
          if (cancelled) return;
          controller.add(tick);
          void bump() => controller.add(++tick);
          mealsSub = boxes[0].watch().listen((_) => bump());
          targetsSub = boxes[1].watch().listen((_) => bump());
        },
        onError: (Object e, StackTrace st) {
          if (!cancelled) {
            controller.addError(e, st);
          }
        },
      );
    });
  }

  /// Save a meal entry to local storage.
  ///
  /// Stores the meal in Hive for offline access.
  /// Uses the meal ID as the key for easy retrieval.
  Future<void> saveMealEntry(MealModel meal) async {
    try {
      AppLogger.debug('📊 [NutritionData] Saving meal entry...');
      AppLogger.debug('🔍 [NutritionData] Meal ID: ${meal.id}, Name: ${meal.name}');
      
      final mealsBox = await _ensureMealsBox();
      if (!mealsBox.isOpen) {
        AppLogger.debug('⚠️ [NutritionData] Meals box is not open');
        throw Exception('Meals box not open');
      }
      
      await mealsBox.put(meal.id, meal.toJson());
      
      AppLogger.debug('✅ [NutritionData] Meal saved successfully');
      AppLogger.debug('🔍 [NutritionData] Calories: ${meal.macros.calories}, Name: ${meal.name}');
    } catch (e, stackTrace) {
      AppLogger.debug('❌ [NutritionData] Failed to save meal: $e');
      AppLogger.debug('🔍 [NutritionData] Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Get all meals for a specific date.
  ///
  /// Filters meals by date from local storage.
  /// Returns an empty list if no meals found.
  Future<List<MealModel>> getMealsByDate(DateTime date) async {
    try {
      AppLogger.debug('📊 [NutritionData] Getting meals by date...');
      AppLogger.debug('🔍 [NutritionData] Date: ${date.year}-${date.month}-${date.day}');
      
      final mealsBox = await _ensureMealsBox();
      if (!mealsBox.isOpen) {
        AppLogger.debug('⚠️ [NutritionData] Meals box is not open');
        throw Exception('Meals box not open');
      }
      
      final meals = mealsBox.values
          .map((json) => MealModel.fromJson(deepCastMap(json)))
          .where((meal) {
            final mealDate = DateTime.parse(meal.timestamp);
            return mealDate.year == date.year &&
                mealDate.month == date.month &&
                mealDate.day == date.day;
          })
          .toList();
      
      AppLogger.debug('✅ [NutritionData] Meals retrieved successfully');
      AppLogger.debug('🔍 [NutritionData] Found ${meals.length} meals for date');
      
      return meals;
    } catch (e, stackTrace) {
      AppLogger.debug('❌ [NutritionData] Failed to get meals by date: $e');
      AppLogger.debug('🔍 [NutritionData] Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Get all meals for a date range.
  ///
  /// Filters meals between [startDate] and [endDate] from local storage.
  /// Useful for analytics and history views.
  Future<List<MealModel>> getMealsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      AppLogger.debug('📊 [NutritionData] Getting meals by date range...');
      AppLogger.debug('🔍 [NutritionData] Start: ${startDate.toIso8601String()}, End: ${endDate.toIso8601String()}');
      
      final mealsBox = await _ensureMealsBox();
      if (!mealsBox.isOpen) {
        AppLogger.debug('⚠️ [NutritionData] Meals box is not open');
        throw Exception('Meals box not open');
      }
      
      final meals = mealsBox.values
          .map((json) => MealModel.fromJson(deepCastMap(json)))
          .where((meal) {
            final mealDate = DateTime.parse(meal.timestamp);
            return mealDate.isAfter(startDate) && mealDate.isBefore(endDate);
          })
          .toList();
      
      AppLogger.debug('✅ [NutritionData] Meals retrieved successfully');
      AppLogger.debug('🔍 [NutritionData] Found ${meals.length} meals in date range');
      
      return meals;
    } catch (e, stackTrace) {
      AppLogger.debug('❌ [NutritionData] Failed to get meals by date range: $e');
      AppLogger.debug('🔍 [NutritionData] Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Get all meals from local storage.
  ///
  /// Returns all meal entries stored locally.
  Future<List<MealModel>> getAllMeals() async {
    try {
      AppLogger.debug('📊 [NutritionData] Getting all meals...');
      
      final mealsBox = await _ensureMealsBox();
      if (!mealsBox.isOpen) {
        AppLogger.debug('⚠️ [NutritionData] Meals box is not open');
        throw Exception('Meals box not open');
      }
      
      final meals = mealsBox.values
          .map((json) => MealModel.fromJson(deepCastMap(json)))
          .toList();
      
      AppLogger.debug('✅ [NutritionData] All meals retrieved successfully');
      AppLogger.debug('🔍 [NutritionData] Total meals: ${meals.length}');
      
      return meals;
    } catch (e, stackTrace) {
      AppLogger.debug('❌ [NutritionData] Failed to get all meals: $e');
      AppLogger.debug('🔍 [NutritionData] Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Get a specific meal by ID.
  ///
  /// Returns the meal if found, null otherwise.
  Future<MealModel?> getMealById(String mealId) async {
    try {
      AppLogger.debug('📊 [NutritionData] Getting meal by ID...');
      AppLogger.debug('🔍 [NutritionData] Meal ID: $mealId');
      
      final mealsBox = await _ensureMealsBox();
      if (!mealsBox.isOpen) {
        AppLogger.debug('⚠️ [NutritionData] Meals box is not open');
        throw Exception('Meals box not open');
      }
      
      final json = mealsBox.get(mealId);
      
      if (json == null) {
        AppLogger.debug('⚠️ [NutritionData] Meal not found');
        return null;
      }
      
      final meal = MealModel.fromJson(deepCastMap(json));
      AppLogger.debug('✅ [NutritionData] Meal retrieved successfully');
      AppLogger.debug('🔍 [NutritionData] Name: ${meal.name}, Calories: ${meal.macros.calories}');
      
      return meal;
    } catch (e, stackTrace) {
      AppLogger.debug('❌ [NutritionData] Failed to get meal by ID: $e');
      AppLogger.debug('🔍 [NutritionData] Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Delete a meal entry from local storage.
  ///
  /// Removes the meal by its ID.
  Future<void> deleteMealEntry(String mealId) async {
    try {
      AppLogger.debug('📊 [NutritionData] Deleting meal entry...');
      AppLogger.debug('🔍 [NutritionData] Meal ID: $mealId');
      
      final mealsBox = await _ensureMealsBox();
      if (!mealsBox.isOpen) {
        AppLogger.debug('⚠️ [NutritionData] Meals box is not open');
        throw Exception('Meals box not open');
      }
      
      await mealsBox.delete(mealId);
      
      AppLogger.debug('✅ [NutritionData] Meal deleted successfully');
    } catch (e, stackTrace) {
      AppLogger.debug('❌ [NutritionData] Failed to delete meal: $e');
      AppLogger.debug('🔍 [NutritionData] Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Delete all meals for a specific date.
  ///
  /// Useful for clearing a day's nutrition data.
  Future<void> deleteMealsByDate(DateTime date) async {
    try {
      AppLogger.debug('📊 [NutritionData] Deleting meals by date...');
      AppLogger.debug('🔍 [NutritionData] Date: ${date.year}-${date.month}-${date.day}');
      
      final mealsBox = await _ensureMealsBox();
      if (!mealsBox.isOpen) {
        AppLogger.debug('⚠️ [NutritionData] Meals box is not open');
        throw Exception('Meals box not open');
      }
      
      final meals = await getMealsByDate(date);
      AppLogger.debug('🔍 [NutritionData] Found ${meals.length} meals to delete');
      
      for (final meal in meals) {
        await mealsBox.delete(meal.id);
      }
      
      AppLogger.debug('✅ [NutritionData] Meals deleted successfully');
      AppLogger.debug('🔍 [NutritionData] Deleted ${meals.length} meals');
    } catch (e, stackTrace) {
      AppLogger.debug('❌ [NutritionData] Failed to delete meals by date: $e');
      AppLogger.debug('🔍 [NutritionData] Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Save nutrition targets to local storage.
  ///
  /// Stores targets under an account-scoped key (`current_<userId>`).
  /// The scope is [userId] when supplied, otherwise the owner carried
  /// by [targets]. The legacy `current` key is used only when neither
  /// value provides an account scope.
  Future<void> saveNutritionTargets(
    NutritionTargetsModel targets, {
    String? userId,
  }) async {
    try {
      AppLogger.debug('📊 [NutritionData] Saving nutrition targets...');
      AppLogger.debug('🔍 [NutritionData] Macros - Calories: ${targets.macros.calories}, Protein: ${targets.macros.protein}g');
      
      final targetsBox = await _ensureTargetsBox();
      if (!targetsBox.isOpen) {
        AppLogger.debug('⚠️ [NutritionData] Targets box is not open');
        throw Exception('Targets box not open');
      }
      
      final scopeUserId = RecordOwnershipRules.normalizeUserId(userId) ??
          RecordOwnershipRules.normalizeUserId(targets.userId);
      await targetsBox.put(
        scopeUserId == null ? targetsKey : _targetsKeyForUser(scopeUserId),
        targets.toJson(),
      );
      
      AppLogger.debug('✅ [NutritionData] Nutrition targets saved successfully');
      AppLogger.debug('🔍 [NutritionData] Macros - Calories: ${targets.macros.calories}, Protein: ${targets.macros.protein}g, Carbs: ${targets.macros.carbs}g, Fat: ${targets.macros.fats}g');
    } catch (e, stackTrace) {
      AppLogger.debug('❌ [NutritionData] Failed to save nutrition targets: $e');
      AppLogger.debug('🔍 [NutritionData] Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Get nutrition targets from local storage.
  ///
  /// Returns the account-scoped targets for [userId], or null if not set.
  /// A legacy `current` value is adopted only when its stored owner
  /// exactly matches [userId], or when it is legacy-unowned and no
  /// account-scoped target exists yet. It is never adopted from another
  /// account.
  Future<NutritionTargetsModel?> getNutritionTargets({String? userId}) async {
    try {
      AppLogger.debug('📊 [NutritionData] Getting nutrition targets...');
      
      final targetsBox = await _ensureTargetsBox();
      if (!targetsBox.isOpen) {
        AppLogger.debug('⚠️ [NutritionData] Targets box is not open');
        throw Exception('Targets box not open');
      }
      
      final scopeUserId = RecordOwnershipRules.normalizeUserId(userId);
      NutritionTargetsModel? targets;

      if (scopeUserId == null) {
        targets = _decodeTargets(targetsBox.get(targetsKey));
      } else {
        final scopedKey = _targetsKeyForUser(scopeUserId);
        targets = _decodeTargets(targetsBox.get(scopedKey));

        if (targets == null) {
          final legacyJson = targetsBox.get(targetsKey);
          final legacyTargets = _decodeTargets(legacyJson);
          if (legacyJson != null && legacyTargets != null) {
            final ownership = RecordOwnershipRules.classify(
              ownerId: legacyTargets.userId,
              currentUserId: scopeUserId,
            );
            final hasScopedTargets = targetsBox.keys.any(
              (key) => key.toString().startsWith('${targetsKey}_'),
            );
            final canAdopt =
                ownership == RecordOwnership.ownedByCurrentUser ||
                    (ownership == RecordOwnership.legacyUnowned &&
                        !hasScopedTargets);
            if (canAdopt) {
              await targetsBox.put(scopedKey, legacyJson);
              await targetsBox.delete(targetsKey);
              targets = legacyTargets;
            }
          }
        }
      }

      if (targets == null) {
        AppLogger.debug('⚠️ [NutritionData] No nutrition targets found');
        return null;
      }

      AppLogger.debug('✅ [NutritionData] Nutrition targets retrieved successfully');
      AppLogger.debug('🔍 [NutritionData] Macros - Calories: ${targets.macros.calories}, Protein: ${targets.macros.protein}g');

      return targets;
    } catch (e, stackTrace) {
      AppLogger.debug('❌ [NutritionData] Failed to get nutrition targets: $e');
      AppLogger.debug('🔍 [NutritionData] Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Delete the nutrition targets for [userId], or the legacy targets
  /// when no account scope is supplied.
  Future<void> deleteNutritionTargets({String? userId}) async {
    final targetsBox = await _ensureTargetsBox();
    if (!targetsBox.isOpen) {
      throw Exception('Targets box not open');
    }
    final scopeUserId = RecordOwnershipRules.normalizeUserId(userId);
    await targetsBox.delete(
      scopeUserId == null ? targetsKey : _targetsKeyForUser(scopeUserId),
    );
  }

  /// Clear local nutrition data.
  ///
  /// With [userId], removes only meals visible to that account
  /// (exact-owned and legacy-unowned) and that account's scoped
  /// targets. Meals and targets proven to belong to another account
  /// are preserved. Without [userId], preserves the previous
  /// whole-box clear for direct unscoped callers.
  Future<void> clearAllData({String? userId}) async {
    try {
      AppLogger.debug('📊 [NutritionData] Clearing nutrition data...');
      final scopeUserId = RecordOwnershipRules.normalizeUserId(userId);

      final mealsBox = await _ensureMealsBox();
      if (!mealsBox.isOpen) {
        AppLogger.debug('⚠️ [NutritionData] Meals box is not open');
      } else if (scopeUserId == null) {
        final mealsCount = mealsBox.length;
        await mealsBox.clear();
        AppLogger.debug('✅ [NutritionData] Meals box cleared ($mealsCount meals removed)');
      } else {
        var removedCount = 0;
        for (final meal in await getAllMeals()) {
          if (!RecordOwnershipRules.belongsToCurrentUser(
            ownerId: meal.userId,
            currentUserId: scopeUserId,
          )) {
            continue;
          }
          await mealsBox.delete(meal.id);
          removedCount++;
        }
        AppLogger.debug('✅ [NutritionData] Scoped meals cleared ($removedCount meals removed)');
      }

      final targetsBox = await _ensureTargetsBox();
      if (!targetsBox.isOpen) {
        AppLogger.debug('⚠️ [NutritionData] Targets box is not open');
      } else if (scopeUserId == null) {
        await targetsBox.clear();
        AppLogger.debug('✅ [NutritionData] Targets box cleared');
      } else {
        // Resolve/adopt a safely attributable legacy target first,
        // then delete only this account's scoped target key.
        await getNutritionTargets(userId: scopeUserId);
        await deleteNutritionTargets(userId: scopeUserId);
        AppLogger.debug('✅ [NutritionData] Scoped targets cleared');
      }

      AppLogger.debug('✅ [NutritionData] Nutrition data cleared successfully');
    } catch (e, stackTrace) {
      AppLogger.debug('❌ [NutritionData] Failed to clear all data: $e');
      AppLogger.debug('🔍 [NutritionData] Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Get count of meals in local storage.
  ///
  /// Useful for debugging and monitoring.
  Future<int> getMealCount() async {
    try {
      AppLogger.debug('📊 [NutritionData] Getting meal count...');
      
      final mealsBox = await _ensureMealsBox();
      if (!mealsBox.isOpen) {
        AppLogger.debug('⚠️ [NutritionData] Meals box is not open');
        throw Exception('Meals box not open');
      }
      
      final count = mealsBox.length;
      AppLogger.debug('✅ [NutritionData] Meal count retrieved successfully');
      AppLogger.debug('🔍 [NutritionData] Total meals: $count');
      
      return count;
    } catch (e, stackTrace) {
      AppLogger.debug('❌ [NutritionData] Failed to get meal count: $e');
      AppLogger.debug('🔍 [NutritionData] Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Check if local storage has any meals.
  ///
  /// Returns true if at least one meal is stored.
  Future<bool> hasMeals() async {
    try {
      AppLogger.debug('📊 [NutritionData] Checking if meals exist...');
      
      final mealsBox = await _ensureMealsBox();
      if (!mealsBox.isOpen) {
        AppLogger.debug('⚠️ [NutritionData] Meals box is not open');
        throw Exception('Meals box not open');
      }
      
      final hasData = mealsBox.isNotEmpty;
      AppLogger.debug('✅ [NutritionData] Meal check completed');
      AppLogger.debug('🔍 [NutritionData] Has meals: $hasData');
      
      return hasData;
    } catch (e, stackTrace) {
      AppLogger.debug('❌ [NutritionData] Failed to check meals: $e');
      AppLogger.debug('🔍 [NutritionData] Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Get all unique dates with meals.
  ///
  /// Useful for calendar views and history.
  Future<List<DateTime>> getAllMealDates() async {
    try {
      AppLogger.debug('📊 [NutritionData] Getting all meal dates...');
      
      final mealsBox = await _ensureMealsBox();
      if (!mealsBox.isOpen) {
        AppLogger.debug('⚠️ [NutritionData] Meals box is not open');
        throw Exception('Meals box not open');
      }
      
      final dates = <DateTime>{};
      for (final json in mealsBox.values) {
        final meal = MealModel.fromJson(deepCastMap(json));
        final mealDate = DateTime.parse(meal.timestamp);
        dates.add(DateTime(mealDate.year, mealDate.month, mealDate.day));
      }
      
      final sortedDates = dates.toList()..sort();
      AppLogger.debug('✅ [NutritionData] Meal dates retrieved successfully');
      AppLogger.debug('🔍 [NutritionData] Unique dates: ${sortedDates.length}');
      
      return sortedDates;
    } catch (e, stackTrace) {
      AppLogger.debug('❌ [NutritionData] Failed to get meal dates: $e');
      AppLogger.debug('🔍 [NutritionData] Stack trace: $stackTrace');
      rethrow;
    }
  }
}
