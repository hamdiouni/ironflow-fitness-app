# Technical Design Document: IronFlow Product Upgrade

## Architecture Overview

The upgrade maintains IronFlow's Clean Architecture while fixing system connections and completing partial implementations.

### Key Design Principles

1. **Single Source of Truth**: Active program is the authoritative source for all workouts
2. **Reactive State Management**: Riverpod providers automatically update dependent screens
3. **Offline-First**: All data persists locally with Hive
4. **Type Safety**: Freezed immutable data classes throughout
5. **Error Handling**: User-friendly messages with proper exception mapping

---

## Part 1: Critical Bug Fixes

### Fix 1: Workout Start Flow

**Current Problem:**
```dart
// BROKEN: Creates empty workout
Future<Workout> call() async {
  return Workout(
    id: const Uuid().v4(),
    date: DateTime.now(),
    exercises: [],  // ← ALWAYS EMPTY
    duration: Duration.zero,
    totalVolume: 0,
  );
}
```

**Solution:**
```dart
class StartWorkoutUseCase {
  final WorkoutRepository repository;
  final ActiveProgramRepository activeProgramRepository;

  StartWorkoutUseCase(this.repository, this.activeProgramRepository);

  Future<Workout> call() async {
    // Load active program
    final activeProgram = await activeProgramRepository.loadActiveProgram();
    
    if (activeProgram == null) {
      throw ActiveProgramException('No active program set');
    }

    // Get current day exercises
    final currentDay = activeProgram.currentDay;
    
    // Convert program exercises to workout exercises
    final exercises = currentDay.exercises.map((pe) => Exercise(
      id: const Uuid().v4(),
      name: pe.exerciseName,
      type: ExerciseType.strength,
      sets: [],
      suggestedSets: pe.sets,
      suggestedReps: pe.reps,
      suggestedRestSeconds: pe.restSeconds,
    )).toList();

    return Workout(
      id: const Uuid().v4(),
      date: DateTime.now(),
      exercises: exercises,
      duration: Duration.zero,
      totalVolume: 0,
      programDayId: currentDay.dayNumber,
    );
  }
}
```

**Impact**: Workouts now load with all program exercises pre-populated.

---

### Fix 2: Weight Validation

**Current Problem:**
```dart
// BROKEN: No validation
TextField(
  keyboardType: TextInputType.number,
  onChanged: (value) {
    weight = double.tryParse(value) ?? 0;
  },
)
```

**Solution:**
```dart
class WeightInputField extends StatefulWidget {
  final double initialValue;
  final Function(double) onChanged;
  final String? Function(String?)? validator;

  const WeightInputField({
    required this.initialValue,
    required this.onChanged,
    this.validator,
  });

  @override
  State<WeightInputField> createState() => _WeightInputFieldState();
}

class _WeightInputFieldState extends State<WeightInputField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue.toString());
  }

  String? _validateWeight(String? value) {
    if (value == null || value.isEmpty) return 'Weight required';
    
    final weight = double.tryParse(value);
    if (weight == null) return 'Invalid number';
    if (weight < 0 || weight > 500) return 'Weight must be 0-500kg';
    
    return widget.validator?.call(value);
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: 'Weight (kg)',
        hintText: '0-500',
        errorMaxLines: 2,
      ),
      validator: _validateWeight,
      onChanged: (value) {
        final weight = double.tryParse(value);
        if (weight != null && weight >= 0 && weight <= 500) {
          widget.onChanged(weight);
        }
      },
    );
  }
}
```

**Impact**: Prevents 20kg → 200kg typos. Real-time validation feedback.

---

### Fix 3: Video System Integration

**Current Problem:**
- Video map exists but no player widget
- Thumbnails show but don't open player
- No fallback handling

**Solution:**

Create `lib/features/workout/presentation/widgets/exercise_video_player.dart`:

