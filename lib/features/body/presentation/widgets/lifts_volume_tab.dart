import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_theme.dart';
import '../../../onboarding/domain/entities/user_profile.dart';
import '../../../onboarding/presentation/providers/onboarding_provider.dart';
import '../../../workout/data/exercise_database.dart';
import '../../../workout/domain/entities/exercise_definition.dart';
import '../../../workout/domain/entities/workout.dart';
import '../../../workout/presentation/providers/workout_providers.dart';

/// Lifts & Volume tab merged from Analytics into ProgressScreen.
/// Displays workout telemetry, frequency curves, volume progression, and muscle group distribution.
class LiftsVolumeTab extends ConsumerWidget {
  const LiftsVolumeTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = AppThemeTokens.of(context);
    final workoutHistoryAsync = ref.watch(workoutHistoryProvider);
    final profileAsync = ref.watch(userProfileProvider);

    return workoutHistoryAsync.when(
      loading: () => Center(
        child: CircularProgressIndicator(
          color: tokens.kineticAccent,
          strokeWidth: 2.5,
        ),
      ),
      error: (error, stack) => Center(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingLarge),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.warning_amber_rounded, size: 48, color: tokens.error),
              const SizedBox(height: 16),
              Text(
                'Error loading lift analytics: $error',
                textAlign: TextAlign.center,
                style: TextStyle(color: tokens.textSecondary, fontSize: 13),
              ),
            ],
          ),
        ),
      ),
      data: (history) {
        final profile = profileAsync.value;
        final stats = _calculateStats(history, profile);

        return ListView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacingMedium,
            vertical: AppTheme.spacingMedium,
          ),
          children: [
            // Stats cards
            _StatsCard(
              title: 'Total Workouts',
              value: stats.totalWorkouts.toString(),
              icon: Icons.fitness_center_rounded,
              color: tokens.kineticAccent,
              tokens: tokens,
            ),
            const SizedBox(height: 10),
            _StatsCard(
              title: 'Current Streak',
              value: '${stats.currentStreak} days',
              icon: Icons.local_fire_department_rounded,
              color: tokens.warning,
              tokens: tokens,
            ),
            const SizedBox(height: 10),
            _StatsCard(
              title: 'Weekly Consistency',
              value: '${(stats.weeklyConsistency * 100).toStringAsFixed(0)}%',
              icon: Icons.trending_up_rounded,
              color: tokens.cyanAccent,
              tokens: tokens,
            ),
            const SizedBox(height: 24),

            // Frequency chart
            _SectionHeader(
              title: 'Workout Frequency',
              subtitle: 'SESSIONS / WEEK (LAST 12 WEEKS)',
              tokens: tokens,
            ),
            const SizedBox(height: 10),
            _WorkoutFrequencyChart(history: history, tokens: tokens),
            const SizedBox(height: 24),

            // Volume progression chart
            _SectionHeader(
              title: 'Total Volume Over Time',
              subtitle: 'VOLUME LOAD (KG) PER WEEK',
              tokens: tokens,
            ),
            const SizedBox(height: 10),
            _VolumeProgressionChart(history: history, tokens: tokens),
            const SizedBox(height: 24),

            // Muscle group breakdown
            _SectionHeader(
              title: 'Muscle Group Distribution',
              subtitle: 'EXERCISE TARGET DENSITY',
              tokens: tokens,
            ),
            const SizedBox(height: 10),
            _MuscleGroupChart(history: history, tokens: tokens),
            const SizedBox(height: 32),
          ],
        );
      },
    );
  }

  _AnalyticsStats _calculateStats(List<Workout> history, UserProfile? profile) {
    final totalWorkouts = history.length;
    final currentStreak = _calculateStreak(history);
    final weeklyConsistency = _calculateWeeklyConsistency(history, profile);

    return _AnalyticsStats(
      totalWorkouts: totalWorkouts,
      currentStreak: currentStreak,
      weeklyConsistency: weeklyConsistency,
    );
  }

  int _calculateStreak(List<Workout> history) {
    if (history.isEmpty) return 0;

    int streak = 0;
    DateTime? lastDate;

    // Sort by date descending (most recent first)
    final sorted = List<Workout>.from(history);
    sorted.sort((a, b) => b.date.compareTo(a.date));

    for (final workout in sorted) {
      if (lastDate == null) {
        streak = 1;
        lastDate = workout.date;
      } else {
        final daysDifference = lastDate.difference(workout.date).inDays;
        if (daysDifference == 1) {
          streak++;
          lastDate = workout.date;
        } else if (daysDifference > 1) {
          break;
        }
      }
    }

    return streak;
  }

  double _calculateWeeklyConsistency(List<Workout> history, UserProfile? profile) {
    if (history.isEmpty) return 0;

    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 7));

    final thisWeekWorkouts = history
        .where((w) => w.date.isAfter(weekStart) && w.date.isBefore(weekEnd))
        .length;

    final targetDays = profile?.workoutDaysPerWeek ?? 3;
    return (thisWeekWorkouts / (targetDays > 0 ? targetDays : 1)).clamp(0.0, 1.0);
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

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final AppThemeTokens tokens;

  const _SectionHeader({
    required this.title,
    required this.subtitle,
    required this.tokens,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontFamily: AppTypography.displayFontFamily,
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
            color: tokens.textPrimary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: TextStyle(
            fontFamily: AppTypography.displayFontFamily,
            fontSize: 9,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.0,
            color: tokens.textMuted,
          ),
        ),
      ],
    );
  }
}

