import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'ai_destination.dart';

/// Shared, consistent entry button for launching the AI Fitness Coach from screen headers.
///
/// Ensures identical iconography, accessibility labels, 48dp tap target,
/// and routing behavior across all permitted screens (Home, Workout, Nutrition, Analytics).
class AiEntryButton extends ConsumerWidget {
  const AiEntryButton({
    super.key,
    this.onPressed,
  });

  /// Optional custom action callback. Defaults to navigating to [AppRoutes.aiChat].
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Semantics(
      button: true,
      label: 'AI Fitness Coach',
      hint: 'Opens the AI Fitness Coach for advice and workouts',
      child: Tooltip(
        message: 'AI Fitness Coach',
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minWidth: 48,
            minHeight: 48,
          ),
          child: Material(
            color: Colors.transparent,
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onPressed ?? () => navigateToAiCoach(context),
              customBorder: const CircleBorder(),
              child: Center(
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: primary.withValues(alpha: 0.12),
                    border: Border.all(
                      color: primary.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    Icons.auto_awesome,
                    size: 18,
                    color: primary,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
