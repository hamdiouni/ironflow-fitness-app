import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_theme.dart';
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
    final tokens = context.tokens;

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
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: tokens.card,
                    border: Border.all(
                      color: tokens.kineticAccent.withValues(alpha: 0.4),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: tokens.kineticAccent.withValues(alpha: tokens.isDark ? 0.18 : 0.08),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.auto_awesome,
                    size: 18,
                    color: tokens.kineticAccent,
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
