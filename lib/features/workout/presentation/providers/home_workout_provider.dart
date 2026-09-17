import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/workout.dart';
import '../../domain/usecases/get_workouts_paginated_use_case.dart';
import 'workout_providers.dart';

/// Provider for home screen workout data.
/// 
/// Only loads the most recent workouts needed for home screen display
/// (weekly activity, recent workout card, etc.) to optimize performance.
final homeWorkoutDataProvider = FutureProvider<List<Workout>>((ref) async {
  // Re-runs whenever workoutRefreshCounterProvider is incremented.
  ref.watch(workoutRefreshCounterProvider);
  
  final repository = ref.watch(workoutRepositoryProvider);
  final useCase = GetWorkoutsPaginatedUseCase(repository);
  
  // Only load the first 30 workouts for home screen - enough for weekly activity
  // and recent workout display without loading all historical data
  return useCase(offset: 0, limit: 30);
});