import 'package:mockito/annotations.dart';
import 'package:progression_tracker/features/workout/domain/repositories/workout_repository.dart';
import 'package:progression_tracker/features/nutrition/domain/repositories/nutrition_repository.dart';
import 'package:progression_tracker/features/body/domain/repositories/body_repository.dart';

@GenerateMocks([
  WorkoutRepository,
  NutritionRepository,
  BodyRepository,
])
void main() {}