import 'package:progression_tracker/core/utils/app_logger.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../exercise_database.dart';
import 'firestore_exercise_datasource.dart';

/// Script to upload all exercises from the local database to Firestore.
/// 
/// This should be run once during app initialization or via a manual trigger.
/// Usage:
/// ```dart
/// final firestore = FirebaseFirestore.instance;
/// await uploadAllExercisesToFirestore(firestore);
/// ```
Future<void> uploadAllExercisesToFirestore(FirebaseFirestore firestore) async {
  try {
    AppLogger.debug('Starting exercise upload to Firestore...');
    AppLogger.debug('Total exercises to upload: ${ExerciseDatabase.all.length}');

    final datasource = FirestoreExerciseDatasource(firestore);
    
    // Upload all exercises
    await datasource.uploadExercises(ExerciseDatabase.all);
    
    AppLogger.debug('✓ Successfully uploaded ${ExerciseDatabase.all.length} exercises to Firestore');
    
    // Verify upload by checking count
    final allExercises = await datasource.getAllExercises();
    AppLogger.debug('✓ Verification: ${allExercises.length} exercises found in Firestore');
    
    // Print summary by muscle group
    final byMuscleGroup = <String, int>{};
    for (final exercise in allExercises) {
      final group = exercise.muscleGroup.name;
      byMuscleGroup[group] = (byMuscleGroup[group] ?? 0) + 1;
    }
    
    AppLogger.debug('\nExercises by muscle group:');
    byMuscleGroup.forEach((group, total) {
      AppLogger.debug('  $group: $total');
    });
    
  } catch (e) {
    AppLogger.debug('✗ Error uploading exercises: $e');
    rethrow;
  }
}

/// Verify that all exercises are properly uploaded to Firestore.
/// Returns true if all exercises are present and valid.
Future<bool> verifyExercisesInFirestore(FirebaseFirestore firestore) async {
  try {
    AppLogger.debug('Verifying exercises in Firestore...');
    
    final datasource = FirestoreExerciseDatasource(firestore);
    final firestoreExercises = await datasource.getAllExercises();
    final localExercises = ExerciseDatabase.all;
    
    AppLogger.debug('Local exercises: ${localExercises.length}');
    AppLogger.debug('Firestore exercises: ${firestoreExercises.length}');
    
    if (firestoreExercises.length != localExercises.length) {
      AppLogger.debug('✗ Exercise count mismatch!');
      return false;
    }
    
    // Check that all local exercises are in Firestore
    final firestoreIds = firestoreExercises.map((e) => e.id).toSet();
    final localIds = localExercises.map((e) => e.id).toSet();
    
    final missing = localIds.difference(firestoreIds);
    if (missing.isNotEmpty) {
      AppLogger.debug('✗ Missing exercises in Firestore: $missing');
      return false;
    }
    
    AppLogger.debug('✓ All exercises verified successfully!');
    return true;
  } catch (e) {
    AppLogger.debug('✗ Error verifying exercises: $e');
    return false;
  }
}

/// Delete all exercises from Firestore (use with caution!).
Future<void> deleteAllExercisesFromFirestore(FirebaseFirestore firestore) async {
  try {
    AppLogger.debug('Deleting all exercises from Firestore...');
    
    final batch = firestore.batch();
    final snapshot = await firestore.collection('exercises').get();
    
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    
    await batch.commit();
    AppLogger.debug('✓ Successfully deleted ${snapshot.docs.length} exercises from Firestore');
  } catch (e) {
    AppLogger.debug('✗ Error deleting exercises: $e');
    rethrow;
  }
}
