import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/config/firestore_paths.dart';
import '../../../../core/models/sync_operation.dart';
import '../../../workout/data/models/active_program_model.dart';
import '../../../workout/data/models/workout_model.dart';

/// Remote data source for user-owned records.
///
/// The UID is part of every document path (`users/{uid}/...`), rather than
/// relying only on a `userId` field in a top-level collection. This mirrors
/// [FirestorePaths] and the repository's Firestore security rules.
abstract class FirestoreSyncDataSource {
  // Workouts
  Future<void> syncWorkout(String userId, WorkoutModel workout);
  Future<List<WorkoutModel>> getWorkouts(String userId, {DateTime? since});
  Future<List<String>> getDeletedWorkoutIds(String userId);
  Future<void> deleteWorkout(String userId, String workoutId);

  // The synchronized program is the stateful active program, not just the
  // program template. It includes day position, completion dates and active
  // status so those values survive reinstall/device changes.
  Future<void> syncProgram(String userId, ActiveProgramModel program);
  Future<ActiveProgramModel?> getActiveProgram(
    String userId, {
    DateTime? since,
  });
  Future<void> deleteProgram(String userId, String programId);

  // Nutrition
  Future<void> syncNutritionLog(String userId, Map<String, dynamic> log);
  Future<List<Map<String, dynamic>>> getNutritionLogs(
    String userId, {
    DateTime? since,
  });
  Future<List<String>> getDeletedNutritionLogIds(String userId);
  Future<void> deleteNutritionLog(String userId, String mealId);
  Future<void> syncNutritionTargets(
    String userId,
    Map<String, dynamic> targets,
  );
  Future<Map<String, dynamic>?> getNutritionTargets(String userId);

  // Body progress
  Future<void> syncBodyProgress(
    String userId,
    Map<String, dynamic> progress,
  );
  Future<List<Map<String, dynamic>>> getBodyProgress(
    String userId, {
    DateTime? since,
  });
  Future<List<String>> getDeletedBodyProgressIds(String userId);
  Future<void> deleteBodyProgress(String userId, String entryId);

  // Sync metadata
  Future<DateTime?> getLastSyncTime(String userId, String dataType);
  Future<void> updateLastSyncTime(String userId, String dataType, DateTime time);

  // Batch sync for the legacy operation queue. Each operation must carry its
  // owner UID and a supported collection name.
  Future<void> syncBatch(List<SyncOperation> operations);
}

class FirestoreSyncDataSourceImpl implements FirestoreSyncDataSource {
  final FirebaseFirestore _firestore;

  FirestoreSyncDataSourceImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  static const Set<String> _userCollections = {
    FirestorePaths.workouts,
    FirestorePaths.programs,
    FirestorePaths.nutrition,
    FirestorePaths.bodyProgress,
  };

  CollectionReference<Map<String, dynamic>> _userCollection(
    String userId,
    String collection,
  ) =>
      FirestorePaths.userCollection(_firestore, userId, collection);

  Map<String, dynamic> _withDocumentId(
    QueryDocumentSnapshot<Map<String, dynamic>> document,
  ) =>
      <String, dynamic>{...document.data(), 'id': document.id};

