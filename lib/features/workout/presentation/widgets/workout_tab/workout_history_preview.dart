import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/router/app_router.dart';
import '../../../../../core/theme/app_theme_tokens.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../shared/presentation/components/components.dart';

class WorkoutHistoryPreview extends StatelessWidget {
  const WorkoutHistoryPreview({super.key, required this.workouts});
  final List<dynamic> workouts;

  @override
  Widget build(BuildContext context) {
    final tokens = AppThemeTokens.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'RECENT SESSIONS',
                style: TextStyle(
                  color: tokens.textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
                  fontFamily: AppTypography.fontFamilyHeadings,
                ),
              ),
              GestureDetector(
                onTap: () => context.go(AppRoutes.workoutHistory),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  child: Text(
                    'VIEW ALL',
                    style: TextStyle(
                      color: tokens.kineticAccent,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      fontFamily: AppTypography.fontFamilyHeadings,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        ...workouts.asMap().entries.map((entry) {
          final workout = entry.value;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: _HistoryItem(workout: workout, tokens: tokens),
          ).animate().fadeIn(delay: (200 + entry.key * 60).ms);
        }),
      ],
    );
  }
}

class _HistoryItem extends StatelessWidget {
  const _HistoryItem({required this.workout, required this.tokens});
  final dynamic workout;
  final AppThemeTokens tokens;

  @override
  Widget build(BuildContext context) {
    final dateStr =
        '${workout.date.day.toString().padLeft(2, '0')}/${workout.date.month.toString().padLeft(2, '0')}/${workout.date.year}';
    final h = workout.duration.inHours as int;
    final m = (workout.duration.inMinutes as int).remainder(60);
    final duration = h > 0 ? '${h}h ${m}m' : '${m}m';

    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: tokens.kineticAccent.withValues(alpha: 0.12),
              border: Border.all(
                color: tokens.kineticAccent.withValues(alpha: 0.25),
                width: 1,
              ),
            ),
            child: Icon(
              Icons.fitness_center_rounded,
              color: tokens.kineticAccent,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${workout.exercises.length} EXERCISES',
                  style: TextStyle(
                    color: tokens.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    fontFamily: AppTypography.fontFamilyHeadings,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  dateStr,
                  style: TextStyle(
                    color: tokens.textMuted,
                    fontSize: 11,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${workout.totalVolume.toStringAsFixed(0)} KG',
                style: TextStyle(
                  color: tokens.kineticAccent,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  fontFamily: AppTypography.fontFamilyHeadings,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                duration,
                style: TextStyle(
                  color: tokens.textMuted,
                  fontSize: 11,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

