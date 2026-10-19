import 'package:flutter/material.dart';
import '../../../../../core/theme/app_theme_tokens.dart';
import '../../../../../core/theme/app_typography.dart';

/// Interactive days-per-week selector allowing 1..7 training days.
class DaysStepper extends StatelessWidget {
  final int daysPerWeek;
  final ValueChanged<int> onChanged;

  const DaysStepper({
    super.key,
    required this.daysPerWeek,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = AppThemeTokens.of(context);
    final restDays = 7 - daysPerWeek;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: tokens.card,
        borderRadius: BorderRadius.circular(tokens.radiusLg),
        border: Border.all(color: tokens.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'TRAINING DAYS PER WEEK',
                style: TextStyle(
                  color: tokens.textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
                  fontFamily: AppTypography.fontFamilyHeadings,
                ),
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: tokens.cyanAccent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(tokens.radiusSm),
                      border: Border.all(
                        color: tokens.cyanAccent.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      '$daysPerWeek WORK',
                      style: TextStyle(
                        color: tokens.cyanAccent,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        fontFamily: AppTypography.fontFamilyHeadings,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: tokens.violetAccent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(tokens.radiusSm),
                      border: Border.all(
                        color: tokens.violetAccent.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      '$restDays REST',
                      style: TextStyle(
                        color: tokens.violetAccent,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        fontFamily: AppTypography.fontFamilyHeadings,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (index) {
              final dayValue = index + 1;
              final isSelected = dayValue == daysPerWeek;

              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: index < 6 ? 6.0 : 0.0,
                  ),
                  child: InkWell(
                    key: Key('days_stepper_day_$dayValue'),
                    onTap: () => onChanged(dayValue),
                    borderRadius: BorderRadius.circular(tokens.radiusMd),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? tokens.cyanAccent.withValues(alpha: 0.2)
                            : tokens.panel,
                        borderRadius: BorderRadius.circular(tokens.radiusMd),
                        border: Border.all(
                          color: isSelected
                              ? tokens.cyanAccent
                              : tokens.borderSubtle,
                          width: isSelected ? 1.5 : 1.0,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: tokens.cyanAccent.withValues(alpha: 0.35),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: Center(
                        child: Text(
                          '$dayValue',
                          style: TextStyle(
                            color: isSelected
                                ? tokens.cyanAccent
                                : tokens.textSecondary,
                            fontSize: 16,
                            fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                            fontFamily: AppTypography.fontFamilyHeadings,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
