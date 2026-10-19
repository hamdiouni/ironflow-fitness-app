import 'package:flutter/material.dart' hide Split;
import '../../../../../core/theme/app_theme_tokens.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../domain/splits/entities/split.dart';

/// Card component representing a selectable training split.
class SplitSelectionCard extends StatelessWidget {
  final Split split;
  final bool isSelected;
  final VoidCallback onTap;

  const SplitSelectionCard({
    super.key,
    required this.split,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = AppThemeTokens.of(context);
    final accentColor = split.isHybrid
        ? tokens.violetAccent
        : (split.id == 'custom_mix' ? tokens.kineticAccent : tokens.cyanAccent);

    return InkWell(
      key: Key('split_card_${split.id}'),
      onTap: onTap,
      borderRadius: BorderRadius.circular(tokens.radiusLg),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? accentColor.withValues(alpha: 0.12)
              : tokens.card,
          borderRadius: BorderRadius.circular(tokens.radiusLg),
          border: Border.all(
            color: isSelected ? accentColor : tokens.borderSubtle,
            width: isSelected ? 1.8 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: accentColor.withValues(alpha: 0.28),
                    blurRadius: 12,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    split.name.toUpperCase(),
                    style: TextStyle(
                      color: isSelected ? accentColor : tokens.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      fontFamily: AppTypography.fontFamilyHeadings,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
                Icon(
                  isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                  color: isSelected ? accentColor : tokens.textMuted,
                  size: 20,
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              split.description,
              style: TextStyle(
                color: tokens.textSecondary,
                fontSize: 12,
                height: 1.35,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: tokens.panel,
                    borderRadius: BorderRadius.circular(tokens.radiusSm),
                    border: Border.all(color: tokens.borderSubtle),
                  ),
                  child: Text(
                    'CYCLE: ${split.cycleDays.length} DAYS',
                    style: TextStyle(
                      color: tokens.textMuted,
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
                      fontFamily: AppTypography.fontFamilyHeadings,
                      letterSpacing: 0.6,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(tokens.radiusSm),
                    border: Border.all(
                      color: accentColor.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    'RECOMMENDED: ${split.minRecommendedDays}–${split.maxRecommendedDays} D/WK',
                    style: TextStyle(
                      color: accentColor,
                      fontSize: 9.5,
                      fontWeight: FontWeight.w800,
                      fontFamily: AppTypography.fontFamilyHeadings,
                      letterSpacing: 0.6,
                    ),
                  ),
                ),
                if (split.isHybrid)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: tokens.violetAccent.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(tokens.radiusSm),
                    ),
                    child: Text(
                      'HYBRID',
                      style: TextStyle(
                        color: tokens.violetAccent,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w900,
                        fontFamily: AppTypography.fontFamilyHeadings,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
