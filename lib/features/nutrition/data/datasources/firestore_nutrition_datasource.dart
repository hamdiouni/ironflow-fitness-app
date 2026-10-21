import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/config/firestore_paths.dart';
import '../models/meal_model.dart';
import '../models/nutrition_targets_model.dart';

/// Firestore datasource for nutrition data.
///
/// Handles cloud operations for:
/// - Saving meal entries
/// - Retrieving nutrition history
/// - Managing nutrition targets
/// - Syncing offline operations
class FirestoreNutritionDatasource {
  final FirebaseFirestore _firestore;

  FirestoreNutritionDatasource(this._firestore);

  /// Get the nutrition collection reference for a user.
  CollectionReference<Map<String, dynamic>> _getNutritionCollection(
    String userId,
  ) {
    return FirestorePaths.userCollection(
      _firestore,
      userId,
      FirestorePaths.nutrition,
    );
  }

  /// Get the nutrition targets document reference for a user.
  String _utcTimestampString(DateTime timestamp) =>
      timestamp.toUtc().toIso8601String();

  MealModel _mealFromDocument(
    QueryDocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = Map<String, dynamic>.from(document.data());
    final timestamp = data['timestamp'];
    if (timestamp is Timestamp) {
      data['timestamp'] = timestamp.toDate().toLocal().toIso8601String();
    } else if (timestamp is String) {
      data['timestamp'] = DateTime.parse(timestamp).toLocal().toIso8601String();
    }
    data['id'] = document.id;
    return MealModel.fromJson(data);
  }

  DocumentReference<Map<String, dynamic>> _getNutritionTargetsDoc(
    String userId,
  ) {
    return FirestorePaths.userDocument(
      _firestore,
      userId,
      FirestorePaths.nutrition,
      'targets',
    );
  }

  /// Save a meal entry to Firestore.
  ///
  /// Creates or updates a meal document in the user's nutrition collection.
  /// Uses the meal ID as the document ID for easy retrieval.
  Future<void> saveMealEntry(String userId, MealModel meal) async {
    try {
      await _getNutritionCollection(userId).doc(meal.id).set(
        {
          ...meal.toJson(),
          'id': meal.id,
          'timestamp': _utcTimestampString(DateTime.parse(meal.timestamp)),
          'userId': userId,
          'isDeleted': false,
          'syncUpdatedAt': FieldValue.serverTimestamp(),
          'syncedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error saving meal to Firestore: $e');
      }
      rethrow;
    }
  }

