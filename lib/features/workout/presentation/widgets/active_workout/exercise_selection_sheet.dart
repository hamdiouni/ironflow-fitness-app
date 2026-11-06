import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:progression_tracker/core/constants/app_theme.dart';
import 'package:progression_tracker/features/workout/data/exercise_video_map.dart';

class ExerciseSelectionSheet extends StatefulWidget {
  const ExerciseSelectionSheet({super.key, required this.scrollController, required this.onExerciseSelected});
  final ScrollController scrollController;
  final void Function(String name) onExerciseSelected;
  @override
  State<ExerciseSelectionSheet> createState() => _ExerciseSelectionSheetState();
}

class _ExerciseSelectionSheetState extends State<ExerciseSelectionSheet> {
  static const _exercises = [
    'Bench Press', 'Squat', 'Deadlift', 'Overhead Press', 'Barbell Row',
    'Pull-Up', 'Dip', 'Incline Bench Press', 'Romanian Deadlift', 'Leg Press',
    'Lunges', 'Bicep Curl', 'Barbell Curl', 'Dumbbell Curl', 'Tricep Pushdown',
    'Lateral Raise', 'Face Pull', 'Running', 'Cycling', 'Rowing Machine',
    'Jump Rope', 'Plank', 'Crunch', 'Leg Raise', 'Hip Thrust',
    'Glute Bridge', 'Lat Pulldown', 'Seated Cable Row', 'Dumbbell Row',
    'Push-Up', 'Hammer Curl', 'Skull Crusher', 'Calf Raise', 'Hack Squat',
    'Bulgarian Split Squat', 'Leg Curl', 'Leg Extension', 'Cable Crossover',
    'Arnold Press', 'Front Raise', 'Reverse Fly', 'Dumbbell Shoulder Press',
    'Overhead Tricep Extension', 'Close Grip Bench Press', 'Russian Twist',
  ];

  String _query = '';
  List<String> get _filtered => _query.isEmpty ? _exercises : _exercises.where((e) => e.toLowerCase().contains(_query.toLowerCase())).toList();

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Container(
      decoration: BoxDecoration(
        color: tokens.canvas,
        borderRadius: BorderRadius.vertical(top: Radius.circular(tokens.radiusLg)),
        border: Border(top: BorderSide(color: tokens.borderSubtle, width: 1)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: tokens.borderSubtle,
              borderRadius: BorderRadius.circular(tokens.radiusPill),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              autofocus: true,
              onChanged: (v) => setState(() => _query = v),
              style: TextStyle(color: tokens.textPrimary),
              decoration: InputDecoration(
                hintText: 'Search exercises...',
                hintStyle: TextStyle(color: tokens.textMuted),
                prefixIcon: Icon(Icons.search, color: tokens.textMuted),
                filled: true,
                fillColor: tokens.panel,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(tokens.radiusPill),
                  borderSide: BorderSide(color: tokens.borderSubtle, width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(tokens.radiusSm),
                  borderSide: BorderSide(color: tokens.kineticAccent, width: 1.5),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: widget.scrollController,
              itemCount: _filtered.length,
              itemBuilder: (context, index) {
                final name = _filtered[index];
                final thumbUrl = ExerciseVideoMap.thumbnailUrl(name);
                return ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(tokens.radiusSm),
                    child: CachedNetworkImage(
                      imageUrl: thumbUrl,
                      width: 48,
                      height: 36,
                      fit: BoxFit.cover,
                      errorWidget: (_, _, _) => Container(
                        width: 48, height: 36,
                        color: tokens.panel,
                        child: Icon(Icons.fitness_center, color: tokens.kineticAccent, size: 18),
                      ),
                    ),
                  ),
                  title: Text(
                    name,
                    style: TextStyle(
                      color: tokens.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onTap: () => widget.onExerciseSelected(name),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
