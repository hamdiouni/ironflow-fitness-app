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
    print('Starting exercise upload to Firestore...');
    print('Total exercises to upload: ${ExerciseDatabase.all.length}');

    final datasource = FirestoreExerciseDatasource(firestore);
    
    // Upload all exercises
    await datasource.uploadExercises(ExerciseDatabase.all);
    
    print('✓ Successfully uploaded ${ExerciseDatabase.all.length} exercises to Firestore');
    
    // Verify upload by checking count
    final allExercises = await datasource.getAllExercises();
    print('✓ Verification: ${allExercises.length} exercises found in Firestore');
    
    // Print summary by muscle group
    final byMuscleGroup = <String, int>{};
    for (final exercise in allExercises) {
      final group = exercise.muscleGroup.displayName;
      byMuscleGroup[group] = (byMuscleGroup[group] ?? 0) + 1;
    }
    
    print('\nExercises by muscle group:');
    byMuscleGroup.forEach((group, count) {
      print('  $group: $count');
    });
    
  } catch (e) {
    print('✗ Error uploading exercises: $e');
    rethrow;
  }
}

/// Verify that all exercises are properly uploaded to Firestore.
/// Returns true if all exercises are present and valid.
Future<bool> verifyExercisesInFirestore(FirebaseFirestore firestore) async {
  try {
    print('Verifying exercises in Firestore...');
    
    final datasource = FirestoreExerciseDatasource(firestore);
    final firestoreExercises = await datasource.getAllExercises();
    final localExercises = ExerciseDatabase.all;
    
    print('Local exercises: ${localExercises.length}');
    print('Firestore exercises: ${firestoreExercises.length}');
    
    if (firestoreExercises.length != localExercises.length) {
      print('✗ Exercise count mismatch!');
      return false;
    }
    
    // Check that all local exercises are in Firestore
    final firestoreIds = firestoreExercises.map((e) => e.id).toSet();
    final localIds = localExercises.map((e) => e.id).toSet();
    
    final missing = localIds.difference(firestoreIds);
    if (missing.isNotEmpty) {
      print('✗ Missing exercises in Firestore: $missing');
      return false;
    }
    
    print('✓ All exercises verified successfully!');
    return true;
  } catch (e) {
    print('✗ Error verifying exercises: $e');
    return false;
  }
}

/// Delete all exercises from Firestore (use with caution!).
Future<void> deleteAllExercisesFromFirestore(FirebaseFirestore firestore) async {
  try {
    print('Deleting all exercises from Firestore...');
    
    final batch = firestore.batch();
    final snapshot = await firestore.collection('exercises').get();
    
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    
    await batch.commit();
    print('✓ Successfully deleted ${snapshot.docs.length} exercises from Firestore');
  } catch (e) {
    print('✗ Error deleting exercises: $e');
    rethrow;
  }
}
