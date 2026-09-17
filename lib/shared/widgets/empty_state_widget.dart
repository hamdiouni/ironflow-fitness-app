import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// A reusable empty state widget with consistent styling and animations
class EmptyStateWidget extends StatelessWidget {
  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionText,
    this.onActionPressed,
    this.illustration,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionText;
  final VoidCallback? onActionPressed;
  final Widget? illustration;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon or Illustration
            if (illustration != null)
              illustration!
            else
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(40),
                ),
                child: Icon(
                  icon,
                  size: 40,
                  color: theme.colorScheme.primary,
                ),
              ),
            
            const SizedBox(height: 24),
            
            // Title
            Text(
              title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 12),
            
            // Message
            Text(
              message,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            
            // Action Button
            if (actionText != null && onActionPressed != null) ...[
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: onActionPressed,
                icon: const Icon(Icons.add),
                label: Text(actionText!),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 600.ms, curve: Curves.easeOut)
        .slideY(begin: 0.3, end: 0, duration: 600.ms, curve: Curves.easeOut);
  }
}

/// Predefined empty states for common scenarios
class EmptyStates {
  static Widget workouts({VoidCallback? onStartWorkout}) {
    return EmptyStateWidget(
      icon: Icons.fitness_center,
      title: 'No Workouts Yet',
      message: 'Start your fitness journey today!\nLog your first workout to track your progress.',
      actionText: 'Start First Workout',
      onActionPressed: onStartWorkout,
    );
  }

  static Widget meals({VoidCallback? onLogMeal}) {
    return EmptyStateWidget(
      icon: Icons.restaurant,
      title: 'No Meals Logged',
      message: 'Track your nutrition to reach your goals!\nLog your first meal to get started.',
      actionText: 'Log First Meal',
      onActionPressed: onLogMeal,
    );
  }

  static Widget progress() {
    return const EmptyStateWidget(
      icon: Icons.show_chart,
      title: 'No Progress Data',
      message: 'Complete workouts and log meals to see your progress!\nYour journey starts with the first step.',
    );
  }

  static Widget exercises() {
    return const EmptyStateWidget(
      icon: Icons.search,
      title: 'No Exercises Found',
      message: 'Try adjusting your search or browse different muscle groups.',
    );
  }

  static Widget aiInsights() {
    return const EmptyStateWidget(
      icon: Icons.psychology,
      title: 'No Insights Yet',
      message: 'Complete workouts and log meals to get personalized AI insights!',
    );
  }

  static Widget generic({
    required String title,
    required String message,
    IconData icon = Icons.info_outline,
  }) {
    return EmptyStateWidget(
      icon: icon,
      title: title,
      message: message,
    );
  }
}