import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../../../../core/data/datasources/user_datasource.dart';

/// Firebase Realtime Database implementation for user data
/// NO BILLING REQUIRED - Uses Firebase Realtime Database free tier
class RealtimeDbUserDataSource implements UserDataSource {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  @override
  Future<void> saveUser(UserModel user) async {
    try {
      await _database.child('users').child(user.id).set(user.toJson());
      if (kDebugMode) {
        print('✓ [RealtimeDB] User saved: ${user.id}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ [RealtimeDB] Error saving user: $e');
      }
      rethrow;
    }
  }

  @override
  Future<UserModel?> getUser(String userId) async {
    try {
      final snapshot = await _database.child('users').child(userId).get();
      
      if (!snapshot.exists) {
        if (kDebugMode) {
          print('ℹ️ [RealtimeDB] User not found: $userId');
        }
        return null;
      }

      final data = Map<String, dynamic>.from(snapshot.value as Map);
      if (kDebugMode) {
        print('✓ [RealtimeDB] User loaded: $userId');
      }
      return UserModel.fromJson(data);
    } catch (e) {
      if (kDebugMode) {
        print('❌ [RealtimeDB] Error loading user: $e');
      }
      rethrow;
    }
  }

  @override
  Future<void> updateUser(UserModel user) async {
    try {
      await _database.child('users').child(user.id).update(user.toJson());
      if (kDebugMode) {
        print('✓ [RealtimeDB] User updated: ${user.id}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ [RealtimeDB] Error updating user: $e');
      }
      rethrow;
    }
  }

  @override
  Future<void> deleteUser(String userId) async {
    try {
      await _database.child('users').child(userId).remove();
      if (kDebugMode) {
        print('✓ [RealtimeDB] User deleted: $userId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ [RealtimeDB] Error deleting user: $e');
      }
      rethrow;
    }
  }

  /// Listen to real-time updates for a user
  Stream<UserModel?> watchUser(String userId) {
    return _database.child('users').child(userId).onValue.map((event) {
      if (!event.snapshot.exists) {
        return null;
      }
      final data = Map<String, dynamic>.from(event.snapshot.value as Map);
      return UserModel.fromJson(data);
    });
  }

  /// Save workout data to Realtime Database
  Future<void> saveWorkout(String userId, String workoutId, Map<String, dynamic> workoutData) async {
    try {
      await _database
          .child('users')
          .child(userId)
          .child('workouts')
          .child(workoutId)
          .set(workoutData);
      if (kDebugMode) {
        print('✓ [RealtimeDB] Workout saved: $workoutId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ [RealtimeDB] Error saving workout: $e');
      }
      rethrow;
    }
  }

  /// Get all workouts for a user
  Future<List<Map<String, dynamic>>> getWorkouts(String userId) async {
    try {
      final snapshot = await _database
          .child('users')
          .child(userId)
          .child('workouts')
          .get();

      if (!snapshot.exists) {
        return [];
      }

      final workoutsMap = Map<String, dynamic>.from(snapshot.value as Map);
      final workouts = workoutsMap.entries.map((entry) {
        final workout = Map<String, dynamic>.from(entry.value as Map);
        workout['id'] = entry.key;
        return workout;
      }).toList();

      if (kDebugMode) {
        print('✓ [RealtimeDB] Loaded ${workouts.length} workouts');
      }
      return workouts;
    } catch (e) {
      if (kDebugMode) {
        print('❌ [RealtimeDB] Error loading workouts: $e');
      }
      rethrow;
    }
  }

  /// Save nutrition data to Realtime Database
  Future<void> saveNutrition(String userId, String date, Map<String, dynamic> nutritionData) async {
    try {
      await _database
          .child('users')
          .child(userId)
          .child('nutrition')
          .child(date)
          .set(nutritionData);
      if (kDebugMode) {
        print('✓ [RealtimeDB] Nutrition saved for: $date');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ [RealtimeDB] Error saving nutrition: $e');
      }
      rethrow;
    }
  }

  /// Get nutrition data for a date range
  Future<List<Map<String, dynamic>>> getNutrition(String userId, String startDate, String endDate) async {
    try {
      final snapshot = await _database
          .child('users')
          .child(userId)
          .child('nutrition')
          .orderByKey()
          .startAt(startDate)
          .endAt(endDate)
          .get();

      if (!snapshot.exists) {
        return [];
      }

      final nutritionMap = Map<String, dynamic>.from(snapshot.value as Map);
      final nutrition = nutritionMap.entries.map((entry) {
        final data = Map<String, dynamic>.from(entry.value as Map);
        data['date'] = entry.key;
        return data;
      }).toList();

      if (kDebugMode) {
        print('✓ [RealtimeDB] Loaded ${nutrition.length} nutrition entries');
      }
      return nutrition;
    } catch (e) {
      if (kDebugMode) {
        print('❌ [RealtimeDB] Error loading nutrition: $e');
      }
      rethrow;
    }
  }

  /// Save progress data to Realtime Database
  Future<void> saveProgress(String userId, String progressId, Map<String, dynamic> progressData) async {
    try {
      await _database
          .child('users')
          .child(userId)
          .child('progress')
          .child(progressId)
          .set(progressData);
      if (kDebugMode) {
        print('✓ [RealtimeDB] Progress saved: $progressId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ [RealtimeDB] Error saving progress: $e');
      }
      rethrow;
    }
  }

  /// Get all progress entries for a user
  Future<List<Map<String, dynamic>>> getProgress(String userId) async {
    try {
      final snapshot = await _database
          .child('users')
          .child(userId)
          .child('progress')
          .get();

      if (!snapshot.exists) {
        return [];
      }

      final progressMap = Map<String, dynamic>.from(snapshot.value as Map);
      final progress = progressMap.entries.map((entry) {
        final data = Map<String, dynamic>.from(entry.value as Map);
        data['id'] = entry.key;
        return data;
      }).toList();

      if (kDebugMode) {
        print('✓ [RealtimeDB] Loaded ${progress.length} progress entries');
      }
      return progress;
    } catch (e) {
      if (kDebugMode) {
        print('❌ [RealtimeDB] Error loading progress: $e');
      }
      rethrow;
    }
  }
}
