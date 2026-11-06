import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:progression_tracker/core/constants/app_theme.dart';
import 'package:progression_tracker/core/utils/error_handler.dart';
import 'package:progression_tracker/shared/presentation/services/app_haptics.dart';
import 'package:progression_tracker/features/nutrition/domain/entities/meal.dart';
import 'package:progression_tracker/features/nutrition/presentation/providers/nutrition_providers.dart';

// ---------------------------------------------------------------------------
// Recent foods quick-add widget (Batch 5)
// ---------------------------------------------------------------------------

class RecentFoodsQuickAdd extends ConsumerWidget {
  const RecentFoodsQuickAdd({
    super.key,
    required this.today,
  });

  final DateTime today;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recentAsync = ref.watch(recentFoodsProvider);
    final tokens = AppThemeTokens.of(context);

    return recentAsync.when(
      data: (foods) {
        if (foods.isEmpty) {
          return const SizedBox.shrink();
        }
        return Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingMedium,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.bolt_rounded,
                      size: 15,
                      color: tokens.kineticAccent,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'QUICK RE-LOG RECENT',
                      style: TextStyle(
                        fontFamily: AppTypography.displayFontFamily,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.0,
                        color: tokens.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 56,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingMedium,
                  ),
                  scrollDirection: Axis.horizontal,
                  itemCount: foods.length,
                  separatorBuilder: (_, index) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final meal = foods[index];
                    return _RecentFoodChip(
                      meal: meal,
                      tokens: tokens,
                      onTap: () => _logRecentMeal(context, ref, meal),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (err, stack) => const SizedBox.shrink(),
    );
  }

  Future<void> _logRecentMeal(
    BuildContext context,
    WidgetRef ref,
    Meal recentMeal,
  ) async {
    AppHaptics.shared.selectionChanged();
    final newMeal = Meal.create(
      foodItemId: recentMeal.foodItemId,
      name: recentMeal.name,
      macros: recentMeal.macros,
      micros: recentMeal.micros,
      vitamins: recentMeal.vitamins,
      minerals: recentMeal.minerals,
    );

    try {
      await ref
          .read(dailyNutritionSummaryProvider(nutritionDayKey(today)).notifier)
          .addMeal(newMeal);

      if (context.mounted) {
        final tokens = AppThemeTokens.of(context);
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Re-logged ${newMeal.name}'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: tokens.panel,
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'UNDO',
              textColor: tokens.kineticAccent,
              onPressed: () async {
                AppHaptics.shared.buttonPress();
                await ref
                    .read(dailyNutritionSummaryProvider(nutritionDayKey(today)).notifier)
                    .deleteMeal(newMeal.id);
                ref.invalidate(recentFoodsProvider);
              },
            ),
          ),
        );
      }
    } catch (e, stack) {
      if (context.mounted) {
        ErrorHandler.handleError(context, e, stack);
      }
    }
  }
}

class _RecentFoodChip extends StatelessWidget {
  const _RecentFoodChip({
    required this.meal,
    required this.tokens,
    required this.onTap,
  });

  final Meal meal;
  final AppThemeTokens tokens;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(tokens.radiusPill),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: tokens.card,
            borderRadius: BorderRadius.circular(tokens.radiusPill),
            border: Border.all(
              color: tokens.borderSubtle,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: tokens.kineticAccent.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.add_rounded,
                  size: 14,
                  color: tokens.kineticAccent,
                ),
              ),
              const SizedBox(width: 8),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 160),
                    child: Text(
                      meal.name,
                      style: TextStyle(
                        fontFamily: AppTypography.displayFontFamily,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: tokens.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    '${meal.calories.round()} kcal • ${meal.protein.round()}g P',
                    style: TextStyle(
                      fontFamily: AppTypography.displayFontFamily,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: tokens.textMuted,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
