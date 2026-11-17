// ignore_for_file: subtype_of_sealed_class, must_be_immutable

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:progression_tracker/core/catalog/catalog_search_index.dart';
import 'package:progression_tracker/features/nutrition/data/datasources/firestore_food_datasource.dart';
import 'package:progression_tracker/features/nutrition/domain/entities/food_item.dart';

class _FakeDocSnapshot extends Fake
    implements QueryDocumentSnapshot<Map<String, dynamic>> {
  _FakeDocSnapshot(this._id, this._data);

  final String _id;
  final Map<String, dynamic> _data;

  @override
  String get id => _id;

  @override
  bool get exists => true;

  @override
  Map<String, dynamic> data() => _data;
}

class _FakeQuerySnapshot extends Fake
    implements QuerySnapshot<Map<String, dynamic>> {
  _FakeQuerySnapshot(this._docs);

  final List<QueryDocumentSnapshot<Map<String, dynamic>>> _docs;

  @override
  List<QueryDocumentSnapshot<Map<String, dynamic>>> get docs => _docs;
}

class _FakeQuery extends Fake implements Query<Map<String, dynamic>> {
  _FakeQuery(this._allDocs, {this.limitValue, this.startAfterId});

  final List<_FakeDocSnapshot> _allDocs;
  final int? limitValue;
  final String? startAfterId;
  int? observedLimit;

  @override
  Query<Map<String, dynamic>> orderBy(
    Object field, {
    bool descending = false,
  }) =>
      this;

  @override
  Query<Map<String, dynamic>> limit(int limit) {
    observedLimit = limit;
    return _FakeQuery(_allDocs, limitValue: limit, startAfterId: startAfterId);
  }

  @override
  Query<Map<String, dynamic>> startAfterDocument(
    DocumentSnapshot<Object?> documentSnapshot,
  ) {
    return _FakeQuery(
      _allDocs,
      limitValue: limitValue,
      startAfterId: documentSnapshot.id,
    );
  }

  @override
  Future<QuerySnapshot<Map<String, dynamic>>> get([GetOptions? options]) async {
    var list = _allDocs;
    if (startAfterId != null) {
      final idx = list.indexWhere((d) => d.id == startAfterId);
      list = idx >= 0 ? list.sublist(idx + 1) : const [];
    }
    if (limitValue != null) {
      list = list.take(limitValue!).toList();
    }
    return _FakeQuerySnapshot(list);
  }
}

class _FakeCollectionReference extends Fake
    implements CollectionReference<Map<String, dynamic>> {
  _FakeCollectionReference(this._allDocs);

  final List<_FakeDocSnapshot> _allDocs;
  int? lastRequestedLimit;

  @override
  Query<Map<String, dynamic>> orderBy(
    Object field, {
    bool descending = false,
  }) =>
      _FakeQuery(_allDocs);

  @override
  Query<Map<String, dynamic>> limit(int limit) {
    lastRequestedLimit = limit;
    return _FakeQuery(_allDocs, limitValue: limit);
  }

  @override
  Query<Map<String, dynamic>> where(
    Object field, {
    Object? isEqualTo,
    Object? isNotEqualTo,
    Object? isLessThan,
    Object? isLessThanOrEqualTo,
    Object? isGreaterThan,
    Object? isGreaterThanOrEqualTo,
    Object? arrayContains,
    Iterable<Object?>? arrayContainsAny,
    Iterable<Object?>? whereIn,
    Iterable<Object?>? whereNotIn,
    bool? isNull,
  }) =>
      _FakeQuery(_allDocs);

  @override
  Future<QuerySnapshot<Map<String, dynamic>>> get([GetOptions? options]) async {
    return _FakeQuerySnapshot(_allDocs);
  }
}

class _FakeFirestore extends Fake implements FirebaseFirestore {
  _FakeFirestore(this._collection);

  final _FakeCollectionReference _collection;

  @override
  CollectionReference<Map<String, dynamic>> collection(String collectionPath) =>
      _collection;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('LazyJsonCatalogLoader loads canonical asset catalogs with 282 foods and 129 exercises', () async {
    final foodsIndex = await LazyJsonCatalogLoader.loadFoodsIndex();
    final exercisesIndex = await LazyJsonCatalogLoader.loadExercisesIndex();

    expect(foodsIndex.length, 282);
    final chicken = foodsIndex.getById('usda_chicken_breast_raw');
    expect(chicken, isNotNull);
    expect(chicken!.caloriesPer100g, 120.0);
    expect(chicken.proteinPer100g, 22.5);
    expect(chicken.fdcId, '171077');
    expect(chicken.microsPer100g?.vitaminDMcg, 0.1);
    expect(foodsIndex.search('chicken breast').map((f) => f.id), contains('usda_chicken_breast_raw'));

    expect(exercisesIndex.length, 129);
    expect(
      exercisesIndex.all.map((e) => e.id.toLowerCase()).toSet().length,
      129,
    );
    final bench = exercisesIndex.getById('chest_001');
    expect(bench?.name, 'Bench Press');
    expect(exercisesIndex.search('bench press').map((e) => e.id), contains('chest_001'));
  });

