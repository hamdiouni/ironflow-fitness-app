# Technical Design Document: Progression Tracker Fitness App

## Overview

The Progression Tracker is a production-ready Flutter mobile fitness application implementing Clean Architecture principles with an offline-first approach. The app enables users to track progressive overload in workouts, monitor body evolution, and log nutrition through a highly interactive, performance-optimized interface.

### Core Design Principles

1. **Clean Architecture**: Strict separation of concerns with Domain, Data, and Presentation layers
2. **Offline-First**: All functionality works without network connectivity using local storage
3. **Feature-Based Modularity**: Independent workout, body, and nutrition modules
4. **Performance-Optimized**: <100ms feedback, 60 FPS animations, lazy loading
5. **Immutable State**: Freezed data classes with Riverpod state management

### Technology Stack

- **Framework**: Flutter 3.x
- **State Management**: Riverpod 2.x
- **Local Storage**: Hive (preferred) or Drift/SQLite
- **Routing**: go_router
- **Animations**: flutter_animate, Lottie
- **Data Classes**: Freezed, json_serializable
- **Charts**: fl_chart

## Architecture

### Layer Structure

```
lib/
├── core/                          # Shared infrastructure
│   ├── error/                     # Custom exceptions
│   ├── utils/                     # Helpers, extensions
│   └── constants/                 # App-wide constants
├── shared/                        # Shared UI components
│   ├── widgets/                   # Reusable widgets
│   └── animations/                # Animation components
├── features/
│   ├── workout/
│   │   ├── domain/
│   │   │   ├── entities/          # Workout, Exercise, SetEntry
│   │   │   ├── repositories/      # Abstract repository interfaces
│   │   │   └── usecases/          # Business logic operations
│   │   ├── data/
│   │   │   ├── models/            # JSON serializable models
│   │   │   ├── datasources/       # Local storage implementation
│   │   │   └── repositories/      # Repository implementations
│   │   └── presentation/
│   │       ├── providers/         # Riverpod providers
│   │       ├── screens/           # UI screens
│   │       └── widgets/           # Feature-specific widgets
│   ├── body/
│   │   ├── domain/
│   │   ├── data/
│   │   └── presentation/
│   └── nutrition/
│       ├── domain/
│       ├── data/
│       └── presentation/
└── main.dart
```

### Dependency Flow

```
Presentation Layer (Flutter UI)
        ↓ (depends on)
Domain Layer (Pure Dart)
        ↑ (implemented by)
Data Layer (Storage, APIs)
```

**Key Rules**:
- Domain layer has ZERO Flutter imports
- Presentation depends on Domain abstractions only
- Data layer implements Domain interfaces
- Features do not import from other features

## Components and Interfaces

### Domain Layer Entities

#### Workout Module

```dart
@freezed
class Workout with _$Workout {
  const factory Workout({
    required String id,
    required DateTime date,
    required List<Exercise> exercises,
    required Duration duration,
    required double totalVolume,
  }) = _Workout;
}

@freezed
class Exercise with _$Exercise {
  const factory Exercise({
    required String id,
    required String name,
    required ExerciseType type,
    required List<SetEntry> sets,
  }) = _Exercise;
}

enum ExerciseType { strength, cardio, flexibility }

@freezed
class SetEntry with _$SetEntry {
  const factory SetEntry({
    required String id,
    required int reps,
    required double weight,
    int? rpe,  // Optional: 1-10 scale
    required DateTime timestamp,
  }) = _SetEntry;
  
  // Validation in factory constructor
  factory SetEntry.create({
    required int reps,
    required double weight,
    int? rpe,
  }) {
    if (reps <= 0) throw InvalidRepsException();
    if (weight < 0) throw InvalidWeightException();
    if (rpe != null && (rpe < 1 || rpe > 10)) throw InvalidRPEException();
    
    return SetEntry(
      id: const Uuid().v4(),
      reps: reps,
      weight: weight,
      rpe: rpe,
      timestamp: DateTime.now(),
    );
  }
}
```

#### Body Module

```dart
@freezed
class BodyEntry with _$BodyEntry {
  const factory BodyEntry({
    required String id,
    required DateTime date,
    required double weight,
    required Map<MeasurementType, double> measurements,
    String? photoPath,
  }) = _BodyEntry;
  
  factory BodyEntry.create({
    required double weight,
    Map<MeasurementType, double>? measurements,
    String? photoPath,
  }) {
    if (weight <= 0) throw InvalidWeightException();
    
    return BodyEntry(
      id: const Uuid().v4(),
      date: DateTime.now(),
      weight: weight,
      measurements: measurements ?? {},
      photoPath: photoPath,
    );
  }
}

enum MeasurementType { chest, waist, hips, arms, legs }
```

#### Nutrition Module

```dart
@freezed
class Meal with _$Meal {
  const factory Meal({
    required String id,
    required String name,
    required double calories,
    required double protein,
    required double carbs,
    required double fats,
    required DateTime timestamp,
  }) = _Meal;
  
  factory Meal.create({
    required String name,
    required double calories,
    required double protein,
    required double carbs,
    required double fats,
  }) {
    if (protein < 0 || carbs < 0 || fats < 0) {
      throw InvalidMacroException();
    }
    
    return Meal(
      id: const Uuid().v4(),
      name: name,
      calories: calories,
      protein: protein,
      carbs: carbs,
      fats: fats,
      timestamp: DateTime.now(),
    );
  }
}

@freezed
class MacroTarget with _$MacroTarget {
  const factory MacroTarget({
    required double protein,
    required double carbs,
    required double fats,
  }) = _MacroTarget;
  
  double get totalCalories => (protein * 4) + (carbs * 4) + (fats * 9);
}

@freezed
class DailyNutritionSummary with _$DailyNutritionSummary {
  const factory DailyNutritionSummary({
    required DateTime date,
    required List<Meal> meals,
    required MacroTarget target,
  }) = _DailyNutritionSummary;
  
  double get totalProtein => meals.fold(0, (sum, meal) => sum + meal.protein);
  double get totalCarbs => meals.fold(0, (sum, meal) => sum + meal.carbs);
  double get totalFats => meals.fold(0, (sum, meal) => sum + meal.fats);
  double get totalCalories => meals.fold(0, (sum, meal) => sum + meal.calories);
  
  MacroTarget get remaining => MacroTarget(
    protein: (target.protein - totalProtein).clamp(0, double.infinity),
    carbs: (target.carbs - totalCarbs).clamp(0, double.infinity),
    fats: (target.fats - totalFats).clamp(0, double.infinity),
  );
}
```

### Repository Interfaces

#### Workout Repository

```dart
abstract class WorkoutRepository {
  /// Save a workout session to local storage
  Future<void> saveWorkout(Workout workout);
  
  /// Retrieve all workouts sorted by date descending
  Future<List<Workout>> getAllWorkouts();
  
  /// Get workouts within a date range
  Future<List<Workout>> getWorkoutsByDateRange(DateTime start, DateTime end);
  
  /// Get the last N performances for a specific exercise
  Future<List<Exercise>> getExerciseHistory(String exerciseName, int limit);
  
  /// Delete a workout by ID
  Future<void> deleteWorkout(String id);
}
```

#### Body Repository

```dart
abstract class BodyRepository {
  /// Save a body entry
  Future<void> saveBodyEntry(BodyEntry entry);
  
  /// Get all body entries sorted by date descending
  Future<List<BodyEntry>> getAllBodyEntries();
  
  /// Get body entries within a date range
  Future<List<BodyEntry>> getBodyEntriesByDateRange(DateTime start, DateTime end);
  
  /// Delete a body entry by ID
  Future<void> deleteBodyEntry(String id);
}
```

#### Nutrition Repository

```dart
abstract class NutritionRepository {
  /// Save a meal entry
  Future<void> saveMeal(Meal meal);
  
  /// Get all meals for a specific date
  Future<List<Meal>> getMealsByDate(DateTime date);
  
  /// Get meals within a date range
  Future<List<Meal>> getMealsByDateRange(DateTime start, DateTime end);
  
  /// Delete a meal by ID
  Future<void> deleteMeal(String id);
  
  /// Save user's macro targets
  Future<void> saveMacroTarget(MacroTarget target);
  
  /// Get user's current macro targets
  Future<MacroTarget?> getMacroTarget();
}
```

### Use Cases

#### Workout Module Use Cases

