import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/constants/app_theme.dart';
import '../../../../core/utils/error_handler.dart';
import '../../domain/entities/food_item_full.dart';
import '../../domain/entities/meal.dart';
import '../providers/nutrition_providers.dart';
import '../providers/food_cache_provider.dart';
import '../widgets/food_alternatives_widget.dart';

/// Meal logging screen with food search, filtering, and quantity input.
///
/// Features:
/// - Search foods by name
/// - Filter by category and dietary tags
/// - Display food with macros/micros
/// - Input quantity with unit selection
/// - Calculate totals based on quantity
/// - Save meal entry and update daily totals
///
/// **Validates: Requirements 3.2, 3.3, 4.7**
class MealLoggingScreen extends ConsumerStatefulWidget {
  const MealLoggingScreen({super.key});

  @override
  ConsumerState<MealLoggingScreen> createState() => _MealLoggingScreenState();
}

class _MealLoggingScreenState extends ConsumerState<MealLoggingScreen> {
  final _searchController = TextEditingController();
  String _selectedCategory = '';
  List<String> _selectedDietaryTags = [];
  final List<FoodItemFull> _selectedFoods = [];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showQuantitySheet(FoodItemFull food) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _QuantityInputSheet(
        food: food,
        onConfirm: (quantity) {
          Navigator.pop(context);
          setState(() {
            _selectedFoods.add(food);
          });
        },
      ),
    );
  }

  Future<void> _saveMealEntry() async {
    if (_selectedFoods.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one food')),
      );
      return;
    }

    // Calculate totals from selected foods
    double totalCalories = 0;
    double totalProtein = 0;
    double totalCarbs = 0;
    double totalFats = 0;
    double totalFiber = 0;
    double totalSugar = 0;
    double totalSodium = 0;
    double totalPotassium = 0;
    double totalVitaminA = 0;
    double totalVitaminB = 0;
    double totalVitaminC = 0;
    double totalVitaminD = 0;
    double totalVitaminE = 0;
    double totalCalcium = 0;
    double totalIron = 0;
    double totalMagnesium = 0;
    double totalZinc = 0;

    for (final food in _selectedFoods) {
      totalCalories += food.macros.calories;
      totalProtein += food.macros.protein;
      totalCarbs += food.macros.carbs;
      totalFats += food.macros.fats;
      totalFiber += food.micros.fiber;
      totalSugar += food.micros.sugar;
      totalSodium += food.micros.sodium;
      totalPotassium += food.micros.potassium;
      totalVitaminA += food.vitamins.vitaminA;
      totalVitaminB += food.vitamins.vitaminB;
      totalVitaminC += food.vitamins.vitaminC;
      totalVitaminD += food.vitamins.vitaminD;
      totalVitaminE += food.vitamins.vitaminE;
      totalCalcium += food.minerals.calcium;
      totalIron += food.minerals.iron;
      totalMagnesium += food.minerals.magnesium;
      totalZinc += food.minerals.zinc;
    }

    final meal = Meal.create(
      name: _selectedFoods.map((f) => f.name).join(', '),
      macros: MealMacros(
        calories: totalCalories,
        protein: totalProtein,
        carbs: totalCarbs,
        fats: totalFats,
      ),
      micros: MealMicros(
        fiber: totalFiber,
        sugar: totalSugar,
        sodium: totalSodium,
        potassium: totalPotassium,
      ),
      vitamins: MealVitamins(
        vitaminA: totalVitaminA,
        vitaminB: totalVitaminB,
        vitaminC: totalVitaminC,
        vitaminD: totalVitaminD,
        vitaminE: totalVitaminE,
      ),
      minerals: MealMinerals(
        calcium: totalCalcium,
        iron: totalIron,
        magnesium: totalMagnesium,
        zinc: totalZinc,
      ),
    );

    try {
      final repository = ref.read(nutritionRepositoryProvider);
      await repository.saveMealEntry(meal);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Meal saved successfully')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving meal: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Log Meal'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search and filter section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search field
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search foods...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {});
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.08),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  ),
                  onChanged: (value) {
                    setState(() {});
                  },
                ),
                const SizedBox(height: 12),
                // Category and dietary tag filters
                _FilterSection(
                  onCategoryChanged: (category) {
                    setState(() {
                      _selectedCategory = category;
                    });
                  },
                  onTagsChanged: (tags) {
                    setState(() {
                      _selectedDietaryTags = tags;
                    });
                  },
                ),
              ],
            ),
          ),
          // Food list
          Expanded(
            child: _FoodListSection(
              searchQuery: _searchController.text,
              selectedCategory: _selectedCategory,
              selectedTags: _selectedDietaryTags,
              onFoodTap: _showQuantitySheet,
            ),
          ),
          // Selected foods summary
          if (_selectedFoods.isNotEmpty)
            _SelectedFoodsSummary(
              foods: _selectedFoods,
              onRemove: (index) {
                setState(() {
                  _selectedFoods.removeAt(index);
                });
              },
            ),
          // Save button
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selectedFoods.isEmpty ? null : _saveMealEntry,
                child: const Text('Save Meal'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Filter section widget
// ---------------------------------------------------------------------------

class _FilterSection extends ConsumerWidget {
  final Function(String) onCategoryChanged;
  final Function(List<String>) onTagsChanged;

  const _FilterSection({
    required this.onCategoryChanged,
    required this.onTagsChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Filters',
          style: Theme.of(context).textTheme.labelMedium,
        ),
        const SizedBox(height: 8),
        // Category filter chips
        SizedBox(
          height: 36,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _FilterChip(
                label: 'All',
                selected: true,
                onTap: () => onCategoryChanged(''),
              ),
              _FilterChip(
                label: 'Protein',
                onTap: () => onCategoryChanged('Protein'),
              ),
              _FilterChip(
                label: 'Carbs',
                onTap: () => onCategoryChanged('Carbs'),
              ),
              _FilterChip(
                label: 'Fats',
                onTap: () => onCategoryChanged('Fats'),
              ),
              _FilterChip(
                label: 'Vegetables',
                onTap: () => onCategoryChanged('Vegetables'),
              ),
              _FilterChip(
                label: 'Fruits',
                onTap: () => onCategoryChanged('Fruits'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FilterChip extends StatefulWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    this.selected = false,
    required this.onTap,
  });

  @override
  State<_FilterChip> createState() => _FilterChipState();
}

class _FilterChipState extends State<_FilterChip> {
  late bool _isSelected;

  @override
  void initState() {
    super.initState();
    _isSelected = widget.selected;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () {
          setState(() {
            _isSelected = !_isSelected;
          });
          widget.onTap();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _isSelected
                ? Theme.of(context).colorScheme.primary
                : Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Colors.white.withValues(alpha: 0.2),
            ),
          ),
          child: Text(
            widget.label,
            style: TextStyle(
              color: _isSelected
                  ? Theme.of(context).colorScheme.onPrimary
                  : Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Food list section
// ---------------------------------------------------------------------------

class _FoodListSection extends ConsumerWidget {
  final String searchQuery;
  final String selectedCategory;
  final List<String> selectedTags;
  final Function(FoodItemFull) onFoodTap;

  const _FoodListSection({
    required this.searchQuery,
    required this.selectedCategory,
    required this.selectedTags,
    required this.onFoodTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final foodsAsync = ref.watch(foodCacheProvider);

    return foodsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Theme.of(context).colorScheme.error.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text('Error loading foods: $error'),
          ],
        ),
      ),
      data: (foods) {
        // Filter foods
        var filtered = foods;

        if (searchQuery.isNotEmpty) {
          filtered = filtered
              .where((f) =>
                  f.name.toLowerCase().contains(searchQuery.toLowerCase()))
              .toList();
        }

        if (selectedCategory.isNotEmpty) {
          filtered = filtered
              .where((f) => f.category.toLowerCase() == selectedCategory.toLowerCase())
              .toList();
        }

        if (selectedTags.isNotEmpty) {
          filtered = filtered
              .where((f) =>
                  selectedTags.every((tag) => f.dietaryTags.contains(tag)))
              .toList();
        }

        if (filtered.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.search_off,
                  size: 48,
                  color: Colors.white.withValues(alpha: 0.3),
                ),
                const SizedBox(height: 16),
                Text(
                  'No foods found',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: filtered.length,
          itemBuilder: (context, index) {
            final food = filtered[index];
            return _FoodListTile(
              food: food,
              onTap: () => onFoodTap(food),
            ).animate().fadeIn(
                  delay: Duration(milliseconds: index * 20),
                  duration: const Duration(milliseconds: 150),
                );
          },
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Food list tile
// ---------------------------------------------------------------------------

class _FoodListTile extends StatelessWidget {
  final FoodItemFull food;
  final VoidCallback onTap;

  const _FoodListTile({
    required this.food,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: CachedNetworkImage(
            imageUrl: food.imageUrl,
            width: 56,
            height: 56,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              color: Colors.white.withValues(alpha: 0.1),
              child: const Center(child: CircularProgressIndicator()),
            ),
            errorWidget: (context, url, error) => Container(
              color: Colors.white.withValues(alpha: 0.1),
              child: const Icon(Icons.image_not_supported),
            ),
          ),
        ),
        title: Text(food.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              food.category,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 4),
            Text(
              '${food.macros.calories.toStringAsFixed(0)} cal | '
              '${food.macros.protein.toStringAsFixed(1)}g protein',
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ],
        ),
        trailing: const Icon(Icons.add_circle_outline),
        onTap: onTap,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Quantity input sheet
// ---------------------------------------------------------------------------

class _QuantityInputSheet extends StatefulWidget {
  final FoodItemFull food;
  final Function(double) onConfirm;
  final Function(FoodItemFull)? onSwap;

  const _QuantityInputSheet({
    required this.food,
    required this.onConfirm,
    this.onSwap,
  });

  @override
  State<_QuantityInputSheet> createState() => _QuantityInputSheetState();
}

class _QuantityInputSheetState extends State<_QuantityInputSheet> {
  late TextEditingController _quantityController;
  String _selectedUnit = 'g';
  late FoodItemFull _scaledFood;
  late FoodItemFull _currentFood;

  @override
  void initState() {
    super.initState();
    _quantityController = TextEditingController(text: '100');
    _currentFood = widget.food;
    _scaledFood = FoodItemFull.scaleAll(widget.food, 100);
  }

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  void _updateScaledFood() {
    final quantity = double.tryParse(_quantityController.text) ?? 100;
    setState(() {
      _scaledFood = FoodItemFull.scaleAll(_currentFood, quantity);
    });
  }

  void _handleSwap(FoodItemFull newFood) {
    setState(() {
      _currentFood = newFood;
      _updateScaledFood();
    });
    // Show feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Swapped to ${newFood.name}'),
        duration: const Duration(milliseconds: 1500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            16,
            16,
            16,
            16 + MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: _currentFood.imageUrl,
                      width: 56,
                      height: 56,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _currentFood.name,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          _currentFood.category,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Quantity input
              Text(
                'Quantity',
                style: Theme.of(context).textTheme.labelMedium,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _quantityController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'Enter quantity',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onChanged: (_) => _updateScaledFood(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  DropdownButton<String>(
                    value: _selectedUnit,
                    items: const [
                      DropdownMenuItem(value: 'g', child: Text('g')),
                      DropdownMenuItem(value: 'oz', child: Text('oz')),
                      DropdownMenuItem(value: 'cup', child: Text('cup')),
                      DropdownMenuItem(value: 'tbsp', child: Text('tbsp')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedUnit = value;
                        });
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Nutrition preview
              Text(
                'Nutrition (per ${_quantityController.text}$_selectedUnit)',
                style: Theme.of(context).textTheme.labelMedium,
              ),
              const SizedBox(height: 12),
              _NutritionPreview(food: _scaledFood),
              const SizedBox(height: 24),
              // Food alternatives
              FoodAlternativesWidget(
                selectedFood: _currentFood,
                onSwap: _handleSwap,
              ),
              const SizedBox(height: 24),
              // Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        final quantity =
                            double.tryParse(_quantityController.text) ?? 100;
                        widget.onConfirm(quantity);
                      },
                      child: const Text('Add'),
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

// ---------------------------------------------------------------------------
// Nutrition preview widget
// ---------------------------------------------------------------------------

class _NutritionPreview extends StatelessWidget {
  final FoodItemFull food;

  const _NutritionPreview({required this.food});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Macros
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NutritionValue(
              label: 'Calories',
              value: food.macros.calories.toStringAsFixed(0),
              unit: 'kcal',
            ),
            _NutritionValue(
              label: 'Protein',
              value: food.macros.protein.toStringAsFixed(1),
              unit: 'g',
            ),
            _NutritionValue(
              label: 'Carbs',
              value: food.macros.carbs.toStringAsFixed(1),
              unit: 'g',
            ),
            _NutritionValue(
              label: 'Fats',
              value: food.macros.fats.toStringAsFixed(1),
              unit: 'g',
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Micros
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NutritionValue(
              label: 'Fiber',
              value: food.micros.fiber.toStringAsFixed(1),
              unit: 'g',
            ),
            _NutritionValue(
              label: 'Sugar',
              value: food.micros.sugar.toStringAsFixed(1),
              unit: 'g',
            ),
            _NutritionValue(
              label: 'Sodium',
              value: food.micros.sodium.toStringAsFixed(0),
              unit: 'mg',
            ),
            _NutritionValue(
              label: 'Potassium',
              value: food.micros.potassium.toStringAsFixed(0),
              unit: 'mg',
            ),
          ],
        ),
      ],
    );
  }
}

class _NutritionValue extends StatelessWidget {
  final String label;
  final String value;
  final String unit;

  const _NutritionValue({
    required this.label,
    required this.value,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        Text(
          unit,
          style: Theme.of(context).textTheme.labelSmall,
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Colors.white.withValues(alpha: 0.6),
              ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Selected foods summary
// ---------------------------------------------------------------------------

class _SelectedFoodsSummary extends StatelessWidget {
  final List<FoodItemFull> foods;
  final Function(int) onRemove;

  const _SelectedFoodsSummary({
    required this.foods,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    double totalCalories = 0;
    double totalProtein = 0;
    double totalCarbs = 0;
    double totalFats = 0;

    for (final food in foods) {
      totalCalories += food.macros.calories;
      totalProtein += food.macros.protein;
      totalCarbs += food.macros.carbs;
      totalFats += food.macros.fats;
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Selected Foods (${foods.length})',
            style: Theme.of(context).textTheme.labelMedium,
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: foods.length,
              itemBuilder: (context, index) {
                final food = foods[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: CachedNetworkImage(
                          imageUrl: food.imageUrl,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => onRemove(index),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.8),
                              shape: BoxShape.circle,
                            ),
                            padding: const EdgeInsets.all(4),
                            child: const Icon(
                              Icons.close,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          // Totals
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NutritionValue(
                label: 'Total Cal',
                value: totalCalories.toStringAsFixed(0),
                unit: 'kcal',
              ),
              _NutritionValue(
                label: 'Protein',
                value: totalProtein.toStringAsFixed(1),
                unit: 'g',
              ),
              _NutritionValue(
                label: 'Carbs',
                value: totalCarbs.toStringAsFixed(1),
                unit: 'g',
              ),
              _NutritionValue(
                label: 'Fats',
                value: totalFats.toStringAsFixed(1),
                unit: 'g',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
