import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:progression_tracker/features/ai/domain/entities/insight.dart';
import 'package:progression_tracker/features/ai/presentation/providers/global_ai_provider.dart';

/// Quick feedback bottom sheet shown after workout completion
///
/// This bottom sheet appears immediately after a workout is completed to
/// celebrate achievements like PRs, volume records, or consistency milestones.
///
/// **Features:**
/// - Dismissible by swipe down or tap outside
/// - Auto-dismiss after 10 seconds
/// - Highlights PR achievements with special styling
/// - Highlights volume records with celebration emojis
/// - CTA button to view detailed insights
///
/// **Requirements:**
/// - 10.1: Display Quick_Feedback bottom sheet when workout completed
/// - 10.2: Show bottom sheet within 1 second of workout completion
/// - 10.3: Highlight notable achievements (PR, volume records, consistency)
/// - 10.4: Display specific exercise and weight for PRs
/// - 10.5: Celebrate Progressive Overload (10%+ volume increase)
/// - 10.6: Add CTA button to view detailed insights
/// - 10.7: Dismiss on swipe down or tap outside
/// - 10.8: Use celebratory language and emojis
class QuickFeedbackBottomSheet extends ConsumerStatefulWidget {
  const QuickFeedbackBottomSheet({
    super.key,
    required this.feedback,
  });

  /// The quick feedback insight to display
  final Insight feedback;

  @override
  ConsumerState<QuickFeedbackBottomSheet> createState() =>
      _QuickFeedbackBottomSheetState();

  /// Show the quick feedback bottom sheet
  ///
  /// This method displays the bottom sheet and automatically dismisses it
  /// after 10 seconds if the user doesn't interact with it.
  ///
  /// **Parameters:**
  /// - [context]: The build context
  /// - [feedback]: The quick feedback insight to display
  ///
  /// **Requirements:**
  /// - 10.2: Show bottom sheet within 1 second of workout completion
  /// - 10.7: Dismiss on swipe down or tap outside
  static void show(BuildContext context, Insight feedback) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      backgroundColor: Colors.transparent,
      builder: (context) => QuickFeedbackBottomSheet(feedback: feedback),
    ).then((_) {
      // Handle dismissal by swipe down or tap outside
      // This ensures dismissQuickFeedback() is called even if the user
      // dismisses the bottom sheet without pressing a button
      if (context.mounted) {
        // Use a short delay to ensure the bottom sheet is fully dismissed
        // before calling dismissQuickFeedback() to avoid state conflicts
        Future.delayed(const Duration(milliseconds: 100), () {
          if (context.mounted) {
            // Read the provider to check if quick feedback is still present
            final container = ProviderScope.containerOf(context);
            final currentState = container.read(globalAIProvider);
            
            // Only dismiss if quick feedback is still present (not already dismissed by button)
            if (currentState.quickFeedback != null) {
              container.read(globalAIProvider.notifier).dismissQuickFeedback();
            }
          }
        });
      }
    });
  }
}

class _QuickFeedbackBottomSheetState
    extends ConsumerState<QuickFeedbackBottomSheet> {
  Timer? _autoDismissTimer;

  @override
  void initState() {
    super.initState();
    
    // Start auto-dismiss timer (10 seconds)
    _autoDismissTimer = Timer(const Duration(seconds: 10), () {
      if (mounted) {
        Navigator.of(context).pop();
        // Dismiss quick feedback from state
        ref.read(globalAIProvider.notifier).dismissQuickFeedback();
      }
    });
  }

  @override
  void dispose() {
    _autoDismissTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              
              // Icon with celebration effect
              _buildCelebrationIcon(),
              const SizedBox(height: 16),
              
              // Title
              Text(
                widget.feedback.title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              
              // Message
              Text(
                widget.feedback.message,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[700],
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              
              // CTA Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Dismiss bottom sheet
                    Navigator.of(context).pop();
                    
                    // Navigate to AI chat screen
                    _navigateToAIChat(context);
                    
                    // Dismiss quick feedback from state
                    ref.read(globalAIProvider.notifier).dismissQuickFeedback();
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'View Detailed Insights',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              
              // Dismiss button
              TextButton(
                onPressed: () {
                  // Cancel auto-dismiss timer
                  _autoDismissTimer?.cancel();
                  
                  // Dismiss bottom sheet
                  Navigator.of(context).pop();
                  
                  // Dismiss quick feedback from state
                  ref.read(globalAIProvider.notifier).dismissQuickFeedback();
                },
                child: const Text('Dismiss'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build celebration icon with special styling
  Widget _buildCelebrationIcon() {
    // Determine if this is a PR or volume record based on title/message
    final isPR = widget.feedback.title.toLowerCase().contains('pr') ||
        widget.feedback.title.toLowerCase().contains('personal record');
    final isVolumeRecord = widget.feedback.title.toLowerCase().contains('volume') ||
        widget.feedback.message.toLowerCase().contains('volume');
    final isConsistency = widget.feedback.title.toLowerCase().contains('consistency') ||
        widget.feedback.title.toLowerCase().contains('streak');

    // Choose icon and color based on achievement type
    IconData iconData;
    Color iconColor;
    String emoji;

    if (isPR) {
      iconData = Icons.emoji_events;
      iconColor = Colors.amber;
      emoji = '🏆';
    } else if (isVolumeRecord) {
      iconData = Icons.trending_up;
      iconColor = Colors.green;
      emoji = '📈';
    } else if (isConsistency) {
      iconData = Icons.local_fire_department;
      iconColor = Colors.orange;
      emoji = '🔥';
    } else {
      iconData = Icons.celebration;
      iconColor = Colors.purple;
      emoji = '🎉';
    }

    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              emoji,
              style: const TextStyle(fontSize: 40),
            ),
            Icon(
              iconData,
              size: 24,
              color: iconColor,
            ),
          ],
        ),
      ),
    );
  }

  /// Navigate to AI chat screen with quick feedback context
  void _navigateToAIChat(BuildContext context) {
    // TODO: Implement navigation to AI chat screen
    // This will be implemented in Phase 5 (Screen Integration)
    // For now, just show a snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('AI Chat navigation will be implemented in Phase 5'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