```dart
// Start a new workout session
class StartWorkoutUseCase {
  final WorkoutRepository repository;
  
  StartWorkoutUseCase(this.repository);
  
  Future<Workout> call() async {
    return Workout(
      id: const Uuid().v4(),
      date: DateTime.now(),
      exercises: [],
      duration: Duration.zero,
      totalVolume: 0,
    );
  }
}

// Add exercise to workout
class AddExerciseToWorkoutUseCase {
  Future<Workout> call(Workout workout, Exercise exercise) async {
    return workout.copyWith(
      exercises: [...workout.exercises, exercise],
    );
  }
}

// Log a set for an exercise
class LogSetUseCase {
  Future<Exercise> call(Exercise exercise, SetEntry set) async {
    return exercise.copyWith(
      sets: [...exercise.sets, set],
    );
  }
}

// Calculate total volume for workout
class CalculateWorkoutVolumeUseCase {
  double call(Workout workout) {
    return workout.exercises.fold(0.0, (total, exercise) {
      final exerciseVolume = exercise.sets.fold(0.0, (sum, set) {
        return sum + (set.weight * set.reps);
      });
      return total + exerciseVolume;
    });
  }
}

// Save completed workout
class SaveWorkoutUseCase {
  final WorkoutRepository repository;
  final CalculateWorkoutVolumeUseCase calculateVolume;
  
  SaveWorkoutUseCase(this.repository, this.calculateVolume);
  
  Future<void> call(Workout workout, Duration duration) async {
    final totalVolume = calculateVolume(workout);
    final completedWorkout = workout.copyWith(
      duration: duration,
      totalVolume: totalVolume,
    );
    await repository.saveWorkout(completedWorkout);
  }
}

// Get workout history
class GetWorkoutHistoryUseCase {
  final WorkoutRepository repository;
  
  GetWorkoutHistoryUseCase(this.repository);
  
  Future<List<Workout>> call() async {
    return await repository.getAllWorkouts();
  }
}
```

#### Progression Engine Use Cases

```dart
@freezed
class ProgressionSuggestion with _$ProgressionSuggestion {
  const factory ProgressionSuggestion({
    required double suggestedWeight,
    required int suggestedReps,
    required bool isStagnant,
    String? message,
  }) = _ProgressionSuggestion;
}

class GetProgressionSuggestionUseCase {
  final WorkoutRepository repository;
  
  GetProgressionSuggestionUseCase(this.repository);
  
  Future<ProgressionSuggestion> call(String exerciseName) async {
    final history = await repository.getExerciseHistory(exerciseName, 3);
    
    if (history.isEmpty) {
      return const ProgressionSuggestion(
        suggestedWeight: 0,
        suggestedReps: 8,
        isStagnant: false,
        message: 'No history available',
      );
    }
    
    // Get the best performance from last 3 sessions
    final lastPerformances = history.map((exercise) {
      if (exercise.sets.isEmpty) return null;
      return exercise.sets.reduce((best, current) {
        final bestVolume = best.weight * best.reps;
        final currentVolume = current.weight * current.reps;
        return currentVolume > bestVolume ? current : best;
      });
    }).whereType<SetEntry>().toList();
    
    if (lastPerformances.isEmpty) {
      return const ProgressionSuggestion(
        suggestedWeight: 0,
        suggestedReps: 8,
        isStagnant: false,
      );
    }
    
    final bestSet = lastPerformances.first;
    
    // Check for stagnation: same weight and reps for 3 consecutive sessions
    final isStagnant = lastPerformances.length >= 3 &&
        lastPerformances.every((set) => 
          set.weight == bestSet.weight && set.reps == bestSet.reps);
    
    if (isStagnant) {
      // Suggest 5% weight increase or 2 more reps
      return ProgressionSuggestion(
        suggestedWeight: bestSet.weight * 1.05,
        suggestedReps: bestSet.reps,
        isStagnant: true,
        message: 'Time to progress! Try increasing weight or reps.',
      );
    }
    
    // Suggest matching or slightly exceeding last performance
    return ProgressionSuggestion(
      suggestedWeight: bestSet.weight,
      suggestedReps: bestSet.reps + 1,
      isStagnant: false,
      message: 'Try to beat your last performance!',
    );
  }
}

class DetectPersonalRecordUseCase {
  final WorkoutRepository repository;
  
  DetectPersonalRecordUseCase(this.repository);
  
  Future<bool> call(String exerciseName, SetEntry newSet) async {
    final history = await repository.getExerciseHistory(exerciseName, 100);
    
    final allSets = history.expand((exercise) => exercise.sets).toList();
    
    if (allSets.isEmpty) return true; // First time is always a PR
    
    final newVolume = newSet.weight * newSet.reps;
    final bestPreviousVolume = allSets
        .map((set) => set.weight * set.reps)
        .reduce((a, b) => a > b ? a : b);
    
    return newVolume > bestPreviousVolume;
  }
}
```

#### Body Module Use Cases

```dart
class SaveBodyEntryUseCase {
  final BodyRepository repository;
  
  SaveBodyEntryUseCase(this.repository);
  
  Future<void> call(BodyEntry entry) async {
    await repository.saveBodyEntry(entry);
  }
}

class GetBodyHistoryUseCase {
  final BodyRepository repository;
  
  GetBodyHistoryUseCase(this.repository);
  
  Future<List<BodyEntry>> call() async {
    return await repository.getAllBodyEntries();
  }
}

class GetWeightTrendUseCase {
  final BodyRepository repository;
  
  GetWeightTrendUseCase(this.repository);
  
  Future<List<WeightDataPoint>> call(DateTime start, DateTime end) async {
    final entries = await repository.getBodyEntriesByDateRange(start, end);
    return entries.map((entry) => WeightDataPoint(
      date: entry.date,
      weight: entry.weight,
    )).toList();
  }
}

@freezed
class WeightDataPoint with _$WeightDataPoint {
  const factory WeightDataPoint({
    required DateTime date,
    required double weight,
  }) = _WeightDataPoint;
}
```

#### Nutrition Module Use Cases

```dart
class SaveMealUseCase {
  final NutritionRepository repository;
  
  SaveMealUseCase(this.repository);
  
  Future<void> call(Meal meal) async {
    await repository.saveMeal(meal);
  }
}

class GetDailyNutritionSummaryUseCase {
  final NutritionRepository repository;
  
  GetDailyNutritionSummaryUseCase(this.repository);
  
  Future<DailyNutritionSummary> call(DateTime date) async {
    final meals = await repository.getMealsByDate(date);
    final target = await repository.getMacroTarget() ?? 
        const MacroTarget(protein: 150, carbs: 200, fats: 60);
    
    return DailyNutritionSummary(
      date: date,
      meals: meals,
      target: target,
    );
  }
}

class GetMealSuggestionsUseCase {
  Future<List<MealSuggestion>> call(MacroTarget remaining) async {
    final suggestions = <MealSuggestion>[];
    
    // High-protein suggestion
    if (remaining.protein > 30) {
      suggestions.add(const MealSuggestion(
        name: 'Grilled Chicken Breast',
        protein: 35,
        carbs: 0,
        fats: 5,
        category: MealCategory.highProtein,
      ));
    }
    
    // High-carb suggestion
    if (remaining.carbs > 40) {
      suggestions.add(const MealSuggestion(
        name: 'Rice Bowl',
        protein: 8,
        carbs: 50,
        fats: 2,
        category: MealCategory.highCarb,
      ));
    }
    
    // Balanced suggestion
    if (remaining.protein > 20 && remaining.carbs > 30 && remaining.fats > 10) {
      suggestions.add(const MealSuggestion(
        name: 'Salmon with Sweet Potato',
        protein: 25,
        carbs: 35,
        fats: 15,
        category: MealCategory.balanced,
      ));
    }
    
    return suggestions;
  }
}

@freezed
class MealSuggestion with _$MealSuggestion {
  const factory MealSuggestion({
    required String name,
    required double protein,
    required double carbs,
    required double fats,
    required MealCategory category,
  }) = _MealSuggestion;
  
  double get calories => (protein * 4) + (carbs * 4) + (fats * 9);
}

enum MealCategory { highProtein, highCarb, balanced }
```

## Data Models

### Data Layer Models (JSON Serializable)

