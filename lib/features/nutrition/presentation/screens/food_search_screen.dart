import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:progression_tracker/core/theme/app_theme_tokens.dart';
import 'package:progression_tracker/core/theme/app_typography.dart';
import 'package:progression_tracker/shared/presentation/services/app_haptics.dart';
import 'package:progression_tracker/features/onboarding/domain/entities/user_profile.dart' show BudgetLevel;
import 'package:progression_tracker/features/onboarding/presentation/providers/onboarding_provider.dart';
import 'package:progression_tracker/features/nutrition/domain/entities/food_item.dart';
import 'package:progression_tracker/features/nutrition/domain/services/food_catalog.dart';
import 'package:progression_tracker/features/nutrition/presentation/providers/food_providers.dart';
import '../widgets/food_search/barcode_scanner_sheet.dart';
import '../widgets/food_search/create_custom_food_dialog.dart';
import '../widgets/food_search/food_detail_quantity_sheet.dart';
import '../widgets/food_search/food_search_pills_and_tile.dart';

/// Screen for searching and selecting food items from the authoritative USDA-verified database.
///
/// Upgraded to the Stripe design system with portion sizing,
/// factual descriptions, verifiable provenance, budget filtering, and
/// true micronutrient telemetry (flagging missing values as "No data").
class FoodSearchScreen extends ConsumerStatefulWidget {
  const FoodSearchScreen({super.key, required this.onFoodLogged});
  final void Function(FoodItem food, double grams) onFoodLogged;

  @override
  ConsumerState<FoodSearchScreen> createState() => _FoodSearchScreenState();
}