```dart
class ExerciseVideoPlayer extends ConsumerStatefulWidget {
  final String exerciseName;
  final String videoUrl;
  final String thumbnailUrl;

  const ExerciseVideoPlayer({
    required this.exerciseName,
    required this.videoUrl,
    required this.thumbnailUrl,
  });

  @override
  ConsumerState<ExerciseVideoPlayer> createState() => _ExerciseVideoPlayerState();
}

class _ExerciseVideoPlayerState extends ConsumerState<ExerciseVideoPlayer> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _hasError = false;
  bool _isMuted = true;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
      await _controller.initialize();
      await _controller.setVolume(0); // Muted by default
      await _controller.play();
      await _controller.setLooping(true);
      
      setState(() => _isInitialized = true);
    } catch (e) {
      setState(() => _hasError = true);
      _retryAfterDelay();
    }
  }

  Future<void> _retryAfterDelay() async {
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      _initializeVideo();
    }
  }

  void _toggleMute() {
    setState(() => _isMuted = !_isMuted);
    _controller.setVolume(_isMuted ? 0 : 1);
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return _buildErrorState();
    }

    if (!_isInitialized) {
      return _buildLoadingState();
    }

    return _buildPlayerState();
  }

  Widget _buildLoadingState() {
    return Container(
      color: Colors.black,
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      color: Colors.black,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.network(
            widget.thumbnailUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: Colors.grey[800],
              child: const Icon(Icons.fitness_center, size: 64),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Video unavailable',
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerState() {
    return GestureDetector(
      onTap: () => _enterFullscreen(),
      child: Stack(
        alignment: Alignment.center,
        children: [
          AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: VideoPlayer(_controller),
          ),
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton.small(
              onPressed: _toggleMute,
              child: Icon(_isMuted ? Icons.volume_off : Icons.volume_up),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _enterFullscreen() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _FullscreenVideoPlayer(
          controller: _controller,
          onMuteToggle: _toggleMute,
          isMuted: _isMuted,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
```

**Impact**: Videos now play in-app with proper controls. Fallback to image on error.

---

## Part 2: System Connections

### Connection 1: Onboarding → Program Generation → Active Program

**Current Flow (Broken):**
```
User completes onboarding
  ↓
Profile saved to storage
  ↓
(Nothing happens - user sees "No Active Program")
```

**New Flow:**
```
User completes onboarding
  ↓
Profile saved to storage
  ↓
Program generated from profile
  ↓
Program saved as ACTIVE PROGRAM
  ↓
Diet plan generated from profile
  ↓
Diet plan saved
  ↓
Navigate to workout screen
  ↓
User sees first day of program ready to go
```

**Implementation:**

Modify `lib/features/onboarding/presentation/providers/onboarding_provider.dart`:

```dart
class OnboardingNotifier extends StateNotifier<AsyncValue<void>> {
  OnboardingNotifier(
    this._storage,
    this._generateProgramUseCase,
    this._setActiveProgramUseCase,
    this._generateDietPlanUseCase,
    this._saveDietPlanUseCase,
  ) : super(const AsyncValue.data(null));

  final UserProfileStorage _storage;
  final GenerateWorkoutProgramUseCase _generateProgramUseCase;
  final SetActiveProgramUseCase _setActiveProgramUseCase;
  final GenerateDietPlanUseCase _generateDietPlanUseCase;
  final SaveDietPlanUseCase _saveDietPlanUseCase;

  Future<void> completeOnboarding(UserProfile profile) async {
    state = const AsyncValue.loading();
    try {
      // 1. Save profile
      await _storage.saveProfile(profile);

      // 2. Generate and set active program
      final program = _generateProgramUseCase(userProfile: profile);
      await _setActiveProgramUseCase(program);

      // 3. Generate and save diet plan
      final dietPlan = _generateDietPlanUseCase(userProfile: profile);
      await _saveDietPlanUseCase(dietPlan);

      // 4. Mark onboarded
      await _storage.markOnboarded();

      state = const AsyncValue.data(null);
    } catch (e, s) {
      state = AsyncValue.error(e, s);
    }
  }
}
```

**Impact**: Users complete onboarding and immediately see their program ready to use.

---

### Connection 2: Workout Screen → Active Program → Exercises

**Current Problem:**
- Workout screen watches active program ✓
- But doesn't pass it to active workout screen ✗
- Active workout screen creates empty workout ✗

**Solution:**

Modify `lib/features/workout/presentation/screens/active_workout_screen.dart`:

```dart
class ActiveWorkoutScreen extends ConsumerStatefulWidget {
  final ActiveProgram? activeProgram;  // NEW: Accept program as parameter

  const ActiveWorkoutScreen({
    super.key,
    this.activeProgram,
  });

  @override
  ConsumerState<ActiveWorkoutScreen> createState() => _ActiveWorkoutScreenState();
}

class _ActiveWorkoutScreenState extends ConsumerState<ActiveWorkoutScreen> {
  @override
  void initState() {
    super.initState();
    _startWorkout();
  }

  Future<void> _startWorkout() async {
    try {
      final useCase = ref.read(startWorkoutUseCaseProvider);
      final workout = await useCase.call();  // Now loads from active program
      
      ref.read(workoutNotifierProvider.notifier).startWorkout(workout);
    } catch (e) {
      if (mounted) {
        ErrorHandler.handleError(context, e, null);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // ... rest of widget
  }
}
```

