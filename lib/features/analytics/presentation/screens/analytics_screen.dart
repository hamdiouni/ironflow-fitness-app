import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/constants/app_theme.dart';
import '../../../workout/presentation/providers/workout_providers.dart';
import '../../../onboarding/presentation/providers/onboarding_provider.dart';
import '../../../onboarding/domain/entities/user_profile.dart';

class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> {
  DateTimeRange? _selectedRange;

  @override
  Widget build(BuildContext context) {
    final workoutHistoryAsync = ref.watch(workoutHistoryProvider);
    final profileAsync = ref.watch(userProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Progress Analytics'),
        elevation: 0,
      ),
      body: workoutHistoryAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error loading analytics: $error'),
        ),
        data: (history) {
          final profile = profileAsync.value;
          final stats = _calculateStats(history, profile);

          return ListView(
            padding: const EdgeInsets.all(AppTheme.spacingMedium),
            children: [
              // Stats cards
              _StatsCard(
                title: 'Total Workouts',
                value: stats.totalWorkouts.toString(),
                icon: Icons.fitness_center,
                color: AppTheme.primaryColor,
              ),
              const SizedBox(height: AppTheme.spacingMedium),
              _StatsCard(
                title: 'Current Streak',
                value: '${stats.currentStreak} days',
                icon: Icons.local_fire_department,
                color: Colors.orange,
              ),
              const SizedBox(height: AppTheme.spacingMedium),
              _StatsCard(
                title: 'Weekly Consistency',
                value: '${(stats.weeklyConsistency * 100).toStringAsFixed(0)}%',
                icon: Icons.trending_up,
                color: AppTheme.accentColor,
              ),
              const SizedBox(height: AppTheme.spacingLarge),
              
              // Strength progression chart
              const Text(
                'Workout Frequency',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppTheme.spacingMedium),
              _WorkoutFrequencyChart(history: history),
              const SizedBox(height: AppTheme.spacingLarge),

              // Volume progression chart
              const Text(
                'Total Volume Over Time',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppTheme.spacingMedium),
              _VolumeProgressionChart(history: history),
              const SizedBox(height: AppTheme.spacingLarge),

              // Muscle group breakdown
              const Text(
                'Muscle Group Distribution',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppTheme.spacingMedium),
              _MuscleGroupChart(history: history),
            ],
          );
        },
      ),
    );
  }

  _AnalyticsStats _calculateStats(List<dynamic> history, UserProfile? profile) {
    final totalWorkouts = history.length;
    final currentStreak = _calculateStreak(history);
    final weeklyConsistency = _calculateWeeklyConsistency(history, profile);

    return _AnalyticsStats(
      totalWorkouts: totalWorkouts,
      currentStreak: currentStreak,
      weeklyConsistency: weeklyConsistency,
    );
  }

  int _calculateStreak(List<dynamic> history) {
    if (history.isEmpty) return 0;

    int streak = 0;
    DateTime? lastDate;

    // Sort by date descending (most recent first)
    final sorted = List.from(history);
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
        } else {
          break;
        }
      }
    }

    return streak;
  }

  double _calculateWeeklyConsistency(List<dynamic> history, UserProfile? profile) {
    if (history.isEmpty) return 0;

    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 7));

    final thisWeekWorkouts = history
        .where((w) => w.date.isAfter(weekStart) && w.date.isBefore(weekEnd))
        .length;

    return (thisWeekWorkouts / (profile?.workoutDaysPerWeek ?? 1)).clamp(0.0, 1.0);
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

