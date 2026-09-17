import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../workout/data/models/workout_model.dart';
import '../../../workout/data/models/program_model.dart';

/// Data source for syncing data to/from Firestore
abstract class FirestoreSyncDataSource {
  // Workouts
  Future<void> syncWorkout(String userId, WorkoutModel workout);
  Future<List<WorkoutModel>> getWorkouts(String userId, {DateTime? since});
  Future<void> deleteWorkout(String userId, String workoutId);

  // Programs
  Future<void> syncProgram(String userId, ProgramModel program);
  Future<ProgramModel?> getActiveProgram(String userId);
  Future<void> deleteProgram(String userId, String programId);

  // Nutrition (simplified for now)
  Future<void> syncNutritionLog(String userId, Map<String, dynamic> log);
  Future<List<Map<String, dynamic>>> getNutritionLogs(String userId, {DateTime? since});

  // Body Progress
  Future<void> syncBodyProgress(String userId, Map<String, dynamic> progress);
  Future<List<Map<String, dynamic>>> getBodyProgress(String userId, {DateTime? since});

  // Sync metadata
  Future<DateTime?> getLastSyncTime(String userId, String dataType);
  Future<void> updateLastSyncTime(String userId, String dataType, DateTime time);
}

class FirestoreSyncDataSourceImpl implements FirestoreSyncDataSource {
  final FirebaseFirestore _firestore;

  FirestoreSyncDataSourceImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // Collection names
  static const String _workoutsCollection = 'workouts';
  static const String _programsCollection = 'programs';
  static const String _nutritionCollection = 'nutrition';
  static const String _bodyProgressCollection = 'body_progress';
  static const String _syncMetadataCollection = 'sync_metadata';

  @override
  Future<void> syncWorkout(String userId, WorkoutModel workout) async {
    try {
      await _firestore
          .collection(_workoutsCollection)
          .doc(workout.id)
          .set({
        ...workout.toJson(),
        'userId': userId,
        'syncedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to sync workout: $e');
    }
  }

  @override
  Future<List<WorkoutModel>> getWorkouts(String userId, {DateTime? since}) async {
    try {
      Query query = _firestore
          .collection(_workoutsCollection)
          .where('userId', isEqualTo: userId)
          .orderBy('date', descending: true);

      if (since != null) {
        query = query.where('syncedAt', isGreaterThan: Timestamp.fromDate(since));
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => WorkoutModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to get workouts: $e');
    }
  }

  @override
  Future<void> deleteWorkout(String userId, String workoutId) async {
    try {
      await _firestore.collection(_workoutsCollection).doc(workoutId).delete();
    } catch (e) {
      throw Exception('Failed to delete workout: $e');
    }
  }

  @override
  Future<void> syncProgram(String userId, ProgramModel program) async {
    try {
      await _firestore
          .collection(_programsCollection)
          .doc(program.id)
          .set({
        ...program.toJson(),
        'userId': userId,
        'syncedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to sync program: $e');
    }
  }

  @override
  Future<ProgramModel?> getActiveProgram(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(_programsCollection)
          .where('userId', isEqualTo: userId)
          .where('isActive', isEqualTo: true)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        return null;
      }

      return ProgramModel.fromJson(snapshot.docs.first.data());
    } catch (e) {
      throw Exception('Failed to get active program: $e');
    }
  }

  @override
  Future<void> deleteProgram(String userId, String programId) async {
    try {
      await _firestore.collection(_programsCollection).doc(programId).delete();
    } catch (e) {
      throw Exception('Failed to delete program: $e');
    }
  }

  @override
  Future<void> syncNutritionLog(String userId, Map<String, dynamic> log) async {
    try {
      await _firestore
          .collection(_nutritionCollection)
          .doc(log['id'] as String)
          .set({
        ...log,
        'userId': userId,
        'syncedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to sync nutrition log: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getNutritionLogs(
    String userId, {
    DateTime? since,
  }) async {
    try {
      Query query = _firestore
          .collection(_nutritionCollection)
          .where('userId', isEqualTo: userId)
          .orderBy('date', descending: true);

      if (since != null) {
        query = query.where('syncedAt', isGreaterThan: Timestamp.fromDate(since));
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      throw Exception('Failed to get nutrition logs: $e');
    }
  }

  @override
  Future<void> syncBodyProgress(String userId, Map<String, dynamic> progress) async {
    try {
      await _firestore
          .collection(_bodyProgressCollection)
          .doc(progress['id'] as String)
          .set({
        ...progress,
        'userId': userId,
        'syncedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to sync body progress: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getBodyProgress(
    String userId, {
    DateTime? since,
  }) async {
    try {
      Query query = _firestore
          .collection(_bodyProgressCollection)
          .where('userId', isEqualTo: userId)
          .orderBy('date', descending: true);

      if (since != null) {
        query = query.where('syncedAt', isGreaterThan: Timestamp.fromDate(since));
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      throw Exception('Failed to get body progress: $e');
    }
  }

  @override
  Future<DateTime?> getLastSyncTime(String userId, String dataType) async {
    try {
      final doc = await _firestore
          .collection(_syncMetadataCollection)
          .doc('$userId\_$dataType')
          .get();

      if (!doc.exists) {
        return null;
      }

      final timestamp = doc.data()?['lastSyncTime'] as Timestamp?;
      return timestamp?.toDate();
    } catch (e) {
      print('Failed to get last sync time: $e');
      return null;
    }
  }

  @override
  Future<void> updateLastSyncTime(
    String userId,
    String dataType,
    DateTime time,
  ) async {
    try {
      await _firestore
          .collection(_syncMetadataCollection)
          .doc('$userId\_$dataType')
          .set({
        'userId': userId,
        'dataType': dataType,
        'lastSyncTime': Timestamp.fromDate(time),
      }, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to update last sync time: $e');
    }
  }
}
