# Food Database Upload to Firestore

This document describes how to upload the local food database to Firestore.

## Overview

The food database contains 200+ foods with complete nutritional information:
- Macronutrients (calories, protein, carbs, fats)
- Micronutrients (fiber, sugar, sodium, potassium)
- Vitamins (A, B, C, D, E)
- Minerals (calcium, iron, magnesium, zinc)
- Dietary tags (vegan, vegetarian, gluten-free, etc.)
- Image URLs

## Architecture

### Components

1. **FirestoreFoodDatasource** (`firestore_food_datasource.dart`)
   - Handles uploading foods to Firestore
   - Handles retrieving foods from Firestore
   - Converts between FoodItemFull entities and Firestore maps
   - Supports searching and filtering

2. **Food Upload Script** (`food_upload_script.dart`)
   - Converts FoodItem (basic) to FoodItemFull (complete)
   - Estimates micronutrients, vitamins, and minerals based on category
   - Uploads all foods in batches
   - Verifies upload success
   - Provides deletion capability

3. **Food Providers** (`../presentation/providers/food_providers.dart`)
   - Provides Firestore instance
   - Provides FirestoreFoodDatasource
   - Provides upload status tracking

## Firestore Schema

```
foods/ (collection)
  {foodId} (document)
    id: string
    name: string
    category: string
    servingSize: double (optional)
    servingUnit: string (optional)
    macros: {
      caloriesPer100g: double
      proteinPer100g: double
      carbsPer100g: double
      fatsPer100g: double
    }
    micros: {
      fiberPer100g: double
      sugarPer100g: double
      sodiumPer100g: double
      potassiumPer100g: double
    }
    vitamins: {
      aPer100g: double
      bPer100g: double
      cPer100g: double
      dPer100g: double
      ePer100g: double
    }
    minerals: {
      calciumPer100g: double
      ironPer100g: double
      magnesiumPer100g: double
      zincPer100g: double
    }
    imageUrl: string
    dietaryTags: string[]
    createdAt: timestamp
```

## How to Upload Foods

### Option 1: Manual Upload via Code

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:progression_tracker/features/nutrition/data/datasources/food_upload_script.dart';

// Upload all foods
final firestore = FirebaseFirestore.instance;
await uploadAllFoodsToFirestore(firestore);

// Verify upload
final isValid = await verifyFoodsInFirestore(firestore);
print('Upload valid: $isValid');
```

### Option 2: Upload via Provider (in UI)

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:progression_tracker/features/nutrition/presentation/providers/food_providers.dart';
import 'package:progression_tracker/features/nutrition/data/datasources/food_upload_script.dart';

// In a widget
final uploadNotifier = ref.read(foodUploadStatusProvider.notifier);

// Trigger upload
await uploadAllFoodsToFirestore(
  ref.read(firestoreProvider),
);

// Verify
final isValid = await verifyFoodsInFirestore(
  ref.read(firestoreProvider),
);
```

### Option 3: Add to Settings Screen

Add a button to the settings screen to trigger the upload:

```dart
ElevatedButton(
  onPressed: () async {
    try {
      await uploadAllFoodsToFirestore(firestore);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Foods uploaded successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  },
  child: const Text('Upload Foods to Firestore'),
)
```

## Data Conversion

The upload script converts FoodItem (basic) to FoodItemFull (complete) by:

1. **Extracting basic data** from FoodItem:
   - ID, name, category
   - Calories, protein, carbs, fats per 100g
   - Image URL, dietary tags

2. **Estimating micronutrients** based on category:
   - Protein: high sodium, high potassium
   - Carbs: moderate fiber, moderate sugar
   - Vegetables: high fiber, low sugar
   - Fruits: moderate fiber, high sugar
   - Dairy: high calcium, moderate sugar
   - Fats: minimal micros
   - Snacks: moderate sodium, moderate sugar
   - Beverages: minimal micros

3. **Estimating vitamins** based on category:
   - Protein: B vitamins, vitamin D
   - Vegetables: vitamin A, C, E
   - Fruits: vitamin C
   - Dairy: vitamin A, D

4. **Estimating minerals** based on category:
   - Protein: iron, zinc, magnesium
   - Dairy: calcium
   - Vegetables: magnesium, iron
   - Fruits: minimal minerals

## Idempotency

The upload is idempotent - it can be run multiple times safely:

- Uses `batch.set()` which overwrites existing documents
- Handles duplicate IDs by appending a counter
- No data loss if run multiple times
- Safe to re-run if upload fails partway through

## Verification

After upload, verify the data:

```dart
// Check count
final foods = await datasource.getAllFoods();
print('Total foods: ${foods.length}'); // Should be 200+

// Check by category
final byCategory = <String, int>{};
for (final food in foods) {
  byCategory[food.category] = (byCategory[food.category] ?? 0) + 1;
}
print('Foods by category: $byCategory');

// Check specific food
final chicken = await datasource.getFoodById('chicken_breast');
print('Chicken: ${chicken?.name}');
```

## Deletion

To delete all foods from Firestore (use with caution):

```dart
await deleteAllFoodsFromFirestore(firestore);
```

## Performance

- Upload time: ~5-10 seconds for 200+ foods (depends on network)
- Uses batch writes for efficiency (max 500 per batch)
- Handles large datasets gracefully

## Troubleshooting

### Upload fails with "Permission denied"

- Check Firestore security rules
- Ensure user is authenticated
- Check Firebase project configuration

### Foods not appearing in Firestore

- Check Firebase Console > Firestore > foods collection
- Verify upload completed without errors
- Check network connectivity

### Duplicate foods

- Run `deleteAllFoodsFromFirestore()` first
- Then run upload again

### Missing nutritional data

- Micronutrients, vitamins, and minerals are estimated
- For accurate data, update the conversion logic in `food_upload_script.dart`
- Or manually update documents in Firestore

## Future Improvements

1. **Accurate nutritional data**: Replace estimates with real data from USDA database
2. **Serving size**: Add serving size and unit to each food
3. **Allergen information**: Add allergen tags
4. **Preparation methods**: Add different preparation methods (raw, cooked, etc.)
5. **Batch import**: Support importing from CSV/JSON files
6. **Admin panel**: Create admin UI for managing foods