```dart
@freezed
class WorkoutModel with _$WorkoutModel {
  const factory WorkoutModel({
    required String id,
    required String date,  // ISO 8601 string
    required List<ExerciseModel> exercises,
    required int durationSeconds,
    required double totalVolume,
  }) = _WorkoutModel;
  
  factory WorkoutModel.fromJson(Map<String, dynamic> json) =>
      _$WorkoutModelFromJson(json);
  
  factory WorkoutModel.fromEntity(Workout workout) {
    return WorkoutModel(
      id: workout.id,
      date: workout.date.toIso8601String(),
      exercises: workout.exercises.map(ExerciseModel.fromEntity).toList(),
      durationSeconds: workout.duration.inSeconds,
      totalVolume: workout.totalVolume,
    );
  }
  
  Workout toEntity() {
    return Workout(
      id: id,
      date: DateTime.parse(date),
      exercises: exercises.map((e) => e.toEntity()).toList(),
      duration: Duration(seconds: durationSeconds),
      totalVolume: totalVolume,
    );
  }
}

@freezed
class ExerciseModel with _$ExerciseModel {
  const factory ExerciseModel({
    required String id,
    required String name,
    required String type,
    required List<SetEntryModel> sets,
  }) = _ExerciseModel;
  
  factory ExerciseModel.fromJson(Map<String, dynamic> json) =>
      _$ExerciseModelFromJson(json);
  
  factory ExerciseModel.fromEntity(Exercise exercise) {
    return ExerciseModel(
      id: exercise.id,
      name: exercise.name,
      type: exercise.type.name,
      sets: exercise.sets.map(SetEntryModel.fromEntity).toList(),
    );
  }
  
  Exercise toEntity() {
    return Exercise(
      id: id,
      name: name,
      type: ExerciseType.values.firstWhere((e) => e.name == type),
      sets: sets.map((s) => s.toEntity()).toList(),
    );
  }
}

@freezed
class SetEntryModel with _$SetEntryModel {
  const factory SetEntryModel({
    required String id,
    required int reps,
    required double weight,
    int? rpe,
    required String timestamp,
  }) = _SetEntryModel;
  
  factory SetEntryModel.fromJson(Map<String, dynamic> json) =>
      _$SetEntryModelFromJson(json);
  
  factory SetEntryModel.fromEntity(SetEntry set) {
    return SetEntryModel(
      id: set.id,
      reps: set.reps,
      weight: set.weight,
      rpe: set.rpe,
      timestamp: set.timestamp.toIso8601String(),
    );
  }
  
  SetEntry toEntity() {
    return SetEntry(
      id: id,
      reps: reps,
      weight: weight,
      rpe: rpe,
      timestamp: DateTime.parse(timestamp),
    );
  }
}
```

### Local Storage Implementation (Hive)

```dart
class HiveWorkoutDataSource {
  static const String boxName = 'workouts';
  
  Future<Box<Map>> get _box async => await Hive.openBox<Map>(boxName);
  
  Future<void> saveWorkout(WorkoutModel workout) async {
    final box = await _box;
    await box.put(workout.id, workout.toJson());
  }
  
  Future<List<WorkoutModel>> getAllWorkouts() async {
    final box = await _box;
    final workouts = box.values
        .map((json) => WorkoutModel.fromJson(Map<String, dynamic>.from(json)))
        .toList();
    
    // Sort by date descending
    workouts.sort((a, b) => b.date.compareTo(a.date));
    return workouts;
  }
  
  Future<void> deleteWorkout(String id) async {
    final box = await _box;
    await box.delete(id);
  }
}

class WorkoutRepositoryImpl implements WorkoutRepository {
  final HiveWorkoutDataSource dataSource;
  
  WorkoutRepositoryImpl(this.dataSource);
  
  @override
  Future<void> saveWorkout(Workout workout) async {
    final model = WorkoutModel.fromEntity(workout);
    await dataSource.saveWorkout(model);
  }
  
  @override
  Future<List<Workout>> getAllWorkouts() async {
    final models = await dataSource.getAllWorkouts();
    return models.map((m) => m.toEntity()).toList();
  }
  
  @override
  Future<List<Exercise>> getExerciseHistory(String exerciseName, int limit) async {
    final workouts = await getAllWorkouts();
    final exercises = <Exercise>[];
    
    for (final workout in workouts) {
      final matchingExercises = workout.exercises
          .where((e) => e.name.toLowerCase() == exerciseName.toLowerCase());
      exercises.addAll(matchingExercises);
      
      if (exercises.length >= limit) break;
    }
    
    return exercises.take(limit).toList();
  }
  
  @override
  Future<List<Workout>> getWorkoutsByDateRange(DateTime start, DateTime end) async {
    final allWorkouts = await getAllWorkouts();
    return allWorkouts.where((workout) {
      return workout.date.isAfter(start) && workout.date.isBefore(end);
    }).toList();
  }
  
  @override
  Future<void> deleteWorkout(String id) async {
    await dataSource.deleteWorkout(id);
  }
}
```


## State Management Architecture

### Riverpod Provider Structure

```dart
// Workout Providers
final workoutRepositoryProvider = Provider<WorkoutRepository>((ref) {
  final dataSource = HiveWorkoutDataSource();
  return WorkoutRepositoryImpl(dataSource);
});

final startWorkoutUseCaseProvider = Provider<StartWorkoutUseCase>((ref) {
  final repository = ref.watch(workoutRepositoryProvider);
  return StartWorkoutUseCase(repository);
});

final saveWorkoutUseCaseProvider = Provider<SaveWorkoutUseCase>((ref) {
  final repository = ref.watch(workoutRepositoryProvider);
  final calculateVolume = ref.watch(calculateVolumeUseCaseProvider);
  return SaveWorkoutUseCase(repository, calculateVolume);
});

final calculateVolumeUseCaseProvider = Provider<CalculateWorkoutVolumeUseCase>((ref) {
  return CalculateWorkoutVolumeUseCase();
});

final progressionSuggestionUseCaseProvider = Provider<GetProgressionSuggestionUseCase>((ref) {
  final repository = ref.watch(workoutRepositoryProvider);
  return GetProgressionSuggestionUseCase(repository);
});

final detectPRUseCaseProvider = Provider<DetectPersonalRecordUseCase>((ref) {
  final repository = ref.watch(workoutRepositoryProvider);
  return DetectPersonalRecordUseCase(repository);
});

// Workout State
@freezed
class WorkoutState with _$WorkoutState {
  const factory WorkoutState.initial() = _Initial;
  const factory WorkoutState.inProgress(Workout workout, DateTime startTime) = _InProgress;
  const factory WorkoutState.completed(Workout workout) = _Completed;
}

class WorkoutNotifier extends StateNotifier<WorkoutState> {
  final StartWorkoutUseCase startWorkout;
  final AddExerciseToWorkoutUseCase addExercise;
  final LogSetUseCase logSet;
  final SaveWorkoutUseCase saveWorkout;
  final DetectPersonalRecordUseCase detectPR;
  
  WorkoutNotifier({
    required this.startWorkout,
    required this.addExercise,
    required this.logSet,
    required this.saveWorkout,
    required this.detectPR,
  }) : super(const WorkoutState.initial());
  
  Future<void> start() async {
    final workout = await startWorkout();
    state = WorkoutState.inProgress(workout, DateTime.now());
  }
  
  Future<void> addExerciseToWorkout(Exercise exercise) async {
    state.maybeWhen(
      inProgress: (workout, startTime) async {
        final updated = await addExercise(workout, exercise);
        state = WorkoutState.inProgress(updated, startTime);
      },
      orElse: () {},
    );
  }
  
  Future<bool> logSetForExercise(String exerciseId, SetEntry set) async {
    bool isPR = false;
    
    await state.maybeWhen(
      inProgress: (workout, startTime) async {
        final exerciseIndex = workout.exercises.indexWhere((e) => e.id == exerciseId);
        if (exerciseIndex == -1) return;
        
        final exercise = workout.exercises[exerciseIndex];
        final updatedExercise = await logSet(exercise, set);
        
        // Check for PR
        isPR = await detectPR(exercise.name, set);
        
        final updatedExercises = List<Exercise>.from(workout.exercises);
        updatedExercises[exerciseIndex] = updatedExercise;
        
        final updatedWorkout = workout.copyWith(exercises: updatedExercises);
        state = WorkoutState.inProgress(updatedWorkout, startTime);
      },
      orElse: () {},
    );
    
    return isPR;
  }
  
  Future<void> finish() async {
    await state.maybeWhen(
      inProgress: (workout, startTime) async {
        final duration = DateTime.now().difference(startTime);
        await saveWorkout(workout, duration);
        state = WorkoutState.completed(workout);
      },
      orElse: () {},
    );
  }
  
  void reset() {
    state = const WorkoutState.initial();
  }
}

final workoutNotifierProvider = StateNotifierProvider<WorkoutNotifier, WorkoutState>((ref) {
  return WorkoutNotifier(
    startWorkout: ref.watch(startWorkoutUseCaseProvider),
    addExercise: AddExerciseToWorkoutUseCase(),
    logSet: LogSetUseCase(),
    saveWorkout: ref.watch(saveWorkoutUseCaseProvider),
    detectPR: ref.watch(detectPRUseCaseProvider),
  );
});

// Workout History Provider
final workoutHistoryProvider = FutureProvider<List<Workout>>((ref) async {
  final repository = ref.watch(workoutRepositoryProvider);
  final useCase = GetWorkoutHistoryUseCase(repository);
  return await useCase();
});

// Progression Suggestion Provider
final progressionSuggestionProvider = FutureProvider.family<ProgressionSuggestion, String>(
  (ref, exerciseName) async {
    final useCase = ref.watch(progressionSuggestionUseCaseProvider);
    return await useCase(exerciseName);
  },
);
```

