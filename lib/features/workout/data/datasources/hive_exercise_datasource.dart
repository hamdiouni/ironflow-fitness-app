import 'package:hive/hive.dart';
import '../../domain/entities/exercise_definition.dart';

/// Hive datasource for caching exercise definitions locally.
/// Provides persistent storage for exercises across app sessions.
class HiveExerciseDatasource {
  static const String boxName = 'exercises';

  Future<Box<Map>> get _box async => await Hive.openBox<Map>(boxName);

  /// Save all exercises to Hive for offline access.
  Future<void> saveExercises(List<ExerciseDefinition> exercises) async {
    final box = await _box;
    await box.clear(); // Clear old data
    
    for (final exercise in exercises) {
      await box.put(exercise.id, _exerciseToMap(exercise));
    }
  }

  /// Get all exercises from Hive cache.
  Future<List<ExerciseDefinition>> getAllExercises() async {
    final box = await _box;
    if (box.isEmpty) return [];
    
    return box.values
        .map((data) => _mapToExercise(data as Map<dynamic, dynamic>))
        .toList();
  }

  /// Get exercises by muscle group from cache.
  Future<List<ExerciseDefinition>> getExercisesByMuscleGroup(
    String muscleGroup,
  ) async {
    final box = await _box;
    if (box.isEmpty) return [];
    
    return box.values
        .map((data) => _mapToExercise(data as Map<dynamic, dynamic>))
        .where((exercise) => exercise.muscleGroup.name == muscleGroup)
        .toList();
  }

  /// Search exercises by name from cache.
  Future<List<ExerciseDefinition>> searchExercises(String query) async {
    final box = await _box;
    if (box.isEmpty) return [];
    
    final lowerQuery = query.toLowerCase();
    return box.values
        .map((data) => _mapToExercise(data as Map<dynamic, dynamic>))
        .where((exercise) => exercise.name.toLowerCase().contains(lowerQuery))
        .toList();
  }

  /// Get a single exercise by ID from cache.
  Future<ExerciseDefinition?> getExerciseById(String id) async {
    final box = await _box;
    final data = box.get(id);
    if (data == null) return null;
    return _mapToExercise(data as Map<dynamic, dynamic>);
  }

  /// Check if exercises are cached.
  Future<bool> hasExercises() async {
    final box = await _box;
    return box.isNotEmpty;
  }

  /// Clear all cached exercises.
  Future<void> clearCache() async {
    final box = await _box;
    await box.clear();
  }

  /// Convert ExerciseDefinition to map for Hive storage.
  Map<String, dynamic> _exerciseToMap(ExerciseDefinition exercise) {
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
    };
  }

  /// Convert map from Hive to ExerciseDefinition.
  ExerciseDefinition _mapToExercise(Map<dynamic, dynamic> data) {
    return ExerciseDefinition(
      id: data['id'] as String,
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
