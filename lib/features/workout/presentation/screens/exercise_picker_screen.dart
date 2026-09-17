import 'package:flutter/material.dart';

import '../../data/exercise_database.dart';
import '../../domain/entities/exercise_definition.dart';

/// Screen for selecting an exercise to replace in the program editor.
///
/// Displays:
/// - Exercises grouped by muscle group
/// - Filter by muscle group
/// - Search functionality
/// - Exercise images
/// - Returns selected exercise via Navigator.pop()
///
/// **Validates: Requirements 3.2**
class ExercisePickerScreen extends StatefulWidget {
  /// Optional initial muscle group filter
  final MuscleGroup? initialMuscleGroup;

  const ExercisePickerScreen({
    super.key,
    this.initialMuscleGroup,
  });

  @override
  State<ExercisePickerScreen> createState() => _ExercisePickerScreenState();
}

class _ExercisePickerScreenState extends State<ExercisePickerScreen> {
  late TextEditingController _searchController;
  MuscleGroup? _selectedMuscleGroup;
  late List<ExerciseDefinition> _filteredExercises;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _selectedMuscleGroup = widget.initialMuscleGroup;
    _updateFilteredExercises();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _updateFilteredExercises() {
    final searchTerm = _searchController.text.toLowerCase();

    _filteredExercises = ExerciseDatabase.all.where((exercise) {
      // Filter by muscle group if selected
      if (_selectedMuscleGroup != null && exercise.muscleGroup != _selectedMuscleGroup) {
        return false;
      }

      // Filter by search term
      if (searchTerm.isNotEmpty) {
        return exercise.name.toLowerCase().contains(searchTerm);
      }

      return true;
    }).toList();

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Exercise'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search field
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search exercises...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _updateFilteredExercises();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (_) => _updateFilteredExercises(),
            ),
          ),
          // Muscle group filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                FilterChip(
                  label: const Text('All'),
                  selected: _selectedMuscleGroup == null,
                  onSelected: (_) {
                    setState(() => _selectedMuscleGroup = null);
                    _updateFilteredExercises();
                  },
                ),
                const SizedBox(width: 8),
                ...MuscleGroup.values.map((group) {
                  final isSelected = _selectedMuscleGroup == group;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(group.displayName),
                      selected: isSelected,
                      onSelected: (_) {
                        setState(() => _selectedMuscleGroup = isSelected ? null : group);
                        _updateFilteredExercises();
                      },
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Exercise list
          Expanded(
            child: _filteredExercises.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.fitness_center,
                          size: 48,
                          color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No exercises found',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _filteredExercises.length,
                    itemBuilder: (context, index) {
                      final exercise = _filteredExercises[index];
                      return _ExercisePickerTile(
                        exercise: exercise,
                        onTap: () => Navigator.pop(context, exercise.name),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

/// Tile widget for displaying an exercise in the picker.
class _ExercisePickerTile extends StatelessWidget {
  final ExerciseDefinition exercise;
  final VoidCallback onTap;

  const _ExercisePickerTile({
    required this.exercise,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          exercise.imageUrl,
          width: 56,
          height: 56,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: exercise.muscleGroup.color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.fitness_center,
                color: exercise.muscleGroup.color,
              ),
            );
          },
        ),
      ),
      title: Text(exercise.name),
      subtitle: Text(exercise.muscleGroup.displayName),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      onTap: onTap,
    );
  }
}
