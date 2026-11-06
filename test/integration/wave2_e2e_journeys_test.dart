// Wave 2.2 — End-to-end user journeys.
//
// These journeys drive the real use cases, repositories and Hive storage
// (in a throw-away temp directory) end to end. Only the platform edges are
// faked: Firebase Auth (in-memory auth data source), the AI proxy (an HTTP
// MockClient), the cloud purge, notifications and secure storage.
//
// They run headless with `flutter test test/integration/wave2_e2e_journeys_test.dart`
// and on a real device/emulator through
// `integration_test/wave2_e2e_journeys_test.dart`, which re-uses
// [defineWave2Journeys].
//
// They do NOT tap through screens. Screen-level coverage lives in the widget
// tests and the existing integration_test flows.
//
// All numbers below are test fixtures, not nutrition or exercise data.

import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:progression_tracker/core/router/app_router.dart';
import 'package:progression_tracker/core/utils/secure_storage_manager.dart';
import 'package:progression_tracker/features/ai/data/datasources/ai_chat_storage.dart';
import 'package:progression_tracker/features/ai/data/datasources/gemini_ai_service.dart';
import 'package:progression_tracker/features/ai/presentation/providers/ai_provider.dart';
import 'package:progression_tracker/features/auth/data/datasources/mock_auth_datasource.dart';
import 'package:progression_tracker/features/auth/data/datasources/mock_user_datasource.dart';
import 'package:progression_tracker/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:progression_tracker/features/auth/domain/entities/user.dart';
import 'package:progression_tracker/features/auth/domain/entities/user_profile.dart'
    as auth_profile;
import 'package:progression_tracker/features/auth/domain/usecases/sign_in_with_email_use_case.dart';
import 'package:progression_tracker/features/auth/domain/usecases/sign_out_use_case.dart';
import 'package:progression_tracker/features/auth/domain/usecases/sign_up_with_email_use_case.dart';
import 'package:progression_tracker/features/auth/domain/usecases/update_profile_use_case.dart';
import 'package:progression_tracker/features/body/domain/entities/body_entry.dart';
import 'package:progression_tracker/features/body/domain/repositories/body_repository.dart';
import 'package:progression_tracker/features/notifications/domain/services/notification_service.dart';
import 'package:progression_tracker/features/nutrition/data/datasources/hive_food_datasource.dart';
import 'package:progression_tracker/features/nutrition/data/datasources/hive_nutrition_datasource.dart';
import 'package:progression_tracker/features/nutrition/data/models/food_item_full_model.dart';
import 'package:progression_tracker/features/nutrition/data/repositories/nutrition_repository_impl.dart';
import 'package:progression_tracker/features/nutrition/domain/entities/meal.dart';
import 'package:progression_tracker/features/nutrition/domain/entities/nutrition_targets.dart';
import 'package:progression_tracker/features/nutrition/domain/usecases/get_daily_nutrition_summary_use_case.dart';
import 'package:progression_tracker/features/nutrition/domain/usecases/save_meal_use_case.dart';
import 'package:progression_tracker/features/nutrition/domain/utils/macro_calculator.dart';
import 'package:progression_tracker/features/onboarding/domain/entities/user_profile.dart'
    as onboarding;
import 'package:progression_tracker/features/settings/data/repositories/remote_data_purger_impl.dart'
    show RemotePurgeException;
import 'package:progression_tracker/features/settings/domain/repositories/remote_data_purger.dart';
import 'package:progression_tracker/features/settings/domain/services/local_data_wiper.dart';
import 'package:progression_tracker/features/settings/domain/usecases/delete_account_use_case.dart';
import 'package:progression_tracker/features/settings/domain/usecases/restore_data_use_case.dart';
import 'package:progression_tracker/features/workout/data/datasources/hive_workout_data_source.dart';
import 'package:progression_tracker/features/workout/data/repositories/workout_repository_impl.dart';
import 'package:progression_tracker/features/workout/domain/entities/active_program.dart';
import 'package:progression_tracker/features/workout/domain/entities/exercise.dart';
import 'package:progression_tracker/features/workout/domain/entities/exercise_type.dart';
import 'package:progression_tracker/features/workout/domain/entities/set_entry.dart';
import 'package:progression_tracker/features/workout/domain/entities/workout.dart';
import 'package:progression_tracker/features/workout/domain/repositories/active_program_repository.dart';
import 'package:progression_tracker/features/workout/domain/usecases/calculate_workout_volume_use_case.dart';
import 'package:progression_tracker/features/workout/domain/usecases/complete_workout_use_case.dart';
import 'package:progression_tracker/features/workout/domain/usecases/generate_workout_program_use_case.dart';
import 'package:progression_tracker/features/workout/domain/usecases/log_set_use_case.dart';
import 'package:progression_tracker/features/workout/domain/usecases/save_workout_use_case.dart';
import 'package:progression_tracker/features/workout/domain/usecases/start_workout_use_case.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ---------------------------------------------------------------------------
// Platform-edge fakes (in-memory). No Firebase, no network, no real storage.
// ---------------------------------------------------------------------------

