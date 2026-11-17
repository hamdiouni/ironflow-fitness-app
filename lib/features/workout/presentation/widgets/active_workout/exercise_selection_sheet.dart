import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:progression_tracker/core/constants/app_theme.dart';
import 'package:progression_tracker/features/workout/data/exercise_video_map.dart';
import 'package:progression_tracker/features/workout/domain/entities/exercise_definition.dart';
import 'package:progression_tracker/features/workout/domain/services/exercise_catalog.dart';

class ExerciseSelectionSheet extends StatefulWidget {
  const ExerciseSelectionSheet({
    super.key,
    required this.scrollController,
    required this.onExerciseSelected,
  });
  final ScrollController scrollController;
  final void Function(String name) onExerciseSelected;

  @override
  State<ExerciseSelectionSheet> createState() => _ExerciseSelectionSheetState();
}

class _ExerciseSelectionSheetState extends State<ExerciseSelectionSheet> {
  String _query = '';

  List<ExerciseDefinition> get _filtered {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return ExerciseCatalog.all;
    return ExerciseCatalog.all.where((e) {
      return e.name.toLowerCase().contains(q) ||
          e.muscleGroup.displayName.toLowerCase().contains(q) ||
          e.equipment.displayName.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final items = _filtered;
    return Container(
      decoration: BoxDecoration(
        color: tokens.canvas,
        borderRadius: BorderRadius.vertical(top: Radius.circular(tokens.radiusXl)),
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
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              autofocus: true,
              onChanged: (v) => setState(() => _query = v),
              style: TextStyle(color: tokens.textPrimary),
              decoration: InputDecoration(
                hintText: 'Search ${ExerciseCatalog.all.length} exercises...',
                hintStyle: TextStyle(color: tokens.textMuted),
                prefixIcon: Icon(Icons.search, color: tokens.textMuted),
                filled: true,
                fillColor: tokens.panel,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(tokens.radiusSm),
                  borderSide: BorderSide(color: tokens.borderSubtle, width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(tokens.radiusSm),
                  borderSide: BorderSide(color: tokens.kineticAccent, width: 1.5),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '${items.length} OF ${ExerciseCatalog.all.length} EXERCISES',
                style: TextStyle(
                  fontFamily: AppTypography.displayFontFamily,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: tokens.textMuted,
                  letterSpacing: 0.6,
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: widget.scrollController,
              itemCount: items.length,
              itemBuilder: (context, index) {
                final ex = items[index];
                final thumbUrl = ExerciseVideoMap.thumbnailUrl(ex.name);
                return ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(tokens.radiusSm),
                    child: CachedNetworkImage(
                      imageUrl: thumbUrl,
                      width: 48,
                      height: 36,
                      fit: BoxFit.cover,
                      errorWidget: (_, _, _) => Container(
                        width: 48,
                        height: 36,
                        color: tokens.panel,
                        child: Icon(
                          Icons.fitness_center,
                          color: tokens.kineticAccent,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                  title: Text(
                    ex.name,
                    style: TextStyle(
                      color: tokens.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontFamily: AppTypography.bodyFontFamily,
                    ),
                  ),
                  subtitle: Text(
                    '${ex.muscleGroup.displayName} • ${ex.equipment.displayName}',
                    style: TextStyle(
                      color: tokens.textSecondary,
                      fontSize: 12,
                      fontFamily: AppTypography.bodyFontFamily,
                    ),
                  ),
                  onTap: () => widget.onExerciseSelected(ex.name),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
