import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/theme/app_theme_tokens.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/presentation/components/app_button.dart';
import '../../../../shared/presentation/services/app_haptics.dart';
import '../../../onboarding/domain/entities/user_profile.dart' show BudgetLevel;
import '../../../onboarding/presentation/providers/onboarding_provider.dart';
import '../../domain/entities/food_item.dart';
import '../../domain/entities/food_item_full.dart';
import '../../domain/usecases/get_budget_food_alternatives_use_case.dart';
import '../providers/food_providers.dart';

/// Screen for searching and selecting food items from the authoritative USDA-verified database.
///
/// Upgraded to the Monolithic Sci-Fi design system with portion sizing,
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
      builder: (_) => _FoodDetailAndQuantitySheet(
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
      builder: (_) => _CreateCustomFoodDialog(
        onFoodCreated: (food) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Custom fuel entry "${food.name}" logged!'),
              backgroundColor: const Color(0xFF00E676),
              duration: const Duration(seconds: 2),
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
    final profileAsync = ref.watch(userProfileProvider);
    final userBudget = profileAsync.valueOrNull?.budget;

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
              'FUEL DATABASE',
              style: TextStyle(
                fontFamily: AppTypography.displayFontFamily,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
                color: tokens.textPrimary,
              ),
            ),
            Text(
              'VERIFIED NUTRITION TELEMETRY',
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
            padding: const EdgeInsets.only(right: 12),
            child: Container(
              decoration: BoxDecoration(
                color: tokens.panel,
                borderRadius: BorderRadius.circular(tokens.radiusSm),
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
                borderRadius: BorderRadius.circular(tokens.radiusMd),
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
                  hintText: 'Search 80+ USDA verified fitness staples...',
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
                _SciFiPill(
                  label: 'ALL CATEGORIES',
                  selected: search.category == null,
                  onTap: () {
                    AppHaptics.shared.selectionChanged();
                    ref.read(foodSearchProvider.notifier).setCategory(null);
                  },
                ),
                ...FoodCategory.values.map((c) => _SciFiPill(
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
                _BudgetPill(
                  label: 'ALL BUDGETS',
                  selected: search.budgetTier == null,
                  onTap: () {
                    AppHaptics.shared.selectionChanged();
                    ref.read(foodSearchProvider.notifier).setBudget(null);
                  },
                ),
                _BudgetPill(
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
                _BudgetPill(
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
                _BudgetPill(
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
                      '${foods.length} VERIFIED STAPLES AVAILABLE',
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
                      borderRadius: BorderRadius.circular(4),
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
                ? _EmptySearchState(
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
                      return _FoodListTile(
                        food: food,
                        onTap: () => _showFoodDetailSheet(food),
                      ).animate().fadeIn(
                            delay: Duration(milliseconds: (index % 15) * 15),
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

// ─────────────────────────────────────────────────────────────────────────────
// FILTER PILLS
// ─────────────────────────────────────────────────────────────────────────────

class _SciFiPill extends StatelessWidget {
  const _SciFiPill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = AppThemeTokens.of(context);

    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: selected ? tokens.cyanAccent.withValues(alpha: 0.15) : tokens.panel,
            borderRadius: BorderRadius.circular(tokens.radiusSm),
            border: Border.all(
              color: selected ? tokens.cyanAccent : tokens.borderSubtle,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontFamily: AppTypography.displayFontFamily,
                fontSize: 10,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                letterSpacing: 0.6,
                color: selected ? tokens.cyanAccent : tokens.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BudgetPill extends StatelessWidget {
  const _BudgetPill({
    required this.label,
    required this.selected,
    required this.onTap,
    this.tier,
    this.isProfileMatch = false,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final BudgetLevel? tier;
  final bool isProfileMatch;

  Color _tierColor(AppThemeTokens tokens) {
    switch (tier) {
      case BudgetLevel.low:
        return const Color(0xFF00E676);
      case BudgetLevel.medium:
        return tokens.cyanAccent;
      case BudgetLevel.high:
        return const Color(0xFFFFB300);
      case null:
        return tokens.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = AppThemeTokens.of(context);
    final color = _tierColor(tokens);

    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: selected ? color.withValues(alpha: 0.15) : tokens.panel.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(tokens.radiusSm),
            border: Border.all(
              color: selected
                  ? color
                  : (isProfileMatch ? color.withValues(alpha: 0.4) : tokens.borderSubtle),
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isProfileMatch && !selected) ...[
                Icon(Icons.star_rounded, size: 11, color: color),
                const SizedBox(width: 4),
              ],
              Text(
                label,
                style: TextStyle(
                  fontFamily: AppTypography.displayFontFamily,
                  fontSize: 9.5,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                  letterSpacing: 0.5,
                  color: selected ? color : tokens.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// FOOD LIST TILE
// ─────────────────────────────────────────────────────────────────────────────

class _FoodListTile extends StatelessWidget {
  const _FoodListTile({required this.food, required this.onTap});
  final FoodItem food;
  final VoidCallback onTap;

  IconData _categoryIcon(FoodCategory cat) {
    switch (cat) {
      case FoodCategory.protein:
        return Icons.fitness_center_rounded;
      case FoodCategory.carbs:
        return Icons.grain_rounded;
      case FoodCategory.fats:
        return Icons.opacity_rounded;
      case FoodCategory.vegetables:
        return Icons.eco_rounded;
      case FoodCategory.fruits:
        return Icons.apple_rounded;
      case FoodCategory.dairy:
        return Icons.egg_alt_rounded;
      case FoodCategory.snacks:
        return Icons.cookie_rounded;
      case FoodCategory.beverages:
        return Icons.local_cafe_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = AppThemeTokens.of(context);
    final isUsda = food.id.startsWith('usda_') || food.fdcId != null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: tokens.panel,
          borderRadius: BorderRadius.circular(tokens.radiusMd),
          border: Border.all(color: tokens.borderSubtle, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Food Image / Icon container
                ClipRRect(
                  borderRadius: BorderRadius.circular(tokens.radiusSm),
                  child: CachedNetworkImage(
                    imageUrl: food.imageUrl,
                    width: 58,
                    height: 58,
                    fit: BoxFit.cover,
                    placeholder: (_, _) => Container(
                      width: 58,
                      height: 58,
                      color: tokens.card,
                      child: Icon(_categoryIcon(food.category), color: tokens.cyanAccent, size: 24),
                    ),
                    errorWidget: (_, _, _) => Container(
                      width: 58,
                      height: 58,
                      color: tokens.card,
                      child: Icon(_categoryIcon(food.category), color: tokens.cyanAccent, size: 24),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Name, Provenance badges, and serving info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Badges row
                      Row(
                        children: [
                          if (isUsda)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                              margin: const EdgeInsets.only(right: 6),
                              decoration: BoxDecoration(
                                color: tokens.cyanAccent.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(3),
                                border: Border.all(
                                  color: tokens.cyanAccent.withValues(alpha: 0.4),
                                  width: 0.8,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.verified_rounded, size: 9, color: tokens.cyanAccent),
                                  const SizedBox(width: 3),
                                  Text(
                                    'USDA ${food.fdcId != null ? "#${food.fdcId}" : "VERIFIED"}',
                                    style: TextStyle(
                                      fontFamily: AppTypography.displayFontFamily,
                                      fontSize: 8.5,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.4,
                                      color: tokens.cyanAccent,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          _buildBudgetBadge(tokens, food.budgetTier),
                        ],
                      ),
                      const SizedBox(height: 4),

                      // Food Name
                      Text(
                        food.name,
                        style: TextStyle(
                          fontFamily: AppTypography.displayFontFamily,
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.2,
                          color: tokens.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),

                      // Serving description
                      Text(
                        food.servingDescription.isNotEmpty
                            ? food.servingDescription
                            : '${food.servingWeightGrams.toInt()}g per standard serving',
                        style: TextStyle(
                          fontSize: 11,
                          color: tokens.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                // Calories header badge
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${food.caloriesPer100g.toInt()}',
                      style: TextStyle(
                        fontFamily: AppTypography.displayFontFamily,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                        color: tokens.textPrimary,
                      ),
                    ),
                    Text(
                      'KCAL / 100G',
                      style: TextStyle(
                        fontFamily: AppTypography.displayFontFamily,
                        fontSize: 8,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                        color: tokens.textMuted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Telemetry Macro Chips Row
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: tokens.card.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(tokens.radiusSm),
                border: Border.all(color: tokens.borderSubtle.withValues(alpha: 0.5), width: 1),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _MacroTelemetryChip(
                    label: 'PROTEIN',
                    value: '${food.proteinPer100g.toStringAsFixed(1)}g',
                    color: tokens.protein,
                  ),
                  _MacroTelemetryChip(
                    label: 'CARBS',
                    value: '${food.carbsPer100g.toStringAsFixed(1)}g',
                    color: tokens.carbs,
                  ),
                  _MacroTelemetryChip(
                    label: 'FATS',
                    value: '${food.fatPer100g.toStringAsFixed(1)}g',
                    color: tokens.fats,
                  ),
                  Row(
                    children: [
                      Text(
                        'CONFIGURE',
                        style: TextStyle(
                          fontFamily: AppTypography.displayFontFamily,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                          color: tokens.cyanAccent,
                        ),
                      ),
                      const SizedBox(width: 2),
                      Icon(Icons.chevron_right_rounded, size: 14, color: tokens.cyanAccent),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetBadge(AppThemeTokens tokens, BudgetLevel tier) {
    Color color;
    String label;
    switch (tier) {
      case BudgetLevel.low:
        color = const Color(0xFF00E676);
        label = 'BUDGET \$';
        break;
      case BudgetLevel.medium:
        color = tokens.cyanAccent;
        label = 'MODERATE \$\$';
        break;
      case BudgetLevel.high:
        color = const Color(0xFFFFB300);
        label = 'PREMIUM \$\$\$';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(3),
        border: Border.all(color: color.withValues(alpha: 0.35), width: 0.8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: AppTypography.displayFontFamily,
          fontSize: 8.5,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
          color: color,
        ),
      ),
    );
  }
}

class _MacroTelemetryChip extends StatelessWidget {
  const _MacroTelemetryChip({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final tokens = AppThemeTokens.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 5,
          height: 5,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 5),
        Text(
          '$label: ',
          style: TextStyle(
            fontFamily: AppTypography.displayFontFamily,
            fontSize: 9.5,
            fontWeight: FontWeight.w600,
            color: tokens.textMuted,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontFamily: AppTypography.displayFontFamily,
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// FOOD DETAIL & QUANTITY SHEET (PORTION ENGINE + MICRONUTRIENT MATRIX)
// ─────────────────────────────────────────────────────────────────────────────

class _FoodDetailAndQuantitySheet extends ConsumerStatefulWidget {
  const _FoodDetailAndQuantitySheet({
    required this.food,
    required this.onConfirm,
  });

  final FoodItem food;
  final void Function(FoodItem food, double grams) onConfirm;

  @override
  ConsumerState<_FoodDetailAndQuantitySheet> createState() =>
      _FoodDetailAndQuantitySheetState();
}

class _FoodDetailAndQuantitySheetState
    extends ConsumerState<_FoodDetailAndQuantitySheet> {
  bool _isServingMode = true;
  double _servings = 1.0;
  double _grams = 100.0;
  late FoodItem _currentFood;
  late final TextEditingController _gramsController;

  @override
  void initState() {
    super.initState();
    _currentFood = widget.food;
    _grams = _currentFood.servingWeightGrams;
    _gramsController = TextEditingController(text: _grams.toInt().toString());
  }

  @override
  void dispose() {
    _gramsController.dispose();
    super.dispose();
  }

  void _setServings(double s) {
    AppHaptics.shared.selectionChanged();
    setState(() {
      _servings = s;
      _grams = (s * _currentFood.servingWeightGrams).roundToDouble();
      _gramsController.text = _grams.toInt().toString();
    });
  }

  void _setGrams(double g) {
    AppHaptics.shared.selectionChanged();
    setState(() {
      _grams = g;
      _servings = _currentFood.servingWeightGrams > 0
          ? double.parse((g / _currentFood.servingWeightGrams).toStringAsFixed(2))
          : 1.0;
      _gramsController.text = g.toInt().toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    final tokens = AppThemeTokens.of(context);
    final isUsda = _currentFood.id.startsWith('usda_') || _currentFood.fdcId != null;
    final macros = _currentFood.macrosForGrams(_grams);
    final micros = _currentFood.microsForGrams(_grams);

    final profileAsync = ref.watch(userProfileProvider);
    final userBudget = profileAsync.value?.budget ?? BudgetLevel.low;

    final alternatives = const GetBudgetFoodAlternativesUseCase().getAlternativesForFood(
      _currentFood,
      preferredBudget: userBudget,
      limit: 2,
    );

    return DraggableScrollableSheet(
      initialChildSize: 0.88,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: tokens.canvas,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(color: tokens.borderGlow.withValues(alpha: 0.4), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: tokens.cyanAccent.withValues(alpha: 0.08),
                blurRadius: 30,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            children: [
              // Sheet Handle
              Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 8),
                child: Center(
                  child: Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: tokens.borderSubtle,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),

              // Scrollable Sheet Content
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(20, 6, 20, 30),
                  children: [
                    // Header title & badges
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(tokens.radiusSm),
                          child: CachedNetworkImage(
                            imageUrl: _currentFood.imageUrl,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            placeholder: (_, _) => Container(
                              width: 60,
                              height: 60,
                              color: tokens.panel,
                              child: Icon(Icons.restaurant_rounded, color: tokens.cyanAccent),
                            ),
                            errorWidget: (_, _, _) => Container(
                              width: 60,
                              height: 60,
                              color: tokens.panel,
                              child: Icon(Icons.restaurant_rounded, color: tokens.cyanAccent),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  if (isUsda)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      margin: const EdgeInsets.only(right: 6),
                                      decoration: BoxDecoration(
                                        color: tokens.cyanAccent.withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(
                                          color: tokens.cyanAccent.withValues(alpha: 0.5),
                                          width: 1,
                                        ),
                                      ),
                                      child: Text(
                                        'USDA FDC #${_currentFood.fdcId ?? "VERIFIED"}',
                                        style: TextStyle(
                                          fontFamily: AppTypography.displayFontFamily,
                                          fontSize: 9,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 0.5,
                                          color: tokens.cyanAccent,
                                        ),
                                      ),
                                    ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: tokens.panel,
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(color: tokens.borderSubtle, width: 1),
                                    ),
                                    child: Text(
                                      _currentFood.category.displayName.toUpperCase(),
                                      style: TextStyle(
                                        fontFamily: AppTypography.displayFontFamily,
                                        fontSize: 9,
                                        fontWeight: FontWeight.w700,
                                        color: tokens.textSecondary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                _currentFood.name,
                                style: TextStyle(
                                  fontFamily: AppTypography.displayFontFamily,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.4,
                                  color: tokens.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Factual Scientific Description Card
                    if (_currentFood.description.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: tokens.panel,
                          borderRadius: BorderRadius.circular(tokens.radiusSm),
                          border: Border.all(color: tokens.borderSubtle, width: 1),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.info_outline_rounded, size: 14, color: tokens.cyanAccent),
                                const SizedBox(width: 6),
                                Text(
                                  'SCIENTIFIC PROFILE & BIOAVAILABILITY',
                                  style: TextStyle(
                                    fontFamily: AppTypography.displayFontFamily,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.8,
                                    color: tokens.cyanAccent,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _currentFood.description,
                              style: TextStyle(
                                fontSize: 12,
                                height: 1.45,
                                color: tokens.textSecondary,
                              ),
                            ),
                            if (_currentFood.source.isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Text(
                                'Data Provenance: ${_currentFood.source}',
                                style: TextStyle(
                                  fontFamily: AppTypography.displayFontFamily,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w600,
                                  color: tokens.textMuted,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                    ],

                    // Portion Control Engine (Mode toggle: By Serving / By Grams)
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              AppHaptics.shared.selectionChanged();
                              setState(() => _isServingMode = true);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 9),
                              decoration: BoxDecoration(
                                color: _isServingMode
                                    ? tokens.cyanAccent.withValues(alpha: 0.15)
                                    : tokens.panel,
                                borderRadius: BorderRadius.circular(tokens.radiusSm),
                                border: Border.all(
                                  color: _isServingMode ? tokens.cyanAccent : tokens.borderSubtle,
                                  width: _isServingMode ? 1.5 : 1,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  'BY STANDARD SERVING',
                                  style: TextStyle(
                                    fontFamily: AppTypography.displayFontFamily,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.6,
                                    color: _isServingMode ? tokens.cyanAccent : tokens.textMuted,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              AppHaptics.shared.selectionChanged();
                              setState(() => _isServingMode = false);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 9),
                              decoration: BoxDecoration(
                                color: !_isServingMode
                                    ? tokens.cyanAccent.withValues(alpha: 0.15)
                                    : tokens.panel,
                                borderRadius: BorderRadius.circular(tokens.radiusSm),
                                border: Border.all(
                                  color: !_isServingMode ? tokens.cyanAccent : tokens.borderSubtle,
                                  width: !_isServingMode ? 1.5 : 1,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  'CUSTOM GRAM WEIGHT',
                                  style: TextStyle(
                                    fontFamily: AppTypography.displayFontFamily,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.6,
                                    color: !_isServingMode ? tokens.cyanAccent : tokens.textMuted,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Portion Selectors
                    if (_isServingMode) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: tokens.panel,
                          borderRadius: BorderRadius.circular(tokens.radiusSm),
                          border: Border.all(color: tokens.borderSubtle, width: 1),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'PORTION DEFINITION',
                                  style: TextStyle(
                                    fontFamily: AppTypography.displayFontFamily,
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w700,
                                    color: tokens.textSecondary,
                                    letterSpacing: 0.6,
                                  ),
                                ),
                                Text(
                                  '${_grams.toInt()}g total',
                                  style: TextStyle(
                                    fontFamily: AppTypography.displayFontFamily,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: tokens.cyanAccent,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _currentFood.servingDescription,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: tokens.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [0.5, 1.0, 1.5, 2.0, 3.0].map((s) {
                                final isSelected = (_servings - s).abs() < 0.05;
                                return GestureDetector(
                                  onTap: () => _setServings(s),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? tokens.cyanAccent
                                          : tokens.card,
                                      borderRadius: BorderRadius.circular(tokens.radiusSm),
                                      border: Border.all(
                                        color: isSelected ? tokens.cyanAccent : tokens.borderSubtle,
                                        width: 1,
                                      ),
                                    ),
                                    child: Text(
                                      '${s}x',
                                      style: TextStyle(
                                        fontFamily: AppTypography.displayFontFamily,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: isSelected ? Colors.black : tokens.textPrimary,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 52,
                              decoration: BoxDecoration(
                                color: tokens.panel,
                                borderRadius: BorderRadius.circular(tokens.radiusSm),
                                border: Border.all(color: tokens.borderSubtle, width: 1),
                              ),
                              child: TextField(
                                controller: _gramsController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                style: TextStyle(
                                  fontFamily: AppTypography.displayFontFamily,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: tokens.textPrimary,
                                ),
                                decoration: InputDecoration(
                                  labelText: 'WEIGHT IN GRAMS',
                                  labelStyle: TextStyle(
                                    fontFamily: AppTypography.displayFontFamily,
                                    fontSize: 10,
                                    color: tokens.textMuted,
                                    letterSpacing: 0.6,
                                  ),
                                  suffixText: 'g',
                                  suffixStyle: TextStyle(
                                    fontFamily: AppTypography.displayFontFamily,
                                    fontWeight: FontWeight.w700,
                                    color: tokens.cyanAccent,
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                ),
                                onChanged: (v) {
                                  final parsed = double.tryParse(v);
                                  if (parsed != null && parsed > 0) {
                                    setState(() {
                                      _grams = parsed;
                                      _servings = _currentFood.servingWeightGrams > 0
                                          ? double.parse(
                                              (parsed / _currentFood.servingWeightGrams)
                                                  .toStringAsFixed(2))
                                          : 1.0;
                                    });
                                  }
                                },
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ...[50.0, 100.0, 150.0, 200.0].map((g) {
                            final isSel = (_grams - g).abs() < 1.0;
                            return Padding(
                              padding: const EdgeInsets.only(left: 4),
                              child: GestureDetector(
                                onTap: () => _setGrams(g),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
                                  decoration: BoxDecoration(
                                    color: isSel ? tokens.cyanAccent : tokens.panel,
                                    borderRadius: BorderRadius.circular(tokens.radiusSm),
                                    border: Border.all(
                                      color: isSel ? tokens.cyanAccent : tokens.borderSubtle,
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    '${g.toInt()}g',
                                    style: TextStyle(
                                      fontFamily: AppTypography.displayFontFamily,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: isSel ? Colors.black : tokens.textSecondary,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    ],
                    const SizedBox(height: 20),

                    // Scaled Macro Telemetry Gauges (Live)
                    Text(
                      'SCALED PROTOCOL MACROS (${_grams.toInt()}G)',
                      style: TextStyle(
                        fontFamily: AppTypography.displayFontFamily,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: tokens.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _MacroGaugeCard(
                          title: 'CALORIES',
                          value: macros.calories.toStringAsFixed(0),
                          unit: 'kcal',
                          color: const Color(0xFFFFD54F),
                        ),
                        const SizedBox(width: 8),
                        _MacroGaugeCard(
                          title: 'PROTEIN',
                          value: macros.protein.toStringAsFixed(1),
                          unit: 'g',
                          color: tokens.protein,
                        ),
                        const SizedBox(width: 8),
                        _MacroGaugeCard(
                          title: 'CARBS',
                          value: macros.carbs.toStringAsFixed(1),
                          unit: 'g',
                          color: tokens.carbs,
                        ),
                        const SizedBox(width: 8),
                        _MacroGaugeCard(
                          title: 'FATS',
                          value: macros.fat.toStringAsFixed(1),
                          unit: 'g',
                          color: tokens.fats,
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),

                    // Authoritative Micronutrient Matrix
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: tokens.panel,
                        borderRadius: BorderRadius.circular(tokens.radiusSm),
                        border: Border.all(color: tokens.borderSubtle, width: 1),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'EXACT MICRONUTRIENT TELEMETRY',
                                style: TextStyle(
                                  fontFamily: AppTypography.displayFontFamily,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.8,
                                  color: tokens.cyanAccent,
                                ),
                              ),
                              Text(
                                'USDA AUTHORITATIVE',
                                style: TextStyle(
                                  fontFamily: AppTypography.displayFontFamily,
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.w600,
                                  color: tokens.textMuted,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Missing measurements are explicitly flagged as "-- No data" rather than fake zeros.',
                            style: TextStyle(
                              fontSize: 10,
                              color: tokens.textMuted,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildMicrosGrid(tokens, micros),
                        ],
                      ),
                    ),

                    // Smart Budget Alternatives
                    if (alternatives.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      _BudgetAlternativesSheetSection(
                        alternatives: alternatives,
                        tokens: tokens,
                        onSelectAlternative: (alt) {
                          AppHaptics.shared.selectionChanged();
                          setState(() {
                            _currentFood = alt.food;
                            _grams = alt.scaledGrams;
                            _servings = alt.scaledServings;
                            _gramsController.text = _grams.toInt().toString();
                          });
                        },
                      ),
                    ],
                    const SizedBox(height: 26),

                    // Log Action Button
                    AppButton(
                      label: 'LOG ${_grams.toInt()}G (${macros.calories.toInt()} KCAL)',
                      icon: const Icon(Icons.check_circle_rounded, size: 20),
                      isFullWidth: true,
                      onPressed: () {
                        AppHaptics.shared.buttonPress();
                        widget.onConfirm(_currentFood, _grams);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMicrosGrid(AppThemeTokens tokens, FoodMicros? micros) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _MicroRow(
                label: 'Dietary Fiber',
                amount: micros?.fiberGrams,
                unit: 'g',
                tokens: tokens,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MicroRow(
                label: 'Total Sugars',
                amount: micros?.sugarGrams,
                unit: 'g',
                tokens: tokens,
              ),
            ),
          ],
        ),
        const Divider(height: 14, color: Colors.white10),
        Row(
          children: [
            Expanded(
              child: _MicroRow(
                label: 'Sodium',
                amount: micros?.sodiumMg,
                unit: 'mg',
                tokens: tokens,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MicroRow(
                label: 'Potassium',
                amount: micros?.potassiumMg,
                unit: 'mg',
                tokens: tokens,
              ),
            ),
          ],
        ),
        const Divider(height: 14, color: Colors.white10),
        Row(
          children: [
            Expanded(
              child: _MicroRow(
                label: 'Calcium',
                amount: micros?.calciumMg,
                unit: 'mg',
                tokens: tokens,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MicroRow(
                label: 'Iron',
                amount: micros?.ironMg,
                unit: 'mg',
                decimals: 2,
                tokens: tokens,
              ),
            ),
          ],
        ),
        const Divider(height: 14, color: Colors.white10),
        Row(
          children: [
            Expanded(
              child: _MicroRow(
                label: 'Vitamin D',
                amount: micros?.vitaminDMcg,
                unit: 'mcg',
                decimals: 1,
                tokens: tokens,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MicroRow(
                label: 'Saturated Fat',
                amount: micros?.saturatedFatGrams,
                unit: 'g',
                decimals: 1,
                tokens: tokens,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MicroRow extends StatelessWidget {
  const _MicroRow({
    required this.label,
    required this.amount,
    required this.unit,
    required this.tokens,
    this.decimals = 0,
  });

  final String label;
  final double? amount;
  final String unit;
  final AppThemeTokens tokens;
  final int decimals;

  @override
  Widget build(BuildContext context) {
    final hasData = amount != null;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: tokens.textSecondary,
          ),
        ),
        Text(
          hasData
              ? '${decimals == 0 ? amount!.toStringAsFixed(0) : amount!.toStringAsFixed(decimals)} $unit'
              : '-- No data',
          style: TextStyle(
            fontFamily: AppTypography.displayFontFamily,
            fontSize: 10.5,
            fontWeight: hasData ? FontWeight.w700 : FontWeight.w500,
            color: hasData ? tokens.textPrimary : tokens.textMuted,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }
}

class _BudgetAlternativesSheetSection extends StatelessWidget {
  const _BudgetAlternativesSheetSection({
    required this.alternatives,
    required this.tokens,
    required this.onSelectAlternative,
  });

  final List<BudgetFoodAlternative> alternatives;
  final AppThemeTokens tokens;
  final void Function(BudgetFoodAlternative) onSelectAlternative;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: tokens.panel,
        borderRadius: BorderRadius.circular(tokens.radiusSm),
        border: Border.all(
          color: const Color(0xFF00E676).withValues(alpha: 0.35),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.swap_horiz_rounded, size: 16, color: const Color(0xFF00E676)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'SMART BUDGET-ALIGNED ALTERNATIVES',
                  style: TextStyle(
                    fontFamily: AppTypography.displayFontFamily,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: const Color(0xFF00E676),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Equi-macro swaps aligned with your budget protocol with verified nutritional provenance.',
            style: TextStyle(
              fontSize: 10.5,
              color: tokens.textMuted,
            ),
          ),
          const SizedBox(height: 12),
          ...alternatives.map((alt) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: tokens.card,
                borderRadius: BorderRadius.circular(tokens.radiusSm),
                border: Border.all(color: tokens.borderSubtle, width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          alt.food.name,
                          style: TextStyle(
                            fontFamily: AppTypography.displayFontFamily,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: tokens.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: alt.savingsBadge.contains('SAVE')
                              ? const Color(0xFF00E676).withValues(alpha: 0.15)
                              : tokens.cyanAccent.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: Text(
                          alt.savingsBadge,
                          style: TextStyle(
                            fontFamily: AppTypography.displayFontFamily,
                            fontSize: 8.5,
                            fontWeight: FontWeight.w700,
                            color: alt.savingsBadge.contains('SAVE')
                                ? const Color(0xFF00E676)
                                : tokens.cyanAccent,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Portion: ${alt.scaledGrams.toInt()}g (${alt.scaledServings}x) • ${alt.scaledMacros.calories.toInt()} kcal • ${alt.scaledMacros.protein.toStringAsFixed(1)}g P',
                    style: TextStyle(
                      fontFamily: AppTypography.displayFontFamily,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: tokens.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    alt.rationale,
                    style: TextStyle(
                      fontSize: 10,
                      color: tokens.textMuted,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () => onSelectAlternative(alt),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: tokens.cyanAccent.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: tokens.cyanAccent.withValues(alpha: 0.6),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check_rounded, size: 12, color: tokens.cyanAccent),
                            const SizedBox(width: 4),
                            Text(
                              'SWITCH TO THIS FOOD',
                              style: TextStyle(
                                fontFamily: AppTypography.displayFontFamily,
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                                color: tokens.cyanAccent,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _MacroGaugeCard extends StatelessWidget {
  const _MacroGaugeCard({
    required this.title,
    required this.value,
    required this.unit,
    required this.color,
  });

  final String title;
  final String value;
  final String unit;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final tokens = AppThemeTokens.of(context);

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        decoration: BoxDecoration(
          color: tokens.panel,
          borderRadius: BorderRadius.circular(tokens.radiusSm),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
        ),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                fontFamily: AppTypography.displayFontFamily,
                fontSize: 8.5,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.6,
                color: tokens.textMuted,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontFamily: AppTypography.displayFontFamily,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                    color: color,
                  ),
                ),
                const SizedBox(width: 2),
                Text(
                  unit,
                  style: TextStyle(
                    fontFamily: AppTypography.displayFontFamily,
                    fontSize: 8.5,
                    fontWeight: FontWeight.w600,
                    color: color.withValues(alpha: 0.8),
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

// ─────────────────────────────────────────────────────────────────────────────
// EMPTY SEARCH STATE
// ─────────────────────────────────────────────────────────────────────────────

class _EmptySearchState extends StatelessWidget {
  const _EmptySearchState({required this.query, required this.onReset});
  final String query;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final tokens = AppThemeTokens.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: tokens.panel,
                shape: BoxShape.circle,
                border: Border.all(color: tokens.borderSubtle, width: 1),
              ),
              child: Icon(Icons.search_off_rounded, size: 36, color: tokens.textMuted),
            ),
            const SizedBox(height: 16),
            Text(
              'NO FOODS FOUND',
              style: TextStyle(
                fontFamily: AppTypography.displayFontFamily,
                fontSize: 15,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.6,
                color: tokens.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              query.isNotEmpty
                  ? 'No verified food matches "$query" under the active category/budget filter.'
                  : 'No verified items found with active filter selections.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: tokens.textSecondary, height: 1.4),
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: onReset,
              icon: Icon(Icons.refresh_rounded, size: 16, color: tokens.cyanAccent),
              label: Text(
                'RESET FILTERS',
                style: TextStyle(
                  fontFamily: AppTypography.displayFontFamily,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: tokens.cyanAccent,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CUSTOM FOOD DIALOG
// ─────────────────────────────────────────────────────────────────────────────

class _CreateCustomFoodDialog extends ConsumerStatefulWidget {
  const _CreateCustomFoodDialog({required this.onFoodCreated});
  final void Function(FoodItemFull food) onFoodCreated;

  @override
  ConsumerState<_CreateCustomFoodDialog> createState() =>
      _CreateCustomFoodDialogState();
}

class _CreateCustomFoodDialogState
    extends ConsumerState<_CreateCustomFoodDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _proteinController = TextEditingController();
  final _carbsController = TextEditingController();
  final _fatController = TextEditingController();
  FoodCategory _selectedCategory = FoodCategory.protein;
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    super.dispose();
  }

  String? _validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName required';
    }
    return null;
  }

  String? _validateNumber(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName required';
    }
    final number = double.tryParse(value);
    if (number == null) return 'Invalid number';
    if (number < 0) return 'Cannot be negative';
    return null;
  }

  Future<void> _saveCustomFood() async {
    if (!_formKey.currentState!.validate()) return;
    AppHaptics.shared.buttonPress();
    setState(() => _isSaving = true);

    try {
      final customFood = FoodItemFull(
        id: 'custom_${const Uuid().v4()}',
        name: _nameController.text.trim(),
        category: _selectedCategory.displayName.toLowerCase(),
        imageUrl: '',
        macros: MacrosPer100g(
          calories: double.parse(_caloriesController.text),
          protein: double.parse(_proteinController.text),
          carbs: double.parse(_carbsController.text),
          fats: double.parse(_fatController.text),
        ),
        micros: const MicrosPer100g(
          fiber: 0,
          sugar: 0,
          sodium: 0,
          potassium: 0,
        ),
        vitamins: const VitaminsPer100g(
          vitaminA: 0,
          vitaminB: 0,
          vitaminC: 0,
          vitaminD: 0,
          vitaminE: 0,
        ),
        minerals: const MineralsPer100g(
          calcium: 0,
          iron: 0,
          magnesium: 0,
          zinc: 0,
        ),
      );

      await ref.read(customFoodsProvider.notifier).addCustomFood(customFood);

      if (mounted) {
        Navigator.pop(context);
        widget.onFoodCreated(customFood);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save fuel: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = AppThemeTokens.of(context);

    return Dialog(
      backgroundColor: tokens.canvas,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(tokens.radiusMd),
        side: BorderSide(color: tokens.borderGlow.withValues(alpha: 0.5), width: 1.5),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'NEW FUEL ENTRY',
                    style: TextStyle(
                      fontFamily: AppTypography.displayFontFamily,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                      color: tokens.textPrimary,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close_rounded, color: tokens.textMuted, size: 20),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Define nutritional values per 100 grams.',
                style: TextStyle(fontSize: 11, color: tokens.textSecondary),
              ),
              const SizedBox(height: 16),

              // Name
              TextFormField(
                controller: _nameController,
                style: TextStyle(color: tokens.textPrimary, fontSize: 13),
                decoration: _dialogInputDecoration(tokens, 'Food Name', 'e.g. Homemade Protein Bar'),
                validator: (v) => _validateRequired(v, 'Name'),
              ),
              const SizedBox(height: 12),

              // Category selector
              DropdownButtonFormField<FoodCategory>(
                value: _selectedCategory,
                dropdownColor: tokens.panel,
                style: TextStyle(color: tokens.textPrimary, fontSize: 13),
                decoration: _dialogInputDecoration(tokens, 'Category', ''),
                items: FoodCategory.values.map((c) {
                  return DropdownMenuItem(
                    value: c,
                    child: Text(c.displayName),
                  );
                }).toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _selectedCategory = v);
                },
              ),
              const SizedBox(height: 12),

              // Calories
              TextFormField(
                controller: _caloriesController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: TextStyle(color: tokens.textPrimary, fontSize: 13),
                decoration: _dialogInputDecoration(tokens, 'Calories per 100g', 'kcal'),
                validator: (v) => _validateNumber(v, 'Calories'),
              ),
              const SizedBox(height: 12),

              // Macros row
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _proteinController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: TextStyle(color: tokens.protein, fontSize: 13, fontWeight: FontWeight.w700),
                      decoration: _dialogInputDecoration(tokens, 'Protein (g)', 'g'),
                      validator: (v) => _validateNumber(v, 'Protein'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _carbsController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: TextStyle(color: tokens.carbs, fontSize: 13, fontWeight: FontWeight.w700),
                      decoration: _dialogInputDecoration(tokens, 'Carbs (g)', 'g'),
                      validator: (v) => _validateNumber(v, 'Carbs'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _fatController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: TextStyle(color: tokens.fats, fontSize: 13, fontWeight: FontWeight.w700),
                      decoration: _dialogInputDecoration(tokens, 'Fat (g)', 'g'),
                      validator: (v) => _validateNumber(v, 'Fat'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'CANCEL',
                        style: TextStyle(
                          fontFamily: AppTypography.displayFontFamily,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: tokens.textMuted,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: AppButton(
                      label: _isSaving ? 'SAVING...' : 'SAVE FUEL',
                      icon: const Icon(Icons.check_rounded, size: 18),
                      onPressed: _isSaving ? null : _saveCustomFood,
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

  InputDecoration _dialogInputDecoration(AppThemeTokens tokens, String label, String hint) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        fontFamily: AppTypography.displayFontFamily,
        fontSize: 10,
        color: tokens.textMuted,
        letterSpacing: 0.5,
      ),
      hintText: hint,
      hintStyle: TextStyle(color: tokens.textMuted.withValues(alpha: 0.5), fontSize: 12),
      filled: true,
      fillColor: tokens.panel,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(tokens.radiusSm),
        borderSide: BorderSide(color: tokens.borderSubtle, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(tokens.radiusSm),
        borderSide: BorderSide(color: tokens.cyanAccent, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(tokens.radiusSm),
        borderSide: BorderSide(color: tokens.error, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(tokens.radiusSm),
        borderSide: BorderSide(color: tokens.error, width: 1.5),
      ),
    );
  }
}
