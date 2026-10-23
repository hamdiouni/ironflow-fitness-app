import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/exercise_definition.dart';

/// Firestore datasource for exercise definitions.
/// Handles uploading and retrieving exercises from Firestore.
class FirestoreExerciseDatasource {
  final FirebaseFirestore _firestore;

  FirestoreExerciseDatasource(this._firestore);

  /// Upload all exercises to Firestore.
  /// This is typically called once during app initialization or via admin script.
  ///
  /// IDs are preserved EXACTLY (Phase 2, F-14): `exerciseDefinitionId`s
  /// stored on workouts/programs reference these catalog IDs, so the
  /// previous duplicate-handling (`id`, `id_1`, `id_2`…) silently forked
  /// identity between the local catalog and the cloud. Duplicate IDs in
  /// the source catalog are a data bug — fail loudly instead.
  Future<void> uploadExercises(List<ExerciseDefinition> exercises) async {
    final seen = <String>{};
    final duplicates = <String>{};
    for (final exercise in exercises) {
      if (!seen.add(exercise.id)) duplicates.add(exercise.id);
    }
    if (duplicates.isNotEmpty) {
      throw StateError(
        'Exercise catalog contains duplicate IDs $duplicates; '
        'fix the source catalog instead of rewriting IDs on upload.',
      );
    }

    final exercisesCollection = _firestore.collection('exercises');
    // Firestore batches are capped at 500 operations; chunk at 400.
    for (var start = 0; start < exercises.length; start += 400) {
      final batch = _firestore.batch();
      for (final exercise in exercises.skip(start).take(400)) {
        batch.set(
          exercisesCollection.doc(exercise.id),
          exerciseToMap(exercise),
        );
      }
      await batch.commit();
    }
  }

  /// Get all exercises from Firestore.
  Future<List<ExerciseDefinition>> getAllExercises() async {
    final snapshot = await _firestore.collection('exercises').get();
    return snapshot.docs
        .map((doc) => mapToExercise(doc.data(), doc.id))
        .toList();
  }

  /// Get exercises by muscle group.
  Future<List<ExerciseDefinition>> getExercisesByMuscleGroup(
    String muscleGroup,
  ) async {
    final snapshot = await _firestore
        .collection('exercises')
        .where('muscleGroup', isEqualTo: muscleGroup)
        .get();
    return snapshot.docs
        .map((doc) => mapToExercise(doc.data(), doc.id))
        .toList();
  }

  /// Search exercises by name.
  Future<List<ExerciseDefinition>> searchExercises(String query) async {
    final snapshot = await _firestore
        .collection('exercises')
        .where('name', isGreaterThanOrEqualTo: query)
        .where('name', isLessThan: '${query}z')
        .get();
    return snapshot.docs
        .map((doc) => mapToExercise(doc.data(), doc.id))
        .toList();
  }

  /// Get a single exercise by ID.
  Future<ExerciseDefinition?> getExerciseById(String id) async {
    final doc = await _firestore.collection('exercises').doc(id).get();
    if (!doc.exists) return null;
    return mapToExercise(doc.data()!, id);
  }

  /// Convert ExerciseDefinition to Firestore map.
  Map<String, dynamic> exerciseToMap(ExerciseDefinition exercise) {
    return {
      'id': exercise.id,
      'name': exercise.name,
      'muscleGroup': exercise.muscleGroup.name,
      'subMuscle': exercise.subMuscle,
      'equipment': exercise.equipment.name,
      'difficulty': exercise.difficulty.name,
      'imageUrl': exercise.imageUrl,
      'animationUrl': exercise.animationUrl,
      'instructions': exercise.instructions,
      'primaryMuscles': exercise.primaryMuscles.map((m) => m.name).toList(),
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  /// Convert Firestore map to ExerciseDefinition.
  ExerciseDefinition mapToExercise(Map<String, dynamic> data, String id) {
    return ExerciseDefinition(
      id: id,
      name: data['name'] as String,
      muscleGroup: MuscleGroup.values.firstWhere(
        (e) => e.name == data['muscleGroup'],
      ),
      subMuscle: data['subMuscle'] as String,
      equipment: Equipment.values.firstWhere(
        (e) => e.name == data['equipment'],
      ),
      difficulty: Difficulty.values.firstWhere(
        (e) => e.name == data['difficulty'],
      ),
      imageUrl: data['imageUrl'] as String,
      animationUrl: data['animationUrl'] as String,
      instructions: data['instructions'] as String,
      primaryMuscles: (data['primaryMuscles'] as List<dynamic>)
          .map((m) => MuscleGroup.values.firstWhere((e) => e.name == m))
          .toList(),
    );
  }
}