  test('Unified FoodItem parses catalog JSON and legacy FoodItemFullModel Hive/Firestore JSON without data loss', () {
    final legacyHiveJson = <String, dynamic>{
      'id': 'legacy_salmon',
      'name': 'Wild Salmon',
      'category': 'protein',
      'macros': {'calories': 208, 'protein': 20, 'carbs': 0, 'fats': 13},
      'micros': {'fiber': 0, 'sugar': 0, 'sodium': 59, 'potassium': 490},
      'vitamins': {'vitaminA': 40, 'vitaminB': 3.2, 'vitaminC': 0, 'vitaminD': 11, 'vitaminE': 1.2},
      'minerals': {'calcium': 12, 'iron': 0.8, 'magnesium': 29, 'zinc': 0.6},
      'imageUrl': 'https://example.com/salmon.jpg',
      'dietaryTags': ['high-protein', 'omega-3'],
    };

    final food = FoodItem.fromAnyJson(legacyHiveJson);
    expect(food.id, 'legacy_salmon');
    expect(food.category, FoodCategory.protein);
    expect(food.caloriesPer100g, 208.0);
    expect(food.proteinPer100g, 20.0);
    expect(food.fatPer100g, 13.0);
    expect(food.tags, ['high-protein', 'omega-3']);
    expect(food.microsPer100g?.potassiumMg, 490.0);
    expect(food.microsPer100g?.vitaminDMcg, 11.0);
    expect(food.microsPer100g?.vitaminAMcg, 40.0);
    expect(food.microsPer100g?.vitaminBMg, 3.2);
    expect(food.microsPer100g?.magnesiumMg, 29.0);
    expect(food.microsPer100g?.zincMg, 0.6);

    final roundTrip = FoodItem.fromAnyJson(food.toJson());
    expect(roundTrip.microsPer100g?.vitaminAMcg, 40.0);
    expect(roundTrip.microsPer100g?.magnesiumMg, 29.0);
    expect(roundTrip.microsPer100g?.zincMg, 0.6);
  });

  test('FirestoreFoodDatasource handles partial/malformed docs safely and paginates with cursor + limit', () async {
    final ds = FirestoreFoodDatasource(
      _FakeFirestore(
        _FakeCollectionReference([
          _FakeDocSnapshot('f1', {
            'name': 'Apple',
            'category': 'fruits',
            'macros': {'caloriesPer100g': 52, 'proteinPer100g': 0, 'carbsPer100g': 14, 'fatsPer100g': 0},
          }), // missing micros/vitamins/minerals/imageUrl/dietaryTags!
          _FakeDocSnapshot('f_bad', {
            // missing name & macros completely -> skipped in page results, mapToFood returns null
            'category': 999,
          }),
          _FakeDocSnapshot('f2', {
            'name': 'Banana',
            'category': 'fruits',
            'macros': {'caloriesPer100g': 89, 'proteinPer100g': 1.1, 'carbsPer100g': 23, 'fatsPer100g': 0.3},
            'vitamins': {'dPer100g': 0, 'cPer100g': 8.7},
          }),
          _FakeDocSnapshot('f3', {
            'name': 'Chicken',
            'category': 'protein',
            'macros': {'caloriesPer100g': 165, 'proteinPer100g': 31, 'carbsPer100g': 0, 'fatsPer100g': 3.6},
          }),
        ]),
      ),
    );

    final page1 = await ds.getFoodsPage(limit: 2);
    expect(page1.items.map((f) => f.id), ['f1']); // f_bad skipped safely without throwing!
    expect(page1.items.first.caloriesPer100g, 52.0);
    expect(page1.hasMore, isTrue);
    expect(page1.lastDocument, isNotNull);

    final page2 = await ds.getFoodsPage(limit: 2, startAfter: page1.lastDocument);
    expect(page2.items.map((f) => f.id), ['f2', 'f3']);
    expect(page2.items.first.microsPer100g?.vitaminCMg, 8.7);
  });
}
