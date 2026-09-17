import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../domain/entities/food_item_full.dart';
import '../../domain/usecases/get_food_alternatives_use_case.dart';
import '../providers/nutrition_providers.dart';

/// Widget to display food alternatives in a horizontal scrollable list.
///
/// Shows alternatives with:
/// - Food image
/// - Food name
/// - Macro comparison (calories, protein, carbs, fats)
/// - Quality score badge
/// - One-tap swap button
///
/// **Validates: Requirements 3.3**
class FoodAlternativesWidget extends ConsumerWidget {
  final FoodItemFull selectedFood;
  final Function(FoodItemFull) onSwap;

  const FoodAlternativesWidget({
    super.key,
    required this.selectedFood,
    required this.onSwap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alternativesAsync = ref.watch(foodAlternativesProvider(selectedFood));

    return alternativesAsync.when(
      loading: () => Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: SizedBox(
          height: 180,
          child: Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
            ),
          ),
        ),
      ),
      error: (error, stackTrace) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: SizedBox(
          height: 180,
          child: Center(
            child: Text(
              'Error loading alternatives',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ),
      ),
      data: (alternatives) {
        if (alternatives.isEmpty) {
          return SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Text(
                'Similar Foods',
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ),
            SizedBox(
              height: 180,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: alternatives.length,
                itemBuilder: (context, index) {
                  final alternative = alternatives[index];
                  return _AlternativeFoodCard(
                    alternative: alternative,
                    onSwap: onSwap,
                  ).animate().fadeIn(
                        delay: Duration(milliseconds: index * 50),
                        duration: const Duration(milliseconds: 200),
                      );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Card widget for displaying a single food alternative.
class _AlternativeFoodCard extends StatelessWidget {
  final FoodAlternative alternative;
  final Function(FoodItemFull) onSwap;

  const _AlternativeFoodCard({
    required this.alternative,
    required this.onSwap,
  });

  @override
  Widget build(BuildContext context) {
    final food = alternative.food;
    final qualityScore = alternative.qualityScore;

    // Determine quality color based on score
    final qualityColor = qualityScore >= 95
        ? Colors.green
        : qualityScore >= 85
            ? Colors.amber
            : Colors.orange;

    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: GestureDetector(
        onTap: () => onSwap(food),
        child: Container(
          width: 140,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.1),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image with quality badge
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                    child: CachedNetworkImage(
                      imageUrl: food.imageUrl,
                      width: double.infinity,
                      height: 80,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.white.withValues(alpha: 0.1),
                        child: const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.white.withValues(alpha: 0.1),
                        child: const Icon(Icons.image_not_supported),
                      ),
                    ),
                  ),
                  // Quality score badge
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: qualityColor.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${qualityScore.toStringAsFixed(0)}%',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                  ),
                ],
              ),
              // Food name
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
                child: Text(
                  food.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
              // Macro comparison
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _MacroComparisonRow(
                      label: 'Cal',
                      value: food.macros.calories.toStringAsFixed(0),
                    ),
                    _MacroComparisonRow(
                      label: 'P',
                      value: food.macros.protein.toStringAsFixed(1),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              // Swap button
              Padding(
                padding: const EdgeInsets.all(8),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => onSwap(food),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      backgroundColor: Theme.of(context).colorScheme.primary,
                    ),
                    child: Text(
                      'Swap',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Row showing macro comparison between foods.
class _MacroComparisonRow extends StatelessWidget {
  final String label;
  final String value;

  const _MacroComparisonRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Colors.white.withValues(alpha: 0.6),
              ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}