class _InMemoryAuthDataSource implements MockAuthDataSource {
  User? _current;
  final Map<String, User> _usersByEmail = {};
  final Map<String, String> _passwords = {};
  int _nextId = 1;

  @override
  Future<User> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    if (_usersByEmail.containsKey(email)) {
      throw Exception('Email already in use');
    }
    final now = DateTime.utc(2026, 1, 1);
    final user = User(
      id: 'uid_${_nextId++}',
      email: email,
      displayName: email.split('@').first,
      photoUrl: null,
      createdAt: now,
      updatedAt: now,
    );
    _usersByEmail[email] = user;
    _passwords[email] = password;
    _current = user;
    return user;
  }

  @override
  Future<User> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final user = _usersByEmail[email];
    if (user == null || _passwords[email] != password) {
      throw Exception('Invalid credentials');
    }
    _current = user;
    return user;
  }

  @override
  Future<void> signOut() async => _current = null;

  @override
  Future<User?> getCurrentUser() async => _current;

  @override
  Future<bool> isAuthenticated() async => _current != null;

  @override
  Future<void> reauthenticateWithPassword(String password) async {
    final user = _current;
    if (user == null || _passwords[user.email] != password) {
      throw Exception('Wrong password');
    }
  }

  @override
  Future<void> deleteAccount() async {
    final user = _current;
    if (user == null) return;
    _usersByEmail.remove(user.email);
    _passwords.remove(user.email);
    _current = null;
  }

  bool hasAccount(String email) => _usersByEmail.containsKey(email);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _InMemoryUserDataSource implements MockUserDataSource {
  final Map<String, auth_profile.UserProfile> profiles = {};

  @override
  Future<void> createUserProfile(auth_profile.UserProfile profile) async =>
      profiles[profile.userId] = profile;

  @override
  Future<auth_profile.UserProfile?> getUserProfile(String userId) async =>
      profiles[userId];

  @override
  Future<void> updateUserProfile(auth_profile.UserProfile profile) async =>
      profiles[profile.userId] = profile;

  @override
  Future<void> deleteUserProfile(String userId) async =>
      profiles.remove(userId);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _InMemoryActiveProgramRepository implements ActiveProgramRepository {
  ActiveProgram? _active;

  @override
  Future<void> saveActiveProgram(ActiveProgram program) async =>
      _active = program;

  @override
  Future<ActiveProgram?> loadActiveProgram() async => _active;

  @override
  Future<void> updateActiveProgram(ActiveProgram program) async =>
      _active = program;

  @override
  Future<void> clearActiveProgram() async => _active = null;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _InMemoryBodyRepository implements BodyRepository {
  final Map<String, BodyEntry> entries = {};

  @override
  Future<void> saveBodyEntry(BodyEntry entry) async => entries[entry.id] = entry;

  @override
  Future<List<BodyEntry>> getAllBodyEntries() async => entries.values.toList();

  @override
  Future<void> deleteBodyEntry(String id) async => entries.remove(id);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Records cloud purge calls; can be told to fail like the real purger.
class _RecordingRemotePurger implements RemoteDataPurger {
  final List<String> purgedUserIds = [];
  Object? failWith;

  @override
  Future<void> purgeRemoteUserData(String userId) async {
    final failure = failWith;
    if (failure != null) throw failure;
    purgedUserIds.add(userId);
  }
}

class _NoopNotificationService implements NotificationService {
  int cancelCalls = 0;

  @override
  Future<void> cancelAllNotifications() async => cancelCalls++;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _NoopSecureStorage implements SecureStorageManager {
  int clearCalls = 0;

  @override
  Future<void> clearAll() async => clearCalls++;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// ---------------------------------------------------------------------------
// Fixture helpers
// ---------------------------------------------------------------------------

DateTime _todayAt(int hour) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day, hour);
}

Meal _meal({
  required String id,
  required String name,
  required double calories,
  required double protein,
  required double carbs,
  required double fats,
  required DateTime timestamp,
  String? userId,
  String? foodItemId,
}) {
  return Meal(
    id: id,
    name: name,
    macros: MealMacros(
      calories: calories,
      protein: protein,
      carbs: carbs,
      fats: fats,
    ),
    micros: const MealMicros(fiber: 0, sugar: 0, sodium: 0, potassium: 0),
    vitamins: const MealVitamins(
      vitaminA: 0,
      vitaminB: 0,
      vitaminC: 0,
      vitaminD: 0,
      vitaminE: 0,
    ),
    minerals: const MealMinerals(calcium: 0, iron: 0, magnesium: 0, zinc: 0),
    timestamp: timestamp,
    userId: userId,
    foodItemId: foodItemId,
  );
}

Workout _workout({
  required String id,
  required String userId,
  required DateTime date,
  double weight = 100,
  int reps = 5,
}) {
  return Workout(
    id: id,
    userId: userId,
    date: date,
    exercises: [
      Exercise(
        id: '${id}_ex',
        name: 'Barbell Squat',
        type: ExerciseType.strength,
        sets: [
          SetEntry(id: '${id}_s1', reps: reps, weight: weight, timestamp: date),
        ],
      ),
    ],
    duration: const Duration(minutes: 40),
    totalVolume: weight * reps,
  );
}

NutritionTargets _targets(String userId) {
  final now = DateTime.now();
  return NutritionTargets(
    userId: userId,
    macros: const MacroTargets(calories: 2000, protein: 150, carbs: 200, fats: 60),
    micros: const MicroTargets(fiber: 30, sugar: 40, sodium: 2300, potassium: 3500),
    vitamins: const VitaminTargets(
      vitaminA: 900,
      vitaminB: 2.4,
      vitaminC: 90,
      vitaminD: 20,
      vitaminE: 15,
    ),
    minerals: const MineralTargets(calcium: 1000, iron: 18, magnesium: 400, zinc: 11),
    createdAt: now,
    updatedAt: now,
  );
}

WorkoutRepositoryImpl _workoutRepoFor(String? userId) =>
    WorkoutRepositoryImpl(HiveWorkoutDataSource(), userId: userId);

NutritionRepositoryImpl _nutritionRepoFor(String userId) =>
    NutritionRepositoryImpl(hiveDataSource: HiveNutritionDatasource(), userId: userId);

http.Response _proxyOk(String text) => http.Response(
      jsonEncode({
        'candidates': [
          {
            'content': {
              'parts': [
                {'text': text},
              ],
            },
          },
        ],
      }),
      200,
      headers: {'content-type': 'application/json'},
    );

// ---------------------------------------------------------------------------
// Journeys
// ---------------------------------------------------------------------------

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  defineWave2Journeys();
}

/// Registers the seven Wave 2.2 journeys. Shared with
/// `integration_test/wave2_e2e_journeys_test.dart` so the same journeys run
/// headless in CI and on a real device.
void defineWave2Journeys() {
  late Directory tempDir;

  setUpAll(() {
    tempDir = Directory.systemTemp.createTempSync('ironflow_wave2_journeys_');
    Hive.init(tempDir.path);
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await Hive.openBox<Map>(HiveWorkoutDataSource.boxName);
    await Hive.openBox<Map>(HiveNutritionDatasource.mealsBoxName);
    await Hive.openBox<Map>(HiveNutritionDatasource.targetsBoxName);
    await Hive.openBox('foods');
  });

  tearDown(() async {
    await Hive.deleteFromDisk();
  });

  tearDownAll(() async {
    await Hive.close();
    try {
      tempDir.deleteSync(recursive: true);
    } catch (_) {}
  });

  group('Wave 2.2 journeys', () {
    test('J1 signup -> onboarding -> plan -> workout -> summary', () async {
      // Sign up.
      final authDs = _InMemoryAuthDataSource();
      final userDs = _InMemoryUserDataSource();
      final auth = AuthRepositoryImpl(authDataSource: authDs, userDataSource: userDs);
      final user = await SignUpWithEmailUseCase(auth)(
        email: 'new.athlete@example.test',
        password: 'Password123!',
        confirmPassword: 'Password123!',
      );
      expect(await auth.isAuthenticated(), isTrue);

      // Onboarding: answers are saved on the profile and the gate sends the
      // user home (never back to auth/onboarding).
      final defaultProfile = await auth.getUserProfile(user.id);
      expect(defaultProfile, isNotNull);
      await UpdateProfileUseCase(auth)(
        defaultProfile!.copyWith(
          age: 28,
          fitnessLevel: 'intermediate',
          goals: const ['gainMuscle'],
        ),
      );
      final savedProfile = await auth.getUserProfile(user.id);
      expect(savedProfile?.age, 28);
      expect(savedProfile?.fitnessLevel, 'intermediate');
      expect(AppRoutes.resolvePostAuthRedirect(AppRoutes.onboarding), AppRoutes.home);

      // Plan: deterministic program from the onboarding answers.
      const answers = onboarding.UserProfile(
        goal: onboarding.FitnessGoal.gainMuscle,
        age: 28,
        weightKg: 80,
        heightCm: 180,
        fitnessLevel: onboarding.FitnessLevel.intermediate,
        equipment: onboarding.EquipmentType.gym,
        workoutDaysPerWeek: 3,
        budget: onboarding.BudgetLevel.medium,
      );
      final program = const GenerateWorkoutProgramUseCase()(userProfile: answers);
      final again = const GenerateWorkoutProgramUseCase()(userProfile: answers);
      expect(program.days, isNotEmpty);
      expect(
        program.days.map((d) => d.exercises.length).toList(),
        again.days.map((d) => d.exercises.length).toList(),
        reason: 'Program generation must be deterministic',
      );

      final firstTrainingDay = program.days
          .indexWhere((d) => !d.isRestDay && d.exercises.isNotEmpty);
      expect(firstTrainingDay, isNot(-1));

      final activeRepo = _InMemoryActiveProgramRepository();
      await activeRepo.saveActiveProgram(ActiveProgram(
        id: 'active_1',
        program: program,
        currentDayIndex: firstTrainingDay,
        isActive: true,
        userId: user.id,
      ));

      // Workout: start from the plan, log sets, finish.
      final workoutRepo = _workoutRepoFor(user.id);
      var session = await StartWorkoutUseCase(workoutRepo, activeRepo)();
      expect(session.userId, user.id);
      expect(session.programDayIndex, firstTrainingDay);
      expect(
        session.exercises.length,
        program.days[firstTrainingDay].exercises.length,
      );

      final logSet = LogSetUseCase();
      final t = DateTime.now();
      final logged = <Exercise>[];
      for (final exercise in session.exercises) {
        var e = await logSet(
          exercise,
          SetEntry(id: '${exercise.id}_w', reps: 10, weight: 40, timestamp: t, type: SetType.warmup),
        );
        for (var i = 0; i < 3; i++) {
          e = await logSet(
            e,
            SetEntry(id: '${exercise.id}_$i', reps: 8, weight: 60, timestamp: t),
          );
        }
        logged.add(e);
      }
      session = session.copyWith(exercises: logged);

      final nextDay = (await activeRepo.loadActiveProgram())!.nextWorkoutDayIndex;
      await CompleteWorkoutUseCase(
        saveWorkout: SaveWorkoutUseCase(workoutRepo, CalculateWorkoutVolumeUseCase()),
        activeProgramRepository: activeRepo,
      )(session, const Duration(minutes: 45));

      // Summary: saved once, owned by the user, warm-ups excluded from volume,
      // and the program moved to the next training day.
      final saved = await workoutRepo.getAllWorkouts();
      expect(saved, hasLength(1));
      final summary = saved.single;
      expect(summary.userId, user.id);
      expect(summary.duration, const Duration(minutes: 45));
      expect(summary.totalVolume, logged.length * 3 * 8 * 60.0);

      final advanced = await activeRepo.loadActiveProgram();
      expect(advanced!.currentDayIndex, nextDay);
      expect(advanced.completedDays.containsKey(firstTrainingDay), isTrue);
    });

    test('J2 meal log updates daily totals and remaining macros', () async {
      const userId = 'uid_meal';
      final repo = _nutritionRepoFor(userId);
      await repo.saveNutritionTargets(_targets(userId));

      final save = SaveMealUseCase(repo);
      await save(_meal(
        id: 'm_breakfast',
        name: 'Breakfast',
        calories: 500,
        protein: 30,
        carbs: 60,
        fats: 15,
        timestamp: _todayAt(8),
      ));
      await save(_meal(
        id: 'm_lunch',
        name: 'Lunch',
        calories: 700,
        protein: 50,
        carbs: 70,
        fats: 20,
        timestamp: _todayAt(13),
      ));

      final summary = await GetDailyNutritionSummaryUseCase(repo)(_todayAt(12));
      expect(summary.meals, hasLength(2));
      expect(summary.totalCalories, 1200);
      expect(summary.totalProtein, 80);
      expect(summary.meals.every((m) => m.userId == userId), isTrue);

      final targets = await repo.getNutritionTargets();
      expect(targets, isNotNull);
      final remaining = targets!.getRemainingMacros(MacroTargets(
        calories: summary.totalCalories,
        protein: summary.totalProtein,
        carbs: summary.totalCarbs,
        fats: summary.totalFats,
      ));
      expect(remaining.calories, 800);
      expect(remaining.protein, 70);

      // Deleting a meal updates the totals.
      await repo.deleteMealEntry('m_lunch');
      final after = await GetDailyNutritionSummaryUseCase(repo)(_todayAt(12));
      expect(after.totalCalories, 500);
    });

    test('J3 recipe add (custom food) -> scale by grams -> log -> totals', () async {
      // The app stores a user's own recipe as a custom food (per 100 g).
      // NOTE: there is no multi-ingredient recipe builder in lib/features;
      // this journey covers the custom-food path that exists today.
      const chefId = 'uid_chef';
      final chefFoods = HiveFoodDataSource(userId: chefId);
      await chefFoods.saveCustomFood(const FoodItemFullModel(
        id: 'custom_overnight_oats',
        name: 'My overnight oats',
        category: 'custom',
        macros: MacrosPer100gModel(calories: 150, protein: 6, carbs: 24, fats: 3.5),
        micros: MicrosPer100gModel(fiber: 3, sugar: 8, sodium: 40, potassium: 150),
        vitamins: VitaminsPer100gModel(
          vitaminA: 0,
          vitaminB: 0,
          vitaminC: 0,
          vitaminD: 0,
          vitaminE: 0,
        ),
        minerals: MineralsPer100gModel(calcium: 80, iron: 1, magnesium: 30, zinc: 1),
        imageUrl: '',
      ));

      final mine = await chefFoods.getCustomFoods();
      expect(mine.map((f) => f.id), ['custom_overnight_oats']);
      // Custom foods are personal: another account on this device sees none.
      expect(await HiveFoodDataSource(userId: 'uid_other').getCustomFoods(), isEmpty);

      final recipe = mine.single;
      final portion = MacroCalculator.scaleMacros(
        caloriesPer100g: recipe.macros.calories,
        proteinPer100g: recipe.macros.protein,
        carbsPer100g: recipe.macros.carbs,
        fatsPer100g: recipe.macros.fats,
        grams: 250,
      );
      expect(portion.calories, closeTo(375, 0.001));
      expect(portion.protein, closeTo(15, 0.001));
      expect(portion.fats, closeTo(8.75, 0.001));

      final repo = _nutritionRepoFor(chefId);
      await SaveMealUseCase(repo)(_meal(
        id: 'm_oats',
        name: recipe.name,
        calories: portion.calories,
        protein: portion.protein,
        carbs: portion.carbs,
        fats: portion.fats,
        timestamp: _todayAt(9),
        foodItemId: recipe.id,
      ));

      final summary = await GetDailyNutritionSummaryUseCase(repo)(_todayAt(12));
      expect(summary.meals.single.foodItemId, 'custom_overnight_oats');
      expect(summary.totalCalories, closeTo(375, 0.001));
    });

    test('J4 AI coach online (proxy) and offline (local coach fallback)', () async {
      // Online: request goes to the proxy with the user token, never with a
      // direct API key in the URL.
      http.Request? sent;
      final online = ProviderContainer(overrides: [
        aiChatStorageProvider.overrideWithValue(null),
        geminiAIServiceProvider.overrideWithValue(GeminiAIService(
          apiKey: '',
          proxyUrl: 'https://ai-proxy.example.test/aiGenerate',
          allowDirectApiKey: false,
          authTokenProvider: () async => 'test-id-token',
          appCheckTokenProvider: () async => 'test-app-check-token',
          httpClient: MockClient((request) async {
            sent = request;
            return _proxyOk('Rest about 2 minutes between heavy sets.');
          }),
        )),
      ]);
      addTearDown(online.dispose);

      await online.read(aiChatProvider.notifier).sendMessage('How long should I rest?');
      final onlineState = online.read(aiChatProvider);
      expect(onlineState.isOfflineFallback, isFalse);
      expect(onlineState.error, isNull);
      expect(onlineState.messages.map((m) => m.role), ['user', 'assistant']);
      expect(onlineState.messages.last.content, 'Rest about 2 minutes between heavy sets.');
      expect(sent, isNotNull);
      expect(sent!.url.host, 'ai-proxy.example.test');
      expect(sent!.url.queryParameters.containsKey('key'), isFalse);
      expect(sent!.headers['Authorization'], 'Bearer test-id-token');
      expect(sent!.headers['X-Firebase-AppCheck'], 'test-app-check-token');

      // Offline: network fails -> the local coach answers and the user sees a
      // short, plain message with a retry option.
      final offline = ProviderContainer(overrides: [
        aiChatStorageProvider.overrideWithValue(null),
        geminiAIServiceProvider.overrideWithValue(GeminiAIService(
          apiKey: '',
          proxyUrl: 'https://ai-proxy.example.test/aiGenerate',
          allowDirectApiKey: false,
          authTokenProvider: () async => 'test-id-token',
          appCheckTokenProvider: () async => null,
          httpClient: MockClient((_) async => throw const SocketException('offline')),
        )),
      ]);
      addTearDown(offline.dispose);

      await offline.read(aiChatProvider.notifier).sendMessage('How long should I rest?');
      final offlineState = offline.read(aiChatProvider);
      expect(offlineState.isOfflineFallback, isTrue);
      expect(offlineState.isLoading, isFalse);
      expect(offlineState.error, contains('internet connection'));
      expect(offlineState.lastFailedMessage, 'How long should I rest?');
      expect(offlineState.messages.last.role, 'assistant');
      expect(offlineState.messages.last.content.trim(), isNotEmpty);

      // Not configured at all (no proxy, no debug key): local coach, no HTTP.
      var calls = 0;
      final unconfigured = ProviderContainer(overrides: [
        aiChatStorageProvider.overrideWithValue(null),
        geminiAIServiceProvider.overrideWithValue(GeminiAIService(
          apiKey: '',
          proxyUrl: '',
          allowDirectApiKey: false,
          httpClient: MockClient((_) async {
            calls++;
            return _proxyOk('should not be called');
          }),
        )),
      ]);
      addTearDown(unconfigured.dispose);

      expect(unconfigured.read(aiChatProvider).isKeyMissing, isTrue);
      await unconfigured.read(aiChatProvider.notifier).sendMessage('Hi');
      expect(calls, 0);
      expect(unconfigured.read(aiChatProvider).isOfflineFallback, isTrue);
    });

    test('J5 backup and restore brings back workouts, meals and body data', () async {
      final authDs = _InMemoryAuthDataSource();
      final auth = AuthRepositoryImpl(
        authDataSource: authDs,
        userDataSource: _InMemoryUserDataSource(),
      );
      // The restore flow stamps restored records with the signed-in user's ID.
      final signedInUser = await auth.signUpWithEmail(
        email: 'backup@example.test',
        password: 'Password123!',
      );
      final userId = signedInUser.id;
      final workoutRepo = _workoutRepoFor(userId);
      final nutritionRepo = _nutritionRepoFor(userId);
      final bodyRepo = _InMemoryBodyRepository();

      final docs = Directory('${tempDir.path}/docs_backup')..createSync(recursive: true);
      final restore = RestoreDataUseCase(workoutRepo, nutritionRepo, bodyRepo, auth, null, docs);

      final day = DateTime.now().subtract(const Duration(days: 1));
      await workoutRepo.saveWorkout(_workout(id: 'w_backup', userId: userId, date: day));
      await nutritionRepo.saveMealEntry(_meal(
        id: 'm_backup',
        name: 'Dinner',
        calories: 650,
        protein: 45,
        carbs: 60,
        fats: 22,
        timestamp: _todayAt(19),
        userId: userId,
      ));
      await bodyRepo.saveBodyEntry(BodyEntry(
        id: 'b_backup',
        date: day,
        weight: 81.5,
        measurements: const {},
        userId: userId,
      ));

      final snapshot = await restore.createSafetySnapshot();
      expect(await snapshot.exists(), isTrue);

      // Simulate data loss.
      await workoutRepo.deleteWorkout('w_backup');
      await nutritionRepo.clearAllData();
      bodyRepo.entries.clear();
      expect(await workoutRepo.getAllWorkouts(), isEmpty);
      expect(await nutritionRepo.getMealsByDate(_todayAt(12)), isEmpty);

      final result = await restore.restoreFromLocalFile(snapshot.path, overwriteExisting: true);
      expect(result.success, isTrue, reason: result.errors.join('; '));

      final workouts = await workoutRepo.getAllWorkouts();
      expect(workouts.map((w) => w.id), ['w_backup']);
      expect(workouts.single.totalVolume, 500);
      final meals = await nutritionRepo.getMealsByDate(_todayAt(12));
      expect(meals.map((m) => m.id), ['m_backup']);
      expect(meals.single.macros.calories, 650);
      expect(bodyRepo.entries['b_backup']?.weight, 81.5);
    });

    test('J6 account deletion purges cloud, deletes auth and wipes local data', () async {
      final authDs = _InMemoryAuthDataSource();
      final userDs = _InMemoryUserDataSource();
      final auth = AuthRepositoryImpl(authDataSource: authDs, userDataSource: userDs);
      final user = await auth.signUpWithEmail(
        email: 'leaving@example.test',
        password: 'Password123!',
      );

      await _workoutRepoFor(user.id)
          .saveWorkout(_workout(id: 'w_leave', userId: user.id, date: DateTime.now()));
      await _nutritionRepoFor(user.id).saveMealEntry(_meal(
        id: 'm_leave',
        name: 'Snack',
        calories: 200,
        protein: 10,
        carbs: 20,
        fats: 8,
        timestamp: _todayAt(16),
        userId: user.id,
      ));

      final purger = _RecordingRemotePurger();
      final notifications = _NoopNotificationService();
      final secure = _NoopSecureStorage();
      final docs = Directory('${tempDir.path}/docs_delete')..createSync(recursive: true);
      File('${docs.path}/ironflow_backup.json').writeAsStringSync('{}');

      final deleteAccount = DeleteAccountUseCase(
        authRepository: auth,
        remoteDataPurger: purger,
        localDataWiper: LocalDataWiper(
          secureStorage: secure,
          notificationService: notifications,
          privateDocumentsDir: docs,
        ),
      );

      // 1. Cloud purge failure is surfaced and nothing is deleted.
      purger.failWith = const RemotePurgeException(['storage: permission-denied']);
      final failed = await deleteAccount(userId: user.id, password: 'Password123!');
      expect(failed.success, isFalse);
      expect(failed.message, contains('Failed to purge cloud records'));
      expect(authDs.hasAccount('leaving@example.test'), isTrue);
      expect(await _workoutRepoFor(user.id).getAllWorkouts(), hasLength(1));

      // 2. Wrong password is rejected before anything is deleted.
      purger.failWith = null;
      final wrong = await deleteAccount(userId: user.id, password: 'nope');
      expect(wrong.success, isFalse);
      expect(purger.purgedUserIds, isEmpty);

      // 3. Happy path.
      final ok = await deleteAccount(userId: user.id, password: 'Password123!');
      expect(ok.success, isTrue, reason: ok.message);
      expect(purger.purgedUserIds, [user.id]);
      expect(authDs.hasAccount('leaving@example.test'), isFalse);
      expect(userDs.profiles.containsKey(user.id), isFalse);
      expect(await auth.getCurrentUser(), isNull);
      expect(await _workoutRepoFor(user.id).getAllWorkouts(), isEmpty);
      expect(await _nutritionRepoFor(user.id).getMealsByDate(_todayAt(12)), isEmpty);
      expect(File('${docs.path}/ironflow_backup.json').existsSync(), isFalse);
      expect(notifications.cancelCalls, 1);
      expect(secure.clearCalls, 1);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString(DeleteAccountUseCase.pendingWipeKey), isNull);
    });

    test(
      'J6b KNOWN ISSUE W2-F1 (characterization): deleting one account also wipes '
      'another account\'s unsynced local records on the same device',
      () async {
        // Current behaviour, recorded so a fix is a visible, reviewed change.
        // LocalDataWiper clears whole shared boxes ('workouts', 'meals', ...)
        // instead of only the deleted user's records. Owner approval is needed
        // before changing this (storage behaviour). When fixed, flip the last
        // expectation to `hasLength(1)`.
        await _workoutRepoFor('uid_a')
            .saveWorkout(_workout(id: 'w_a', userId: 'uid_a', date: DateTime.now()));
        await _workoutRepoFor('uid_b')
            .saveWorkout(_workout(id: 'w_b', userId: 'uid_b', date: DateTime.now()));

        await LocalDataWiper(
          secureStorage: _NoopSecureStorage(),
          notificationService: _NoopNotificationService(),
          privateDocumentsDir: Directory('${tempDir.path}/docs_w2f1')..createSync(recursive: true),
        ).wipeAllUserData('uid_a');

        expect(await _workoutRepoFor('uid_a').getAllWorkouts(), isEmpty);
        expect(
          await _workoutRepoFor('uid_b').getAllWorkouts(),
          isEmpty,
          reason: 'W2-F1: user B data is lost today; expected to be kept after the fix',
        );
      },
    );

    test('J7 two users on one device never see each other\'s data', () async {
      final authDs = _InMemoryAuthDataSource();
      final auth = AuthRepositoryImpl(
        authDataSource: authDs,
        userDataSource: _InMemoryUserDataSource(),
      );
      final signUp = SignUpWithEmailUseCase(auth);
      final signIn = SignInWithEmailUseCase(auth);
      final signOut = SignOutUseCase(auth);
      final now = DateTime.now();

      // User A logs a workout and a meal.
      final a = await signUp(
        email: 'a@example.test',
        password: 'Password123!',
        confirmPassword: 'Password123!',
      );
      await _workoutRepoFor(a.id).saveWorkout(_workout(id: 'w_a', userId: a.id, date: now));
      await _nutritionRepoFor(a.id).saveMealEntry(_meal(
        id: 'm_a',
        name: 'A lunch',
        calories: 600,
        protein: 40,
        carbs: 60,
        fats: 20,
        timestamp: _todayAt(12),
        userId: a.id,
      ));
      await signOut();
      expect(await auth.getCurrentUser(), isNull);

      // User B signs up on the same device: sees nothing from A.
      final b = await signUp(
        email: 'b@example.test',
        password: 'Password123!',
        confirmPassword: 'Password123!',
      );
      expect(b.id, isNot(a.id));
      final bWorkouts = _workoutRepoFor(b.id);
      final bMeals = _nutritionRepoFor(b.id);
      expect(await bWorkouts.getAllWorkouts(), isEmpty);
      expect(await bMeals.getMealsByDate(_todayAt(12)), isEmpty);

      // B logs a workout. B cannot overwrite or delete A's record by id.
      await bWorkouts.saveWorkout(_workout(id: 'w_b', userId: b.id, date: now, weight: 50));
      await bWorkouts.saveWorkout(_workout(id: 'w_a', userId: b.id, date: now, weight: 1));
      await bWorkouts.deleteWorkout('w_a');
      expect((await bWorkouts.getAllWorkouts()).map((w) => w.id), ['w_b']);
      await signOut();

      // A signs back in: only A's data, unchanged.
      final aAgain = await signIn(email: 'a@example.test', password: 'Password123!');
      expect(aAgain.id, a.id);
      final aWorkouts = await _workoutRepoFor(a.id).getAllWorkouts();
      expect(aWorkouts.map((w) => w.id), ['w_a']);
      expect(aWorkouts.single.totalVolume, 500);
      final aMeals = await _nutritionRepoFor(a.id).getMealsByDate(_todayAt(12));
      expect(aMeals.map((m) => m.id), ['m_a']);
    });
  });
}
