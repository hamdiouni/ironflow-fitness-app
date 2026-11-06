import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:progression_tracker/core/constants/app_theme.dart';
import 'package:progression_tracker/shared/presentation/components/components.dart';
import 'package:progression_tracker/features/onboarding/domain/entities/user_profile.dart';
import 'package:progression_tracker/features/workout/domain/entities/workout.dart';

// ── Weekly Activity Section ───────────────────────────────────────────────────

class WeeklyActivitySection extends StatelessWidget {
  const WeeklyActivitySection({super.key, required this.workouts, required this.target});
  final List<Workout> workouts;
  final int target;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final weekStart = now.subtract(const Duration(days: 6));
    final weekWorkouts = workouts.where((w) => w.date.isAfter(weekStart)).toList();
    final count = weekWorkouts.length;
    final tokens = context.tokens;
    final progress = target > 0 ? (count / target).clamp(0.0, 1.0) : 0.0;
    final isGoalMet = count >= target && target > 0;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacings.lg,
        vertical: AppSpacings.sm,
      ),
      child: AppCard(
        isGlowing: isGoalMet,
        padding: const EdgeInsets.all(AppSpacings.lg),
        child: Row(
          children: [
            AppProgressRing(
              progress: progress,
              size: 82,
              strokeWidth: 8,
              progressColor: tokens.kineticAccent,
              backgroundColor: tokens.elevated,
              centerWidget: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$count',
                    style: AppTypography.tabularMetric(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: tokens.kineticAccent,
                    ),
                  ),
                  Text(
                    '/ $target',
                    style: TextStyle(
                      fontFamily: AppTypography.displayFontFamily,
                      color: tokens.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacings.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CONSISTENCY',
                    style: TextStyle(
                      fontFamily: AppTypography.displayFontFamily,
                      color: tokens.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    count == 0
                        ? 'Start your first workout!'
                        : count < target
                            ? '${target - count} more to reach goal'
                            : 'Weekly goal achieved!',
                    style: TextStyle(
                      fontFamily: AppTypography.bodyFontFamily,
                      color: tokens.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacings.md),
                  _WeekDayDots(workouts: weekWorkouts),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.05);
  }
}

class _WeekDayDots extends StatelessWidget {
  const _WeekDayDots({required this.workouts});
  final List<Workout> workouts;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final days = List.generate(7, (i) => now.subtract(Duration(days: 6 - i)));
    final workoutDates = workouts
        .map((w) => DateTime(w.date.year, w.date.month, w.date.day))
        .toSet();
    final tokens = context.tokens;

    return Row(
      children: days.map((day) {
        final hasWorkout = workoutDates.contains(DateTime(day.year, day.month, day.day));
        final isToday = day.day == now.day && day.month == now.month && day.year == now.year;
        return Expanded(
          child: Column(
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: hasWorkout
                      ? tokens.kineticAccent
                      : isToday
                          ? tokens.elevated
                          : tokens.panel,
                  border: isToday
                      ? Border.all(color: tokens.kineticAccent, width: 1.5)
                      : Border.all(color: tokens.borderSubtle, width: 0.5),
                  boxShadow: hasWorkout
                      ? [
                          BoxShadow(
                            color: tokens.kineticAccent.withValues(alpha: 0.3),
                            blurRadius: 6,
                          ),
                        ]
                      : null,
                ),
                child: hasWorkout
                    ? const Icon(Icons.check, size: 14, color: Colors.black)
                    : isToday
                        ? Center(
                            child: Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: tokens.kineticAccent,
                              ),
                            ),
                          )
                        : null,
              ),
              const SizedBox(height: 4),
              Text(
                DateFormat('E').format(day).substring(0, 1),
                style: TextStyle(
                  fontFamily: AppTypography.displayFontFamily,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: isToday
                      ? tokens.kineticAccent
                      : hasWorkout
                          ? tokens.textPrimary
                          : tokens.textMuted,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

// ── Today Summary Row ─────────────────────────────────────────────────────────

class TodaySummaryRow extends StatelessWidget {
  const TodaySummaryRow({
    super.key,
    required this.workouts,
    required this.profile,
  });
  final List<Workout> workouts;
  final UserProfile? profile;

  @override
  Widget build(BuildContext context) {
    final lastWorkout = workouts.isNotEmpty ? workouts.first : null;
    final lastDate = lastWorkout != null
        ? DateFormat('MMM d').format(lastWorkout.date)
        : 'None';
    final calories = profile?.dailyCalorieTarget.toInt() ?? 2000;
    final weight = profile?.weightKg.toStringAsFixed(1) ?? '--';
    final tokens = context.tokens;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacings.lg,
        vertical: AppSpacings.xs,
      ),
      child: Row(
        children: [
          Expanded(
            child: _SummaryCard(
              icon: Icons.fitness_center,
              label: 'Last Workout',
              value: lastDate,
              color: tokens.cyanAccent,
            ).animate().fadeIn(delay: 150.ms).slideX(begin: -0.05),
          ),
          const SizedBox(width: AppSpacings.sm),
          Expanded(
            child: _SummaryCard(
              icon: Icons.local_fire_department,
              label: 'Calories',
              value: '$calories kcal',
              color: tokens.warning,
            ).animate().fadeIn(delay: 200.ms),
          ),
          const SizedBox(width: AppSpacings.sm),
          Expanded(
            child: _SummaryCard(
              icon: Icons.monitor_weight_outlined,
              label: 'Weight',
              value: '${weight}kg',
              color: tokens.kineticAccent,
            ).animate().fadeIn(delay: 250.ms).slideX(begin: 0.05),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return AppCard(
      padding: const EdgeInsets.all(AppSpacings.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: AppSpacings.xs),
          Text(
            value,
            style: AppTypography.tabularMetric(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontFamily: AppTypography.bodyFontFamily,
              color: tokens.textSecondary,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
