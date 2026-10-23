import 'package:progression_tracker/core/utils/app_logger.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../workout/data/models/workout_model.dart';
import '../../../workout/data/models/active_program_model.dart';
import '../../../nutrition/data/models/meal_model.dart';
import '../../../nutrition/data/models/nutrition_targets_model.dart';
import '../../../body/data/models/body_entry_model.dart';

/// THE cloud layout (Phase 2, DATABASE_AND_SYNC_AUDIT F-02).
///
/// Exactly one layout exists for syncable data — flat top-level
/// collections, one document per record, ownership in the `userId` field
/// (enforced by `firestore.rules` via `readsOwnDoc()`/`writesOwnDoc()`),
/// and a server `syncedAt` timestamp on every document, which is the
/// pull cursor field:
///
/// - `workouts/{workoutId}`        — WorkoutModel JSON
/// - `programs/{activeProgramId}`  — ActiveProgramModel JSON (full state:
///   program definition + day index + completed days, not just the plan)
/// - `nutrition/{mealId}`          — MealModel JSON
/// - `body_progress/{entryId}`     — BodyEntryModel JSON
/// - `nutrition_targets/{userId}`  — NutritionTargetsModel JSON (singleton)
///
/// The per-user `users/{uid}/…` tree remains only for auth profile data
/// and backups (not outbox-synced aggregates).
///
/// Deletes are **tombstones**: the document is merged with
/// `{userId, deletedAt, syncedAt}` instead of being removed, so other
/// devices observe the deletion on their next pull (F-11) instead of
/// resurrecting the record. Pull queries therefore return tombstones
/// too; [SyncService] applies them as local deletes.
///
/// Pull cursors are deliberately NOT stored here: a cursor is
/// per-device state ("what has *this* device seen"), so it lives in
/// local storage (see HiveSyncQueueDataSource.getCursor). The previous
/// cloud-side `sync_metadata` cursor let one device's pulls hide data
/// from another device.
abstract class FirestoreSyncDataSource {
  // Workouts
  Future<void> syncWorkout(String userId, WorkoutModel workout);
  Future<List<WorkoutModel>> getWorkouts(String userId, {DateTime? since});
  Future<void> deleteWorkout(String userId, String workoutId);

  // Active program (full state)
  Future<void> syncActiveProgram(String userId, ActiveProgramModel program);
  Future<ActiveProgramModel?> getActiveProgram(String userId, {DateTime? since});
  Future<void> deleteProgram(String userId, String programId);

  // Meals
  Future<void> syncMeal(String userId, MealModel meal);
  Future<List<MealModel>> getMeals(String userId, {DateTime? since});
  Future<void> deleteMeal(String userId, String mealId);

  // Body entries
  Future<void> syncBodyEntry(String userId, BodyEntryModel entry);
  Future<List<BodyEntryModel>> getBodyEntries(String userId, {DateTime? since});
  Future<void> deleteBodyEntry(String userId, String entryId);

  // Nutrition targets (singleton document per user)
  Future<void> syncNutritionTargets(String userId, NutritionTargetsModel targets);
  Future<NutritionTargetsModel?> getNutritionTargets(String userId);
}

class FirestoreSyncDataSourceImpl implements FirestoreSyncDataSource {
  final FirebaseFirestore _firestore;

  FirestoreSyncDataSourceImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // Collection names — the single source of truth for the cloud layout.
  static const String workoutsCollection = 'workouts';
  static const String programsCollection = 'programs';
  static const String nutritionCollection = 'nutrition';
  static const String bodyProgressCollection = 'body_progress';
  static const String nutritionTargetsCollection = 'nutrition_targets';

  // ---------------------------------------------------------------------------
  // Workouts
  // ---------------------------------------------------------------------------