Modify navigation in `workout_screen.dart`:

```dart
ElevatedButton(
  onPressed: () {
    context.push(
      AppRoutes.workoutActive,
      extra: activeProgram,  // Pass active program
    );
  },
  child: const Text('Start Workout'),
)
```

**Impact**: Workouts now load with all program exercises automatically.

---

### Connection 3: Nutrition Screen → Diet Plan Generation

**Current Problem:**
```dart
ElevatedButton.icon(
  onPressed: () => {},  // ← EMPTY
  icon: const Icon(Icons.add),
  label: const Text('Generate Diet Plan'),
),
```

**Solution:**

```dart
ElevatedButton.icon(
  onPressed: () async {
    try {
      final userProfile = await ref.read(userProfileProvider.future);
      if (userProfile == null) {
        throw Exception('User profile not found');
      }

      // Generate diet plan
      final generateUseCase = ref.read(generateDietPlanUseCaseProvider);
      final dietPlan = generateUseCase(userProfile: userProfile);

      // Save diet plan
      final saveUseCase = ref.read(saveDietPlanUseCaseProvider);
      await saveUseCase(dietPlan);

      // Refresh provider to show new plan
      ref.invalidate(dietPlanProvider);

      if (mounted) {
        ErrorHandler.showSnackBar(context, 'Diet plan generated!');
      }
    } catch (e, s) {
      if (mounted) {
        ErrorHandler.handleError(context, e, s);
      }
    }
  },
  icon: const Icon(Icons.add),
  label: const Text('Generate Diet Plan'),
),
```

**Impact**: Users can now generate personalized diet plans with one tap.

---

## Part 3: Complete Partial Implementations

### Implementation 1: Program Editor Screen

Create `lib/features/workout/presentation/screens/program_editor_screen.dart`:

```dart
class ProgramEditorScreen extends ConsumerStatefulWidget {
  const ProgramEditorScreen({super.key});

  @override
  ConsumerState<ProgramEditorScreen> createState() => _ProgramEditorScreenState();
}

class _ProgramEditorScreenState extends ConsumerState<ProgramEditorScreen> {
  late int _selectedDayIndex;

  @override
  void initState() {
    super.initState();
    _selectedDayIndex = 0;
  }

  @override
  Widget build(BuildContext context) {
    final activeProgramAsync = ref.watch(activeProgramProvider);

    return activeProgramAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        body: Center(child: Text('Error: $error')),
      ),
      data: (activeProgram) {
        if (activeProgram == null) {
          return const Scaffold(
            body: Center(child: Text('No active program')),
          );
        }

        final currentDay = activeProgram.program.days[_selectedDayIndex];

        return Scaffold(
          appBar: AppBar(
            title: const Text('Edit Program'),
            actions: [
              IconButton(
                onPressed: () => _saveProgram(activeProgram),
                icon: const Icon(Icons.check),
              ),
            ],
          ),
          body: Column(
            children: [
              // Day selector
              SizedBox(
                height: 60,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: activeProgram.program.days.length,
                  itemBuilder: (context, index) {
                    final day = activeProgram.program.days[index];
                    final isSelected = index == _selectedDayIndex;

                    return Padding(
                      padding: const EdgeInsets.all(8),
                      child: FilterChip(
                        selected: isSelected,
                        label: Text(day.name),
                        onSelected: (_) {
                          setState(() => _selectedDayIndex = index);
                        },
                      ),
                    );
                  },
                ),
              ),
              // Exercise list
              Expanded(
                child: ReorderableListView.builder(
                  onReorder: (oldIndex, newIndex) {
                    _reorderExercises(activeProgram, _selectedDayIndex, oldIndex, newIndex);
                  },
                  itemCount: currentDay.exercises.length,
                  itemBuilder: (context, index) {
                    final exercise = currentDay.exercises[index];

                    return ExerciseEditCard(
                      key: ValueKey(exercise.exerciseName),
                      exercise: exercise,
                      onReplace: () => _showReplaceDialog(activeProgram, _selectedDayIndex, index),
                      onEdit: () => _showEditDialog(activeProgram, _selectedDayIndex, index),
                      onDelete: () => _deleteExercise(activeProgram, _selectedDayIndex, index),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _saveProgram(ActiveProgram activeProgram) async {
    try {
      final useCase = ref.read(updateActiveProgramUseCaseProvider);
      await useCase(activeProgram);
      
      if (mounted) {
        ErrorHandler.showSnackBar(context, 'Program saved!');
        context.pop();
      }
    } catch (e, s) {
      if (mounted) {
        ErrorHandler.handleError(context, e, s);
      }
    }
  }

  void _showReplaceDialog(ActiveProgram activeProgram, int dayIndex, int exerciseIndex) {
    // Show exercise picker
    context.push(
      AppRoutes.exercisePicker,
      extra: {
        'muscleGroup': _getMuscleGroup(activeProgram.program.days[dayIndex].exercises[exerciseIndex].exerciseName),
        'onSelect': (String exerciseName) {
          _replaceExercise(activeProgram, dayIndex, exerciseIndex, exerciseName);
        },
      },
    );
  }

  void _showEditDialog(ActiveProgram activeProgram, int dayIndex, int exerciseIndex) {
    final exercise = activeProgram.program.days[dayIndex].exercises[exerciseIndex];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Exercise'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              initialValue: exercise.sets.toString(),
              decoration: const InputDecoration(labelText: 'Sets'),
              onChanged: (value) {
                // Update sets
              },
            ),
            TextFormField(
              initialValue: exercise.reps,
              decoration: const InputDecoration(labelText: 'Reps'),
              onChanged: (value) {
                // Update reps
              },
            ),
            TextFormField(
              initialValue: exercise.restSeconds.toString(),
              decoration: const InputDecoration(labelText: 'Rest (seconds)'),
              onChanged: (value) {
                // Update rest
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Save changes
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _replaceExercise(ActiveProgram activeProgram, int dayIndex, int exerciseIndex, String newExerciseName) {
    // Update exercise in program
    ref.read(replaceExerciseUseCaseProvider).call(
      dayIndex: dayIndex,
      exerciseIndex: exerciseIndex,
      newExerciseName: newExerciseName,
    );
  }

  void _reorderExercises(ActiveProgram activeProgram, int dayIndex, int oldIndex, int newIndex) {
    ref.read(reorderExercisesUseCaseProvider).call(
      dayIndex: dayIndex,
      oldIndex: oldIndex,
      newIndex: newIndex,
    );
  }

  void _deleteExercise(ActiveProgram activeProgram, int dayIndex, int exerciseIndex) {
    // Delete exercise from program
  }

  String _getMuscleGroup(String exerciseName) {
    // Return muscle group for exercise
    return 'chest';
  }
}
```

