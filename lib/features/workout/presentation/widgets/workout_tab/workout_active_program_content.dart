import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/router/app_router.dart';
import '../../../../../core/theme/app_theme_tokens.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../shared/presentation/components/components.dart';
import '../../../../ai/domain/entities/insight.dart';
import '../../../../ai/presentation/widgets/contextual_insight_banner.dart';
import '../../../../retention/presentation/widgets/streak_display.dart';
import '../../../domain/entities/workout_program.dart';
import '../../providers/active_program_providers.dart';
import '../program_exercise_card.dart';
import 'workout_history_preview.dart';

class WorkoutActiveProgramContent extends ConsumerWidget {
  final dynamic activeProgram;
  final AsyncValue<List<dynamic>> historyAsync;

  const WorkoutActiveProgramContent({
    super.key,
    required this.activeProgram,
    required this.historyAsync,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // Streak Display
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: StreakDisplay(),
          ),
        ),

        // Contextual AI Insight Banner (Hybrid AI placement)
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: ContextualInsightBanner(context: InsightContext.workout),
          ),
        ),

        // Active Program Header
        SliverToBoxAdapter(
          child: _ActiveProgramHeader(activeProgram: activeProgram),
        ),

        // Week View with Day Chips
        SliverToBoxAdapter(
          child: _WeekView(activeProgram: activeProgram),
        ),

        // Current Day Content
        SliverToBoxAdapter(
          child: _CurrentDayContent(activeProgram: activeProgram),
        ),

        // History Preview
        SliverToBoxAdapter(
          child: historyAsync.when(
            data: (workouts) => workouts.isNotEmpty
                ? WorkoutHistoryPreview(workouts: workouts.take(3).toList())
                : const SizedBox.shrink(),
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const SizedBox.shrink(),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }
}

class _ActiveProgramHeader extends StatelessWidget {
  final dynamic activeProgram;

  const _ActiveProgramHeader({required this.activeProgram});

