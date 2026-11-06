import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:progression_tracker/core/constants/app_theme.dart';
import 'package:progression_tracker/features/ai/presentation/providers/ai_provider.dart';
import 'package:progression_tracker/shared/presentation/services/app_haptics.dart';

class AIChatTelemetryStatusBanner extends StatelessWidget {
  const AIChatTelemetryStatusBanner({
    super.key,
    required this.tokens,
    required this.state,
  });

  final AppThemeTokens tokens;
  final AIChatState state;

  @override
  Widget build(BuildContext context) {
    if (state.isKeyMissing || state.isOfflineFallback) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        color: tokens.warning.withValues(alpha: 0.12),
        child: Row(
          children: [
            Icon(Icons.cloud_off_outlined, size: 14, color: tokens.warning),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Offline mode • Basic assistant active',
                style: TextStyle(
                  fontFamily: AppTypography.displayFontFamily,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                  color: tokens.warning,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      color: tokens.panel,
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: tokens.kineticAccent,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: tokens.kineticAccent.withValues(alpha: 0.6),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Online • Ready to help',
            style: TextStyle(
              fontFamily: AppTypography.displayFontFamily,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
              color: tokens.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}


class AIChatContextualChipsBar extends StatelessWidget {
  const AIChatContextualChipsBar({
    super.key,
    required this.tokens,
    required this.selectedCategory,
    required this.currentChips,
    required this.onSelectCategory,
    required this.onSelectPrompt,
  });

  final AppThemeTokens tokens;
  final String selectedCategory;
  final List<String> currentChips;
  final ValueChanged<String> onSelectCategory;
  final ValueChanged<String> onSelectPrompt;

  @override
  Widget build(BuildContext context) {
    final categories = [
      (id: 'today', label: 'Today', icon: Icons.today_rounded),
      (id: 'workout', label: 'Workout', icon: Icons.fitness_center_rounded),
      (id: 'fuel', label: 'Fuel', icon: Icons.restaurant_rounded),
      (id: 'progress', label: 'Progress', icon: Icons.trending_up_rounded),
    ];

    return Container(
      decoration: BoxDecoration(
        color: tokens.panel,
        border: Border(
          bottom: BorderSide(color: tokens.borderSubtle, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
            child: Row(
              children: categories.map((cat) {
                final isSelected = selectedCategory == cat.id;
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: InkWell(
                    key: ValueKey('screen_tab_${cat.id}'),
                    onTap: () {
                      AppHaptics.shared.selectionChanged();
                      onSelectCategory(cat.id);
                    },
                    borderRadius: BorderRadius.circular(tokens.radiusPill),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: isSelected ? tokens.kineticAccent.withValues(alpha: 0.2) : tokens.card,
                        borderRadius: BorderRadius.circular(tokens.radiusPill),
                        border: Border.all(
                          color: isSelected ? tokens.kineticAccent : tokens.borderSubtle,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            cat.icon,
                            size: 13,
                            color: isSelected ? tokens.kineticAccent : tokens.textMuted,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            cat.label,
                            style: TextStyle(
                              fontFamily: AppTypography.displayFontFamily,
                              fontSize: 11,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              color: isSelected ? tokens.kineticAccent : tokens.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
            child: Row(
              children: currentChips.map((prompt) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: InkWell(
                    onTap: () => onSelectPrompt(prompt),
                    borderRadius: BorderRadius.circular(tokens.radiusPill),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: tokens.card,
                        borderRadius: BorderRadius.circular(tokens.radiusPill),
                        border: Border.all(color: tokens.borderSubtle),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.chat_bubble_outline, size: 12, color: tokens.kineticAccent),
                          const SizedBox(width: 6),
                          Text(
                            prompt,
                            style: TextStyle(
                              fontFamily: AppTypography.bodyFontFamily,
                              fontSize: 12,
                              color: tokens.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class AIChatInteractiveErrorBanner extends ConsumerWidget {
  const AIChatInteractiveErrorBanner({
    super.key,
    required this.tokens,
    required this.chatState,
  });

  final AppThemeTokens tokens;
  final AIChatState chatState;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      key: const ValueKey('ai_chat_error_banner'),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: tokens.panel,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.redAccent.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.redAccent.withValues(alpha: 0.1),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Colors.redAccent, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              chatState.error!,
              style: TextStyle(
                fontFamily: AppTypography.bodyFontFamily,
                fontSize: 12,
                color: tokens.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: 8),
          FilledButton.icon(
            key: const ValueKey('ai_chat_retry_button'),
            onPressed: () {
              AppHaptics.shared.buttonPress();
              ref.read(aiChatProvider.notifier).retryLastMessage();
            },
            icon: const Icon(Icons.refresh, size: 14),
            label: const Text('Retry'),
            style: FilledButton.styleFrom(
              backgroundColor: tokens.kineticAccent,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              minimumSize: const Size(0, 34),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(tokens.radiusPill),
              ),
              textStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 16),
            color: tokens.textMuted,
            onPressed: () {
              ref.read(aiChatProvider.notifier).clearError();
            },
            tooltip: 'Dismiss',
          ),
        ],
      ),
    );
  }
}


class AIChatEmptyState extends StatelessWidget {
  const AIChatEmptyState({
    super.key,
    required this.tokens,
    required this.chips,
    required this.onSelectPrompt,
  });

  final AppThemeTokens tokens;
  final List<String> chips;
  final ValueChanged<String> onSelectPrompt;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: tokens.panel,
                shape: BoxShape.circle,
                border: Border.all(color: tokens.kineticAccent.withValues(alpha: 0.5)),
                boxShadow: [
                  BoxShadow(
                    color: tokens.kineticAccent.withValues(alpha: 0.25),
                    blurRadius: 16,
                  ),
                ],
              ),
              child: Icon(
                Icons.psychology,
                size: 36,
                color: tokens.kineticAccent,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'AI Fitness Assistant',
              style: TextStyle(
                fontFamily: AppTypography.displayFontFamily,
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: tokens.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Ask me anything about workouts, nutrition, form, or your progress',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppTypography.bodyFontFamily,
                fontSize: 13,
                color: tokens.textMuted,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 28),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 10,
              runSpacing: 10,
              children: chips.take(3).map((prompt) {
                return _SuggestionChip(
                  icon: Icons.chat_bubble_outline_rounded,
                  label: prompt,
                  onTap: () => onSelectPrompt(prompt),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class AIChatLoadingIndicator extends StatelessWidget {
  const AIChatLoadingIndicator({super.key, required this.tokens});

  final AppThemeTokens tokens;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      decoration: BoxDecoration(
        color: tokens.panel,
        border: Border(top: BorderSide(color: tokens.borderSubtle)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(tokens.kineticAccent),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'Coach is typing...',
            style: TextStyle(
              fontFamily: AppTypography.displayFontFamily,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: tokens.kineticAccent,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

/// Suggestion chip for empty state
class _SuggestionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SuggestionChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = AppThemeTokens.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(tokens.radiusPill),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: tokens.panel,
          borderRadius: BorderRadius.circular(tokens.radiusPill),
          border: Border.all(color: tokens.borderSubtle),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: tokens.kineticAccent),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontFamily: AppTypography.displayFontFamily,
                color: tokens.textPrimary,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

