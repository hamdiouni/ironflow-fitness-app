import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/constants/app_theme.dart';
import '../../../../core/providers/connectivity_provider.dart';
import '../../domain/entities/insight.dart';
import '../providers/global_ai_provider.dart';
import 'ai_destination.dart';
import 'ai_empty_state.dart';
import 'ai_error_state.dart';
import 'ai_loading_state.dart';
import 'ai_no_key_state.dart';
import 'ai_offline_state.dart';

/// The primary AI element on the Home screen.
///
/// Displays the top prioritized daily insight with glassmorphic styling,
/// prominent call to action, and comprehensive state handling:
/// - Loading (shimmer)
/// - Success (top insight with action)
/// - Empty ("Start Your Journey")
/// - Error (with retry)
/// - Offline (with cached indication)
/// - Missing API Key (safe explanation without secrets)
class AiCoachHeroCard extends ConsumerStatefulWidget {
  const AiCoachHeroCard({
    super.key,
    this.isConfigured,
  });

  /// Optional override for API key presence (defaults to AppConfig check).
  final bool? isConfigured;

  @override
  ConsumerState<AiCoachHeroCard> createState() => _AiCoachHeroCardState();
}

class _AiCoachHeroCardState extends ConsumerState<AiCoachHeroCard> {
  int _activeInsightIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(globalAIProvider.notifier).getInsights(InsightContext.home);
    });
  }

  void _refresh() {
    ref.read(globalAIProvider.notifier).refreshInsights(InsightContext.home);
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final primary = tokens.kineticAccent;

    // Check configuration and connectivity
    final hasKey = widget.isConfigured ??
        (AppConfig.hasOpenAI || AppConfig.hasGemini || AppConfig.hasNvidia);
    final isOnline = ref.watch(isOnlineProvider).value ?? true;

    // Watch GlobalAIState for Home context
    final insights = ref.watch(globalAIProvider.select(
      (state) => state.getInsights(InsightContext.home),
    ));
    final isLoading = ref.watch(globalAIProvider.select(
      (state) => state.isLoadingForContext(InsightContext.home),
    ));
    final error = ref.watch(globalAIProvider.select(
      (state) => state.getError(InsightContext.home),
    ));

    return Semantics(
      container: true,
      label: 'AI Coach Hero Card',
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: AppSpacings.lg,
          vertical: AppSpacings.sm,
        ),
        decoration: BoxDecoration(
          color: tokens.card,
          borderRadius: BorderRadius.circular(tokens.radiusMd),
          border: Border.all(
            color: tokens.kineticAccent.withValues(alpha: 0.35),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: tokens.kineticAccent.withValues(alpha: tokens.isDark ? 0.08 : 0.04),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(tokens.radiusMd),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacings.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top header row
                _buildHeader(context, primary, isLoading, hasKey),
                const SizedBox(height: AppSpacings.sm),

                // Main state content
                _buildContent(
                  context: context,
                  hasKey: hasKey,
                  isOnline: isOnline,
                  insights: insights,
                  isLoading: isLoading,
                  error: error,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    Color primary,
    bool isLoading,
    bool hasKey,
  ) {
    final tokens = context.tokens;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: tokens.kineticAccent.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(tokens.radiusXs),
            border: Border.all(
              color: tokens.kineticAccent.withValues(alpha: 0.3),
              width: 0.8,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.auto_awesome, size: 14, color: tokens.kineticAccent),
              const SizedBox(width: 6),
              Text(
                'AI COACH',
                style: TextStyle(
                  fontFamily: AppTypography.displayFontFamily,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                  color: tokens.kineticAccent,
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        if (isLoading)
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(tokens.kineticAccent),
            ),
          )
        else if (hasKey)
          Semantics(
            button: true,
            label: 'Refresh AI insights',
            child: Tooltip(
              message: 'Refresh Insights',
              child: ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                child: IconButton(
                  icon: Icon(
                    Icons.refresh,
                    size: 18,
                    color: tokens.textSecondary,
                  ),
                  onPressed: _refresh,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildContent({
    required BuildContext context,
    required bool hasKey,
    required bool isOnline,
    required List<Insight> insights,
    required bool isLoading,
    required String? error,
  }) {
    // 1. Success: Always show insights if available (including cached insights when offline)
    if (insights.isNotEmpty) {
      final safeIndex = _activeInsightIndex.clamp(0, insights.length - 1);
      final insight = insights[safeIndex];
      return _buildSuccessContent(context, insight, insights.length);
    }

    // 2. Missing API Key (when no insights available)
    if (!hasKey) {
      return const AiNoKeyState();
    }

    // 3. Offline (when no insights available)
    if (!isOnline) {
      return AiOfflineState(onRetry: _refresh);
    }

    // 4. Loading (when no insights available)
    if (isLoading) {
      return const AiLoadingState();
    }

    // 5. Error (when no insights available)
    if (error != null) {
      return AiErrorState(
        message: error,
        onRetry: _refresh,
      );
    }

    // 6. Clean Empty state
    return AiEmptyState(
      onAction: () => navigateToAiCoach(context),
    );
  }

  Widget _buildSuccessContent(
    BuildContext context,
    Insight insight,
    int totalCount,
  ) {
    final tokens = context.tokens;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(tokens.radiusSm),
          onTap: () {
            navigateToAiCoach(
              context,
              initialMessage: 'Tell me more about: ${insight.title}',
            );
          },
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Insight Icon badge
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: tokens.elevated,
                  borderRadius: BorderRadius.circular(tokens.radiusSm),
                  border: Border.all(color: tokens.borderSubtle, width: 1),
                ),
                child: Text(
                  insight.icon,
                  style: const TextStyle(fontSize: 22),
                ),
              ),
              const SizedBox(width: AppSpacings.md),
              // Title & message
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      insight.title,
                      style: TextStyle(
                        fontFamily: AppTypography.displayFontFamily,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: tokens.textPrimary,
                        letterSpacing: -0.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacings.xs),
                    Text(
                      insight.message,
                      style: TextStyle(
                        fontFamily: AppTypography.bodyFontFamily,
                        fontSize: 13,
                        color: tokens.textSecondary,
                        height: 1.4,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacings.md),

        // Bottom action row: Carousel indicator + CTA button
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: AppSpacings.sm,
          runSpacing: AppSpacings.sm,
          children: [
            if (totalCount > 1)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(totalCount, (index) {
                  final isActive = index == _activeInsightIndex;
                  return InkWell(
                    key: ValueKey('carousel_dot_$index'),
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      setState(() {
                        _activeInsightIndex = index;
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 8,
                      ),
                      child: Container(
                        width: isActive ? 18 : 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: isActive
                              ? tokens.kineticAccent
                              : tokens.textTertiary,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  );
                }),
              )
            else
              const SizedBox.shrink(),

            // CTA Button (>=48dp touch target)
            ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 48),
              child: FilledButton.icon(
                onPressed: () {
                  navigateToAiCoach(
                    context,
                    initialMessage: 'Tell me more about: ${insight.title}',
                  );
                },
                icon: const Icon(Icons.chat_bubble_outline, size: 16),
                label: const Text('Chat with Coach'),
                style: FilledButton.styleFrom(
                  backgroundColor: tokens.kineticAccent,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacings.md,
                    vertical: AppSpacings.sm,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(tokens.radiusSm),
                  ),
                  textStyle: const TextStyle(
                    fontFamily: AppTypography.displayFontFamily,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