  @override
  Widget build(BuildContext context) {
    final tokens = AppThemeTokens.of(context);
    final program = activeProgram.program;
    final completionPercentage =
        (activeProgram.weekCompletionPercentage as num).toDouble();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: AppCard(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header tag & Program name
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: tokens.kineticAccent,
                        boxShadow: [
                          BoxShadow(
                            color: tokens.kineticAccent.withValues(alpha: 0.6),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'ACTIVE PROTOCOL',
                      style: TextStyle(
                        color: tokens.textMuted,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                        fontFamily: AppTypography.fontFamilyHeadings,
                      ),
                    ),
                  ],
                ),
                Text(
                  '${(completionPercentage * 100).toStringAsFixed(0)}%',
                  style: TextStyle(
                    color: tokens.kineticAccent,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    fontFamily: AppTypography.fontFamilyHeadings,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              program.name,
              style: TextStyle(
                color: tokens.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w800,
                fontFamily: AppTypography.fontFamilyHeadings,
                letterSpacing: -0.3,
              ),
            ),
            if (program.description.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                program.description,
                style: TextStyle(
                  color: tokens.textMuted,
                  fontSize: 13,
                  height: 1.3,
                ),
              ),
            ],
            const SizedBox(height: 16),
            // Stripe Progress Bar
            AppProgressBar(
              progress: completionPercentage,
              progressColor: tokens.kineticAccent,
              backgroundColor: tokens.panel,
              height: 6,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (program.cycleLength != null)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: tokens.panel,
                      borderRadius: BorderRadius.circular(tokens.radiusSm),
                      border: Border.all(color: tokens.borderSubtle),
                    ),
                    child: Text(
                      'CYCLE: ${program.cycleLength} DAYS',
                      style: TextStyle(
                        color: tokens.textMuted,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        fontFamily: AppTypography.fontFamilyHeadings,
                        letterSpacing: 0.8,
                      ),
                    ),
                  )
                else
                  const SizedBox.shrink(),
                InkWell(
                  key: const Key('switch_split_header_btn'),
                  onTap: () => context.go(AppRoutes.workoutProgramSelection),
                  borderRadius: BorderRadius.circular(tokens.radiusSm),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'CHANGE SPLIT',
                          style: TextStyle(
                            color: tokens.cyanAccent,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            fontFamily: AppTypography.fontFamilyHeadings,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: tokens.cyanAccent,
                          size: 10,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _WeekView extends ConsumerWidget {
  final dynamic activeProgram;

  const _WeekView({required this.activeProgram});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = AppThemeTokens.of(context);
    final program = activeProgram.program;
    final currentDayIndex = activeProgram.currentDayIndex;
    final completedDays = activeProgram.completedDays;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 10),
            child: Text(
              'CYCLE SCHEDULE',
              style: TextStyle(
                color: tokens.textMuted,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.1,
                fontFamily: AppTypography.fontFamilyHeadings,
              ),
            ),
          ),
          SizedBox(
            height: 76,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: program.days.length,
              itemBuilder: (context, index) {
                final day = program.days[index];
                final isCurrentDay = index == currentDayIndex;
                final isCompleted = completedDays.containsKey(index);

                return _DayChip(
                  day: day,
                  index: index,
                  isCurrentDay: isCurrentDay,
                  isCompleted: isCompleted,
                  tokens: tokens,
                  onTap: () {
                    ref
                        .read(activeProgramProvider.notifier)
                        .setCurrentDayIndex(index);
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

class _DayChip extends StatelessWidget {
  final ProgramDay day;
  final int index;
  final bool isCurrentDay;
  final bool isCompleted;
  final AppThemeTokens tokens;
  final VoidCallback onTap;

  const _DayChip({
    required this.day,
    required this.index,
    required this.isCurrentDay,
    required this.isCompleted,
    required this.tokens,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final activeBorderColor = tokens.kineticAccent;
    final defaultBorderColor = tokens.borderSubtle;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 76,
        margin: const EdgeInsets.only(right: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(tokens.radiusMd),
          color: isCurrentDay ? tokens.panel : tokens.card,
          border: Border.all(
            color: isCurrentDay ? activeBorderColor : defaultBorderColor,
            width: isCurrentDay ? 1.5 : 1,
          ),
          boxShadow: isCurrentDay
              ? [
                  BoxShadow(
                    color: tokens.kineticAccent.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isCompleted)
              Icon(
                Icons.check_circle_rounded,
                color: tokens.kineticAccent,
                size: 20,
              )
            else if (day.isRestDay)
              Icon(Icons.bedtime_outlined, color: tokens.textMuted, size: 18)
            else
              Text(
                'DAY ${day.dayNumber}',
                style: TextStyle(
                  color: isCurrentDay ? tokens.kineticAccent : tokens.textMuted,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                  fontFamily: AppTypography.fontFamilyHeadings,
                ),
              ),
            const SizedBox(height: 4),
            Text(
              day.isRestDay ? 'REST' : day.focus.split(' ').first.toUpperCase(),
              style: TextStyle(
                color:
                    isCurrentDay ? tokens.textPrimary : tokens.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                fontFamily: AppTypography.fontFamilyHeadings,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _CurrentDayContent extends StatelessWidget {
  final dynamic activeProgram;

  const _CurrentDayContent({required this.activeProgram});

  @override
  Widget build(BuildContext context) {
    final tokens = AppThemeTokens.of(context);
    final currentDay = activeProgram.currentDay;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Day Header
          AppCard(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentDay.name.toUpperCase(),
                        style: TextStyle(
                          color: tokens.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          fontFamily: AppTypography.fontFamilyHeadings,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        currentDay.focus,
                        style: TextStyle(
                          color: tokens.kineticAccent,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: tokens.panel,
                    borderRadius: BorderRadius.circular(tokens.radiusSm),
                    border: Border.all(color: tokens.borderSubtle, width: 1),
                  ),
                  child: Text(
                    currentDay.isRestDay
                        ? 'RECOVERY'
                        : '${currentDay.exercises.length} EXERCISES',
                    style: TextStyle(
                      color: tokens.textMuted,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      fontFamily: AppTypography.fontFamilyHeadings,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Rest Day or Exercises List
          if (currentDay.isRestDay)
            _RestDayMessage(tokens: tokens)
          else ...[
            ...currentDay.exercises.asMap().entries.map((entry) {
              return ProgramExerciseCard(
                exercise: entry.value,
                index: entry.key,
              );
            }),
            const SizedBox(height: 8),
            // Start Workout Button
            AppButton(
              label: '▶ START SESSION',
              variant: AppButtonVariant.primary,
              isFullWidth: true,
              height: 52,
              onPressed: () => context.push(
                AppRoutes.workoutActive,
                extra: activeProgram,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _RestDayMessage extends StatelessWidget {
  final AppThemeTokens tokens;

  const _RestDayMessage({required this.tokens});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: tokens.panel,
              border: Border.all(color: tokens.borderSubtle, width: 1),
            ),
            child: Icon(
              Icons.bedtime_outlined,
              size: 28,
              color: tokens.kineticAccent,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'RECOVERY PHASE',
            style: TextStyle(
              color: tokens.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              fontFamily: AppTypography.fontFamilyHeadings,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Muscles rebuild and adapt during rest. Prioritize hydration, protein intake, and sleep.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: tokens.textMuted,
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

