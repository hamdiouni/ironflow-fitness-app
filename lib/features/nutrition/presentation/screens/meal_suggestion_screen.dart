import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_theme.dart';
import '../../domain/entities/food_item.dart';
import '../providers/nutrition_providers.dart';
import '../widgets/food_item_card.dart';

/// Screen for displaying meal suggestions based on macro targets.
///
/// Shows suggested meals with macro breakdown and allows user to select one.
class MealSuggestionScreen extends ConsumerStatefulWidget {
  final double targetCalories;
  final double targetProtein;
  final double targetCarbs;
  final double targetFat;

  const MealSuggestionScreen({
    required this.targetCalories,
    required this.targetProtein,
    required this.targetCarbs,
    required this.targetFat,
    super.key,
  });

  @override
  ConsumerState<MealSuggestionScreen> createState() =>
      _MealSuggestionScreenState();
}

class _MealSuggestionScreenState extends ConsumerState<MealSuggestionScreen> {
  @override
  Widget build(BuildContext context) {
    final suggestionsAsync = ref.watch(
      mealSuggestionsProvider(
        (
          targetCalories: widget.targetCalories,
          targetProtein: widget.targetProtein,
          targetCarbs: widget.targetCarbs,
          targetFat: widget.targetFat,
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meal Suggestions'),
      ),
      body: suggestionsAsync.when(
        data: (suggestions) => _SuggestionsContent(
          suggestions: suggestions,
          targetCalories: widget.targetCalories,
          targetProtein: widget.targetProtein,
          targetCarbs: widget.targetCarbs,
          targetFat: widget.targetFat,
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error loading suggestions: $error'),
        ),
      ),
    );
  }
}

class _SuggestionsContent extends StatelessWidget {
  final List<FoodItem> suggestions;
  final double targetCalories;
  final double targetProtein;
  final double targetCarbs;
  final double targetFat;

  const _SuggestionsContent({
    required this.suggestions,
    required this.targetCalories,
    required this.targetProtein,
    required this.targetCarbs,
    required this.targetFat,
  });

  @override
  Widget build(BuildContext context) {
    if (suggestions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.restaurant_menu,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            const Text(
              'No Suggestions Found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Try adjusting your macro targets',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(AppTheme.spacingMedium),
      children: [
        // Target macros display
        AppTheme.glassmorphicCard(
          padding: const EdgeInsets.all(AppTheme.spacingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Target Macros',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _MacroDisplay(
                    label: 'Calories',
                    value: targetCalories.toStringAsFixed(0),
                    unit: 'kcal',
                  ),
                  _MacroDisplay(
                    label: 'Protein',
                    value: targetProtein.toStringAsFixed(1),
                    unit: 'g',
                  ),
                  _MacroDisplay(
                    label: 'Carbs',
                    value: targetCarbs.toStringAsFixed(1),
                    unit: 'g',
                  ),
                  _MacroDisplay(
                    label: 'Fat',
                    value: targetFat.toStringAsFixed(1),
                    unit: 'g',
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: AppTheme.spacingMedium),

        // Suggestions title
        const Text(
          'Suggested Meals',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppTheme.spacingSmall),

        // Suggestions list
        ...suggestions.asMap().entries.map((entry) {
          final food = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: AppTheme.spacingSmall),
            child: FoodItemCard(
              food: food,
              targetCalories: targetCalories,
              targetProtein: targetProtein,
              targetCarbs: targetCarbs,
              targetFat: targetFat,
              onSelect: () {
                Navigator.pop(context, food);
              },
            ),
          );
        }).toList(),
      ],
    );
  }
}

class _MacroDisplay extends StatelessWidget {
  final String label;
  final String value;
  final String unit;

  const _MacroDisplay({
    required this.label,
    required this.value,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          unit,
          style: const TextStyle(
            fontSize: 10,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }
}
