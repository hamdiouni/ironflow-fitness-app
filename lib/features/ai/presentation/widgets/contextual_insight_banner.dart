import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_theme.dart';
import '../../domain/entities/insight.dart';
import '../providers/banner_dismissal_provider.dart';
import '../providers/global_ai_provider.dart';
import 'ai_destination.dart';

/// Contextual, non-intrusive AI banner for secondary screens (Workout, Nutrition, Profile).
///
/// Rules:
/// - At most ONE insight banner displayed per screen.
/// - Never displayed on Home (where [AiCoachHeroCard] is the primary presentation).
/// - Fully dismissible by the user, with dismissal state persisted via [bannerDismissalProvider].
/// - 48dp touch targets, theme tokens only, responsive to 1.5x font scale without overflow.
/// - Tapping launches the unified AI Coach destination [navigateToAiCoach].
class ContextualInsightBanner extends ConsumerWidget {
  const ContextualInsightBanner({
    super.key,
    required this.context,
    this.margin,
  });

  /// The domain context for the insights (Workout, Nutrition, Profile).
  final InsightContext context;

  /// Optional custom outer margin.
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Rule: Never duplicate hero card content on Home.
    if (this.context == InsightContext.home) {
      return const SizedBox.shrink();
    }

    final insights = ref.watch(globalAIProvider.select(
      (state) => state.getInsights(this.context),
    ));
    final dismissedIds = ref.watch(bannerDismissalProvider);

    // Filter out dismissed insights
    final activeInsights =
        insights.where((i) => !dismissedIds.contains(i.id)).toList();

    // At most ONE insight banner per screen
    if (activeInsights.isEmpty) {
      return const SizedBox.shrink();
    }

    final insight = activeInsights.first;
    final tokens = context.tokens;

    return Semantics(
      container: true,
      label: 'AI Tip: ${insight.title}. ${insight.message}',
      child: Container(
        margin: margin ??
            const EdgeInsets.symmetric(
              horizontal: AppSpacings.lg,
              vertical: AppSpacings.sm,
            ),
        decoration: BoxDecoration(
          color: tokens.card,
          borderRadius: BorderRadius.circular(tokens.radiusSm),
          border: Border.all(
            color: tokens.kineticAccent.withValues(alpha: 0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: tokens.kineticAccent.withValues(
                alpha: tokens.isDark ? 0.08 : 0.04,
              ),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(tokens.radiusSm),
            onTap: () {
              navigateToAiCoach(
                context,
                initialMessage: 'Tell me more about: ${insight.title}',
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacings.md,
                vertical: AppSpacings.sm,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Icon
                  Container(
                    width: 36,
                    height: 36,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: tokens.elevated,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: tokens.borderSubtle,
                        width: 0.8,
                      ),
                    ),
                    child: Text(
                      insight.icon,
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                  const SizedBox(width: AppSpacings.sm),

                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          insight.title,
                          style: TextStyle(
                            fontFamily: AppTypography.displayFontFamily,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: tokens.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          insight.message,
                          style: TextStyle(
                            fontFamily: AppTypography.bodyFontFamily,
                            fontSize: 12,
                            color: tokens.textSecondary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacings.sm),

                  // Dismiss button (constrained to 48dp minimum tap target)
                  Semantics(
                    button: true,
                    label: 'Dismiss AI tip',
                    child: Tooltip(
                      message: 'Dismiss',
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          minWidth: 48,
                          minHeight: 48,
                        ),
                        child: IconButton(
                          icon: Icon(
                            Icons.close,
                            size: 16,
                            color: tokens.textMuted,
                          ),
                          onPressed: () {
                            ref
                                .read(bannerDismissalProvider.notifier)
                                .dismiss(insight.id);
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