  /// Get all meals for a specific date from Firestore.
  ///
  /// Queries meals where the date matches the given date.
  /// Returns an empty list if no meals found.
  Future<List<MealModel>> getMealsByDate(
    String userId,
    DateTime date,
  ) async {
    try {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final snapshot = await _getNutritionCollection(userId)
          .where(
            'timestamp',
            isGreaterThanOrEqualTo: _utcTimestampString(startOfDay),
          )
          .where('timestamp', isLessThan: _utcTimestampString(endOfDay))
          .get();

      return snapshot.docs
          .where((document) => document.data()['isDeleted'] != true)
          .map(_mealFromDocument)
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting meals by date from Firestore: $e');
      }
      rethrow;
    }
  }

  /// Get all meals for a date range from Firestore.
  ///
  /// Queries meals between [startDate] and [endDate].
  /// Useful for analytics and history views.
  Future<List<MealModel>> getMealsByDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final snapshot = await _getNutritionCollection(userId)
          .where(
            'timestamp',
            isGreaterThanOrEqualTo: _utcTimestampString(startDate),
          )
          .where('timestamp', isLessThan: _utcTimestampString(endDate))
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs
          .where((document) => document.data()['isDeleted'] != true)
          .map(_mealFromDocument)
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting meals by date range from Firestore: $e');
      }
      rethrow;
    }
  }

  /// Delete a meal entry from Firestore.
  ///
  /// Marks the meal as deleted so other devices can observe the change.
  Future<void> deleteMealEntry(String userId, String mealId) async {
    try {
      await _getNutritionCollection(userId).doc(mealId).set(
        {
          'id': mealId,
          'userId': userId,
          'isDeleted': true,
          'syncUpdatedAt': FieldValue.serverTimestamp(),
          'syncedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting meal from Firestore: $e');
      }
      rethrow;
    }
  }

  /// Save nutrition targets to Firestore.
  ///
  /// Stores the user's daily nutrition targets in a special 'targets' document.
  /// Targets include macros, micros, vitamins, and minerals.
  Future<void> saveNutritionTargets(
    String userId,
    NutritionTargetsModel targets,
  ) async {
    try {
      await _getNutritionTargetsDoc(userId).set(
        {
          ...targets.toJson(),
          'syncUpdatedAt': FieldValue.serverTimestamp(),
          'syncedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error saving nutrition targets to Firestore: $e');
      }
      rethrow;
    }
  }

  /// Get nutrition targets from Firestore.
  ///
  /// Retrieves the user's daily nutrition targets.
  /// Returns null if targets haven't been set.
  Future<NutritionTargetsModel?> getNutritionTargets(String userId) async {
    try {
      final doc = await _getNutritionTargetsDoc(userId).get();
      if (!doc.exists) {
        return null;
      }
      return NutritionTargetsModel.fromJson(doc.data() ?? {});
    } catch (e) {
      if (kDebugMode) {
        print('Error getting nutrition targets from Firestore: $e');
      }
      rethrow;
    }
  }

  /// Get daily nutrition summary from Firestore.
  ///
  /// Aggregates all meals for a date and returns totals.
  Future<Map<String, dynamic>> getDailyNutritionSummary(
    String userId,
    DateTime date,
  ) async {
    try {
      final meals = await getMealsByDate(userId, date);
      
      // Calculate totals
      double totalCalories = 0;
      double totalProtein = 0;
      double totalCarbs = 0;
      double totalFats = 0;
      double totalFiber = 0;
      double totalSugar = 0;
      double totalSodium = 0;
      double totalPotassium = 0;
      double totalVitaminA = 0;
      double totalVitaminB = 0;
      double totalVitaminC = 0;
      double totalVitaminD = 0;
      double totalVitaminE = 0;
      double totalCalcium = 0;
      double totalIron = 0;
      double totalMagnesium = 0;
      double totalZinc = 0;

      for (final meal in meals) {
        totalCalories += meal.macros.calories;
        totalProtein += meal.macros.protein;
        totalCarbs += meal.macros.carbs;
        totalFats += meal.macros.fats;
        totalFiber += meal.micros.fiber;
        totalSugar += meal.micros.sugar;
        totalSodium += meal.micros.sodium;
        totalPotassium += meal.micros.potassium;
        totalVitaminA += meal.vitamins.vitaminA;
        totalVitaminB += meal.vitamins.vitaminB;
        totalVitaminC += meal.vitamins.vitaminC;
        totalVitaminD += meal.vitamins.vitaminD;
        totalVitaminE += meal.vitamins.vitaminE;
        totalCalcium += meal.minerals.calcium;
        totalIron += meal.minerals.iron;
        totalMagnesium += meal.minerals.magnesium;
        totalZinc += meal.minerals.zinc;
      }

      return {
        'date': date.toIso8601String(),
        'mealCount': meals.length,
        'totals': {
          'macros': {
            'calories': totalCalories,
            'protein': totalProtein,
            'carbs': totalCarbs,
            'fats': totalFats,
          },
          'micros': {
            'fiber': totalFiber,
            'sugar': totalSugar,
            'sodium': totalSodium,
            'potassium': totalPotassium,
          },
          'vitamins': {
            'vitaminA': totalVitaminA,
            'vitaminB': totalVitaminB,
            'vitaminC': totalVitaminC,
            'vitaminD': totalVitaminD,
            'vitaminE': totalVitaminE,
          },
          'minerals': {
            'calcium': totalCalcium,
            'iron': totalIron,
            'magnesium': totalMagnesium,
            'zinc': totalZinc,
          },
        },
      };
    } catch (e) {
      if (kDebugMode) {
        print('Error getting daily nutrition summary from Firestore: $e');
      }
      rethrow;
    }
  }

  /// Batch save multiple meal entries.
  ///
  /// Useful for syncing offline operations.
  /// Uses a batch write for efficiency.
  Future<void> batchSaveMeals(String userId, List<MealModel> meals) async {
    try {
      final batch = _firestore.batch();
      for (final meal in meals) {
        final docRef = _getNutritionCollection(userId).doc(meal.id);
        batch.set(
          docRef,
          {
            ...meal.toJson(),
            'id': meal.id,
            'timestamp': _utcTimestampString(DateTime.parse(meal.timestamp)),
            'userId': userId,
            'isDeleted': false,
            'syncUpdatedAt': FieldValue.serverTimestamp(),
            'syncedAt': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );
      }
      await batch.commit();
    } catch (e) {
      if (kDebugMode) {
        print('Error batch saving meals to Firestore: $e');
      }
      rethrow;
    }
  }

  /// Batch delete multiple meal entries.
  ///
  /// Useful for syncing offline deletions.
  Future<void> batchDeleteMeals(String userId, List<String> mealIds) async {
    try {
      final batch = _firestore.batch();
      for (final mealId in mealIds) {
        final docRef = _getNutritionCollection(userId).doc(mealId);
        batch.set(
          docRef,
          {
            'id': mealId,
            'userId': userId,
            'isDeleted': true,
            'syncUpdatedAt': FieldValue.serverTimestamp(),
            'syncedAt': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );
      }
      await batch.commit();
    } catch (e) {
      if (kDebugMode) {
        print('Error batch deleting meals from Firestore: $e');
      }
      rethrow;
    }
  }
}
