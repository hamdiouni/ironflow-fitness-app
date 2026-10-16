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
  const AiCoachHeroCard({super.key});

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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.colorScheme.primary;

    // Check configuration and connectivity
    final hasKey = AppConfig.hasOpenAI || AppConfig.hasGemini || AppConfig.hasNvidia;
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

    final cardBg = isDark
        ? AppTheme.darkCard.withValues(alpha: 0.85)
        : AppTheme.lightCard.withValues(alpha: 0.95);

    return Semantics(
      container: true,
      label: 'AI Coach Hero Card',
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingMedium,
          vertical: AppTheme.spacingSmall,
        ),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
          border: Border.all(
            color: primary.withValues(alpha: 0.25),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: primary.withValues(alpha: isDark ? 0.08 : 0.05),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: hasKey && insights.isNotEmpty
                  ? () {
                      final active = insights[_activeInsightIndex.clamp(0, insights.length - 1)];
                      navigateToAiCoach(
                        context,
                        initialMessage: 'Tell me more about: ${active.title}',
                      );
                    }
                  : null,
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.spacingMedium),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Top header row
                    _buildHeader(context, primary, isLoading, hasKey),
                    const SizedBox(height: AppTheme.spacingSmall),

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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: primary.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.auto_awesome, size: 14, color: primary),
              const SizedBox(width: 6),
              Text(
                'AI COACH',
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                  color: primary,
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
              valueColor: AlwaysStoppedAnimation<Color>(primary),
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
                    color: isDark
                        ? AppTheme.darkTextSecondary
                        : AppTheme.lightTextSecondary,
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
    // 1. Missing API Key
    if (!hasKey) {
      return const AiNoKeyState();
    }

    // 2. Offline with no cached insights
    if (!isOnline && insights.isEmpty) {
      return AiOfflineState(onRetry: _refresh);
    }

    // 3. Loading with no previous insights
    if (isLoading && insights.isEmpty) {
      return const AiLoadingState();
    }

    // 4. Error with no cached insights
    if (error != null && insights.isEmpty) {
      return AiErrorState(
        message: error,
        onRetry: _refresh,
      );
    }

    // 5. Empty insights
    if (insights.isEmpty) {
      return AiEmptyState(
        onAction: () => navigateToAiCoach(context),
      );
    }

    // 6. Success: Show top insight
    final safeIndex = _activeInsightIndex.clamp(0, insights.length - 1);
    final insight = insights[safeIndex];

    return _buildSuccessContent(context, insight, insights.length);
  }

  Widget _buildSuccessContent(
    BuildContext context,
    Insight insight,
    int totalCount,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.colorScheme.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Insight Icon badge
            Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
              ),
              child: Text(
                insight.icon,
                style: const TextStyle(fontSize: 22),
              ),
            ),
            const SizedBox(width: AppTheme.spacingMedium),
            // Title & message
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    insight.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppTheme.spacingXSmall),
                  Text(
                    insight.message,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isDark
                          ? AppTheme.darkTextSecondary
                          : AppTheme.lightTextSecondary,
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
        const SizedBox(height: AppTheme.spacingMedium),

        // Bottom action row: Carousel indicator + CTA button
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: AppTheme.spacingSmall,
          runSpacing: AppTheme.spacingSmall,
          children: [
            if (totalCount > 1)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(totalCount, (index) {
                  final isActive = index == _activeInsightIndex;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _activeInsightIndex = index;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 6),
                      width: isActive ? 18 : 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: isActive
                            ? primary
                            : (isDark
                                ? AppTheme.darkTextDisabled
                                : AppTheme.lightTextDisabled),
                        borderRadius: BorderRadius.circular(3),
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
                  backgroundColor: primary,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingMedium,
                    vertical: AppTheme.spacingSmall,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(AppTheme.borderRadiusMedium),
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