  @override
  Future<void> syncWorkout(String userId, WorkoutModel workout) async {
    try {
      await _userCollection(userId, FirestorePaths.workouts)
          .doc(workout.id)
          .set(
        {
          ...workout.toJson(),
          'id': workout.id,
          'userId': userId,
          'isDeleted': false,
          'syncUpdatedAt': FieldValue.serverTimestamp(),
          'syncedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    } catch (e) {
      throw Exception('Failed to sync workout ${workout.id}: $e');
    }
  }

  @override
  Future<List<WorkoutModel>> getWorkouts(
    String userId, {
    DateTime? since,
  }) async {
    try {
      Query<Map<String, dynamic>> query =
          _userCollection(userId, FirestorePaths.workouts);

      if (since != null) {
        query = query.where(
          'syncUpdatedAt',
          isGreaterThan: Timestamp.fromDate(since),
        );
      }

      final snapshot = await query.get();
      return snapshot.docs
          .where((document) => document.data()['isDeleted'] != true)
          .map((document) => WorkoutModel.fromJson(_withDocumentId(document)))
          .toList();
    } catch (e) {
      throw Exception('Failed to get workouts for user $userId: $e');
    }
  }

  @override
  Future<List<String>> getDeletedWorkoutIds(String userId) async {
    try {
      final snapshot = await _userCollection(userId, FirestorePaths.workouts)
          .where('isDeleted', isEqualTo: true)
          .get();
      return snapshot.docs.map((document) => document.id).toList();
    } catch (e) {
      throw Exception('Failed to get deleted workouts for user $userId: $e');
    }
  }

  @override
  Future<void> deleteWorkout(String userId, String workoutId) async {
    try {
      await _userCollection(userId, FirestorePaths.workouts)
          .doc(workoutId)
          .set(
        {
          'id': workoutId,
          'userId': userId,
          'isDeleted': true,
          'syncUpdatedAt': FieldValue.serverTimestamp(),
          'syncedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    } catch (e) {
      throw Exception('Failed to delete workout $workoutId: $e');
    }
  }

  @override
  Future<void> syncProgram(String userId, ActiveProgramModel program) async {
    try {
      await _userCollection(userId, FirestorePaths.programs)
          .doc(program.id)
          .set(
        {
          ...program.toJson(),
          'id': program.id,
          'userId': userId,
          'syncUpdatedAt': FieldValue.serverTimestamp(),
          'syncedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    } catch (e) {
      throw Exception('Failed to sync active program ${program.id}: $e');
    }
  }

  @override
  Future<ActiveProgramModel?> getActiveProgram(
    String userId, {
    DateTime? since,
  }) async {
    try {
      // There is normally only one active program per user. Filter the small
      // user-scoped collection in memory to avoid requiring a composite index
      // for (isActive, syncUpdatedAt).
      final snapshot = await _userCollection(
        userId,
        FirestorePaths.programs,
      ).get();
      final candidates = snapshot.docs.where((document) {
        final data = document.data();
        if (since == null) return true;
        final updatedAt = data['syncUpdatedAt'];
        return updatedAt is Timestamp && updatedAt.toDate().isAfter(since);
      }).toList();
      if (candidates.isEmpty) return null;

      candidates.sort((a, b) {
        final aTime = a.data()['syncUpdatedAt'];
        final bTime = b.data()['syncUpdatedAt'];
        if (aTime is Timestamp && bTime is Timestamp) {
          final timeOrder = bTime.compareTo(aTime);
          if (timeOrder != 0) return timeOrder;
        }

        // If a replacement and the preceding inactive state share a server
        // timestamp, keep the active program as the current state.
        final aIsActive = a.data()['isActive'] == true;
        final bIsActive = b.data()['isActive'] == true;
        if (aIsActive != bIsActive) return aIsActive ? -1 : 1;
        return a.id.compareTo(b.id);
      });
      return ActiveProgramModel.fromJson(_withDocumentId(candidates.first));
    } catch (e) {
      throw Exception('Failed to get active program for user $userId: $e');
    }
  }

  @override
  Future<void> deleteProgram(String userId, String programId) async {
    try {
      await _userCollection(userId, FirestorePaths.programs)
          .doc(programId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete program $programId: $e');
    }
  }

  @override
  Future<void> syncNutritionLog(
    String userId,
    Map<String, dynamic> log,
  ) async {
    final id = log['id'];
    if (id is! String || id.isEmpty || id == 'targets') {
      throw ArgumentError.value(id, 'log.id', 'must be a meal document ID');
    }

    try {
      final payload = Map<String, dynamic>.from(log);
      final timestamp = payload['timestamp'];
      if (timestamp is String) {
        payload['timestamp'] = DateTime.parse(timestamp).toUtc().toIso8601String();
      }
      await _userCollection(userId, FirestorePaths.nutrition).doc(id).set(
        {
          ...payload,
          'id': id,
          'userId': userId,
          'isDeleted': false,
          'syncUpdatedAt': FieldValue.serverTimestamp(),
          'syncedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    } catch (e) {
      throw Exception('Failed to sync meal $id: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getNutritionLogs(
    String userId, {
    DateTime? since,
  }) async {
    try {
      Query<Map<String, dynamic>> query =
          _userCollection(userId, FirestorePaths.nutrition);

      if (since != null) {
        query = query.where(
          'syncUpdatedAt',
          isGreaterThan: Timestamp.fromDate(since),
        );
      }

      final snapshot = await query.get();
      return snapshot.docs
          .where((document) =>
              document.id != 'targets' && document.data()['isDeleted'] != true)
          .map((document) {
            final data = _withDocumentId(document);
            final timestamp = data['timestamp'];
            if (timestamp is Timestamp) {
              data['timestamp'] = timestamp.toDate().toLocal().toIso8601String();
            } else if (timestamp is String) {
              data['timestamp'] =
                  DateTime.parse(timestamp).toLocal().toIso8601String();
            }
            return data;
          })
          .toList();
    } catch (e) {
      throw Exception('Failed to get nutrition logs for user $userId: $e');
    }
  }

  @override
  Future<List<String>> getDeletedNutritionLogIds(String userId) async {
    try {
      final snapshot = await _userCollection(userId, FirestorePaths.nutrition)
          .where('isDeleted', isEqualTo: true)
          .get();
      return snapshot.docs
          .where((document) => document.id != 'targets')
          .map((document) => document.id)
          .toList();
    } catch (e) {
      throw Exception('Failed to get deleted meals for user $userId: $e');
    }
  }

  @override
  Future<void> deleteNutritionLog(String userId, String mealId) async {
    try {
      await _userCollection(userId, FirestorePaths.nutrition)
          .doc(mealId)
          .set(
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
      throw Exception('Failed to delete meal $mealId: $e');
    }
  }

  @override
  Future<void> syncNutritionTargets(
    String userId,
    Map<String, dynamic> targets,
  ) async {
    try {
      await _userCollection(userId, FirestorePaths.nutrition)
          .doc('targets')
          .set(
        {
          ...targets,
          'userId': userId,
          'syncUpdatedAt': FieldValue.serverTimestamp(),
          'syncedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    } catch (e) {
      throw Exception('Failed to sync nutrition targets: $e');
    }
  }

  @override
  Future<Map<String, dynamic>?> getNutritionTargets(String userId) async {
    try {
      final document = await _userCollection(userId, FirestorePaths.nutrition)
          .doc('targets')
          .get();
      return document.data();
    } catch (e) {
      throw Exception('Failed to get nutrition targets: $e');
    }
  }

  @override
  Future<void> syncBodyProgress(
    String userId,
    Map<String, dynamic> progress,
  ) async {
    final id = progress['id'];
    if (id is! String || id.isEmpty) {
      throw ArgumentError.value(id, 'progress.id', 'must not be empty');
    }

    try {
      await _userCollection(userId, FirestorePaths.bodyProgress).doc(id).set(
        {
          ...progress,
          'id': id,
          'userId': userId,
          'isDeleted': false,
          'syncUpdatedAt': FieldValue.serverTimestamp(),
          'syncedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    } catch (e) {
      throw Exception('Failed to sync body progress $id: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getBodyProgress(
    String userId, {
    DateTime? since,
  }) async {
    try {
      Query<Map<String, dynamic>> query =
          _userCollection(userId, FirestorePaths.bodyProgress);

      if (since != null) {
        query = query.where(
          'syncUpdatedAt',
          isGreaterThan: Timestamp.fromDate(since),
        );
      }

      final snapshot = await query.get();
      return snapshot.docs
          .where((document) => document.data()['isDeleted'] != true)
          .map(_withDocumentId)
          .toList();
    } catch (e) {
      throw Exception('Failed to get body progress for user $userId: $e');
    }
  }

  @override
  Future<List<String>> getDeletedBodyProgressIds(String userId) async {
    try {
      final snapshot = await _userCollection(userId, FirestorePaths.bodyProgress)
          .where('isDeleted', isEqualTo: true)
          .get();
      return snapshot.docs.map((document) => document.id).toList();
    } catch (e) {
      throw Exception('Failed to get deleted body progress for user $userId: $e');
    }
  }

  @override
  Future<void> deleteBodyProgress(String userId, String entryId) async {
    try {
      await _userCollection(userId, FirestorePaths.bodyProgress)
          .doc(entryId)
          .set(
        {
          'id': entryId,
          'userId': userId,
          'isDeleted': true,
          'syncUpdatedAt': FieldValue.serverTimestamp(),
          'syncedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    } catch (e) {
      throw Exception('Failed to delete body entry $entryId: $e');
    }
  }

  @override
  Future<DateTime?> getLastSyncTime(String userId, String dataType) async {
    try {
      final document = await _userCollection(
        userId,
        FirestorePaths.syncMetadata,
      ).doc(dataType).get();

      final timestamp = document.data()?['lastSyncTime'];
      if (timestamp is Timestamp) {
        // Re-read a short overlap window so a write racing the last pull is
        // harmlessly re-applied instead of being skipped by a strict cursor.
        return timestamp.toDate().subtract(const Duration(seconds: 5));
      }
      if (timestamp is DateTime) return timestamp;
      return null;
    } catch (e) {
      // Missing metadata is expected on the first sync. Permission errors are
      // surfaced by the actual collection reads/writes in the sync pipeline.
      return null;
    }
  }

  @override
  Future<void> updateLastSyncTime(
    String userId,
    String dataType,
    DateTime _,
  ) async {
    try {
      await _userCollection(userId, FirestorePaths.syncMetadata)
          .doc(dataType)
          .set(
        {
          'userId': userId,
          'dataType': dataType,
          // Use Firestore's clock to avoid client clock skew.
          'lastSyncTime': FieldValue.serverTimestamp(),
          'syncUpdatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    } catch (e) {
      throw Exception('Failed to update sync metadata for $dataType: $e');
    }
  }

  @override
  Future<void> syncBatch(List<SyncOperation> operations) async {
    try {
      final batch = _firestore.batch();
      for (final operation in operations) {
        final userId = operation.data['userId'];
        if (userId is! String || userId.isEmpty) {
          throw ArgumentError(
            'Sync operation ${operation.id} has no owning userId',
          );
        }
        if (!_userCollections.contains(operation.collection)) {
          throw ArgumentError(
            'Unsupported user data collection: ${operation.collection}',
          );
        }

        final document = _userCollection(userId, operation.collection)
            .doc(operation.documentId);
        switch (operation.type) {
          case SyncOperationType.create:
          case SyncOperationType.update:
            batch.set(
              document,
              {
                ...operation.data,
                'syncUpdatedAt': FieldValue.serverTimestamp(),
                'syncedAt': FieldValue.serverTimestamp(),
              },
              SetOptions(merge: true),
            );
            break;
          case SyncOperationType.delete:
            batch.delete(document);
            break;
        }
      }
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to execute user-scoped sync batch: $e');
    }
  }
}
