import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:progression_tracker/core/catalog/catalog_search_index.dart';
import 'package:progression_tracker/features/nutrition/domain/entities/food_item.dart';
import 'package:progression_tracker/features/nutrition/presentation/providers/food_providers.dart';

class _FakeCustomFoodsNotifier extends CustomFoodsNotifier {
  _FakeCustomFoodsNotifier(this.items);
  final List<FoodItem> items;

  @override
  AsyncValue<List<FoodItem>> build() => AsyncValue.data(items);
}

void main() {
  const catalogChicken = FoodItem(
    id: 'usda_chicken',
    name: 'Chicken Breast',
    category: FoodCategory.protein,
    caloriesPer100g: 165,
    proteinPer100g: 31,
    carbsPer100g: 0,
    fatPer100g: 3.6,
    imageUrl: '',
  );

  const catalogOats = FoodItem(
    id: 'usda_oats',
    name: 'Rolled Oats',
    category: FoodCategory.carbs,
    caloriesPer100g: 389,
    proteinPer100g: 16.9,
    carbsPer100g: 66.3,
    fatPer100g: 6.9,
    imageUrl: '',
  );

  const customProteinBowl = FoodItem(
    id: 'custom_bowl_1',
    name: 'Homemade Chicken Rice Bowl',
    category: FoodCategory.protein,
    caloriesPer100g: 185,
    proteinPer100g: 22,
    carbsPer100g: 18,
    fatPer100g: 2.5,
    imageUrl: '',
    source: 'Custom User Food',
  );

  ProviderContainer createContainer({List<FoodItem> customFoods = const [customProteinBowl]}) {
    final index = CatalogSearchIndex.buildSync<FoodItem>(
      items: const [catalogChicken, catalogOats],
      idOf: (f) => f.id,
      searchableTextOf: (f) => '${f.name} ${f.category.name} ${f.tags.join(" ")}',
    );
    return ProviderContainer(
      overrides: [
        foodsCatalogIndexProvider.overrideWith((ref) => index),
        customFoodsProvider.overrideWith(() => _FakeCustomFoodsNotifier(customFoods)),
      ],
    );
  }

  group('filteredFoodProvider custom food merge', () {
    test('includes custom foods ahead of USDA catalog results', () async {
      final container = createContainer();
      addTearDown(container.dispose);
      await container.read(foodsCatalogIndexProvider.future);

      final all = container.read(filteredFoodProvider);
      expect(all.length, 3);
      expect(all.first.id, 'custom_bowl_1');
      expect(all.map((f) => f.id), containsAll(['usda_chicken', 'usda_oats']));
    });

    test('matches custom foods on search query and category filter', () async {
      final container = createContainer();
      addTearDown(container.dispose);
      await container.read(foodsCatalogIndexProvider.future);

      container.read(foodSearchProvider.notifier).setQuery('rice bowl');
      final byQuery = container.read(filteredFoodProvider);
      expect(byQuery.map((f) => f.id).toList(), ['custom_bowl_1']);

      container.read(foodSearchProvider.notifier).setQuery('');
      container.read(foodSearchProvider.notifier).setCategory(FoodCategory.carbs);
      final carbsOnly = container.read(filteredFoodProvider);
      expect(carbsOnly.map((f) => f.id).toList(), ['usda_oats']);
    });

    test('deduplicates if custom food ID matches catalog ID', () async {
      final container = createContainer(customFoods: const [catalogChicken]);
      addTearDown(container.dispose);
      await container.read(foodsCatalogIndexProvider.future);

      final results = container.read(filteredFoodProvider);
      expect(
        results.where((f) => f.id == 'usda_chicken').length,
        1,
      );
    });
  });
}
