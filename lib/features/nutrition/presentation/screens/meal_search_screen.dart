import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_theme.dart';
import '../../domain/entities/food_item.dart';
import '../providers/nutrition_providers.dart';
import '../widgets/food_item_card.dart';

/// Screen for searching and filtering meals.
///
/// Allows users to:
/// - Search by food name or category
/// - Filter by meal type
/// - Filter by dietary preferences
class MealSearchScreen extends ConsumerStatefulWidget {
  const MealSearchScreen({super.key});

  @override
  ConsumerState<MealSearchScreen> createState() => _MealSearchScreenState();
}

class _MealSearchScreenState extends ConsumerState<MealSearchScreen> {
  late TextEditingController _searchController;
  MealType? _selectedMealType;
  final Set<DietaryPreference> _selectedPreferences = {};

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchQuery = _searchController.text;
    final foodsAsync = searchQuery.isNotEmpty
        ? ref.watch(foodSearchProvider(searchQuery))
        : ref.watch(
            foodFilterProvider(
              (
                mealType: _selectedMealType,
                dietaryPreferences: _selectedPreferences.toList(),
              ),
            ),
          );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Meals'),
      ),
      body: Column(
        children: [
          // Search field
          Padding(
            padding: const EdgeInsets.all(AppTheme.spacingMedium),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search meals...',
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
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(AppTheme.borderRadiusMedium),
                ),
              ),
              onChanged: (value) {
                setState(() {});
              },
            ),
          ),

          // Filters
          if (searchQuery.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacingMedium,
                vertical: AppTheme.spacingSmall,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Meal type filter
                  const Text(
                    'Meal Type',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: MealType.values.map((type) {
                      final isSelected = _selectedMealType == type;
                      return FilterChip(
                        label: Text(type.toString().split('.').last),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            _selectedMealType =
                                selected ? type : null;
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  // Dietary preferences filter
                  const Text(
                    'Dietary Preferences',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: DietaryPreference.values.map((pref) {
                      final isSelected = _selectedPreferences.contains(pref);
                      return FilterChip(
                        label: Text(pref.toString().split('.').last),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedPreferences.add(pref);
                            } else {
                              _selectedPreferences.remove(pref);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

          // Results
          Expanded(
            child: foodsAsync.when(
              data: (foods) => foods.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.restaurant_menu,
                            size: 64,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'No Meals Found',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Try adjusting your search or filters',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(AppTheme.spacingMedium),
                      itemCount: foods.length,
                      itemBuilder: (context, index) {
                        final food = foods[index];
                        return Padding(
                          padding: const EdgeInsets.only(
                            bottom: AppTheme.spacingSmall,
                          ),
                          child: FoodItemCard(
                            food: food,
                            targetCalories: food.calories,
                            targetProtein: food.protein,
                            targetCarbs: food.carbs,
                            targetFat: food.fat,
                            onSelect: () {
                              Navigator.pop(context, food);
                            },
                          ),
                        );
                      },
                    ),
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (error, stack) => Center(
                child: Text('Error: $error'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
