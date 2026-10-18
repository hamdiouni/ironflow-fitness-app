import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/remote_data_purger_impl.dart';
import '../../domain/repositories/remote_data_purger.dart';
import '../../domain/services/local_data_wiper.dart';
import '../../domain/usecases/delete_account_use_case.dart';
import '../../domain/usecases/delete_user_data_use_case.dart';
import '../../domain/usecases/export_all_data_use_case.dart';
import '../../domain/usecases/export_nutrition_use_case.dart';
import '../../domain/usecases/export_workouts_use_case.dart';
import '../../domain/usecases/restore_data_use_case.dart';
import '../../domain/usecases/simple_json_export_use_case.dart';
import '../../../workout/presentation/providers/workout_providers.dart';
import '../../../nutrition/presentation/providers/nutrition_providers.dart';
import '../../../body/presentation/providers/body_providers.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

final exportWorkoutsUseCaseProvider = Provider<ExportWorkoutsUseCase>((ref) {
  final workoutRepo = ref.watch(workoutRepositoryProvider);
  return ExportWorkoutsUseCase(workoutRepo);
});

final exportNutritionUseCaseProvider = Provider<ExportNutritionUseCase>((ref) {
  final nutritionRepo = ref.watch(nutritionRepositoryProvider);
  return ExportNutritionUseCase(nutritionRepo);
});

final simpleJsonExportUseCaseProvider = Provider<SimpleJsonExportUseCase>((ref) {
  final workoutRepo = ref.watch(workoutRepositoryProvider);
  final nutritionRepo = ref.watch(nutritionRepositoryProvider);
  final authRepo = ref.watch(authRepositoryProvider);
  return SimpleJsonExportUseCase(workoutRepo, nutritionRepo, authRepo);
});

final exportAllDataUseCaseProvider = Provider<ExportAllDataUseCase>((ref) {
  final workoutRepo = ref.watch(workoutRepositoryProvider);
  final nutritionRepo = ref.watch(nutritionRepositoryProvider);
  final bodyRepo = ref.watch(bodyRepositoryProvider);
  final authRepo = ref.watch(authRepositoryProvider);
  final exportWorkouts = ref.watch(exportWorkoutsUseCaseProvider);
  final exportNutrition = ref.watch(exportNutritionUseCaseProvider);
  return ExportAllDataUseCase(
    workoutRepo,
    nutritionRepo,
    bodyRepo,
    authRepo,
    exportWorkouts,
    exportNutrition,
  );
});

final restoreDataUseCaseProvider = Provider<RestoreDataUseCase>((ref) {
  final workoutRepo = ref.watch(workoutRepositoryProvider);
  final nutritionRepo = ref.watch(nutritionRepositoryProvider);
  final bodyRepo = ref.watch(bodyRepositoryProvider);
  final authRepo = ref.watch(authRepositoryProvider);
  return RestoreDataUseCase(
    workoutRepo,
    nutritionRepo,
    bodyRepo,
    authRepo,
  );
});

final remoteDataPurgerProvider = Provider<RemoteDataPurger>((ref) {
  return RemoteDataPurgerImpl();
});

final localDataWiperProvider = Provider<LocalDataWiper>((ref) {
  return LocalDataWiper();
});

final deleteUserDataUseCaseProvider = Provider<DeleteUserDataUseCase>((ref) {
  final wiper = ref.watch(localDataWiperProvider);
  return DeleteUserDataUseCase(localDataWiper: wiper);
});

final deleteAccountUseCaseProvider = Provider<DeleteAccountUseCase>((ref) {
  final authRepo = ref.watch(authRepositoryProvider);
  final purger = ref.watch(remoteDataPurgerProvider);
  final wiper = ref.watch(localDataWiperProvider);
  return DeleteAccountUseCase(
    authRepository: authRepo,
    remoteDataPurger: purger,
    localDataWiper: wiper,
  );
});
