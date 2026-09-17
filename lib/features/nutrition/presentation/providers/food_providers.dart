import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Firebase - DISABLED
// import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/food_item.dart';
import '../../domain/entities/food_item_full.dart';
import '../../domain/usecases/search_food_use_case.dart';
import '../../../nutrition/presentation/providers/nutrition_providers.dart';
import 'package:uuid/uuid.dart';
// import '../../data/datasources/firestore_food_datasource.dart';

class FoodSearchState {
  const FoodSearchState({this.query = '', this.category});
  final String query;
  final FoodCategory? category;
  FoodSearchState copyWith({String? query, FoodCategory? category, bool clearCategory = false}) {
    return FoodSearchState(
      query: query ?? this.query,
      category: clearCategory ? null : (category ?? this.category),
    );
  }
}

class FoodSearchNotifier extends StateNotifier<FoodSearchState> {
  FoodSearchNotifier() : super(const FoodSearchState());
  void setQuery(String q) => state = state.copyWith(query: q);
  void setCategory(FoodCategory? c) => state = c == null
      ? state.copyWith(clearCategory: true)
      : state.copyWith(category: c);
}

final foodSearchProvider = StateNotifierProvider<FoodSearchNotifier, FoodSearchState>(
  (ref) => FoodSearchNotifier(),
);

final filteredFoodProvider = Provider<List<FoodItem>>((ref) {
  final s = ref.watch(foodSearchProvider);
  return SearchFoodUseCase()(query: s.query, category: s.category);
});

/// Custom Foods StateNotifier for managing user-created foods
class CustomFoodsNotifier extends StateNotifier<AsyncValue<List<FoodItemFull>>> {
  CustomFoodsNotifier(this._repository) : super(const AsyncValue.loading()) {
    _loadCustomFoods();
  }

  final dynamic _repository; // FoodRepository

  /// Load custom foods from repository
  Future<void> _loadCustomFoods() async {
    try {
      if (kDebugMode) {
        print('📊 [CustomFoods] Loading custom foods...');
      }
      
      final foods = await _repository.getCustomFoods();
      
      if (kDebugMode) {
        print('✅ [CustomFoods] Loaded ${foods.length} custom foods');
      }
      
      state = AsyncValue.data(foods);
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('❌ [CustomFoods] Failed to load custom foods: $e');
      }
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// Add a new custom food
  Future<void> addCustomFood(FoodItemFull food) async {
    try {
      if (kDebugMode) {
        print('📊 [CustomFoods] Adding custom food: ${food.name}');
      }
      
      // Save to repository
      await _repository.saveCustomFood(food);
      
      if (kDebugMode) {
        print('✅ [CustomFoods] Custom food saved to repository');
      }
      
      // Update state immediately
      state.whenData((currentFoods) {
        final updatedFoods = [...currentFoods, food];
        
        if (kDebugMode) {
          print('✅ [CustomFoods] State updated with new food');
          print('🔍 [CustomFoods] Total custom foods: ${updatedFoods.length}');
        }
        
        state = AsyncValue.data(updatedFoods);
      });
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('❌ [CustomFoods] Failed to add custom food: $e');
      }
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// Delete a custom food
  Future<void> deleteCustomFood(String id) async {
    try {
      if (kDebugMode) {
        print('📊 [CustomFoods] Deleting custom food: $id');
      }
      
      // Delete from repository
      await _repository.deleteCustomFood(id);
      
      if (kDebugMode) {
        print('✅ [CustomFoods] Custom food deleted from repository');
      }
      
      // Update state immediately
      state.whenData((currentFoods) {
        final updatedFoods = currentFoods.where((f) => f.id != id).toList();
        
        if (kDebugMode) {
          print('✅ [CustomFoods] State updated after deletion');
          print('🔍 [CustomFoods] Remaining custom foods: ${updatedFoods.length}');
        }
        
        state = AsyncValue.data(updatedFoods);
      });
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('❌ [CustomFoods] Failed to delete custom food: $e');
      }
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// Refresh custom foods from repository
  Future<void> refresh() async {
    await _loadCustomFoods();
  }
}

/// Provider for custom foods with instant updates
final customFoodsProvider = StateNotifierProvider<CustomFoodsNotifier, AsyncValue<List<FoodItemFull>>>((ref) {
  final repository = ref.watch(foodRepositoryProvider);
  return CustomFoodsNotifier(repository);
});

/// Provider for food repository
final foodRepositoryProvider = Provider((ref) {
  final nutritionRepo = ref.watch(nutritionRepositoryProvider);
  return nutritionRepo as dynamic; // Cast to FoodRepository
});

/// Provider for Firestore instance - DISABLED
// final firestoreProvider = Provider<FirebaseFirestore>((ref) {
//   return FirebaseFirestore.instance;
// });

/// Provider for Firestore food datasource - DISABLED
// final firestoreFoodDatasourceProvider =
//     Provider<FirestoreFoodDatasource>((ref) {
//   final firestore = ref.watch(firestoreProvider);
//   return FirestoreFoodDatasource(firestore);
// });


/// State for food upload
class FoodUploadState {
  const FoodUploadState({
    this.isLoading = false,
    this.isSuccess = false,
    this.error,
    this.uploadedCount = 0,
    this.totalCount = 0,
  });

  final bool isLoading;
  final bool isSuccess;
  final String? error;
  final int uploadedCount;
  final int totalCount;

  FoodUploadState copyWith({
    bool? isLoading,
    bool? isSuccess,
    String? error,
    int? uploadedCount,
    int? totalCount,
  }) {
    return FoodUploadState(
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      error: error,
      uploadedCount: uploadedCount ?? this.uploadedCount,
      totalCount: totalCount ?? this.totalCount,
    );
  }
}

/// Notifier for food upload - DISABLED (Firebase not available)
// class FoodUploadNotifier extends StateNotifier<FoodUploadState> {
//   final FirebaseFirestore _firestore;
//
//   FoodUploadNotifier(this._firestore)
//       : super(const FoodUploadState());
//
//   /// Upload all foods to Firestore
//   Future<void> uploadFoods() async {
//     state = state.copyWith(isLoading: true, error: null, isSuccess: false);
//     try {
//       // Import the upload script function
//       // This will be called from the upload script
//       state = state.copyWith(
//         isLoading: false,
//         isSuccess: true,
//         error: null,
//       );
//     } catch (e) {
//       state = state.copyWith(
//         isLoading: false,
//         error: e.toString(),
//       );
//     }
//   }
//
//   /// Verify foods in Firestore
//   Future<bool> verifyFoods() async {
//     state = state.copyWith(isLoading: true);
//     try {
//       final datasource = FirestoreFoodDatasource(_firestore);
//       final foods = await datasource.getAllFoods();
//       state = state.copyWith(
//         isLoading: false,
//         uploadedCount: foods.length,
//       );
//       return true;
//     } catch (e) {
//       state = state.copyWith(
//         isLoading: false,
//         error: e.toString(),
//       );
//       return false;
//     }
//   }
// }

/// Provider for food upload status - DISABLED (Firebase not available)
// final foodUploadStatusProvider =
//     StateNotifierProvider<FoodUploadNotifier, FoodUploadState>((ref) {
//   final firestore = ref.watch(firestoreProvider);
//   return FoodUploadNotifier(firestore);
// });
