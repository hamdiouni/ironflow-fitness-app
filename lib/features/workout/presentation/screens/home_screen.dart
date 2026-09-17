import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_theme.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../../core/router/app_router.dart';
import '../../../../shared/widgets/ironflow_logo.dart';
import '../../../onboarding/domain/entities/user_profile.dart';
import '../../../onboarding/presentation/providers/onboarding_provider.dart';
import '../../../ai/domain/entities/insight.dart';
import '../../../ai/presentation/widgets/insight_widget.dart';
import '../../domain/entities/workout.dart';
import '../providers/home_workout_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(homeWorkoutDataProvider);
    final profileAsync = ref.watch(userProfileProvider);

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            // Refresh both providers
            ref.invalidate(homeWorkoutDataProvider);
            ref.invalidate(userProfileProvider);
            // Wait for data to load
            await Future.wait([
              ref.read(homeWorkoutDataProvider.future),
              ref.read(userProfileProvider.future),
            ]);
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // Header - always visible
              SliverToBoxAdapter(
                child: _HomeHeader(profileAsync: profileAsync),
              ),
              
              // Weekly Activity Section
              SliverToBoxAdapter(
                child: historyAsync.when(
                  data: (workouts) => profileAsync.when(
                    data: (profile) {
                      // Handle null profile gracefully without hardcoded fallback
                      if (profile == null) {
                        return _ProfileSetupPrompt();
                      }
                      return _WeeklyActivitySection(
                        workouts: workouts,
                        target: profile.workoutDaysPerWeek,
                      );
                    },
                    loading: () => _LoadingWeeklyActivity(),
                    error: (_, __) => _LoadingWeeklyActivity(),
                  ),
                  loading: () => _LoadingWeeklyActivity(),
                  error: (error, stack) => _ErrorCard(
                    message: 'Failed to load workout data',
                    onRetry: () => ref.invalidate(homeWorkoutDataProvider),
                  ),
                ),
              ),
              
              // AI Insights Widget
              const SliverToBoxAdapter(
                child: InsightWidget(context: InsightContext.home),
              ),
              
              // Today Summary Row
              SliverToBoxAdapter(
                child: profileAsync.when(
                  data: (profile) => historyAsync.when(
                    data: (workouts) => _TodaySummaryRow(
                      workouts: workouts,
                      profile: profile,
                    ),
                    loading: () => _LoadingSummaryRow(),
                    error: (_, __) => _LoadingSummaryRow(),
                  ),
                  loading: () => _LoadingSummaryRow(),
                  error: (_, __) => _LoadingSummaryRow(),
                ),
              ),
              
              // Start Workout CTA
              SliverToBoxAdapter(child: _StartWorkoutCTA()),
              
              // Suggestion Card
              SliverToBoxAdapter(
                child: historyAsync.when(
                  data: (workouts) => profileAsync.when(
                    data: (profile) => _SuggestionCard(
                      workouts: workouts,
                      profile: profile,
                    ),
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),
              ),
              
              // Recent Workout Card
              SliverToBoxAdapter(
                child: historyAsync.when(
                  data: (workouts) => workouts.isNotEmpty
                      ? _RecentWorkoutCard(workout: workouts.first)
                      : _EmptyWorkoutCard(),
                  loading: () => _LoadingWorkoutCard(),
                  error: (_, __) => const SizedBox.shrink(),
                ),
              ),
              
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Header ───────────────────────────────────────────────────────────────────

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({required this.profileAsync});
  final AsyncValue<UserProfile?> profileAsync;

  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Good Morning'
        : hour < 17
            ? 'Good Afternoon'
            : 'Good Evening';
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final secondary = Theme.of(context).colorScheme.onSurfaceVariant;
    final surfaceHigh = Theme.of(context).colorScheme.surfaceContainerHighest;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Row(
        children: [
          const IronFlowLogo(size: 40),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(greeting, style: TextStyle(color: secondary, fontSize: 14)),
                const SizedBox(height: 2),
                Text(
                  'IronFlow',
                  style: TextStyle(
                    color: onSurface,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => context.go(AppRoutes.profile),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primaryColor.withValues(alpha: 0.15),
                border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.4)),
              ),
              child: const Icon(Icons.person, color: AppTheme.primaryColor, size: 22),
            ),
          ),
          const SizedBox(width: 8),
          Consumer(
            builder: (context, ref, child) {
              return GestureDetector(
                onTap: () {
                  ref.read(themeProvider.notifier).toggleTheme();
                },
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: surfaceHigh.withValues(alpha: 0.7),
                  ),
                  child: Icon(
                    isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                    color: secondary,
                    size: 18,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1);
  }
}

