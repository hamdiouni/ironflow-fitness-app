import '../entities/entities.dart';

/// Appends a [SetEntry] to an [Exercise], returning the updated exercise.
class LogSetUseCase {
  Future<Exercise> call(Exercise exercise, SetEntry set) async {
    return exercise.copyWith(
      sets: [...exercise.sets, set],
    );
  }
}