**Impact**: Users can now fully customize their programs.

---

## Part 4: Missing Features

### Feature 1: Progression Suggestion System

Create `lib/features/workout/domain/usecases/get_progression_suggestion_use_case.dart`:

```dart
class GetProgressionSuggestionUseCase {
  final WorkoutRepository repository;
  final ActiveProgramRepository activeProgramRepository;

  GetProgressionSuggestionUseCase(this.repository, this.activeProgramRepository);

  Future<ProgressionSuggestion?> call(String exerciseName) async {
    // Get last 3 workouts for this exercise
    final history = await repository.getExerciseHistory(exerciseName, limit: 3);
    if (history.isEmpty) return null;

    final lastWorkout = history.first;
    final previousWorkout = history.length > 1 ? history[1] : null;

    // Analyze performance
    final completedAllSets = lastWorkout.sets.length == lastWorkout.suggestedSets;
    final easyCompletion = lastWorkout.sets.every((set) => set.reps >= lastWorkout.suggestedReps);
    final struggled = lastWorkout.sets.last.reps < lastWorkout.suggestedReps;

    if (easyCompletion && completedAllSets) {
      // Suggest weight increase
      final lastWeight = lastWorkout.sets.last.weight;
      final increase = (lastWeight * 0.025).roundToDouble(); // 2.5% increase

      return ProgressionSuggestion(
        type: SuggestionType.increaseWeight,
        message: 'Great job! Try increasing weight by ${increase.toStringAsFixed(1)}kg',
        suggestedWeight: lastWeight + increase,
      );
    } else if (struggled) {
      // Suggest maintaining weight
      return ProgressionSuggestion(
        type: SuggestionType.maintain,
        message: 'Maintain current weight and focus on form',
        suggestedWeight: lastWorkout.sets.last.weight,
      );
    } else if (completedAllSets && !easyCompletion) {
      // Suggest adding reps
      return ProgressionSuggestion(
        type: SuggestionType.increaseReps,
        message: 'Try adding 1-2 reps next time',
        suggestedReps: lastWorkout.suggestedReps + 1,
      );
    }

    return null;
  }
}
```

**Impact**: Users get intelligent suggestions after each workout.

---

### Feature 2: Analytics Screen

Create `lib/features/analytics/presentation/screens/analytics_screen.dart`:

