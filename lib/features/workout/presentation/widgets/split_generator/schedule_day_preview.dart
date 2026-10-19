import 'package:flutter/material.dart';
import '../../../../../core/theme/app_theme_tokens.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../onboarding/domain/entities/user_profile.dart';
import '../../../domain/entities/workout_program.dart';
import 'exercise_swap_sheet.dart';

/// Interactive preview of the 7-day program schedule with exercise swap capability.
class ScheduleDayPreview extends StatefulWidget {
  final WorkoutProgram program;
  final EquipmentType equipment;
  final void Function(int dayIndex, int exerciseIndex, String newExerciseName) onExerciseSwapped;

  const ScheduleDayPreview({
    super.key,
    required this.program,
    required this.equipment,
    required this.onExerciseSwapped,
  });

  @override
  State<ScheduleDayPreview> createState() => _ScheduleDayPreviewState();
}

class _ScheduleDayPreviewState extends State<ScheduleDayPreview> {
  int _selectedDayIndex = 0;

  @override
  void didUpdateWidget(covariant ScheduleDayPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_selectedDayIndex >= widget.program.days.length) {
      _selectedDayIndex = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = AppThemeTokens.of(context);
    final days = widget.program.days;

    if (days.isEmpty) {
      return const SizedBox.shrink();
    }

    final currentDay = days[_selectedDayIndex];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: tokens.card,
        borderRadius: BorderRadius.circular(tokens.radiusLg),
        border: Border.all(color: tokens.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.calendar_today_rounded,
                    color: tokens.cyanAccent,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '7-DAY SCHEDULE MATRIX',
                    style: TextStyle(
                      color: tokens.textMuted,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.1,
                      fontFamily: AppTypography.fontFamilyHeadings,
                    ),
                  ),
                ],
              ),
              Text(
                'TAP DAY TO INSPECT',
                style: TextStyle(
                  color: tokens.textMuted,
                  fontSize: 9.5,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // 7 Days Horizontal Tab Bar
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(days.length, (index) {
                final day = days[index];
                final isSelected = index == _selectedDayIndex;
                final isRest = day.isRestDay;

                final accent = isRest
                    ? tokens.violetAccent
                    : tokens.cyanAccent;

                return Padding(
                  padding: EdgeInsets.only(right: index < days.length - 1 ? 8.0 : 0.0),
                  child: InkWell(
                    key: Key('schedule_preview_tab_$index'),
                    onTap: () => setState(() => _selectedDayIndex = index),
                    borderRadius: BorderRadius.circular(tokens.radiusMd),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? accent.withValues(alpha: 0.2)
                            : tokens.panel,
                        borderRadius: BorderRadius.circular(tokens.radiusMd),
                        border: Border.all(
                          color: isSelected ? accent : tokens.borderSubtle,
                          width: isSelected ? 1.5 : 1.0,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: accent.withValues(alpha: 0.3),
                                  blurRadius: 6,
                                ),
                              ]
                            : null,
                      ),
                      child: Column(
                        children: [
                          Text(
                            'DAY ${day.dayNumber}',
                            style: TextStyle(
                              color: isSelected ? accent : tokens.textMuted,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              fontFamily: AppTypography.fontFamilyHeadings,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            isRest ? 'REST' : _getShortDayTitle(day.name),
                            style: TextStyle(
                              color: isSelected ? tokens.textPrimary : tokens.textSecondary,
                              fontSize: 11,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 16),

          // Selected Day Content
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: tokens.panel,
              borderRadius: BorderRadius.circular(tokens.radiusMd),
              border: Border.all(
                color: currentDay.isRestDay
                    ? tokens.violetAccent.withValues(alpha: 0.3)
                    : tokens.cyanAccent.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            currentDay.name.toUpperCase(),
                            style: TextStyle(
                              color: currentDay.isRestDay
                                  ? tokens.violetAccent
                                  : tokens.cyanAccent,
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              fontFamily: AppTypography.fontFamilyHeadings,
                              letterSpacing: 0.6,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            currentDay.focus,
                            style: TextStyle(
                              color: tokens.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!currentDay.isRestDay)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: tokens.card,
                          borderRadius: BorderRadius.circular(tokens.radiusSm),
                          border: Border.all(color: tokens.borderSubtle),
                        ),
                        child: Text(
                          '${currentDay.exercises.length} EXERCISES',
                          style: TextStyle(
                            color: tokens.cyanAccent,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            fontFamily: AppTypography.fontFamilyHeadings,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),

                if (currentDay.isRestDay) ...[
                  Row(
                    children: [
                      Icon(
                        Icons.nightlife_rounded,
                        color: tokens.violetAccent,
                        size: 22,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Muscular adaptation and central nervous system replenishment occur during active rest. Maintain hydration and protein intake.',
                          style: TextStyle(
                            color: tokens.textSecondary,
                            fontSize: 12,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: currentDay.exercises.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, exIndex) {
                      final ex = currentDay.exercises[exIndex];
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: tokens.card,
                          borderRadius: BorderRadius.circular(tokens.radiusSm),
                          border: Border.all(color: tokens.borderSubtle),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    ex.exerciseName,
                                    style: TextStyle(
                                      color: tokens.textPrimary,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${ex.sets} sets × ${ex.reps} reps • ${ex.restSeconds}s rest',
                                    style: TextStyle(
                                      color: tokens.textMuted,
                                      fontSize: 11,
                                    ),
                                  ),
                                  if (ex.notes != null)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 2),
                                      child: Text(
                                        ex.notes!,
                                        style: TextStyle(
                                          color: tokens.warning,
                                          fontSize: 10.5,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            IconButton(
                              key: Key('swap_exercise_btn_${_selectedDayIndex}_$exIndex'),
                              icon: Icon(
                                Icons.swap_horiz_rounded,
                                color: tokens.cyanAccent,
                                size: 18,
                              ),
                              tooltip: 'Swap Exercise',
                              onPressed: () {
                                ExerciseSwapSheet.show(
                                  context: context,
                                  currentExercise: ex,
                                  equipment: widget.equipment,
                                  onSelected: (newExName) {
                                    widget.onExerciseSwapped(
                                      _selectedDayIndex,
                                      exIndex,
                                      newExName,
                                    );
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getShortDayTitle(String name) {
    if (name.contains('Push')) return 'PUSH';
    if (name.contains('Pull')) return 'PULL';
    if (name.contains('Legs')) return 'LEGS';
    if (name.contains('Upper')) return 'UPPER';
    if (name.contains('Lower')) return 'LOWER';
    if (name.contains('Full Body')) return 'FULL';
    if (name.contains('Chest')) return 'CHEST';
    if (name.contains('Shoulder')) return 'ARMS';
    return name.split(' ').first.toUpperCase();
  }
}