### Rest Timer State

```dart
@freezed
class RestTimerState with _$RestTimerState {
  const factory RestTimerState.idle() = _Idle;
  const factory RestTimerState.running(int remainingSeconds, int totalSeconds) = _Running;
  const factory RestTimerState.completed() = _Completed;
}

class RestTimerNotifier extends StateNotifier<RestTimerState> {
  Timer? _timer;
  
  RestTimerNotifier() : super(const RestTimerState.idle());
  
  void start({int seconds = 90}) {
    _timer?.cancel();
    state = RestTimerState.running(seconds, seconds);
    
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      state.maybeWhen(
        running: (remaining, total) {
          final newRemaining = remaining - 0.1;
          if (newRemaining <= 0) {
            timer.cancel();
            state = const RestTimerState.completed();
          } else {
            state = RestTimerState.running(newRemaining.toInt(), total);
          }
        },
        orElse: () => timer.cancel(),
      );
    });
  }
  
  void skip() {
    _timer?.cancel();
    state = const RestTimerState.idle();
  }
  
  void extend(int additionalSeconds) {
    state.maybeWhen(
      running: (remaining, total) {
        state = RestTimerState.running(remaining + additionalSeconds, total);
      },
      orElse: () {},
    );
  }
  
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final restTimerProvider = StateNotifierProvider<RestTimerNotifier, RestTimerState>((ref) {
  return RestTimerNotifier();
});
```

### Nutrition State

```dart
final nutritionRepositoryProvider = Provider<NutritionRepository>((ref) {
  final dataSource = HiveNutritionDataSource();
  return NutritionRepositoryImpl(dataSource);
});

final dailyNutritionSummaryProvider = FutureProvider.family<DailyNutritionSummary, DateTime>(
  (ref, date) async {
    final repository = ref.watch(nutritionRepositoryProvider);
    final useCase = GetDailyNutritionSummaryUseCase(repository);
    return await useCase(date);
  },
);

final mealSuggestionsProvider = FutureProvider.family<List<MealSuggestion>, MacroTarget>(
  (ref, remaining) async {
    final useCase = GetMealSuggestionsUseCase();
    return await useCase(remaining);
  },
);
```

### Body Tracking State

```dart
final bodyRepositoryProvider = Provider<BodyRepository>((ref) {
  final dataSource = HiveBodyDataSource();
  return BodyRepositoryImpl(dataSource);
});

final bodyHistoryProvider = FutureProvider<List<BodyEntry>>((ref) async {
  final repository = ref.watch(bodyRepositoryProvider);
  final useCase = GetBodyHistoryUseCase(repository);
  return await useCase();
});

final weightTrendProvider = FutureProvider.family<List<WeightDataPoint>, DateRange>(
  (ref, dateRange) async {
    final repository = ref.watch(bodyRepositoryProvider);
    final useCase = GetWeightTrendUseCase(repository);
    return await useCase(dateRange.start, dateRange.end);
  },
);

@freezed
class DateRange with _$DateRange {
  const factory DateRange({
    required DateTime start,
    required DateTime end,
  }) = _DateRange;
}
```

## Animation System

### Reusable Animation Components

```dart
// Set Completion Animation
class SetCompletionAnimation extends StatelessWidget {
  final VoidCallback onComplete;
  
  const SetCompletionAnimation({required this.onComplete, super.key});
  
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.green.withOpacity(0.2),
      ),
      child: const Icon(Icons.check, color: Colors.green, size: 32),
    ).animate(onComplete: (_) => onComplete())
      .scale(duration: 200.ms, curve: Curves.easeOut)
      .fadeOut(delay: 300.ms, duration: 200.ms);
  }
}

// PR Celebration Animation
class PRCelebrationAnimation extends StatelessWidget {
  const PRCelebrationAnimation({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Lottie.asset(
      'assets/animations/celebration.json',
      width: 200,
      height: 200,
      repeat: false,
    );
  }
}

// Rest Timer Circular Animation
class RestTimerCircular extends ConsumerWidget {
  const RestTimerCircular({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timerState = ref.watch(restTimerProvider);
    
    return timerState.maybeWhen(
      running: (remaining, total) {
        final progress = remaining / total;
        return Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 200,
              height: 200,
              child: CircularProgressIndicator(
                value: progress,
                strokeWidth: 12,
                backgroundColor: Colors.grey.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation<Color>(
                  progress > 0.5 ? Colors.green : Colors.orange,
                ),
              ),
            ),
            Text(
              '${remaining}s',
              style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
            ),
          ],
        );
      },
      orElse: () => const SizedBox.shrink(),
    );
  }
}

// Workout Summary Animation
class WorkoutSummaryCard extends StatelessWidget {
  final Workout workout;
  final int prCount;
  
  const WorkoutSummaryCard({
    required this.workout,
    required this.prCount,
    super.key,
  });
  
  @override
  Widget build(BuildContext context) {
    final totalSets = workout.exercises.fold(0, (sum, e) => sum + e.sets.length);
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: [Colors.blue.shade900, Colors.purple.shade900],
        ),
      ),
      child: Column(
        children: [
          const Text('Workout Complete!', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          _SummaryItem(label: 'Total Sets', value: '$totalSets'),
          _SummaryItem(label: 'Total Volume', value: '${workout.totalVolume.toStringAsFixed(0)} kg'),
          _SummaryItem(label: 'Duration', value: '${workout.duration.inMinutes} min'),
          if (prCount > 0) _SummaryItem(label: 'PRs', value: '$prCount 🎉'),
        ],
      ),
    ).animate()
      .fadeIn(duration: 300.ms)
      .scale(begin: const Offset(0.8, 0.8), duration: 300.ms, curve: Curves.easeOut);
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;
  
  const _SummaryItem({required this.label, required this.value});
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 18)),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

// Macro Wheel Animation
class MacroWheelChart extends StatelessWidget {
  final double protein;
  final double carbs;
  final double fats;
  
  const MacroWheelChart({
    required this.protein,
    required this.carbs,
    required this.fats,
    super.key,
  });
  
  @override
  Widget build(BuildContext context) {
    final total = protein + carbs + fats;
    
    return SizedBox(
      width: 200,
      height: 200,
      child: PieChart(
        PieChartData(
          sections: [
            PieChartSectionData(
              value: protein,
              title: '${(protein / total * 100).toStringAsFixed(0)}%',
              color: Colors.red,
              radius: 80,
            ),
            PieChartSectionData(
              value: carbs,
              title: '${(carbs / total * 100).toStringAsFixed(0)}%',
              color: Colors.blue,
              radius: 80,
            ),
            PieChartSectionData(
              value: fats,
              title: '${(fats / total * 100).toStringAsFixed(0)}%',
              color: Colors.yellow,
              radius: 80,
            ),
          ],
          sectionsSpace: 2,
          centerSpaceRadius: 40,
        ),
      ),
    ).animate()
      .scale(duration: 300.ms, curve: Curves.easeOut)
      .fadeIn(duration: 200.ms);
  }
}

// Weight Trend Graph with Animation
class WeightTrendGraph extends StatelessWidget {
  final List<WeightDataPoint> dataPoints;
  
  const WeightTrendGraph({required this.dataPoints, super.key});
  
  @override
  Widget build(BuildContext context) {
    if (dataPoints.isEmpty) {
      return const Center(child: Text('No data available'));
    }
    
    final spots = dataPoints.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.weight);
    }).toList();
    
    return SizedBox(
      height: 300,
      child: LineChart(
        LineChartData(
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: Colors.green,
              barWidth: 3,
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                color: Colors.green.withOpacity(0.2),
              ),
            ),
          ],
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() >= dataPoints.length) return const SizedBox();
                  final date = dataPoints[value.toInt()].date;
                  return Text('${date.month}/${date.day}');
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) => Text('${value.toStringAsFixed(0)} kg'),
              ),
            ),
          ),
        ),
      ),
    ).animate()
      .fadeIn(duration: 300.ms)
      .slideY(begin: 0.2, duration: 400.ms, curve: Curves.easeOut);
  }
}

// Swipeable Meal Cards
class SwipeableMealCards extends StatelessWidget {
  final List<Meal> meals;
  final Function(Meal) onDelete;
  
  const SwipeableMealCards({
    required this.meals,
    required this.onDelete,
    super.key,
  });
  
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: meals.length,
      itemBuilder: (context, index) {
        final meal = meals[index];
        return Dismissible(
          key: Key(meal.id),
          direction: DismissDirection.endToStart,
          onDismissed: (_) => onDelete(meal),
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            color: Colors.red,
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          child: MealCard(meal: meal),
        ).animate()
          .fadeIn(delay: (index * 50).ms)
          .slideX(begin: 0.2, delay: (index * 50).ms);
      },
    );
  }
}

class MealCard extends StatelessWidget {
  final Meal meal;
  
  const MealCard({required this.meal, super.key});
  
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.grey.shade900.withOpacity(0.5),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(meal.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('${meal.calories.toStringAsFixed(0)} cal'),
          const SizedBox(height: 4),
          Row(
            children: [
              _MacroChip(label: 'P', value: meal.protein, color: Colors.red),
              const SizedBox(width: 8),
              _MacroChip(label: 'C', value: meal.carbs, color: Colors.blue),
              const SizedBox(width: 8),
              _MacroChip(label: 'F', value: meal.fats, color: Colors.yellow),
            ],
          ),
        ],
      ),
    );
  }
}

class _MacroChip extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  
  const _MacroChip({required this.label, required this.value, required this.color});
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text('$label: ${value.toStringAsFixed(0)}g', style: TextStyle(color: color)),
    );
  }
}
```

