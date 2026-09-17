import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_theme.dart';
import '../../domain/entities/macro_target.dart';
import '../../domain/entities/meal_category.dart';
import '../../domain/entities/meal_suggestion.dart';
import '../providers/nutrition_providers.dart';

/// Displays swipeable meal suggestion cards filtered by the remaining macro budget.
///
/// Consumes [mealSuggestionsProvider] keyed by [remaining] macros and renders
/// a horizontal [PageView] of suggestion cards with macro breakdown and a
/// category badge.
///
/// Requirements: 20.1, 20.2, 20.3, 20.4, 20.5
class MealSuggestionsView extends ConsumerWidget {
  /// The remaining macro budget used to filter suggestions.
  final MacroTarget remaining;

  const MealSuggestionsView({required this.remaining, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final suggestionsAsync = ref.watch(mealSuggestionsProvider(remaining));

    return suggestionsAsync.when(
      loading: () => const SizedBox(
        height: _SuggestionCard.cardHeight,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => SizedBox(
        height: _SuggestionCard.cardHeight,
        child: Center(
          child: Text(
            'Could not load suggestions',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
      data: (suggestions) {
        if (suggestions.isEmpty) {
          return SizedBox(
            height: _SuggestionCard.cardHeight,
            child: Center(
              child: Text(
                'No suggestions for current budget',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          );
        }

        return SizedBox(
          height: _SuggestionCard.cardHeight,
          child: PageView.builder(
            controller: PageController(viewportFraction: 0.88),
            itemCount: suggestions.length,
            itemBuilder: (context, index) {
              return _SuggestionCard(
                suggestion: suggestions[index],
                index: index,
              );
            },
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Suggestion card
// ---------------------------------------------------------------------------

class _SuggestionCard extends StatelessWidget {
  static const double cardHeight = 200.0;

  final MealSuggestion suggestion;
  final int index;

  const _SuggestionCard({required this.suggestion, required this.index});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingSmall),
      child: AppTheme.glassmorphicCard(
        borderRadius: AppTheme.borderRadiusLarge,
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Name + category badge
              Row(
                children: [
                  Expanded(
                    child: Text(
                      suggestion.name,
                      style: Theme.of(context).textTheme.titleLarge,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingSmall),
                  _CategoryBadge(category: suggestion.category),
                ],
              ),
              const SizedBox(height: AppTheme.spacingSmall),

              // Calories
              Text(
                '${suggestion.calories.toStringAsFixed(0)} kcal',
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const Spacer(),

              // Macro breakdown row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _MacroChip(
                    label: 'Protein',
                    value: suggestion.protein,
                    color: AppTheme.proteinColor,
                  ),
                  _MacroChip(
                    label: 'Carbs',
                    value: suggestion.carbs,
                    color: AppTheme.carbsColor,
                  ),
                  _MacroChip(
                    label: 'Fats',
                    value: suggestion.fats,
                    color: AppTheme.fatsColor,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: index * 80))
        .fadeIn(duration: 300.ms)
        .slideX(begin: 0.15, end: 0, duration: 300.ms);
  }
}

// ---------------------------------------------------------------------------
// Category badge
// ---------------------------------------------------------------------------

class _CategoryBadge extends StatelessWidget {
  final MealCategory category;

  const _CategoryBadge({required this.category});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingSmall,
        vertical: AppTheme.spacingXSmall,
      ),
      decoration: BoxDecoration(
        color: _badgeColor.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
        border: Border.all(color: _badgeColor.withValues(alpha: 0.6)),
      ),
      child: Text(
        _badgeLabel,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: _badgeColor,
        ),
      ),
    );
  }

  Color get _badgeColor {
    switch (category) {
      case MealCategory.highProtein:
        return AppTheme.proteinColor;
      case MealCategory.highCarb:
        return AppTheme.carbsColor;
      case MealCategory.balanced:
        return AppTheme.accentColor;
    }
  }

  String get _badgeLabel {
    switch (category) {
      case MealCategory.highProtein:
        return 'High Protein';
      case MealCategory.highCarb:
        return 'High Carb';
      case MealCategory.balanced:
        return 'Balanced';
    }
  }
}

// ---------------------------------------------------------------------------
// Macro chip
// ---------------------------------------------------------------------------

class _MacroChip extends StatelessWidget {
  final String label;
  final double value;
  final Color color;

  const _MacroChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '${value.toStringAsFixed(0)}g',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: AppTheme.spacingXSmall),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