class _FoodSearchScreenState extends ConsumerState<FoodSearchScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showFoodDetailSheet(FoodItem food) {
    AppHaptics.shared.selectionChanged();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FoodDetailAndQuantitySheet(
        food: food,
        onConfirm: (selectedFood, grams) {
          Navigator.pop(context);
          widget.onFoodLogged(selectedFood, grams);
        },
      ),
    );
  }

  void _showCreateCustomFoodDialog() {
    AppHaptics.shared.buttonPress();
    showDialog(
      context: context,
      builder: (_) => CreateCustomFoodDialog(
        onFoodCreated: (food) {
          final tokens = AppThemeTokens.of(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Saved "${food.name}" to your personal food library. Search above to log a portion.',
                style: TextStyle(color: tokens.onAccent),
              ),
              backgroundColor: tokens.success,
              duration: const Duration(seconds: 3),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tokens = AppThemeTokens.of(context);
    final foods = ref.watch(filteredFoodProvider);
    final search = ref.watch(foodSearchProvider);
    final customCount = ref.watch(customFoodsProvider).valueOrNull?.length ?? 0;
    final totalCatalogCount =
        (FoodCatalog.isLoaded ? FoodCatalog.foods.length : 0) + customCount;
    final profileAsync = ref.watch(userProfileProvider);
    final userBudget = profileAsync.valueOrNull?.budget;
    final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;

    return Scaffold(
      backgroundColor: tokens.canvas,
      appBar: AppBar(
        backgroundColor: tokens.canvas,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: tokens.textPrimary, size: 20),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'Back to Nutrition',
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'FOOD DATABASE',
              style: TextStyle(
                fontFamily: AppTypography.displayFontFamily,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
                color: tokens.textPrimary,
              ),
            ),
            Text(
              'USDA & CUSTOM FOODS',
              style: TextStyle(
                fontFamily: AppTypography.displayFontFamily,
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
                color: tokens.cyanAccent,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Container(
              decoration: BoxDecoration(
                color: tokens.panel,
                borderRadius: BorderRadius.circular(tokens.radiusPill),
                border: Border.all(color: tokens.borderSubtle, width: 1),
              ),
              child: IconButton(
                key: const Key('food_search_barcode_button'),
                icon: Icon(
                  Icons.qr_code_scanner_rounded,
                  color: tokens.kineticAccent,
                  size: 20,
                ),
                onPressed: () {
                  AppHaptics.shared.buttonPress();
                  showBarcodeScannerSheet(
                    context,
                    onFoodFound: _showFoodDetailSheet,
                  );
                },
                tooltip: 'Scan Barcode (Open Food Facts)',
                constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                padding: EdgeInsets.zero,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Container(
              decoration: BoxDecoration(
                color: tokens.panel,
                borderRadius: BorderRadius.circular(tokens.radiusPill),
                border: Border.all(color: tokens.borderSubtle, width: 1),
              ),
              child: IconButton(
                icon: Icon(Icons.add_circle_outline_rounded, color: tokens.cyanAccent, size: 20),
                onPressed: _showCreateCustomFoodDialog,
                tooltip: 'Create Custom Food',
                constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                padding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(64),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: tokens.panel,
                borderRadius: BorderRadius.circular(tokens.radiusPill),
                border: Border.all(
                  color: search.query.isNotEmpty ? tokens.cyanAccent : tokens.borderSubtle,
                  width: 1,
                ),
              ),
              child: TextField(
                controller: _searchController,
                autofocus: false,
                style: TextStyle(color: tokens.textPrimary, fontSize: 14),
                onChanged: (v) => ref.read(foodSearchProvider.notifier).setQuery(v),
                decoration: InputDecoration(
                  hintText: totalCatalogCount > 0
                      ? 'Search $totalCatalogCount verified & custom foods...'
                      : 'Search verified & custom foods...',
                  hintStyle: TextStyle(
                    color: tokens.textMuted,
                    fontSize: 13,
                    fontFamily: AppTypography.bodyFontFamily,
                  ),
                  prefixIcon: Icon(Icons.search_rounded, color: tokens.cyanAccent, size: 20),
                  suffixIcon: search.query.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.close_rounded, color: tokens.textMuted, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            ref.read(foodSearchProvider.notifier).setQuery('');
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Category filter strip
          SizedBox(
            height: 38,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                FoodCategoryPill(
                  label: 'ALL CATEGORIES',
                  selected: search.category == null,
                  onTap: () {
                    AppHaptics.shared.selectionChanged();
                    ref.read(foodSearchProvider.notifier).setCategory(null);
                  },
                ),
                ...FoodCategory.values.map((c) => FoodCategoryPill(
                      label: c.displayName.toUpperCase(),
                      selected: search.category == c,
                      onTap: () {
                        AppHaptics.shared.selectionChanged();
                        ref.read(foodSearchProvider.notifier).setCategory(
                              search.category == c ? null : c,
                            );
                      },
                    )),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Budget tier filter strip
          SizedBox(
            height: 34,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                FoodBudgetPill(
                  label: 'ALL BUDGETS',
                  selected: search.budgetTier == null,
                  onTap: () {
                    AppHaptics.shared.selectionChanged();
                    ref.read(foodSearchProvider.notifier).setBudget(null);
                  },
                ),
                FoodBudgetPill(
                  label: 'BUDGET \$',
                  tier: BudgetLevel.low,
                  isProfileMatch: userBudget == BudgetLevel.low,
                  selected: search.budgetTier == BudgetLevel.low,
                  onTap: () {
                    AppHaptics.shared.selectionChanged();
                    ref.read(foodSearchProvider.notifier).setBudget(
                          search.budgetTier == BudgetLevel.low ? null : BudgetLevel.low,
                        );
                  },
                ),
                FoodBudgetPill(
                  label: 'MODERATE \$\$',
                  tier: BudgetLevel.medium,
                  isProfileMatch: userBudget == BudgetLevel.medium,
                  selected: search.budgetTier == BudgetLevel.medium,
                  onTap: () {
                    AppHaptics.shared.selectionChanged();
                    ref.read(foodSearchProvider.notifier).setBudget(
                          search.budgetTier == BudgetLevel.medium ? null : BudgetLevel.medium,
                        );
                  },
                ),
                FoodBudgetPill(
                  label: 'PREMIUM \$\$\$',
                  tier: BudgetLevel.high,
                  isProfileMatch: userBudget == BudgetLevel.high,
                  selected: search.budgetTier == BudgetLevel.high,
                  onTap: () {
                    AppHaptics.shared.selectionChanged();
                    ref.read(foodSearchProvider.notifier).setBudget(
                          search.budgetTier == BudgetLevel.high ? null : BudgetLevel.high,
                        );
                  },
                ),
              ],
            ),
          ),

          // Count and telemetry summary row
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: tokens.cyanAccent,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: tokens.cyanAccent.withValues(alpha: 0.5),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${foods.length} FOODS AVAILABLE',
                      style: TextStyle(
                        fontFamily: AppTypography.displayFontFamily,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: tokens.textSecondary,
                      ),
                    ),
                  ],
                ),
                if (userBudget != null && search.budgetTier == null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: tokens.cyanAccent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(tokens.radiusPill),
                      border: Border.all(
                        color: tokens.cyanAccent.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      'PROFILE: ${userBudget.name.toUpperCase()}',
                      style: TextStyle(
                        fontFamily: AppTypography.displayFontFamily,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: tokens.cyanAccent,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Food Items List
          Expanded(
            child: foods.isEmpty
                ? EmptyFoodSearchState(
                    query: search.query,
                    onReset: () {
                      _searchController.clear();
                      ref.read(foodSearchProvider.notifier).setQuery('');
                      ref.read(foodSearchProvider.notifier).setCategory(null);
                      ref.read(foodSearchProvider.notifier).setBudget(null);
                    },
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    itemCount: foods.length,
                    itemBuilder: (context, index) {
                      final food = foods[index];
                      final tile = FoodListTile(
                        food: food,
                        onTap: () => _showFoodDetailSheet(food),
                      );
                      if (reduceMotion) return tile;
                      return tile.animate().fadeIn(
                            delay: Duration(milliseconds: index.clamp(0, 8) * 15),
                            duration: const Duration(milliseconds: 150),
                          );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