## Navigation Structure

### Router Configuration

```dart
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/home',
    routes: [
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/workout',
        builder: (context, state) => const WorkoutScreen(),
        routes: [
          GoRoute(
            path: 'active',
            builder: (context, state) => const ActiveWorkoutScreen(),
          ),
          GoRoute(
            path: 'history',
            builder: (context, state) => const WorkoutHistoryScreen(),
          ),
          GoRoute(
            path: 'exercise/:name',
            builder: (context, state) {
              final name = state.pathParameters['name']!;
              return ExerciseDetailScreen(exerciseName: name);
            },
          ),
        ],
      ),
      GoRoute(
        path: '/progress',
        builder: (context, state) => const ProgressScreen(),
      ),
      GoRoute(
        path: '/nutrition',
        builder: (context, state) => const NutritionScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
    ],
  );
});

// Main App with Bottom Navigation
class MainApp extends ConsumerWidget {
  const MainApp({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    
    return MaterialApp.router(
      routerConfig: router,
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.green,
        scaffoldBackgroundColor: Colors.black,
        cardTheme: CardTheme(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          color: Colors.grey.shade900.withOpacity(0.5),
        ),
      ),
    );
  }
}

class MainScaffold extends StatefulWidget {
  final Widget child;
  
  const MainScaffold({required this.child, super.key});
  
  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _selectedIndex = 0;
  
  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
    
    final routes = ['/home', '/workout', '/progress', '/nutrition', '/profile'];
    context.go(routes[index]);
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.grey.shade900,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.fitness_center), label: 'Workout'),
          BottomNavigationBarItem(icon: Icon(Icons.trending_up), label: 'Progress'),
          BottomNavigationBarItem(icon: Icon(Icons.restaurant), label: 'Nutrition'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
```

## Workflow State Transitions

### Workout Flow

```
1. Home Screen
   ↓ (User taps "Start Workout")
2. Exercise Selection Screen
   ↓ (User selects exercise)
3. Active Workout Screen
   - Display exercise card with previous performance
   - Show progression suggestion
   - Input fields for reps/weight
   ↓ (User logs set)
4. Set Completion Animation (100ms)
   ↓
5. Rest Timer Starts (90s default)
   - Circular countdown animation
   - Skip/Extend buttons
   ↓ (Timer completes or user skips)
6. Ready for next set
   ↓ (User completes all sets)
7. Finish Workout Button Enabled
   ↓ (User taps finish)
8. Workout Summary Screen
   - Animated summary card
   - Total volume, sets, PRs
   - Save to local storage
   ↓ (Auto-navigate after 3s or user taps)
9. Return to Home Screen
```

### State Persistence Strategy

```dart
class WorkoutStateManager {
  static const String _stateKey = 'active_workout_state';
  
  // Save state after each set
  Future<void> saveState(Workout workout, DateTime startTime) async {
    final box = await Hive.openBox('app_state');
    await box.put(_stateKey, {
      'workout': WorkoutModel.fromEntity(workout).toJson(),
      'startTime': startTime.toIso8601String(),
    });
  }
  
  // Restore state on app launch
  Future<WorkoutState?> restoreState() async {
    final box = await Hive.openBox('app_state');
    final data = box.get(_stateKey);
    
    if (data == null) return null;
    
    final workoutJson = data['workout'] as Map<String, dynamic>;
    final workout = WorkoutModel.fromJson(workoutJson).toEntity();
    final startTime = DateTime.parse(data['startTime'] as String);
    
    return WorkoutState.inProgress(workout, startTime);
  }
  
  // Clear state after workout completion
  Future<void> clearState() async {
    final box = await Hive.openBox('app_state');
    await box.delete(_stateKey);
  }
}
```

## Performance Optimization Strategies

### 1. Lazy Loading for Lists

```dart
class WorkoutHistoryScreen extends ConsumerWidget {
  const WorkoutHistoryScreen({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workoutsAsync = ref.watch(workoutHistoryProvider);
    
    return workoutsAsync.when(
      data: (workouts) => ListView.builder(
        itemCount: workouts.length,
        itemBuilder: (context, index) {
          // Only build visible items
          return WorkoutListItem(workout: workouts[index]);
        },
      ),
      loading: () => const CircularProgressIndicator(),
      error: (error, stack) => ErrorWidget(error: error),
    );
  }
}
```

### 2. Const Widgets

```dart
// Use const constructors wherever possible
class WorkoutCard extends StatelessWidget {
  final Workout workout;
  
  const WorkoutCard({required this.workout, super.key});
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16), // const
      decoration: const BoxDecoration( // const
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      child: Column(
        children: [
          const Text('Workout', style: TextStyle(fontSize: 20)), // const
          Text(workout.date.toString()),
        ],
      ),
    );
  }
}
```

### 3. Caching Computed Values

```dart
class CachedVolumeCalculator {
  final Map<String, double> _cache = {};
  
  double calculateVolume(Workout workout) {
    if (_cache.containsKey(workout.id)) {
      return _cache[workout.id]!;
    }
    
    final volume = workout.exercises.fold(0.0, (total, exercise) {
      return total + exercise.sets.fold(0.0, (sum, set) {
        return sum + (set.weight * set.reps);
      });
    });
    
    _cache[workout.id] = volume;
    return volume;
  }
  
  void invalidate(String workoutId) {
    _cache.remove(workoutId);
  }
}
```

### 4. Debouncing User Input

```dart
class DebouncedSearchField extends StatefulWidget {
  final Function(String) onSearch;
  
  const DebouncedSearchField({required this.onSearch, super.key});
  
  @override
  State<DebouncedSearchField> createState() => _DebouncedSearchFieldState();
}

class _DebouncedSearchFieldState extends State<DebouncedSearchField> {
  Timer? _debounce;
  
  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    
    _debounce = Timer(const Duration(milliseconds: 300), () {
      widget.onSearch(query);
    });
  }
  
  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: _onSearchChanged,
      decoration: const InputDecoration(hintText: 'Search exercises...'),
    );
  }
}
```

### 5. Chart Data Sampling

```dart
class ChartDataSampler {
  static List<WeightDataPoint> sampleData(List<WeightDataPoint> data, int maxPoints) {
    if (data.length <= maxPoints) return data;
    
    final step = data.length / maxPoints;
    final sampled = <WeightDataPoint>[];
    
    for (var i = 0; i < maxPoints; i++) {
      final index = (i * step).floor();
      sampled.add(data[index]);
    }
    
    return sampled;
  }
}

// Usage in widget
class OptimizedWeightGraph extends StatelessWidget {
  final List<WeightDataPoint> dataPoints;
  
  const OptimizedWeightGraph({required this.dataPoints, super.key});
  
  @override
  Widget build(BuildContext context) {
    final sampledData = ChartDataSampler.sampleData(dataPoints, 100);
    return WeightTrendGraph(dataPoints: sampledData);
  }
}
```


## Error Handling

### Custom Exception Types

```dart
// Core exceptions
class AppException implements Exception {
  final String message;
  final String? code;
  
  AppException(this.message, {this.code});
  
  @override
  String toString() => 'AppException: $message${code != null ? ' (code: $code)' : ''}';
}

// Domain layer exceptions
class InvalidRepsException extends AppException {
  InvalidRepsException() : super('Reps must be a positive integer');
}

class InvalidWeightException extends AppException {
  InvalidWeightException() : super('Weight must be a positive number');
}

class InvalidRPEException extends AppException {
  InvalidRPEException() : super('RPE must be between 1 and 10');
}

class InvalidMacroException extends AppException {
  InvalidMacroException() : super('Macro values must be non-negative');
}

class EntityNotFoundException extends AppException {
  EntityNotFoundException(String entityType, String id) 
      : super('$entityType with id $id not found');
}

// Data layer exceptions
class StorageException extends AppException {
  StorageException(String message) : super(message, code: 'STORAGE_ERROR');
}

class SerializationException extends AppException {
  SerializationException(String message) : super(message, code: 'SERIALIZATION_ERROR');
}
```

