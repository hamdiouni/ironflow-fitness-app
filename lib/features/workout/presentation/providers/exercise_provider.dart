import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/exercise_definition.dart';
import '../../data/datasources/firestore_exercise_datasource.dart';
import '../../data/datasources/hive_exercise_datasource.dart';
import '../../data/datasources/exercise_upload_script.dart';
import '../../data/repositories/exercise_repository_impl.dart';
import '../../data/exercise_database.dart';

/// Provider for Firestore instance
final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

/// Provider for Firestore exercise datasource
final firestoreExerciseDatasourceProvider =
    Provider<FirestoreExerciseDatasource>((ref) {
  final firestore = ref.watch(firestoreProvider);
  return FirestoreExerciseDatasource(firestore);
});

/// Provider for Hive exercise datasource
final hiveExerciseDatasourceProvider =
    Provider<HiveExerciseDatasource>((ref) {
  return HiveExerciseDatasource();
});

/// Provider for exercise repository with caching
final exerciseRepositoryProvider = Provider<ExerciseRepositoryImpl>((ref) {
  final firestoreDatasource = ref.watch(firestoreExerciseDatasourceProvider);
  final hiveDatasource = ref.watch(hiveExerciseDatasourceProvider);
  return ExerciseRepositoryImpl(firestoreDatasource, hiveDatasource);
});

/// Provider to initialize exercise cache on app startup
final exerciseCacheInitializerProvider = FutureProvider<void>((ref) async {
  final repository = ref.watch(exerciseRepositoryProvider);
  await repository.initializeCache();
});

/// Provider for all exercises from cache
final allExercisesProvider = FutureProvider<List<ExerciseDefinition>>((ref) async {
  // Ensure cache is initialized
  await ref.watch(exerciseCacheInitializerProvider.future);
  
  final repository = ref.watch(exerciseRepositoryProvider);
  return repository.getAllExercises();
});

/// Provider for exercises by muscle group
final exercisesByMuscleGroupProvider =
    FutureProvider.family<List<ExerciseDefinition>, String>((ref, muscleGroup) async {
  // Ensure cache is initialized
  await ref.watch(exerciseCacheInitializerProvider.future);
  
  final repository = ref.watch(exerciseRepositoryProvider);
  return repository.getExercisesByMuscleGroup(muscleGroup);
});

/// Provider for searching exercises
final searchExercisesProvider =
    FutureProvider.family<List<ExerciseDefinition>, String>((ref, query) async {
  // Ensure cache is initialized
  await ref.watch(exerciseCacheInitializerProvider.future);
  
  final repository = ref.watch(exerciseRepositoryProvider);
  return repository.searchExercises(query);
});

/// Provider for getting a single exercise by ID
final exerciseByIdProvider =
    FutureProvider.family<ExerciseDefinition?, String>((ref, id) async {
  // Ensure cache is initialized
  await ref.watch(exerciseCacheInitializerProvider.future);
  
  final repository = ref.watch(exerciseRepositoryProvider);
  return repository.getExerciseById(id);
});

/// Provider for refreshing exercises from Firestore
final exerciseRefreshProvider = FutureProvider<void>((ref) async {
  final repository = ref.watch(exerciseRepositoryProvider);
  await repository.refreshExercises();
  // Invalidate all exercise providers to refresh UI
  ref.invalidate(allExercisesProvider);
  ref.invalidate(exercisesByMuscleGroupProvider);
  ref.invalidate(searchExercisesProvider);
  ref.invalidate(exerciseByIdProvider);
});

/// Provider for upload status
final exerciseUploadStatusProvider =
    StateNotifierProvider<ExerciseUploadNotifier, ExerciseUploadState>((ref) {
  final firestore = ref.watch(firestoreProvider);
  return ExerciseUploadNotifier(firestore);
});

/// State for exercise upload
class ExerciseUploadState {
  final bool isLoading;
  final bool isSuccess;
  final String? error;
  final int uploadedCount;
  final int totalCount;

  ExerciseUploadState({
    this.isLoading = false,
    this.isSuccess = false,
    this.error,
    this.uploadedCount = 0,
    this.totalCount = 0,
  });

  ExerciseUploadState copyWith({
    bool? isLoading,
    bool? isSuccess,
    String? error,
    int? uploadedCount,
    int? totalCount,
  }) {
    return ExerciseUploadState(
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      error: error ?? this.error,
      uploadedCount: uploadedCount ?? this.uploadedCount,
      totalCount: totalCount ?? this.totalCount,
    );
  }
}

/// Notifier for exercise upload
class ExerciseUploadNotifier extends StateNotifier<ExerciseUploadState> {
  final FirebaseFirestore _firestore;

  ExerciseUploadNotifier(this._firestore)
      : super(ExerciseUploadState(totalCount: ExerciseDatabase.all.length));

  /// Upload all exercises to Firestore
  Future<void> uploadExercises() async {
    state = state.copyWith(isLoading: true, error: null, isSuccess: false);
    try {
      await uploadAllExercisesToFirestore(_firestore);
      state = state.copyWith(
        isLoading: false,
        isSuccess: true,
        uploadedCount: ExerciseDatabase.all.length,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Verify exercises in Firestore
  Future<bool> verifyExercises() async {
    state = state.copyWith(isLoading: true);
    try {
      final isValid = await verifyExercisesInFirestore(_firestore);
      state = state.copyWith(
        isLoading: false,
        isSuccess: isValid,
      );
      return isValid;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  /// Reset upload state
  void reset() {
    state = ExerciseUploadState(totalCount: ExerciseDatabase.all.length);
  }
}
