import 'package:flutter/foundation.dart';
import '../../domain/entities/exercise_definition.dart';
import '../datasources/firestore_exercise_datasource.dart';
import '../datasources/hive_exercise_datasource.dart';

/// Implementation of exercise repository with offline-first caching strategy.
/// 
/// Caching Strategy:
/// 1. In-memory cache for fast access during session
/// 2. Hive local storage for persistence across sessions
/// 3. Firestore as authoritative source
/// 4. Lazy loading: Load from Hive on first use, sync with Firestore when online
class ExerciseRepositoryImpl {
  final FirestoreExerciseDatasource _firestoreDatasource;
  final HiveExerciseDatasource _hiveDatasource;
  
  // In-memory cache
  List<ExerciseDefinition>? _cachedExercises;
  bool _isInitialized = false;

  ExerciseRepositoryImpl(
    this._firestoreDatasource,
    this._hiveDatasource,
  );

  /// Initialize the exercise cache from Hive on app startup.
  /// This ensures exercises are available offline immediately.
  Future<void> initializeCache() async {
    if (_isInitialized) return;
    
    try {
      final hasCache = await _hiveDatasource.hasExercises();
      if (hasCache) {
        _cachedExercises = await _hiveDatasource.getAllExercises();
        debugPrint('Loaded ${_cachedExercises?.length ?? 0} exercises from Hive cache');
      }
      _isInitialized = true;
    } catch (e) {
      debugPrint('Error initializing exercise cache: $e');
      _isInitialized = true;
    }
  }

  /// Get all exercises with caching strategy.
  /// 1. Return from in-memory cache if available
  /// 2. Load from Hive if not in memory
  /// 3. Sync with Firestore in background when online
  Future<List<ExerciseDefinition>> getAllExercises() async {
    // Return in-memory cache if available
    if (_cachedExercises != null) {
      return _cachedExercises!;
    }

    // Try to load from Hive
    final hiveExercises = await _hiveDatasource.getAllExercises();
    if (hiveExercises.isNotEmpty) {
      _cachedExercises = hiveExercises;
      return hiveExercises;
    }

    // Fallback to Firestore and cache the result
    try {
      final firestoreExercises = await _firestoreDatasource.getAllExercises();
      if (firestoreExercises.isNotEmpty) {
        // Cache in both memory and Hive
        _cachedExercises = firestoreExercises;
        await _hiveDatasource.saveExercises(firestoreExercises);
      }
      return firestoreExercises;
    } catch (e) {
      debugPrint('Error fetching exercises from Firestore: $e');
      return [];
    }
  }

  /// Get exercises by muscle group with caching.
  Future<List<ExerciseDefinition>> getExercisesByMuscleGroup(
    String muscleGroup,
  ) async {
    // Ensure cache is initialized
    if (_cachedExercises == null) {
      await getAllExercises();
    }

    // Filter from in-memory cache
    if (_cachedExercises != null) {
      return _cachedExercises!
          .where((e) => e.muscleGroup.name == muscleGroup)
          .toList();
    }

    // Fallback to Hive
    return _hiveDatasource.getExercisesByMuscleGroup(muscleGroup);
  }

  /// Search exercises by name with caching.
  Future<List<ExerciseDefinition>> searchExercises(String query) async {
    // Ensure cache is initialized
    if (_cachedExercises == null) {
      await getAllExercises();
    }

    // Search in-memory cache
    if (_cachedExercises != null) {
      final lowerQuery = query.toLowerCase();
      return _cachedExercises!
          .where((e) => e.name.toLowerCase().contains(lowerQuery))
          .toList();
    }

    // Fallback to Hive
    return _hiveDatasource.searchExercises(query);
  }

  /// Get a single exercise by ID with caching.
  Future<ExerciseDefinition?> getExerciseById(String id) async {
    // Check in-memory cache
    if (_cachedExercises != null) {
      try {
        return _cachedExercises!.firstWhere((e) => e.id == id);
      } catch (e) {
        return null;
      }
    }

    // Try Hive
    final hiveExercise = await _hiveDatasource.getExerciseById(id);
    if (hiveExercise != null) return hiveExercise;

    // Fallback to Firestore
    return _firestoreDatasource.getExerciseById(id);
  }

  /// Upload exercises to Firestore and cache locally.
  /// This is typically called once during app initialization.
  Future<void> uploadExercises(List<ExerciseDefinition> exercises) async {
    try {
      // Upload to Firestore
      await _firestoreDatasource.uploadExercises(exercises);
      
      // Cache locally
      _cachedExercises = exercises;
      await _hiveDatasource.saveExercises(exercises);
      
      debugPrint('Uploaded and cached ${exercises.length} exercises');
    } catch (e) {
      debugPrint('Error uploading exercises: $e');
      rethrow;
    }
  }

  /// Refresh exercises from Firestore and update cache.
  /// Call this when you want to sync with the latest data from cloud.
  Future<void> refreshExercises() async {
    try {
      final firestoreExercises = await _firestoreDatasource.getAllExercises();
      if (firestoreExercises.isNotEmpty) {
        // Update both caches
        _cachedExercises = firestoreExercises;
        await _hiveDatasource.saveExercises(firestoreExercises);
        debugPrint('Refreshed ${firestoreExercises.length} exercises from Firestore');
      }
    } catch (e) {
      debugPrint('Error refreshing exercises: $e');
      rethrow;
    }
  }

  /// Clear all caches (in-memory and Hive).
  Future<void> clearCache() async {
    _cachedExercises = null;
    await _hiveDatasource.clearCache();
  }

  /// Get cache status for debugging.
  Map<String, dynamic> getCacheStatus() {
    return {
      'inMemoryCached': _cachedExercises != null,
      'inMemoryCount': _cachedExercises?.length ?? 0,
      'isInitialized': _isInitialized,
    };
  }
}
