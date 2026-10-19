import 'package:flutter/material.dart';
import '../../../../../core/theme/app_theme_tokens.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../onboarding/domain/entities/user_profile.dart';
import '../../../data/exercise_database.dart';
import '../../../domain/entities/exercise_definition.dart';
import '../../../domain/entities/workout_program.dart';

/// Bottom sheet modal enabling users to swap an exercise in the generated split preview.
class ExerciseSwapSheet extends StatelessWidget {
  final ProgramExercise currentExercise;
  final EquipmentType equipment;
  final ValueChanged<String> onSelected;

  const ExerciseSwapSheet({
    super.key,
    required this.currentExercise,
    required this.equipment,
    required this.onSelected,
  });

  static Future<void> show({
    required BuildContext context,
    required ProgramExercise currentExercise,
    required EquipmentType equipment,
    required ValueChanged<String> onSelected,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ExerciseSwapSheet(
        currentExercise: currentExercise,
        equipment: equipment,
        onSelected: onSelected,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tokens = AppThemeTokens.of(context);
    final isHome = equipment == EquipmentType.home;

    // Find current definition to determine muscle group and movement pattern
    final currentDef = ExerciseDatabase.all.firstWhere(
      (e) => e.name.toLowerCase() == currentExercise.exerciseName.toLowerCase(),
      orElse: () => ExerciseDatabase.all.first,
    );

    // Candidates with compatible equipment and muscle group, sorted by relevance
    final candidates = ExerciseDatabase.all.where((e) {
      if (e.name.toLowerCase() == currentExercise.exerciseName.toLowerCase()) {
        return false;
      }
      if (isHome) {
        final isHomeFriendly = e.equipment == Equipment.bodyweight ||
            e.equipment == Equipment.dumbbell ||
            e.equipment == Equipment.band;
        if (!isHomeFriendly) return false;
      }
      // Match primary muscle group or secondary
      return e.muscleGroup == currentDef.muscleGroup ||
          e.primaryMuscles.contains(currentDef.muscleGroup);
    }).toList();

    // Sort candidates: same equipment first, then alphabetical
    candidates.sort((a, b) {
      final aSameEquip = a.equipment == currentDef.equipment ? 1 : 0;
      final bSameEquip = b.equipment == currentDef.equipment ? 1 : 0;
      if (aSameEquip != bSameEquip) return bSameEquip.compareTo(aSameEquip);
      return a.name.compareTo(b.name);
    });

    // Limit to up to 3 alternatives
    final topAlternatives = candidates.take(3).toList();

    return Container(
      height: MediaQuery.of(context).size.height * 0.65,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: BoxDecoration(
        color: tokens.card,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(tokens.radiusLg),
        ),
        border: Border.all(color: tokens.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: tokens.borderSubtle,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'SWAP EXERCISE',
            style: TextStyle(
              color: tokens.cyanAccent,
              fontSize: 12,
              fontWeight: FontWeight.w800,
              fontFamily: AppTypography.fontFamilyHeadings,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Choose an alternative for "${currentExercise.exerciseName}" (${currentDef.muscleGroup.name.toUpperCase()}):',
            style: TextStyle(
              color: tokens.textSecondary,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 14),
          Expanded(
            child: topAlternatives.isEmpty
                ? Center(
                    child: Text(
                      'No other compatible exercises found for this equipment profile.',
                      style: TextStyle(color: tokens.textMuted),
                    ),
                  )
                : ListView.separated(
                    itemCount: topAlternatives.length,
                    separatorBuilder: (_, _) => Divider(
                      color: tokens.borderSubtle.withValues(alpha: 0.5),
                      height: 1,
                    ),
                    itemBuilder: (context, index) {
                      final candidate = topAlternatives[index];
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 4,
                        ),
                        title: Text(
                          candidate.name,
                          style: TextStyle(
                            color: tokens.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          '${candidate.equipment.name.toUpperCase()} • ${candidate.subMuscle.isNotEmpty ? candidate.subMuscle : candidate.muscleGroup.name}',
                          style: TextStyle(
                            color: tokens.textMuted,
                            fontSize: 11,
                          ),
                        ),
                        trailing: Icon(
                          Icons.swap_horiz_rounded,
                          color: tokens.cyanAccent,
                          size: 20,
                        ),
                        onTap: () {
                          Navigator.of(context).pop();
                          onSelected(candidate.name);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