  @override
  Future<void> syncWorkout(String userId, WorkoutModel workout) async {
    try {
      await _firestore.collection(workoutsCollection).doc(workout.id).set({
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
      final snapshot = await _pullQuery(
        collection: workoutsCollection,
        userId: userId,
        since: since,
        fallbackOrderField: 'date',
      ).get();
      return _parseDocs(snapshot, WorkoutModel.fromJson, 'workout');
    } catch (e) {
      throw Exception('Failed to get workouts: $e');
    }
  }

  @override
  Future<void> deleteWorkout(String userId, String workoutId) async {
    await _tombstone(workoutsCollection, userId, workoutId);
  }

  // ---------------------------------------------------------------------------
  // Active program
  // ---------------------------------------------------------------------------

  @override
  Future<void> syncActiveProgram(String userId, ActiveProgramModel program) async {
    try {
      await _firestore.collection(programsCollection).doc(program.id).set({
        ...program.toJson(),
        'userId': userId,
        'syncedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to sync program: $e');
    }
  }

  @override
  Future<ActiveProgramModel?> getActiveProgram(String userId, {DateTime? since}) async {
    try {
      // ActiveProgramModel JSON carries `isActive`, so this filter now
      // matches what syncActiveProgram writes (the previous bare
      // WorkoutProgramModel payload had no isActive field and this query
      // could never return anything).
      Query query = _firestore
          .collection(programsCollection)
          .where('userId', isEqualTo: userId)
          .where('isActive', isEqualTo: true);

      if (since != null) {
        query = query.where('syncedAt', isGreaterThan: Timestamp.fromDate(since));
      }

      final snapshot = await query.limit(1).get();
      if (snapshot.docs.isEmpty) return null;

      try {
        return ActiveProgramModel.fromJson(
          snapshot.docs.first.data() as Map<String, dynamic>,
        );
      } catch (e) {
        AppLogger.debug('Skipping unparseable program doc: $e');
        return null;
      }
    } catch (e) {
      throw Exception('Failed to get active program: $e');
    }
  }

  @override
  Future<void> deleteProgram(String userId, String programId) async {
    try {
      // Hard delete is fine for the program: pulls query for existence,
      // so a missing document cannot resurrect local state (unlike the
      // cursor-based collection pulls, which need tombstones).
      await _firestore.collection(programsCollection).doc(programId).delete();
    } catch (e) {
      throw Exception('Failed to delete program: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // Meals
  // ---------------------------------------------------------------------------

  @override
  Future<void> syncMeal(String userId, MealModel meal) async {
    try {
      await _firestore.collection(nutritionCollection).doc(meal.id).set({
        ...meal.toJson(),
        'userId': userId,
        'syncedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to sync meal: $e');
    }
  }

  @override
  Future<List<MealModel>> getMeals(String userId, {DateTime? since}) async {
    try {
      final snapshot = await _pullQuery(
        collection: nutritionCollection,
        userId: userId,
        since: since,
        // MealModel's date field is `timestamp` (the old query ordered by
        // a nonexistent `date` field, which silently excluded every doc).
        fallbackOrderField: 'timestamp',
      ).get();
      return _parseDocs(snapshot, MealModel.fromJson, 'meal');
    } catch (e) {
      throw Exception('Failed to get meals: $e');
    }
  }

  @override
  Future<void> deleteMeal(String userId, String mealId) async {
    await _tombstone(nutritionCollection, userId, mealId);
  }

  // ---------------------------------------------------------------------------
  // Body entries
  // ---------------------------------------------------------------------------

  @override
  Future<void> syncBodyEntry(String userId, BodyEntryModel entry) async {
    try {
      await _firestore.collection(bodyProgressCollection).doc(entry.id).set({
        ...entry.toJson(),
        'userId': userId,
        'syncedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to sync body entry: $e');
    }
  }

  @override
  Future<List<BodyEntryModel>> getBodyEntries(String userId, {DateTime? since}) async {
    try {
      final snapshot = await _pullQuery(
        collection: bodyProgressCollection,
        userId: userId,
        since: since,
        fallbackOrderField: 'date',
      ).get();
      return _parseDocs(snapshot, BodyEntryModel.fromJson, 'body entry');
    } catch (e) {
      throw Exception('Failed to get body entries: $e');
    }
  }

  @override
  Future<void> deleteBodyEntry(String userId, String entryId) async {
    await _tombstone(bodyProgressCollection, userId, entryId);
  }

  // ---------------------------------------------------------------------------
  // Nutrition targets (singleton)
  // ---------------------------------------------------------------------------

  @override
  Future<void> syncNutritionTargets(
    String userId,
    NutritionTargetsModel targets,
  ) async {
    try {
      await _firestore.collection(nutritionTargetsCollection).doc(userId).set({
        ...targets.toJson(),
        'userId': userId,
        'syncedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to sync nutrition targets: $e');
    }
  }

  @override
  Future<NutritionTargetsModel?> getNutritionTargets(String userId) async {
    try {
      // Singleton: a direct document read each pull (cheap, no cursor).
      final doc =
          await _firestore.collection(nutritionTargetsCollection).doc(userId).get();
      if (!doc.exists) return null;
      return NutritionTargetsModel.fromJson(doc.data() as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to get nutrition targets: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  /// Builds an incremental pull query.
  ///
  /// Firestore requires the first `orderBy` to be on the inequality
  /// field, so cursor pulls order by `syncedAt`; full pulls order by the
  /// entity's own date field. (The old queries combined
  /// `where(syncedAt >)` with `orderBy(date)`, which Firestore rejects.)
  Query _pullQuery({
    required String collection,
    required String userId,
    required DateTime? since,
    required String fallbackOrderField,
  }) {
    Query query =
        _firestore.collection(collection).where('userId', isEqualTo: userId);
    if (since != null) {
      query = query
          .where('syncedAt', isGreaterThan: Timestamp.fromDate(since))
          .orderBy('syncedAt');
    } else {
      query = query.orderBy(fallbackOrderField, descending: true);
    }
    return query;
  }

  /// Parses query documents, skipping (not failing on) individual bad
  /// documents — e.g. a tombstone stub written for a record that was
  /// deleted before its first sync carries only {userId, deletedAt,
  /// syncedAt} and cannot parse as a full model; other devices never
  /// saw that record, so skipping it is correct.
  List<T> _parseDocs<T>(
    QuerySnapshot snapshot,
    T Function(Map<String, dynamic>) fromJson,
    String label,
  ) {
    final results = <T>[];
    for (final doc in snapshot.docs) {
      try {
        results.add(fromJson(doc.data() as Map<String, dynamic>));
      } catch (e) {
        AppLogger.debug('Skipping unparseable $label doc ${doc.id}: $e');
      }
    }
    return results;
  }

  /// Writes a tombstone: merges deletion markers into the existing
  /// document (keeping its full payload parseable) and bumps `syncedAt`
  /// so cursor pulls on other devices observe the deletion.
  Future<void> _tombstone(String collection, String userId, String docId) async {
    try {
      await _firestore.collection(collection).doc(docId).set({
        'userId': userId,
        'deletedAt': DateTime.now().toIso8601String(),
        'syncedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to tombstone $collection/$docId: $e');
    }
  }
}
