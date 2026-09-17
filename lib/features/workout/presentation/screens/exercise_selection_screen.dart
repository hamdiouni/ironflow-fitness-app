import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/constants/app_theme.dart';
import '../../domain/entities/exercise_type.dart';

/// A predefined exercise with its name and type.
class _ExerciseDefinition {
  const _ExerciseDefinition({required this.name, required this.type});

  final String name;
  final ExerciseType type;
}

/// Predefined list of common exercises.
const List<_ExerciseDefinition> _kExercises = [
  // Strength
  _ExerciseDefinition(name: 'Bench Press', type: ExerciseType.strength),
  _ExerciseDefinition(name: 'Squat', type: ExerciseType.strength),
  _ExerciseDefinition(name: 'Deadlift', type: ExerciseType.strength),
  _ExerciseDefinition(name: 'Overhead Press', type: ExerciseType.strength),
  _ExerciseDefinition(name: 'Barbell Row', type: ExerciseType.strength),
  _ExerciseDefinition(name: 'Pull-Up', type: ExerciseType.strength),
  _ExerciseDefinition(name: 'Dip', type: ExerciseType.strength),
  _ExerciseDefinition(name: 'Incline Bench Press', type: ExerciseType.strength),
  _ExerciseDefinition(name: 'Romanian Deadlift', type: ExerciseType.strength),
  _ExerciseDefinition(name: 'Leg Press', type: ExerciseType.strength),
  _ExerciseDefinition(name: 'Lunges', type: ExerciseType.strength),
  _ExerciseDefinition(name: 'Bicep Curl', type: ExerciseType.strength),
  _ExerciseDefinition(name: 'Tricep Pushdown', type: ExerciseType.strength),
  _ExerciseDefinition(name: 'Lateral Raise', type: ExerciseType.strength),
  _ExerciseDefinition(name: 'Face Pull', type: ExerciseType.strength),
  // Cardio
  _ExerciseDefinition(name: 'Running', type: ExerciseType.cardio),
  _ExerciseDefinition(name: 'Cycling', type: ExerciseType.cardio),
  _ExerciseDefinition(name: 'Rowing', type: ExerciseType.cardio),
  _ExerciseDefinition(name: 'Jump Rope', type: ExerciseType.cardio),
  _ExerciseDefinition(name: 'Elliptical', type: ExerciseType.cardio),
  _ExerciseDefinition(name: 'Stair Climber', type: ExerciseType.cardio),
  // Flexibility
  _ExerciseDefinition(name: 'Yoga', type: ExerciseType.flexibility),
  _ExerciseDefinition(name: 'Hip Flexor Stretch', type: ExerciseType.flexibility),
  _ExerciseDefinition(name: 'Hamstring Stretch', type: ExerciseType.flexibility),
  _ExerciseDefinition(name: 'Shoulder Stretch', type: ExerciseType.flexibility),
];

/// Screen that allows the user to search and select an exercise.
///
/// Accepts an [onExerciseSelected] callback that is invoked with the
/// exercise name when the user taps an exercise card.
///
/// Uses a 300ms debounce on the search field to prevent excessive rebuilds.
///
/// Requirements: 17.2, 16.5
class ExerciseSelectionScreen extends StatefulWidget {
  const ExerciseSelectionScreen({
    required this.onExerciseSelected,
    super.key,
  });

  /// Called when the user selects an exercise.
  final void Function(String exerciseName) onExerciseSelected;

  @override
  State<ExerciseSelectionScreen> createState() =>
      _ExerciseSelectionScreenState();
}

class _ExerciseSelectionScreenState extends State<ExerciseSelectionScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;
  String _query = '';

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() => _query = value.trim().toLowerCase());
      }
    });
  }

  List<_ExerciseDefinition> get _filtered {
    if (_query.isEmpty) return _kExercises;
    return _kExercises
        .where((e) => e.name.toLowerCase().contains(_query))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final exercises = _filtered;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Exercise'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppTheme.spacingMedium),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: const InputDecoration(
                hintText: 'Search exercises...',
                prefixIcon: Icon(Icons.search),
              ),
              autofocus: false,
            ),
          ),
          Expanded(
            child: exercises.isEmpty
                ? Center(
                    child: Text(
                      'No exercises found',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spacingMedium,
                    ),
                    itemCount: exercises.length,
                    itemBuilder: (context, index) {
                      final exercise = exercises[index];
                      return _ExerciseCard(
                        exercise: exercise,
                        onTap: () =>
                            widget.onExerciseSelected(exercise.name),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  const _ExerciseCard({
    required this.exercise,
    required this.onTap,
  });

  final _ExerciseDefinition exercise;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacingSmall),
      child: AppTheme.glassmorphicCard(
        child: InkWell(
          onTap: onTap,
          borderRadius:
              BorderRadius.circular(AppTheme.borderRadiusMedium),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingMedium,
              vertical: AppTheme.spacingMedium,
            ),
            child: Row(
              children: [
                Icon(
                  _iconForType(exercise.type),
                  color: _colorForType(exercise.type),
                  size: 24,
                ),
                const SizedBox(width: AppTheme.spacingMedium),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exercise.name,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: AppTheme.spacingXSmall),
                      Text(
                        _labelForType(exercise.type),
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(
                              color: _colorForType(exercise.type),
                            ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  color: AppTheme.primaryColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _iconForType(ExerciseType type) {
    switch (type) {
      case ExerciseType.strength:
        return Icons.fitness_center;
      case ExerciseType.cardio:
        return Icons.directions_run;
      case ExerciseType.flexibility:
        return Icons.self_improvement;
    }
  }

  Color _colorForType(ExerciseType type) {
    switch (type) {
      case ExerciseType.strength:
        return AppTheme.primaryColor;
      case ExerciseType.cardio:
        return AppTheme.accentColor;
      case ExerciseType.flexibility:
        return AppTheme.warningColor;
    }
  }

  String _labelForType(ExerciseType type) {
    switch (type) {
      case ExerciseType.strength:
        return 'Strength';
      case ExerciseType.cardio:
        return 'Cardio';
      case ExerciseType.flexibility:
        return 'Flexibility';
    }
  }
}
