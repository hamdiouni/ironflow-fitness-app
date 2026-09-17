import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_theme.dart';
import '../providers/streak_provider.dart';

/// Displays the user's current workout streak with fire icon.
///
/// Shows current streak count and longest streak achieved.
class StreakDisplay extends ConsumerWidget {
  const StreakDisplay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streakAsync = ref.watch(streakProvider);

    return streakAsync.when(
      data: (streak) {
        return AppTheme.glassmorphicCard(
          padding: const EdgeInsets.all(AppTheme.spacingMedium),
          child: Row(
            children: [
              // Fire icon with current streak
              Column(
                children: [
                  Icon(
                    Icons.local_fire_department,
                    color: Colors.orange,
                    size: 32,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${streak.currentStreak}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'days',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: AppTheme.spacingMedium),
              // Streak info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Current Streak',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Keep it going!',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: streak.isActive ? Colors.green : Colors.red,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Personal best: ${streak.longestStreak} days',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
      loading: () => AppTheme.glassmorphicCard(
        padding: const EdgeInsets.all(AppTheme.spacingMedium),
        child: const SizedBox(
          height: 80,
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