// ── Weekly Activity Ring ──────────────────────────────────────────────────────

class _WeeklyActivitySection extends StatelessWidget {
  const _WeeklyActivitySection({required this.workouts, required this.target});
  final List<Workout> workouts;
  final int target;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final weekStart = now.subtract(const Duration(days: 6));
    final weekWorkouts = workouts.where((w) => w.date.isAfter(weekStart)).toList();
    final count = weekWorkouts.length;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final secondary = Theme.of(context).colorScheme.onSurfaceVariant;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: AppTheme.glassmorphicCard(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            SizedBox(
              width: 90,
              height: 90,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CustomPaint(
                    size: const Size(90, 90),
                    painter: _RingPainter(
                      progress: (count / target).clamp(0.0, 1.0),
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$count',
                        style: const TextStyle(
                          color: AppTheme.primaryColor,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '/ $target',
                        style: TextStyle(color: secondary, fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Weekly Activity',
                    style: TextStyle(
                      color: onSurface,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    count == 0
                        ? 'Start your first workout!'
                        : count < target
                            ? '${target - count} more to hit your goal'
                            : '🎉 Weekly goal achieved!',
                    style: TextStyle(color: secondary, fontSize: 13),
                  ),
                  const SizedBox(height: 12),
                  _WeekDayDots(workouts: weekWorkouts),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1);
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
    final secondary = Theme.of(context).colorScheme.onSurfaceVariant;
    final surfaceHigh = Theme.of(context).colorScheme.surfaceContainerHighest;

    return Row(
      children: days.map((day) {
        final hasWorkout = workoutDates.contains(DateTime(day.year, day.month, day.day));
        final isToday = day.day == now.day && day.month == now.month && day.year == now.year;
        return Expanded(
          child: Column(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: hasWorkout
                      ? AppTheme.primaryColor
                      : isToday
                          ? AppTheme.primaryColor.withValues(alpha: 0.2)
                          : surfaceHigh,
                  border: isToday
                      ? Border.all(color: AppTheme.primaryColor, width: 1.5)
                      : null,
                ),
                child: hasWorkout
                    ? const Icon(Icons.check, size: 14, color: Colors.black)
                    : null,
              ),
              const SizedBox(height: 3),
              Text(
                DateFormat('E').format(day).substring(0, 1),
                style: TextStyle(
                  fontSize: 10,
                  color: isToday ? AppTheme.primaryColor : secondary,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({required this.progress, required this.color});
  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 10) / 2;
    const strokeWidth = 8.0;
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = color.withValues(alpha: 0.15)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth,
    );
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.progress != progress;
}

// ── Today Summary Row ─────────────────────────────────────────────────────────

class _TodaySummaryRow extends StatelessWidget {
  const _TodaySummaryRow({
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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: _SummaryCard(
              icon: Icons.fitness_center,
              label: 'Last Workout',
              value: lastDate,
              color: AppTheme.accentColor,
            ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.1),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _SummaryCard(
              icon: Icons.local_fire_department,
              label: 'Calories',
              value: '$calories kcal',
              color: Colors.orange,
            ).animate().fadeIn(delay: 250.ms),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _SummaryCard(
              icon: Icons.monitor_weight_outlined,
              label: 'Weight',
              value: '${weight}kg',
              color: AppTheme.primaryColor,
            ).animate().fadeIn(delay: 300.ms).slideX(begin: 0.1),
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
    final secondary = Theme.of(context).colorScheme.onSurfaceVariant;
    return AppTheme.glassmorphicCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.bold),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(color: secondary, fontSize: 10)),
        ],
      ),
    );
  }
}

// ── Start Workout CTA ─────────────────────────────────────────────────────────

class _StartWorkoutCTA extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: GestureDetector(
        onTap: () => context.go(AppRoutes.workoutActive),
        child: Container(
          height: 64,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
            gradient: const LinearGradient(
              colors: [AppTheme.primaryColor, Color(0xFF00CC00)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryColor.withValues(alpha: 0.4),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.play_arrow_rounded, color: Colors.black, size: 28),
              SizedBox(width: 8),
              Text(
                'Start Workout',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: 350.ms).scale(begin: const Offset(0.95, 0.95));
  }
}

// ── Suggestion Card ───────────────────────────────────────────────────────────

class _SuggestionCard extends StatelessWidget {
  const _SuggestionCard({required this.workouts, required this.profile});
  final List<Workout> workouts;
  final UserProfile? profile;

  @override
  Widget build(BuildContext context) {
    final suggestion = _buildSuggestion();
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final secondary = Theme.of(context).colorScheme.onSurfaceVariant;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: AppTheme.glassmorphicCard(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: suggestion.color.withValues(alpha: 0.15),
              ),
              child: Icon(suggestion.icon, color: suggestion.color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    suggestion.title,
                    style: TextStyle(
                      color: onSurface,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    suggestion.body,
                    style: TextStyle(color: secondary, fontSize: 12),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: secondary, size: 14),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1);
  }

  _SuggestionData _buildSuggestion() {
    if (workouts.isEmpty) {
      return _SuggestionData(
        icon: Icons.rocket_launch,
        color: AppTheme.primaryColor,
        title: 'Start your journey!',
        body: 'Log your first workout to unlock progression tracking.',
      );
    }
    final daysSince = DateTime.now().difference(workouts.first.date).inDays;
    if (daysSince >= 3) {
      return _SuggestionData(
        icon: Icons.warning_amber_rounded,
        color: Colors.orange,
        title: 'Time to train!',
        body: 'It\'s been $daysSince days since your last workout. Keep the momentum!',
      );
    }
    if (profile?.goal == FitnessGoal.gainMuscle) {
      return _SuggestionData(
        icon: Icons.trending_up,
        color: AppTheme.accentColor,
        title: 'Progressive Overload',
        body: 'Try adding 2.5kg to your main lifts this session.',
      );
    }
    return _SuggestionData(
      icon: Icons.local_fire_department,
      color: Colors.deepOrange,
      title: 'Stay consistent!',
      body: 'Great work! Keep showing up and results will follow.',
    );
  }
}

class _SuggestionData {
  const _SuggestionData({
    required this.icon,
    required this.color,
    required this.title,
    required this.body,
  });
  final IconData icon;
  final Color color;
  final String title;
  final String body;
}

// ── Recent Workout Card ───────────────────────────────────────────────────────

class _RecentWorkoutCard extends StatelessWidget {
  const _RecentWorkoutCard({required this.workout});
  final Workout workout;

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('EEE, MMM d').format(workout.date);
    final h = workout.duration.inHours;
    final m = workout.duration.inMinutes.remainder(60);
    final duration = h > 0 ? '${h}h ${m}m' : '${m}m';
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final secondary = Theme.of(context).colorScheme.onSurfaceVariant;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: AppTheme.glassmorphicCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Last Workout',
                  style: TextStyle(
                    color: secondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(dateStr, style: TextStyle(color: secondary, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${workout.exercises.length} exercises',
              style: TextStyle(
                color: onSurface,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _WorkoutStat(
                  icon: Icons.fitness_center,
                  value: '${workout.totalVolume.toStringAsFixed(0)}kg',
                  label: 'Volume',
                ),
                const SizedBox(width: 20),
                _WorkoutStat(
                  icon: Icons.timer_outlined,
                  value: duration,
                  label: 'Duration',
                ),
                const SizedBox(width: 20),
                _WorkoutStat(
                  icon: Icons.repeat,
                  value: '${workout.exercises.fold<int>(0, (s, e) => s + e.sets.length)}',
                  label: 'Sets',
                ),
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 450.ms).slideY(begin: 0.1);
  }
}

class _WorkoutStat extends StatelessWidget {
  const _WorkoutStat({
    required this.icon,
    required this.value,
    required this.label,
  });
  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final secondary = Theme.of(context).colorScheme.onSurfaceVariant;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppTheme.primaryColor),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: TextStyle(
                color: onSurface,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(label, style: TextStyle(color: secondary, fontSize: 10)),
          ],
        ),
      ],
    );
  }
}

// ── Loading States ────────────────────────────────────────────────────────────

class _LoadingWeeklyActivity extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final surfaceHigh = Theme.of(context).colorScheme.surfaceContainerHighest;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: AppTheme.glassmorphicCard(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: surfaceHigh.withValues(alpha: 0.3),
              ),
              child: const Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppTheme.primaryColor,
                ),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 16,
                    width: 120,
                    decoration: BoxDecoration(
                      color: surfaceHigh.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 12,
                    width: 180,
                    decoration: BoxDecoration(
                      color: surfaceHigh.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate(onPlay: (controller) => controller.repeat())
        .shimmer(duration: 1500.ms, color: surfaceHigh.withValues(alpha: 0.1));
  }
}

class _LoadingSummaryRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final surfaceHigh = Theme.of(context).colorScheme.surfaceContainerHighest;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Row(
        children: List.generate(3, (index) {
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                left: index == 0 ? 0 : 5,
                right: index == 2 ? 0 : 5,
              ),
              child: AppTheme.glassmorphicCard(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: surfaceHigh.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      height: 13,
                      width: 50,
                      decoration: BoxDecoration(
                        color: surfaceHigh.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      height: 10,
                      width: 40,
                      decoration: BoxDecoration(
                        color: surfaceHigh.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ).animate(onPlay: (controller) => controller.repeat())
                  .shimmer(duration: 1500.ms, color: surfaceHigh.withValues(alpha: 0.1)),
            ),
          );
        }),
      ),
    );
  }
}

