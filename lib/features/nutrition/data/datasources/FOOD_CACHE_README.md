# Food Database Caching System

## Overview

The food caching system provides offline-first access to the food database with persistent local storage using Hive. This ensures users can search and browse foods even without internet connectivity.

## Architecture

```
┌─────────────────────────────────────────┐
│      Presentation Layer (UI)            │
│  (Food Picker, Meal Logging, etc.)      │
└──────────────┬──────────────────────────┘
               │
┌──────────────▼──────────────────────────┐
│      Domain Layer (Use Cases)           │
│  - InitializeFoodCacheUseCase           │
│  - SearchFoodsUseCase                   │
└──────────────┬──────────────────────────┘
               │
┌──────────────▼──────────────────────────┐
│      Data Layer (Repository)            │
│  - FoodRepositoryImpl                    │
│    (Offline-first with fallback)        │
└──────────────┬──────────────────────────┘
               │
        ┌──────┴──────┐
        │             │
┌───────▼────┐  ┌────▼────────┐
│   Hive     │  │  Firestore  │
│  (Local)   │  │  (Remote)   │
└────────────┘  └─────────────┘
```

## Components

### 1. HiveFoodDataSource (`hive_food_datasource.dart`)

Handles all local storage operations for foods using Hive.

**Key Methods:**
- `cacheFoods()` - Store foods locally with timestamp and version
- `getCachedFoods()` - Retrieve all cached foods
- `getCachedFoodById()` - Get a single food by ID
- `searchCachedFoods()` - Search foods by name
- `filterCachedByCategory()` - Filter by category
- `filterCachedByTags()` - Filter by dietary tags
- `isCacheValid()` - Check if cache exists and is valid
- `invalidateCache()` - Clear food data (keeps timestamp)
- `clearCache()` - Complete cache clear

**Cache Structure:**
```
Hive Box: 'foods'
├── 'foods_cache' → List<Map> (JSON serialized foods)
├── 'foods_cache_timestamp' → String (ISO8601 timestamp)
└── 'foods_cache_version' → int (cache version for migrations)
```

### 2. FoodRepository (`food_repository_impl.dart`)

Implements offline-first caching with Firestore as source of truth.

**Strategy:**
1. Check if cache is valid
2. If valid, return cached foods
3. If invalid, fetch from Firestore
4. Cache the fetched foods
5. On error, fallback to cache

**Key Methods:**
- `getAllFoods()` - Get all foods with caching
- `getFoodById()` - Get single food with caching
- `searchFoods()` - Search with cache fallback
- `getFoodsByCategory()` - Filter by category
- `getFoodsByTags()` - Filter by tags
- `getAllCategories()` - Get unique categories
- `getAllDietaryTags()` - Get unique tags
- `isCacheValid()` - Check cache validity
- `invalidateCache()` - Invalidate cache
- `clearCache()` - Clear all cache

### 3. Use Cases

#### InitializeFoodCacheUseCase
Initializes the food cache on app startup.

```dart
final useCase = InitializeFoodCacheUseCase(repository);
final count = await useCase(); // Returns number of cached foods
```

#### SearchFoodsUseCase
Provides search and filter operations.

```dart
final useCase = SearchFoodsUseCase(repository);
final results = await useCase.searchByName('chicken');
final byCategory = await useCase.getByCategory('Protein');
final byTags = await useCase.getByTags(['vegan', 'gluten-free']);
```

### 4. Providers (`food_cache_provider.dart`)

Riverpod providers for dependency injection and state management.

**Key Providers:**
- `foodRepositoryProvider` - Food repository instance
- `foodCacheInitializationProvider` - Initialize cache on startup
- `allCachedFoodsProvider` - Get all foods
- `searchFoodsProvider` - Search foods by query
- `foodsByCategoryProvider` - Get foods by category
- `foodsByTagsProvider` - Get foods by tags
- `foodByIdProvider` - Get single food
- `allCategoriesProvider` - Get all categories
- `allDietaryTagsProvider` - Get all tags
- `isFoodCacheValidProvider` - Check cache validity
- `cachedFoodCountProvider` - Get cache size
- `invalidateFoodCacheProvider` - Invalidate cache

## Usage Examples

### Initialize Cache on App Startup

