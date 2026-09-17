import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/exercise_definition.dart';
import '../../domain/usecases/get_exercises_use_case.dart';

// Filter state
class ExerciseFilterState {
  const ExerciseFilterState({
    this.query = '',
    this.muscleGroup,
    this.equipment,
  });
  final String query;
  final MuscleGroup? muscleGroup;
  final Equipment? equipment;

  ExerciseFilterState copyWith({
    String? query,
    MuscleGroup? muscleGroup,
    bool clearMuscleGroup = false,
    Equipment? equipment,
    bool clearEquipment = false,
  }) {
    return ExerciseFilterState(
      query: query ?? this.query,
      muscleGroup: clearMuscleGroup ? null : (muscleGroup ?? this.muscleGroup),
      equipment: clearEquipment ? null : (equipment ?? this.equipment),
    );
  }
}

class ExerciseFilterNotifier extends StateNotifier<ExerciseFilterState> {
  ExerciseFilterNotifier() : super(const ExerciseFilterState());

  void setQuery(String q) => state = state.copyWith(query: q);
  void setMuscleGroup(MuscleGroup? mg) => state = mg == null
      ? state.copyWith(clearMuscleGroup: true)
      : state.copyWith(muscleGroup: mg);
  void setEquipment(Equipment? eq) => state = eq == null
      ? state.copyWith(clearEquipment: true)
      : state.copyWith(equipment: eq);
  void reset() => state = const ExerciseFilterState();
}

final exerciseFilterProvider =
    StateNotifierProvider<ExerciseFilterNotifier, ExerciseFilterState>(
  (ref) => ExerciseFilterNotifier(),
);

final filteredExercisesProvider = Provider<List<ExerciseDefinition>>((ref) {
  final filter = ref.watch(exerciseFilterProvider);
  final useCase = GetExercisesUseCase();
  return useCase(
    query: filter.query,
    muscleGroup: filter.muscleGroup,
    equipment: filter.equipment,
  );
});