class _StatsCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final AppThemeTokens tokens;

  const _StatsCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.tokens,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: tokens.panel,
        borderRadius: BorderRadius.circular(tokens.radiusMd),
        border: Border.all(color: tokens.borderSubtle, width: 1),
      ),
      padding: const EdgeInsets.all(AppTheme.spacingMedium),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(tokens.radiusSm),
              border: Border.all(
                color: color.withValues(alpha: 0.35),
                width: 1,
              ),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: AppTheme.spacingMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: AppTypography.displayFontFamily,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                    color: tokens.textMuted,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontFamily: AppTypography.displayFontFamily,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                    color: tokens.textPrimary,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WorkoutFrequencyChart extends StatelessWidget {
  final List<Workout> history;
  final AppThemeTokens tokens;

  const _WorkoutFrequencyChart({required this.history, required this.tokens});

  @override
  Widget build(BuildContext context) {
    final weeklyData = _groupByWeek(history);

    return Container(
      decoration: BoxDecoration(
        color: tokens.panel,
        borderRadius: BorderRadius.circular(tokens.radiusMd),
        border: Border.all(color: tokens.borderSubtle, width: 1),
      ),
      padding: const EdgeInsets.all(AppTheme.spacingMedium),
      child: SizedBox(
        height: 240,
        child: weeklyData.isEmpty
            ? Center(
                child: Text(
                  'No workout sessions recorded yet',
                  style: TextStyle(color: tokens.textMuted, fontSize: 13),
                ),
              )
            : LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (_) => FlLine(
                      color: tokens.borderSubtle,
                      strokeWidth: 1,
                    ),
                  ),
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 28,
                        getTitlesWidget: (value, meta) {
                          if (value % 2 != 0) return const SizedBox.shrink();
                          return Text(
                            value.toInt().toString(),
                            style: TextStyle(
                              color: tokens.textMuted,
                              fontSize: 10,
                              fontFeatures: const [FontFeature.tabularFigures()],
                            ),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 24,
                        getTitlesWidget: (value, meta) {
                          final idx = value.toInt();
                          if (idx % 2 != 0) return const SizedBox.shrink();
                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              'W${idx + 1}',
                              style: TextStyle(
                                fontFamily: AppTypography.displayFontFamily,
                                color: tokens.textMuted,
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: weeklyData
                          .asMap()
                          .entries
                          .map((e) =>
                              FlSpot(e.key.toDouble(), e.value.toDouble()))
                          .toList(),
                      isCurved: true,
                      curveSmoothness: 0.3,
                      color: tokens.kineticAccent,
                      barWidth: 2.5,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) =>
                            FlDotCirclePainter(
                          radius: 3.5,
                          color: tokens.kineticAccent,
                          strokeWidth: 2,
                          strokeColor: tokens.panel,
                        ),
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            tokens.kineticAccent.withValues(alpha: 0.25),
                            tokens.kineticAccent.withValues(alpha: 0.0),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  List<int> _groupByWeek(List<Workout> history) {
    if (history.isEmpty) return [];

    final now = DateTime.now();
    final weeks = <int>[];

    for (int i = 0; i < 12; i++) {
      final weekStart =
          now.subtract(Duration(days: now.weekday - 1 + (i * 7)));
      final weekEnd = weekStart.add(const Duration(days: 7));

      final count = history
          .where((w) => w.date.isAfter(weekStart) && w.date.isBefore(weekEnd))
          .length;

      weeks.add(count);
    }

    return weeks.reversed.toList();
  }
}

class _VolumeProgressionChart extends StatelessWidget {
  final List<Workout> history;
  final AppThemeTokens tokens;

  const _VolumeProgressionChart({
    required this.history,
    required this.tokens,
  });

  @override
  Widget build(BuildContext context) {
    final volumeData = _calculateVolumeByWeek(history);

    return Container(
      decoration: BoxDecoration(
        color: tokens.panel,
        borderRadius: BorderRadius.circular(tokens.radiusMd),
        border: Border.all(color: tokens.borderSubtle, width: 1),
      ),
      padding: const EdgeInsets.all(AppTheme.spacingMedium),
      child: SizedBox(
        height: 240,
        child: volumeData.isEmpty
            ? Center(
                child: Text(
                  'No volume data recorded yet',
                  style: TextStyle(color: tokens.textMuted, fontSize: 13),
                ),
              )
            : BarChart(
                BarChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (_) => FlLine(
                      color: tokens.borderSubtle,
                      strokeWidth: 1,
                    ),
                  ),
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 42,
                        getTitlesWidget: (value, meta) {
                          if (value == 0) return const SizedBox.shrink();
                          final kVal = (value / 1000).toStringAsFixed(0);
                          return Text(
                            '${kVal}k',
                            style: TextStyle(
                              color: tokens.textMuted,
                              fontSize: 10,
                              fontFeatures: const [FontFeature.tabularFigures()],
                            ),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 24,
                        getTitlesWidget: (value, meta) {
                          final idx = value.toInt();
                          if (idx % 2 != 0) return const SizedBox.shrink();
                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              'W${idx + 1}',
                              style: TextStyle(
                                fontFamily: AppTypography.displayFontFamily,
                                color: tokens.textMuted,
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: volumeData
                      .asMap()
                      .entries
                      .map((e) => BarChartGroupData(
                            x: e.key,
                            barRods: [
                              BarChartRodData(
                                toY: e.value,
                                color: tokens.cyanAccent,
                                width: 14,
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(4),
                                ),
                              ),
                            ],
                          ))
                      .toList(),
                ),
              ),
      ),
    );
  }

  List<double> _calculateVolumeByWeek(List<Workout> history) {
    if (history.isEmpty) return [];

    final now = DateTime.now();
    final volumes = <double>[];

    for (int i = 0; i < 12; i++) {
      final weekStart =
          now.subtract(Duration(days: now.weekday - 1 + (i * 7)));
      final weekEnd = weekStart.add(const Duration(days: 7));

      final volume = history
          .where((w) => w.date.isAfter(weekStart) && w.date.isBefore(weekEnd))
          .fold<double>(0.0, (sum, w) => sum + w.totalVolume);

      volumes.add(volume);
    }

    return volumes.reversed.toList();
  }
}

class _MuscleGroupChart extends StatelessWidget {
  final List<Workout> history;
  final AppThemeTokens tokens;

  const _MuscleGroupChart({required this.history, required this.tokens});

  static final Map<String, MuscleGroup> _nameToMuscleGroup = {
    for (final def in ExerciseDatabase.all) def.name.toLowerCase(): def.muscleGroup,
  };

  @override
  Widget build(BuildContext context) {
    final muscleGroupData = _calculateMuscleGroupDistribution(history);

    if (muscleGroupData.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          color: tokens.panel,
          borderRadius: BorderRadius.circular(tokens.radiusMd),
          border: Border.all(color: tokens.borderSubtle, width: 1),
        ),
        padding: const EdgeInsets.all(AppTheme.spacingLarge),
        child: Center(
          child: Text(
            'No muscle group data recorded yet',
            style: TextStyle(color: tokens.textMuted, fontSize: 13),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: tokens.panel,
        borderRadius: BorderRadius.circular(tokens.radiusMd),
        border: Border.all(color: tokens.borderSubtle, width: 1),
      ),
      padding: const EdgeInsets.all(AppTheme.spacingMedium),
      child: Column(
        children: [
          SizedBox(
            height: 220,
            child: PieChart(
              PieChartData(
                centerSpaceRadius: 46,
                sectionsSpace: 3,
                sections: muscleGroupData.entries
                    .toList()
                    .asMap()
                    .entries
                    .map((e) => PieChartSectionData(
                          value: e.value.value.toDouble(),
                          title: '${e.value.value}',
                          titleStyle: TextStyle(
                            fontFamily: AppTypography.displayFontFamily,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                          color: _getColorForMuscleGroup(e.value.key, tokens),
                          radius: 40,
                        ))
                    .toList(),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Legend chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: muscleGroupData.entries.map((entry) {
              final color = _getColorForMuscleGroup(entry.key, tokens);
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(tokens.radiusSm),
                  border: Border.all(color: color.withValues(alpha: 0.4)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${entry.key.toUpperCase()} (${entry.value})',
                      style: TextStyle(
                        fontFamily: AppTypography.displayFontFamily,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                        color: tokens.textPrimary,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Map<String, int> _calculateMuscleGroupDistribution(List<Workout> history) {
    final distribution = <String, int>{};

    for (final workout in history) {
      for (final exercise in workout.exercises) {
        final group = _nameToMuscleGroup[exercise.name.toLowerCase()];
        final groupName = group?.displayName ?? 'Other';
        distribution[groupName] = (distribution[groupName] ?? 0) + 1;
      }
    }

    return distribution;
  }

  Color _getColorForMuscleGroup(String muscleGroupName, AppThemeTokens tokens) {
    switch (muscleGroupName.toLowerCase()) {
      case 'chest':
        return tokens.kineticAccent;
      case 'back':
        return tokens.cyanAccent;
      case 'legs':
        return tokens.violetAccent;
      case 'shoulders':
        return tokens.warning;
      case 'arms':
        return tokens.protein;
      case 'abs':
      case 'core':
        return tokens.carbs;
      default:
        return tokens.textMuted;
    }
  }
}
