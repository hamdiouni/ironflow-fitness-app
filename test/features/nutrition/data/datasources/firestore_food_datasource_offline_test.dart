import 'package:flutter_test/flutter_test.dart';
import 'package:progression_tracker/features/nutrition/data/datasources/firestore_food_datasource.dart';
import 'package:progression_tracker/features/nutrition/domain/entities/food_item.dart';

void main() {
  group('FirestoreFoodDatasource (uninitialized Firebase guards)', () {
    const sampleFood = FoodItem(
      id: 'dup_food_1',
      name: 'Chicken Breast',
      category: FoodCategory.protein,
      caloriesPer100g: 165,
      proteinPer100g: 31,
      carbsPer100g: 0,
      fatPer100g: 3.6,
      imageUrl: '',
    );

    test('returns safe empty results when Firebase has no default app', () async {
      final ds = FirestoreFoodDatasource();

      final page = await ds.getFoodsPage();
      expect(page.items, isEmpty);
      expect(page.lastDocument, isNull);
      expect(page.hasMore, isFalse);

      expect(await ds.getAllFoods(), isEmpty);
      expect(await ds.getFoodsByCategory('protein'), isEmpty);
      expect(await ds.searchFoods('chicken'), isEmpty);
      expect(await ds.getFoodById('missing'), isNull);
      expect(await ds.getFoodsByTags(['high-protein']), isEmpty);
      expect(await ds.getFoodsByTags(const []), isEmpty);
      await ds.uploadFoods([sampleFood]);
    });

    test('uploadFoods fails loudly on duplicate IDs even before Firestore write', () async {
      final ds = FirestoreFoodDatasource();
      await expectLater(
        () => ds.uploadFoods([sampleFood, sampleFood]),
        throwsA(isA<StateError>()),
      );
    });
  });
}