### Error Handling Strategy

```dart
// Repository error handling with retry
class ResilientWorkoutRepository implements WorkoutRepository {
  final HiveWorkoutDataSource dataSource;
  final int maxRetries;
  
  ResilientWorkoutRepository(this.dataSource, {this.maxRetries = 1});
  
  @override
  Future<void> saveWorkout(Workout workout) async {
    int attempts = 0;
    
    while (attempts <= maxRetries) {
      try {
        final model = WorkoutModel.fromEntity(workout);
        await dataSource.saveWorkout(model);
        return;
      } catch (e) {
        attempts++;
        if (attempts > maxRetries) {
          throw StorageException('Failed to save workout after $maxRetries retries: $e');
        }
        await Future.delayed(Duration(milliseconds: 100 * attempts));
      }
    }
  }
}

// Presentation layer error handling
class ErrorHandler {
  static void handleError(BuildContext context, Object error, StackTrace? stack) {
    String message;
    
    if (error is InvalidRepsException || 
        error is InvalidWeightException || 
        error is InvalidRPEException ||
        error is InvalidMacroException) {
      message = error.toString();
    } else if (error is StorageException) {
      message = 'Failed to save data. Please try again.';
    } else if (error is EntityNotFoundException) {
      message = 'Item not found.';
    } else {
      message = 'An unexpected error occurred.';
      // Log to crash reporting service
      debugPrint('Unhandled error: $error\n$stack');
    }
    
    _showErrorDialog(context, message);
  }
  
  static void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

// Usage in widgets
class WorkoutScreen extends ConsumerWidget {
  const WorkoutScreen({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: ElevatedButton(
        onPressed: () async {
          try {
            await ref.read(workoutNotifierProvider.notifier).start();
          } catch (e, stack) {
            ErrorHandler.handleError(context, e, stack);
          }
        },
        child: const Text('Start Workout'),
      ),
    );
  }
}
```

## Correctness Properties

*A property is a characteristic or behavior that should hold true across all valid executions of a system—essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees.*

### Property Reflection

After analyzing all acceptance criteria, I identified the following testable properties. During reflection, I found several opportunities for consolidation:

**Redundancies Identified:**
1. Properties for entity creation (1.1, 5.1, 6.1) all test the same pattern: creating entities with required fields. These can be consolidated into a single property about entity creation.
2. Properties for data persistence (1.5, 17.6) both test round-trip persistence and can be combined.
3. Properties for validation (18.6, 18.7) test similar validation patterns and can be consolidated.
4. Properties for calculations (4.5, 6.4, 20.1) all test summation/calculation correctness but for different domains.

**Consolidated Properties:**
- Combined entity creation properties into one comprehensive property
- Combined validation properties into one property covering all validation rules
- Kept calculation properties separate as they validate different business logic domains

### Property 1: Entity Creation Completeness

*For any* valid input data (workout parameters, body entry data, meal data), creating an entity SHALL produce an object with all required fields populated, a valid UUID identifier, and a valid timestamp.

**Validates: Requirements 1.1, 5.1, 6.1**

### Property 2: Exercise Addition Preservation

*For any* workout and exercise, adding the exercise to the workout SHALL result in the workout containing that exercise with all its properties preserved.

**Validates: Requirements 1.2**

### Property 3: Set Logging Preservation

*For any* exercise and valid set entry (positive reps, non-negative weight, optional RPE 1-10), logging the set SHALL result in the exercise containing that set with all field values (reps, weight, RPE, timestamp) preserved.

**Validates: Requirements 1.3**

### Property 4: Workout Persistence Round-Trip

*For any* completed workout, saving the workout to local storage then retrieving it SHALL produce an equivalent workout with all exercises, sets, duration, and volume preserved.

**Validates: Requirements 1.5, 17.6**

### Property 5: Exercise History Retrieval Limit

*For any* exercise name with N historical performances where N ≥ 3, retrieving exercise history SHALL return exactly the 3 most recent performances sorted by date descending.

**Validates: Requirements 2.1**

### Property 6: Progression Suggestion Calculation

*For any* exercise with performance history, the progression engine SHALL calculate suggestions where:
- If last 3 performances are identical (same weight and reps), isStagnant is true and suggested weight increases by 5%
- Otherwise, suggested reps equal last best reps + 1 or suggested weight equals last best weight

**Validates: Requirements 2.2, 2.3**

### Property 7: Rest Timer State Transitions

*For any* rest timer state:
- Calling skip() SHALL transition to idle state
- Calling extend(n) while running SHALL increase remaining time by n seconds
- Timer reaching zero SHALL transition to completed state

**Validates: Requirements 3.4**

### Property 8: Workout History Sorting

*For any* collection of workouts, retrieving workout history SHALL return all workouts sorted by date in descending order (most recent first).

**Validates: Requirements 4.1**

### Property 9: Training Volume Calculation

*For any* workout with exercises and sets, the total training volume SHALL equal the sum of (weight × reps) for all sets across all exercises.

**Validates: Requirements 4.5**

### Property 10: Body Measurement Persistence

*For any* valid measurement map (chest, waist, hips, arms, legs with non-negative values), storing a body entry then retrieving it SHALL preserve all measurement values.

**Validates: Requirements 5.2**

### Property 11: Daily Nutrition Totals Calculation

*For any* collection of meals for a given date, the daily nutrition summary SHALL calculate totals where:
- Total protein = sum of all meal protein values
- Total carbs = sum of all meal carbs values
- Total fats = sum of all meal fats values
- Total calories = sum of all meal calories values

**Validates: Requirements 6.4**

### Property 12: Macro Estimation Consistency

*For any* food item, applying the macro estimation rules SHALL produce consistent macro values (protein, carbs, fats) that sum to match the estimated calories using the formula: calories = (protein × 4) + (carbs × 4) + (fats × 9).

**Validates: Requirements 6.2**

### Property 13: UUID Generation Uniqueness

*For any* sequence of entity creations, all generated UUIDs SHALL be unique and conform to valid UUID v4 format.

**Validates: Requirements 7.5**

### Property 14: Navigation State Preservation

*For any* tab with active state (e.g., scroll position, form data), switching to another tab and returning SHALL preserve the original state.

**Validates: Requirements 12.4**

### Property 15: JSON Serialization Completeness

*For any* data model (WorkoutModel, ExerciseModel, SetEntryModel, MealModel, BodyEntryModel), serializing to JSON SHALL include all required fields with correct types.

**Validates: Requirements 14.3**

### Property 16: JSON Deserialization Error Handling

*For any* JSON object missing required fields, attempting to deserialize SHALL throw a SerializationException with a descriptive error message.

**Validates: Requirements 14.4**

### Property 17: Serialization Round-Trip

*For any* valid data model instance, serializing to JSON then deserializing back to a model SHALL produce an equivalent object where all field values match the original.

**Validates: Requirements 14.5**

### Property 18: Chart Data Sampling Distribution

*For any* dataset with more than 100 data points, sampling to 100 points SHALL produce an evenly distributed subset where sampled points are approximately equidistant in the original dataset.

**Validates: Requirements 16.2**

### Property 19: Computation Caching Consistency

*For any* cached computation (volume calculation, macro totals), repeated calls with the same input SHALL return identical results without recalculation, and cache invalidation SHALL force recalculation on next call.

**Validates: Requirements 16.4**

### Property 20: Input Debouncing

*For any* rapid sequence of input events within a debounce window (300ms), only the final input value after the window expires SHALL trigger a state update.

**Validates: Requirements 16.5**

### Property 21: Validation Enforcement

*For any* entity creation with invalid data:
- Non-positive weight values SHALL throw InvalidWeightException
- Non-positive reps values SHALL throw InvalidRepsException
- RPE values outside 1-10 range SHALL throw InvalidRPEException
- Negative macro values SHALL throw InvalidMacroException

**Validates: Requirements 18.6, 18.7**

### Property 22: Remaining Macro Calculation

*For any* macro target and consumed macros, the remaining macros SHALL equal (target - consumed) clamped to a minimum of 0 for each macro (protein, carbs, fats).

**Validates: Requirements 20.1**

### Property 23: Meal Suggestion Budget Compliance

