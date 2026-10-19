import 'package:flutter/material.dart';
import '../../../../../core/theme/app_theme_tokens.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../domain/splits/entities/hybrid_split.dart';

/// Segmented toggle allowing users to choose between Combined Cycle and Alternate Weeks for hybrid splits.
class HybridModeSelector extends StatelessWidget {
  final HybridMode selectedMode;
  final ValueChanged<HybridMode> onModeChanged;

  const HybridModeSelector({
    super.key,
    required this.selectedMode,
    required this.onModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = AppThemeTokens.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: tokens.card,
        borderRadius: BorderRadius.circular(tokens.radiusLg),
        border: Border.all(
          color: tokens.violetAccent.withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.alt_route_rounded,
                color: tokens.violetAccent,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'HYBRID ARCHITECTURE MODE',
                style: TextStyle(
                  color: tokens.textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
                  fontFamily: AppTypography.fontFamilyHeadings,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _ModeOptionCard(
                  title: 'COMBINED CYCLE',
                  subtitle: 'Single continuous rolling cycle',
                  isSelected: selectedMode == HybridMode.combinedCycle,
                  onTap: () => onModeChanged(HybridMode.combinedCycle),
                  tokens: tokens,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ModeOptionCard(
                  title: 'ALTERNATE WEEKS',
                  subtitle: 'Week A (Split 1) / Week B (Split 2)',
                  isSelected: selectedMode == HybridMode.alternateWeeks,
                  onTap: () => onModeChanged(HybridMode.alternateWeeks),
                  tokens: tokens,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            selectedMode == HybridMode.combinedCycle
                ? 'Templates from both splits are merged into a continuous unified queue that rolls seamlessly across calendar weeks.'
                : 'Odd weeks execute the primary split; even weeks switch to the complementary split for targeted architectural variation.',
            style: TextStyle(
              color: tokens.textSecondary,
              fontSize: 11.5,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeOptionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;
  final AppThemeTokens tokens;

  const _ModeOptionCard({
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
    required this.tokens,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(tokens.radiusMd),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? tokens.violetAccent.withValues(alpha: 0.18)
              : tokens.panel,
          borderRadius: BorderRadius.circular(tokens.radiusMd),
          border: Border.all(
            color: isSelected
                ? tokens.violetAccent
                : tokens.borderSubtle,
            width: isSelected ? 1.5 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: tokens.violetAccent.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isSelected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                  color: isSelected ? tokens.violetAccent : tokens.textMuted,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: isSelected ? tokens.textPrimary : tokens.textSecondary,
                      fontSize: 11.5,
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                      fontFamily: AppTypography.fontFamilyHeadings,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                color: isSelected ? tokens.violetAccent : tokens.textMuted,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