```dart
@override
Widget build(BuildContext context, WidgetRef ref) {
  final cacheInit = ref.watch(foodCacheInitializationProvider);
  
  return cacheInit.when(
    data: (count) => MainApp(),
    loading: () => LoadingScreen(),
    error: (err, st) => ErrorScreen(error: err),
  );
}
```

### Search Foods

```dart
final searchResults = ref.watch(searchFoodsProvider('chicken'));

searchResults.when(
  data: (foods) => ListView(
    children: foods.map((food) => FoodTile(food: food)).toList(),
  ),
  loading: () => LoadingIndicator(),
  error: (err, st) => ErrorWidget(error: err),
);
```

### Get Foods by Category

```dart
final proteinFoods = ref.watch(foodsByCategoryProvider('Protein'));

proteinFoods.when(
  data: (foods) => FoodGrid(foods: foods),
  loading: () => SkeletonLoader(),
  error: (err, st) => ErrorWidget(error: err),
);
```

### Get Single Food

```dart
final food = ref.watch(foodByIdProvider('chicken_breast_123'));

food.when(
  data: (foodItem) => FoodDetailScreen(food: foodItem),
  loading: () => LoadingScreen(),
  error: (err, st) => ErrorScreen(error: err),
);
```

### Invalidate Cache

```dart
final invalidateNotifier = ref.read(invalidateFoodCacheProvider.notifier);
await invalidateNotifier.invalidate();
```

## Cache Invalidation

The cache is invalidated when:
1. User manually refreshes the food list
2. Admin updates the food database
3. App detects data inconsistency
4. User clears app data

**Manual Invalidation:**
```dart
final repository = ref.read(foodRepositoryProvider);
await repository.invalidateCache();

// Then refresh the UI
ref.refresh(allCachedFoodsProvider);
```

## Offline Access

The system ensures offline access by:
1. Caching all foods on first load
2. Storing cache in persistent Hive storage
3. Returning cached foods when offline
4. Gracefully handling network errors

**Offline Flow:**
```
User Action
    ↓
Check Network
    ↓
Online? → Fetch from Firestore → Cache → Return
    ↓
Offline? → Return from Cache
    ↓
Cache Empty? → Return Empty List + Error
```

## Performance Considerations

### Cache Size
- 200+ foods with full nutritional data
- Estimated size: ~2-3 MB
- Hive handles compression automatically

### Search Performance
- In-memory search: O(n) where n = number of foods
- Typical search time: <100ms for 200 foods
- Sorting by name: O(n log n)

### Load Time
- First load (Firestore): 2-5 seconds
- Subsequent loads (Cache): <100ms
- Cache initialization: <50ms

## Testing

### Unit Tests
- `hive_food_datasource_test.dart` - Hive operations
- `food_repository_impl_test.dart` - Repository logic

### Integration Tests
- `food_cache_integration_test.dart` - End-to-end caching

**Run Tests:**
```bash
flutter test test/features/nutrition/data/datasources/hive_food_datasource_test.dart
flutter test test/features/nutrition/data/repositories/food_repository_impl_test.dart
flutter test test/integration/food_cache_integration_test.dart
```

## Error Handling

### Network Errors
- Firestore fetch fails → Return cached foods
- Cache empty → Return empty list with error

### Cache Errors
- Hive read fails → Log error, return empty list
- Hive write fails → Log error, continue without cache

### Data Errors
- Invalid JSON → Skip corrupted entry
- Missing fields → Use defaults
- Type mismatch → Log and skip

## Future Enhancements

1. **Incremental Sync** - Only sync changed foods
2. **Compression** - Reduce cache size
3. **Expiration** - Auto-invalidate old cache
4. **Partial Caching** - Cache only frequently used foods
5. **Search Indexing** - Faster search with indexing
6. **Analytics** - Track cache hit/miss rates

## Troubleshooting

### Cache Not Updating
```dart
// Force refresh from Firestore
final foods = await repository.getAllFoods(forceRefresh: true);
```

### Cache Corrupted
```dart
// Clear and reinitialize
await repository.clearCache();
ref.refresh(foodCacheInitializationProvider);
```

### Slow Search
```dart
// Check cache size
final count = await repository.getCachedFoodCount();
// If > 500, consider pagination or indexing
```

## References

- [Hive Documentation](https://docs.hivedb.dev/)
- [Riverpod Documentation](https://riverpod.dev/)
- [Firebase Firestore](https://firebase.google.com/docs/firestore)
- [Offline-First Architecture](https://offlinefirst.org/)