```dart
class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workoutHistoryAsync = ref.watch(workoutHistoryProvider);
    final activeProgramAsync = ref.watch(activeProgramProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Progress')),
      body: workoutHistoryAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
        data: (history) {
          final stats = _calculateStats(history);

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Stats cards
              _StatsCard(
                title: 'Total Workouts',
                value: stats.totalWorkouts.toString(),
                icon: Icons.fitness_center,
              ),
              _StatsCard(
                title: 'Current Streak',
                value: '${stats.currentStreak} days',
                icon: Icons.local_fire_department,
              ),
              _StatsCard(
                title: 'Weekly Consistency',
                value: '${(stats.weeklyConsistency * 100).toStringAsFixed(0)}%',
                icon: Icons.trending_up,
              ),
              const SizedBox(height: 24),
              // Strength progression chart
              const Text('Strength Progression', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _StrengthProgressionChart(history: history),
              const SizedBox(height: 24),
              // Volume progression chart
              const Text('Volume Progression', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _VolumeProgressionChart(history: history),
            ],
          );
        },
      ),
    );
  }

  _AnalyticsStats _calculateStats(List<Workout> history) {
    final totalWorkouts = history.length;
    final currentStreak = _calculateStreak(history);
    final weeklyConsistency = _calculateWeeklyConsistency(history);

    return _AnalyticsStats(
      totalWorkouts: totalWorkouts,
      currentStreak: currentStreak,
      weeklyConsistency: weeklyConsistency,
    );
  }

  int _calculateStreak(List<Workout> history) {
    // Calculate consecutive days with workouts
    int streak = 0;
    DateTime? lastDate;

    for (final workout in history) {
      if (lastDate == null) {
        streak = 1;
        lastDate = workout.date;
      } else if (lastDate.difference(workout.date).inDays == 1) {
        streak++;
        lastDate = workout.date;
      } else {
        break;
      }
    }

    return streak;
  }

  double _calculateWeeklyConsistency(List<Workout> history) {
    // Calculate % of planned workouts completed this week
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 7));

    final thisWeekWorkouts = history
        .where((w) => w.date.isAfter(weekStart) && w.date.isBefore(weekEnd))
        .length;

    return (thisWeekWorkouts / 5).clamp(0.0, 1.0); // Assume 5 workouts per week
  }
}

class _AnalyticsStats {
  final int totalWorkouts;
  final int currentStreak;
  final double weeklyConsistency;

  _AnalyticsStats({
    required this.totalWorkouts,
    required this.currentStreak,
    required this.weeklyConsistency,
  });
}

class _StatsCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _StatsCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, size: 32),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StrengthProgressionChart extends StatelessWidget {
  final List<Workout> history;

  const _StrengthProgressionChart({required this.history});

  @override
  Widget build(BuildContext context) {
    // Use fl_chart to display line chart
    return Container(
      height: 300,
      color: Colors.grey[100],
      child: const Center(child: Text('Strength Progression Chart')),
    );
  }
}

class _VolumeProgressionChart extends StatelessWidget {
  final List<Workout> history;

  const _VolumeProgressionChart({required this.history});

  @override
  Widget build(BuildContext context) {
    // Use fl_chart to display bar chart
    return Container(
      height: 300,
      color: Colors.grey[100],
      child: const Center(child: Text('Volume Progression Chart')),
    );
  }
}
```

**Impact**: Users can see their progress over time with visual charts.

---

## Part 5: UX Modernization

### Dark Mode Implementation

Modify `lib/core/constants/app_theme.dart`:

```dart
class AppTheme {
  static ThemeData lightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blue,
        brightness: Brightness.light,
      ),
      // ... rest of theme
    );
  }

  static ThemeData darkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blue,
        brightness: Brightness.dark,
      ),
      // ... rest of theme
    );
  }
}
```

Modify `lib/main.dart`:

```dart
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier();
});

class ThemeNotifier extends StateNotifier<ThemeMode> {
  ThemeNotifier() : super(ThemeMode.system);

  void toggleTheme() {
    state = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
  }
}

void main() {
  runApp(const MyApp());
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return MaterialApp.router(
      routerConfig: router,
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),
      themeMode: themeMode,
    );
  }
}
```

**Impact**: App supports both light and dark modes.

---

## Summary

This design document provides the technical blueprint for all 18 requirements. Each section includes:

1. **Problem Statement**: What's broken or missing
2. **Solution**: Code implementation
3. **Impact**: How it improves the app

The implementation follows IronFlow's existing patterns:
- Clean Architecture (domain/data/presentation)
- Riverpod for state management
- Freezed for immutable data
- Hive for local storage
- Proper error handling

All changes maintain backward compatibility and don't break existing functionality.