*For any* remaining macro budget, all meal suggestions returned SHALL have macro values (protein, carbs, fats) less than or equal to the corresponding remaining budget values.

**Validates: Requirements 20.2**

### Property 24: Meal Suggestion Categorization

*For any* meal suggestion, the category SHALL be determined by:
- High-protein: protein > 30g and protein > (carbs + fats)
- High-carb: carbs > 40g and carbs > (protein + fats)
- Balanced: protein > 20g AND carbs > 30g AND fats > 10g

**Validates: Requirements 20.3**


## Testing Strategy

### Dual Testing Approach

The Progression Tracker app will employ a comprehensive testing strategy combining property-based testing for business logic with example-based unit tests and integration tests for UI and infrastructure concerns.

#### Property-Based Testing

**Library**: We will use the **fast_check** Dart package (port of JavaScript's fast-check) or **test_api** with custom generators for property-based testing.

**Configuration**:
- Minimum 100 iterations per property test
- Each property test tagged with: `Feature: progression-tracker-app, Property {number}: {property_text}`
- Tests located in `test/properties/` directory organized by feature

**Property Test Structure**:
```dart
import 'package:test/test.dart';
import 'package:fast_check/fast_check.dart';

void main() {
  group('Workout Module Properties', () {
    test(
      'Feature: progression-tracker-app, Property 1: Entity Creation Completeness',
      () {
        fc.assert(
          fc.property(
            fc.record({
              'exercises': fc.array(exerciseArbitrary),
              'duration': fc.integer(min: 0, max: 10800), // 0-3 hours in seconds
            }),
            (data) {
              final workout = Workout(
                id: const Uuid().v4(),
                date: DateTime.now(),
                exercises: data['exercises'] as List<Exercise>,
                duration: Duration(seconds: data['duration'] as int),
                totalVolume: 0,
              );
              
              // Verify all required fields are present and valid
              expect(workout.id, isNotEmpty);
              expect(Uuid.isValidUUID(fromString: workout.id), isTrue);
              expect(workout.date, isNotNull);
              expect(workout.exercises, isNotNull);
              expect(workout.duration, isNotNull);
            },
          ),
          numRuns: 100,
        );
      },
    );
    
    test(
      'Feature: progression-tracker-app, Property 4: Workout Persistence Round-Trip',
      () async {
        final repository = WorkoutRepositoryImpl(HiveWorkoutDataSource());
        
        fc.assert(
          fc.asyncProperty(
            workoutArbitrary,
            (workout) async {
              // Save workout
              await repository.saveWorkout(workout);
              
              // Retrieve all workouts
              final workouts = await repository.getAllWorkouts();
              
              // Find the saved workout
              final retrieved = workouts.firstWhere((w) => w.id == workout.id);
              
              // Verify equivalence
              expect(retrieved.id, equals(workout.id));
              expect(retrieved.date, equals(workout.date));
              expect(retrieved.exercises.length, equals(workout.exercises.length));
              expect(retrieved.duration, equals(workout.duration));
              expect(retrieved.totalVolume, equals(workout.totalVolume));
            },
          ),
          numRuns: 100,
        );
      },
    );
  });
}

// Custom arbitraries for domain entities
final exerciseArbitrary = fc.record({
  'id': fc.uuid(),
  'name': fc.string(minLength: 1, maxLength: 50),
  'type': fc.constantFrom(ExerciseType.values),
  'sets': fc.array(setEntryArbitrary, minLength: 0, maxLength: 10),
}).map((data) => Exercise(
  id: data['id'] as String,
  name: data['name'] as String,
  type: data['type'] as ExerciseType,
  sets: data['sets'] as List<SetEntry>,
));

final setEntryArbitrary = fc.record({
  'reps': fc.integer(min: 1, max: 50),
  'weight': fc.double(min: 0.0, max: 500.0),
  'rpe': fc.option(fc.integer(min: 1, max: 10)),
}).map((data) => SetEntry(
  id: const Uuid().v4(),
  reps: data['reps'] as int,
  weight: data['weight'] as double,
  rpe: data['rpe'] as int?,
  timestamp: DateTime.now(),
));

final workoutArbitrary = fc.record({
  'exercises': fc.array(exerciseArbitrary, minLength: 0, maxLength: 10),
  'duration': fc.integer(min: 0, max: 10800),
  'totalVolume': fc.double(min: 0.0, max: 50000.0),
}).map((data) => Workout(
  id: const Uuid().v4(),
  date: DateTime.now(),
  exercises: data['exercises'] as List<Exercise>,
  duration: Duration(seconds: data['duration'] as int),
  totalVolume: data['totalVolume'] as double,
));
```

#### Unit Testing

**Purpose**: Test specific examples, edge cases, and error conditions that complement property tests.

**Coverage**:
- Specific business logic scenarios (e.g., PR detection with exact values)
- Edge cases (empty lists, boundary values, null handling)
- Error conditions (invalid inputs, storage failures)
- State transitions (workout flow states, timer states)

**Example Unit Tests**:
```dart
group('Progression Engine Unit Tests', () {
  test('should detect PR when new volume exceeds previous best', () async {
    final repository = MockWorkoutRepository();
    final useCase = DetectPersonalRecordUseCase(repository);
    
    // Setup: Previous best was 100kg × 10 reps = 1000 volume
    when(repository.getExerciseHistory('Bench Press', 100))
        .thenAnswer((_) async => [
          Exercise(
            id: '1',
            name: 'Bench Press',
            type: ExerciseType.strength,
            sets: [SetEntry(id: '1', reps: 10, weight: 100, timestamp: DateTime.now())],
          ),
        ]);
    
    // New set: 105kg × 10 reps = 1050 volume (PR!)
    final newSet = SetEntry(id: '2', reps: 10, weight: 105, timestamp: DateTime.now());
    
    final isPR = await useCase('Bench Press', newSet);
    
    expect(isPR, isTrue);
  });
  
  test('should not detect PR when new volume equals previous best', () async {
    final repository = MockWorkoutRepository();
    final useCase = DetectPersonalRecordUseCase(repository);
    
    when(repository.getExerciseHistory('Bench Press', 100))
        .thenAnswer((_) async => [
          Exercise(
            id: '1',
            name: 'Bench Press',
            type: ExerciseType.strength,
            sets: [SetEntry(id: '1', reps: 10, weight: 100, timestamp: DateTime.now())],
          ),
        ]);
    
    final newSet = SetEntry(id: '2', reps: 10, weight: 100, timestamp: DateTime.now());
    
    final isPR = await useCase('Bench Press', newSet);
    
    expect(isPR, isFalse);
  });
  
  test('should handle empty exercise history as first-time PR', () async {
    final repository = MockWorkoutRepository();
    final useCase = DetectPersonalRecordUseCase(repository);
    
    when(repository.getExerciseHistory('New Exercise', 100))
        .thenAnswer((_) async => []);
    
    final newSet = SetEntry(id: '1', reps: 8, weight: 50, timestamp: DateTime.now());
    
    final isPR = await useCase('New Exercise', newSet);
    
    expect(isPR, isTrue);
  });
});

group('Validation Unit Tests', () {
  test('should throw InvalidWeightException for negative weight', () {
    expect(
      () => SetEntry.create(reps: 10, weight: -5),
      throwsA(isA<InvalidWeightException>()),
    );
  });
  
  test('should throw InvalidRepsException for zero reps', () {
    expect(
      () => SetEntry.create(reps: 0, weight: 100),
      throwsA(isA<InvalidRepsException>()),
    );
  });
  
  test('should throw InvalidRPEException for RPE > 10', () {
    expect(
      () => SetEntry.create(reps: 10, weight: 100, rpe: 11),
      throwsA(isA<InvalidRPEException>()),
    );
  });
  
  test('should accept valid set entry', () {
    final set = SetEntry.create(reps: 10, weight: 100, rpe: 8);
    
    expect(set.reps, equals(10));
    expect(set.weight, equals(100));
    expect(set.rpe, equals(8));
  });
});
```

#### Integration Testing

**Purpose**: Test UI interactions, navigation flows, storage operations, and performance requirements.

**Coverage**:
- Widget rendering and animations
- Navigation flows (workout flow, tab switching)
- Local storage operations (Hive integration)
- Performance requirements (100ms feedback, 60 FPS animations)
- Error handling and recovery

**Example Integration Tests**:
```dart
group('Workout Flow Integration Tests', () {
  testWidgets('should complete full workout flow', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: MainApp()));
    
    // 1. Start workout
    await tester.tap(find.text('Start Workout'));
    await tester.pumpAndSettle();
    
    expect(find.byType(ActiveWorkoutScreen), findsOneWidget);
    
    // 2. Add exercise
    await tester.tap(find.text('Add Exercise'));
    await tester.pumpAndSettle();
    
    await tester.enterText(find.byType(TextField), 'Bench Press');
    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();
    
    // 3. Log set
    await tester.enterText(find.byKey(const Key('reps_input')), '10');
    await tester.enterText(find.byKey(const Key('weight_input')), '100');
    await tester.tap(find.text('Log Set'));
    await tester.pump(const Duration(milliseconds: 100));
    
    // Verify set completion animation appears
    expect(find.byType(SetCompletionAnimation), findsOneWidget);
    
    // Verify rest timer starts
    await tester.pumpAndSettle();
    expect(find.byType(RestTimerCircular), findsOneWidget);
    
    // 4. Skip rest timer
    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();
    
    // 5. Finish workout
    await tester.tap(find.text('Finish Workout'));
    await tester.pumpAndSettle();
    
    // Verify summary screen
    expect(find.byType(WorkoutSummaryCard), findsOneWidget);
    expect(find.textContaining('Total Volume'), findsOneWidget);
  });
  
  testWidgets('should preserve navigation state when switching tabs', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: MainApp()));
    
    // Navigate to workout history and scroll
    await tester.tap(find.text('Workout'));
    await tester.pumpAndSettle();
    
    await tester.tap(find.text('History'));
    await tester.pumpAndSettle();
    
    // Scroll down
    await tester.drag(find.byType(ListView), const Offset(0, -500));
    await tester.pumpAndSettle();
    
    final scrollPosition = tester.widget<ListView>(find.byType(ListView)).controller?.offset;
    
    // Switch to another tab
    await tester.tap(find.text('Progress'));
    await tester.pumpAndSettle();
    
    // Switch back
    await tester.tap(find.text('Workout'));
    await tester.pumpAndSettle();
    
    // Verify scroll position preserved
    final newScrollPosition = tester.widget<ListView>(find.byType(ListView)).controller?.offset;
    expect(newScrollPosition, equals(scrollPosition));
  });
});

group('Performance Integration Tests', () {
  testWidgets('should provide visual feedback within 100ms', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: MainApp()));
    
    final stopwatch = Stopwatch()..start();
    
    await tester.tap(find.text('Log Set'));
    await tester.pump(const Duration(milliseconds: 100));
    
    stopwatch.stop();
    
    // Verify animation appears within 100ms
    expect(find.byType(SetCompletionAnimation), findsOneWidget);
    expect(stopwatch.elapsedMilliseconds, lessThanOrEqualTo(100));
  });
  
  test('should handle 1000+ workouts with lazy loading', () async {
    final repository = WorkoutRepositoryImpl(HiveWorkoutDataSource());
    
    // Create 1000 workouts
    for (var i = 0; i < 1000; i++) {
      await repository.saveWorkout(Workout(
        id: const Uuid().v4(),
        date: DateTime.now().subtract(Duration(days: i)),
        exercises: [],
        duration: const Duration(minutes: 60),
        totalVolume: 1000,
      ));
    }
    
    final stopwatch = Stopwatch()..start();
    final workouts = await repository.getAllWorkouts();
    stopwatch.stop();
    
    expect(workouts.length, equals(1000));
    expect(stopwatch.elapsedMilliseconds, lessThan(1000)); // Should load in < 1s
  });
});

group('Storage Integration Tests', () {
  test('should retry once on storage failure', () async {
    final mockDataSource = MockHiveWorkoutDataSource();
    final repository = ResilientWorkoutRepository(mockDataSource, maxRetries: 1);
    
    var callCount = 0;
    when(mockDataSource.saveWorkout(any)).thenAnswer((_) async {
      callCount++;
      if (callCount == 1) throw Exception('Storage failure');
      return;
    });
    
    final workout = Workout(
      id: '1',
      date: DateTime.now(),
      exercises: [],
      duration: const Duration(minutes: 60),
      totalVolume: 0,
    );
    
    await repository.saveWorkout(workout);
    
    expect(callCount, equals(2)); // Initial attempt + 1 retry
  });
  
  test('should throw StorageException after max retries', () async {
    final mockDataSource = MockHiveWorkoutDataSource();
    final repository = ResilientWorkoutRepository(mockDataSource, maxRetries: 1);
    
    when(mockDataSource.saveWorkout(any))
        .thenThrow(Exception('Persistent storage failure'));
    
    final workout = Workout(
      id: '1',
      date: DateTime.now(),
      exercises: [],
      duration: const Duration(minutes: 60),
      totalVolume: 0,
    );
    
    expect(
      () => repository.saveWorkout(workout),
      throwsA(isA<StorageException>()),
    );
  });
});
```

#### Widget Testing

**Purpose**: Test individual widgets and animation components in isolation.

**Coverage**:
- Animation components (set completion, rest timer, macro wheel)
- Custom widgets (workout cards, meal cards, exercise cards)
- Visual design requirements (glassmorphism, rounded corners)

**Example Widget Tests**:
```dart
group('Animation Component Tests', () {
  testWidgets('RestTimerCircular should display countdown', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          restTimerProvider.overrideWith((ref) {
            final notifier = RestTimerNotifier();
            notifier.start(seconds: 90);
            return notifier;
          }),
        ],
        child: const MaterialApp(home: Scaffold(body: RestTimerCircular())),
      ),
    );
    
    await tester.pump();
    
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('90s'), findsOneWidget);
    
    // Advance time
    await tester.pump(const Duration(seconds: 1));
    
    expect(find.text('89s'), findsOneWidget);
  });
  
  testWidgets('MacroWheelChart should render with correct proportions', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: MacroWheelChart(
            protein: 150,
            carbs: 200,
            fats: 60,
          ),
        ),
      ),
    );
    
    await tester.pumpAndSettle();
    
    expect(find.byType(PieChart), findsOneWidget);
    
    // Verify percentages
    expect(find.text('37%'), findsOneWidget); // protein: 150/410
    expect(find.text('49%'), findsOneWidget); // carbs: 200/410
    expect(find.text('15%'), findsOneWidget); // fats: 60/410
  });
});
```

### Test Organization

```
test/
├── properties/                    # Property-based tests
│   ├── workout_properties_test.dart
│   ├── body_properties_test.dart
│   ├── nutrition_properties_test.dart
│   └── arbitraries/              # Custom generators
│       ├── workout_arbitraries.dart
│       ├── body_arbitraries.dart
│       └── nutrition_arbitraries.dart
├── unit/                         # Unit tests
│   ├── domain/
│   │   ├── usecases/
│   │   └── entities/
│   └── data/
│       ├── repositories/
│       └── models/
├── integration/                  # Integration tests
│   ├── workout_flow_test.dart
│   ├── navigation_test.dart
│   ├── storage_test.dart
│   └── performance_test.dart
└── widget/                       # Widget tests
    ├── animations/
    ├── screens/
    └── components/
```

### Testing Requirements Summary

1. **Property-Based Tests**: 24 properties covering core business logic
2. **Unit Tests**: Specific examples and edge cases for each use case
3. **Integration Tests**: Full workflow testing, storage operations, performance validation
4. **Widget Tests**: UI components and animations
5. **Minimum Coverage**: 80% code coverage across all layers
6. **Performance Benchmarks**: All tests must verify <100ms feedback requirements

### Continuous Integration

```yaml
# .github/workflows/test.yml
name: Test Suite

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.x'
      
      - name: Install dependencies
        run: flutter pub get
      
      - name: Run property-based tests
        run: flutter test test/properties/
      
      - name: Run unit tests
        run: flutter test test/unit/
      
      - name: Run integration tests
        run: flutter test test/integration/
      
      - name: Run widget tests
        run: flutter test test/widget/
      
      - name: Generate coverage
        run: flutter test --coverage
      
      - name: Check coverage threshold
        run: |
          lcov --summary coverage/lcov.info
          # Fail if coverage < 80%
```

---

## Summary

This technical design document provides a comprehensive blueprint for implementing the Progression Tracker fitness app with:

1. **Clean Architecture**: Strict layer separation with Domain, Data, and Presentation layers
2. **Offline-First**: Complete functionality using Hive local storage without network dependency
3. **Feature Modularity**: Independent workout, body, and nutrition modules
4. **State Management**: Riverpod with immutable state using Freezed
5. **Performance**: <100ms feedback, 60 FPS animations, lazy loading, caching
6. **Reusable Animations**: Shared animation components using flutter_animate and Lottie
7. **Comprehensive Testing**: 24 correctness properties with property-based testing, plus unit, integration, and widget tests

The design addresses all 20 requirements with detailed specifications for data models, use cases, repositories, state management, animations, navigation, error handling, and testing strategies. The implementation will follow Test-Driven Development with property-based tests ensuring correctness across all valid inputs.