class _StatsCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatsCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return AppTheme.glassmorphicCard(
      padding: const EdgeInsets.all(AppTheme.spacingMedium),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingMedium),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
            ),
            child: Icon(icon, color: color, size: 32),
          ),
          const SizedBox(width: AppTheme.spacingMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
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
  final List<dynamic> history;

  const _WorkoutFrequencyChart({required this.history});

  @override
  Widget build(BuildContext context) {
    // Group workouts by week
    final weeklyData = _groupByWeek(history);
    
    return AppTheme.glassmorphicCard(
      padding: const EdgeInsets.all(AppTheme.spacingMedium),
      child: SizedBox(
        height: 300,
        child: weeklyData.isEmpty
            ? const Center(child: Text('No data available'))
            : LineChart(
                LineChartData(
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text('W${value.toInt()}');
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: weeklyData
                          .asMap()
                          .entries
                          .map((e) => FlSpot(e.key.toDouble(), e.value.toDouble()))
                          .toList(),
                      isCurved: true,
                      color: AppTheme.primaryColor,
                      barWidth: 3,
                      dotData: FlDotData(show: true),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  List<int> _groupByWeek(List<dynamic> history) {
    if (history.isEmpty) return [];

    final now = DateTime.now();
    final weeks = <int>[];

    for (int i = 0; i < 12; i++) {
      final weekStart = now.subtract(Duration(days: now.weekday - 1 + (i * 7)));
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
  final List<dynamic> history;

  const _VolumeProgressionChart({required this.history});

  @override
  Widget build(BuildContext context) {
    final volumeData = _calculateVolumeByWeek(history);

    return AppTheme.glassmorphicCard(
      padding: const EdgeInsets.all(AppTheme.spacingMedium),
      child: SizedBox(
        height: 300,
        child: volumeData.isEmpty
            ? const Center(child: Text('No data available'))
            : BarChart(
                BarChartData(
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text('W${value.toInt()}');
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: true),
                  barGroups: volumeData
                      .asMap()
                      .entries
                      .map((e) => BarChartGroupData(
                        x: e.key,
                        barRods: [
                          BarChartRodData(
                            toY: e.value.toDouble(),
                            color: AppTheme.accentColor,
                          ),
                        ],
                      ))
                      .toList(),
                ),
              ),
      ),
    );
  }

  List<int> _calculateVolumeByWeek(List<dynamic> history) {
    if (history.isEmpty) return [];

    final now = DateTime.now();
    final volumes = <int>[];

    for (int i = 0; i < 12; i++) {
      final weekStart = now.subtract(Duration(days: now.weekday - 1 + (i * 7)));
      final weekEnd = weekStart.add(const Duration(days: 7));

      final volume = history
          .where((w) => w.date.isAfter(weekStart) && w.date.isBefore(weekEnd))
          .fold<int>(0, (sum, w) => sum + (w.totalVolume as int? ?? 0));

      volumes.add(volume);
    }

    return volumes.reversed.toList();
  }
}

class _MuscleGroupChart extends StatelessWidget {
  final List<dynamic> history;

  const _MuscleGroupChart({required this.history});

  @override
  Widget build(BuildContext context) {
    final muscleGroupData = _calculateMuscleGroupDistribution(history);

    return AppTheme.glassmorphicCard(
      padding: const EdgeInsets.all(AppTheme.spacingMedium),
      child: SizedBox(
        height: 300,
        child: muscleGroupData.isEmpty
            ? const Center(child: Text('No data available'))
            : PieChart(
                PieChartData(
                  sections: muscleGroupData
                      .entries
                      .toList()
                      .asMap()
                      .entries
                      .map((e) => PieChartSectionData(
                        value: e.value.value.toDouble(),
                        title: '${e.value.value}',
                        color: _getColorForMuscleGroup(e.key.toString()),
                        radius: 100,
                      ))
                      .toList(),
                ),
              ),
      ),
    );
  }

  Map<String, int> _calculateMuscleGroupDistribution(List<dynamic> history) {
    final distribution = <String, int>{};

    for (final workout in history) {
      for (final exercise in workout.exercises) {
        final muscleGroup = exercise.muscleGroup?.toString() ?? 'Unknown';
        distribution[muscleGroup] = (distribution[muscleGroup] ?? 0) + 1;
      }
    }

    return distribution;
  }

  Color _getColorForMuscleGroup(String muscleGroup) {
    final colors = {
      'chest': Colors.red,
      'back': Colors.blue,
      'legs': Colors.green,
      'shoulders': Colors.orange,
      'arms': Colors.purple,
      'abs': Colors.yellow,
    };
    return colors[muscleGroup.toLowerCase()] ?? Colors.grey;
  }
}