class _LoadingWorkoutCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final surfaceHigh = Theme.of(context).colorScheme.surfaceContainerHighest;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: AppTheme.glassmorphicCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 12,
              width: 100,
              decoration: BoxDecoration(
                color: surfaceHigh.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              height: 18,
              width: 150,
              decoration: BoxDecoration(
                color: surfaceHigh.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: List.generate(3, (index) {
                return Padding(
                  padding: EdgeInsets.only(right: index < 2 ? 20 : 0),
                  child: Container(
                    height: 14,
                    width: 60,
                    decoration: BoxDecoration(
                      color: surfaceHigh.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ).animate(onPlay: (controller) => controller.repeat())
          .shimmer(duration: 1500.ms, color: surfaceHigh.withValues(alpha: 0.1)),
    );
  }
}

// ── Error States ──────────────────────────────────────────────────────────────

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({
    required this.message,
    required this.onRetry,
  });
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final secondary = Theme.of(context).colorScheme.onSurfaceVariant;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: AppTheme.glassmorphicCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.orange,
              size: 48,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: TextStyle(
                color: onSurface,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Empty States ──────────────────────────────────────────────────────────────

class _EmptyWorkoutCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final secondary = Theme.of(context).colorScheme.onSurfaceVariant;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: AppTheme.glassmorphicCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(
              Icons.fitness_center,
              color: AppTheme.primaryColor.withValues(alpha: 0.5),
              size: 48,
            ),
            const SizedBox(height: 12),
            Text(
              'No workouts yet',
              style: TextStyle(
                color: onSurface,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Start your first workout to see it here',
              style: TextStyle(
                color: secondary,
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 450.ms).slideY(begin: 0.1);
  }
}

class _ProfileSetupPrompt extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final secondary = Theme.of(context).colorScheme.onSurfaceVariant;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: AppTheme.glassmorphicCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(
              Icons.person_outline,
              color: AppTheme.primaryColor.withValues(alpha: 0.7),
              size: 48,
            ),
            const SizedBox(height: 12),
            Text(
              'Complete your profile',
              style: TextStyle(
                color: onSurface,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Set your weekly workout goal to track your progress',
              style: TextStyle(
                color: secondary,
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1);
  }
}
