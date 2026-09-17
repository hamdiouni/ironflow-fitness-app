import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:progression_tracker/features/ai/domain/entities/insight.dart';
import 'package:progression_tracker/features/ai/presentation/providers/global_ai_provider.dart';
import 'package:progression_tracker/core/router/app_router.dart';

/// Reusable widget for displaying AI-generated insights
///
/// This widget displays contextual coaching insights on different screens
/// (Home, Workout, Nutrition, Profile). It handles loading, error, empty,
/// and insights display states automatically.
///
/// **Features:**
/// - Context-specific insights display
/// - Loading state with shimmer effect
/// - Error state with retry button
/// - Empty state with onboarding message
/// - Tap navigation to AI chat
/// - Glassmorphic design with animations
///
/// **Requirements:**
/// - 5.1: Display 2-3 insights in a card
/// - 5.2: Show icon, title, and message for each insight
/// - 5.3: Show loading state while generating insights
/// - 5.4: Show error state with retry button
/// - 5.6: Navigate to AI chat on tap
/// - 5.7: Add fade and slide animations
class InsightWidget extends ConsumerStatefulWidget {
  const InsightWidget({
    super.key,
    required this.context,
  });

  /// The insight context to display insights for
  final InsightContext context;

  @override
  ConsumerState<InsightWidget> createState() => _InsightWidgetState();
}

class _InsightWidgetState extends ConsumerState<InsightWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    
    // Initialize animation controller
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    // Fade animation
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    // Slide animation (from bottom to top)
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    // Start animation
    _animationController.forward();
    
    // Trigger insight generation for this context
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(globalAIProvider.notifier).getInsights(widget.context);
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Watch the global AI provider for insights, loading, and error states
    final insights = ref.watch(globalAIProvider.select(
      (state) => state.getInsights(widget.context),
    ));
    final isLoading = ref.watch(globalAIProvider.select(
      (state) => state.isLoadingForContext(widget.context),
    ));
    final error = ref.watch(globalAIProvider.select(
      (state) => state.getError(widget.context),
    ));

    // Use AnimatedSwitcher for smooth state transitions
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: _buildContent(context, insights, isLoading, error),
    );
  }

  /// Build content based on current state
  Widget _buildContent(
    BuildContext context,
    List<Insight> insights,
    bool isLoading,
    String? error,
  ) {
    // Show loading state
    if (isLoading) {
      return _buildLoadingState(context);
    }

    // Show error state
    if (error != null) {
      return _buildErrorState(context, error);
    }

    // Show empty state if no insights
    if (insights.isEmpty) {
      return _buildEmptyState(context);
    }

    // Show insights list with animations
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: _buildInsightsList(context, insights),
      ),
    );
  }

  /// Build loading state with shimmer effect
  Widget _buildLoadingState(BuildContext context) {
    return GlassmorphicCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Icon(Icons.lightbulb_outline, size: 24),
              const SizedBox(width: 12),
              Text(
                'AI Insights',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Loading shimmer
          _buildShimmerEffect(context),
        ],
      ),
    );
  }

  /// Build shimmer effect for loading state
  Widget _buildShimmerEffect(BuildContext context) {
    return Column(
      children: List.generate(2, (index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title shimmer
              Container(
                height: 16,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 8),
              // Message shimmer
              Container(
                height: 14,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 4),
              Container(
                height: 14,
                width: MediaQuery.of(context).size.width * 0.7,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  /// Build error state with retry button
  Widget _buildErrorState(BuildContext context, String error) {
    return GlassmorphicCard(
      child: Column(
        children: [
          const Icon(
            Icons.error_outline,
            size: 48,
            color: Colors.orange,
          ),
          const SizedBox(height: 16),
          Text(
            'Unable to generate insights',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Something went wrong. Please try again.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              // Retry by refreshing insights
              ref.read(globalAIProvider.notifier).refreshInsights(widget.context);
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  /// Build empty state with onboarding message
  Widget _buildEmptyState(BuildContext context) {
    return GlassmorphicCard(
      child: Column(
        children: [
          const Icon(
            Icons.lightbulb_outline,
            size: 48,
            color: Colors.blue,
          ),
          const SizedBox(height: 16),
          Text(
            'Start Your Journey',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            _getEmptyStateMessage(),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Get context-specific empty state message
  String _getEmptyStateMessage() {
    switch (widget.context) {
      case InsightContext.home:
        return 'Log workouts and meals to get personalized coaching insights.';
      case InsightContext.workout:
        return 'Complete workouts to see training insights and progress analysis.';
      case InsightContext.nutrition:
        return 'Track your meals to get nutrition insights and recommendations.';
      case InsightContext.profile:
        return 'Record body metrics to track your fitness journey progress.';
    }
  }

  /// Build insights list display
  Widget _buildInsightsList(
    BuildContext context,
    List<Insight> insights,
  ) {
    return GlassmorphicCard(
      onTap: () {
        // Navigate to AI chat with pre-populated context
        _navigateToAIChat(context, insights);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Icon(Icons.lightbulb, size: 24, color: Colors.amber),
              const SizedBox(width: 12),
              Text(
                'AI Insights',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const Spacer(),
              const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
          const SizedBox(height: 16),
          // Insights list
          ...insights.map((insight) => _buildInsightItem(context, insight)),
        ],
      ),
    );
  }

  /// Build individual insight item
  Widget _buildInsightItem(BuildContext context, Insight insight) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          Text(
            insight.icon,
            style: const TextStyle(fontSize: 24),
          ),
          const SizedBox(width: 12),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  insight.title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                // Message
                Text(
                  insight.message,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[700],
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Navigate to AI chat screen with pre-populated context
  void _navigateToAIChat(BuildContext context, List<Insight> insights) {
    // Navigate to AI chat screen using GoRouter
    context.push(AppRoutes.aiChat, extra: {
      'context': widget.context,
      'insights': insights,
    });
  }
}

/// Glassmorphic card widget with frosted glass effect
///
/// This widget provides a consistent glassmorphic design across all insight cards.
/// It includes a frosted glass effect, subtle border, and shadow.
///
/// **Requirements:**
/// - 5.8: Implement glassmorphic design with frosted glass effect
class GlassmorphicCard extends StatelessWidget {
  const GlassmorphicCard({
    super.key,
    required this.child,
    this.onTap,
  });

  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: child,
          ),
        ),
      ),
    );
  }
}
