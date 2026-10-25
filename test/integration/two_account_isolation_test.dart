import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:progression_tracker/features/auth/domain/entities/user.dart';
import 'package:progression_tracker/features/auth/domain/repositories/auth_repository.dart';
import 'package:progression_tracker/features/auth/presentation/providers/auth_notifier.dart';
import 'package:progression_tracker/features/auth/presentation/providers/auth_provider.dart';
import 'package:progression_tracker/features/notifications/domain/services/notification_service.dart';
import 'package:progression_tracker/features/notifications/presentation/providers/notification_providers.dart';
import 'package:progression_tracker/features/sync/data/datasources/hive_sync_queue_datasource.dart';
import 'package:progression_tracker/features/workout/domain/entities/entities.dart';
import 'package:progression_tracker/features/workout/presentation/managers/workout_state_manager.dart';
import 'package:progression_tracker/features/workout/presentation/providers/workout_providers.dart';

class _MockNotificationService implements NotificationService {
  int cancelAllCount = 0;
  DateTime? lastScheduledRestTimer;
  int cancelRestTimerCount = 0;

  @override
  Future<void> cancelAllNotifications() async {
    cancelAllCount++;
  }

  @override
  Future<void> scheduleRestTimer(DateTime targetEndTime) async {
    lastScheduledRestTimer = targetEndTime;
  }

  @override
  Future<void> cancelRestTimer() async {
    cancelRestTimerCount++;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _MockAuthRepository implements AuthRepository {
  User? _currentUser;

  void setCurrentUser(User? user) {
    _currentUser = user;
  }

  @override
  Future<User?> getCurrentUser() async => _currentUser;

  @override
  Future<bool> isAuthenticated() async => _currentUser != null;

  @override
  Future<void> signOut() async {
    _currentUser = null;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  late _MockNotificationService notificationService;
  late _MockAuthRepository authRepository;
  late WorkoutStateManager workoutStateManager;
  late HiveSyncQueueDataSourceImpl syncQueueDataSource;
  late ProviderContainer container;

  User makeUser(String id) {
    return User(
      id: id,
      email: '$id@ironflow.com',
      displayName: id,
      photoUrl: null,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );
  }

  final aliceWorkout = Workout(
    id: 'workout_alice_1',
    userId: 'Alice',
    date: DateTime(2026, 10, 20, 10, 0),
    duration: const Duration(minutes: 50),
    totalVolume: 4200.0,
    caloriesBurned: 350.0,
    exercises: [
      Exercise(
        id: 'ex_bench',
        name: 'Bench Press',
        type: ExerciseType.strength,
        sets: [
          SetEntry(
            id: 'set_1',
            reps: 8,
            weight: 90.0,
            rpe: 8,
            timestamp: DateTime(2026, 10, 20, 10, 15),
          ),
        ],
      ),
    ],
  );

  final bobWorkout = Workout(
    id: 'workout_bob_1',
    userId: 'bob',
    date: DateTime(2026, 10, 21, 14, 0),
    duration: const Duration(minutes: 40),
    totalVolume: 2500.0,
    caloriesBurned: 220.0,
    exercises: [
      Exercise(
        id: 'ex_squat',
        name: 'Squat',
        type: ExerciseType.strength,
        sets: [
          SetEntry(
            id: 'set_b1',
            reps: 10,
            weight: 100.0,
            rpe: 7,
            timestamp: DateTime(2026, 10, 21, 14, 20),
          ),
        ],
      ),
    ],
  );

  setUpAll(() async {
    tempDir = Directory.systemTemp.createTempSync('two_account_isolation_');
    Hive.init(tempDir.path);
    await Hive.openBox<dynamic>('active_workout_state');
    await Hive.openBox<String>('app_settings');
    await Hive.openBox<dynamic>('reminder_settings');
    await Hive.openBox<dynamic>('sync_queue');
  });

  setUp(() async {
    notificationService = _MockNotificationService();
    authRepository = _MockAuthRepository();
    workoutStateManager = WorkoutStateManager();
    await workoutStateManager.init();
    syncQueueDataSource = HiveSyncQueueDataSourceImpl();

    container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(authRepository),
        notificationServiceProvider.overrideWithValue(notificationService),
        workoutStateManagerProvider.overrideWithValue(workoutStateManager),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  tearDownAll(() async {
    await Hive.close();
    try {
      tempDir.deleteSync(recursive: true);
    } catch (_) {}
  });

  test('Two-account isolation: account switch does not leak workout, timer, or reminders',
      () async {
    final authNotifier = container.read(authNotifierProvider.notifier);

    // 1. Alice logs in
    authRepository.setCurrentUser(makeUser('Alice'));
    authNotifier.state = AuthState(
      user: makeUser('Alice'),
      isAuthenticated: true,
    );
    await Future<void>.delayed(Duration.zero);
    expect(container.read(currentUserIdProvider), 'Alice');

    // Alice saves active workout and rest timer
    final aliceStart = DateTime(2026, 10, 20, 10, 0);
    await workoutStateManager.saveState(aliceWorkout, aliceStart, userId: 'Alice');
    final aliceTimerEnd = DateTime.now().add(const Duration(seconds: 90));
    await workoutStateManager.saveRestTimer(aliceTimerEnd, 90, userId: 'Alice');

    // Alice has sync queue cursor
    final aliceSyncTime = DateTime(2026, 10, 20, 10, 30);
    await syncQueueDataSource.setCursor('workouts', aliceSyncTime, userId: 'Alice');

    expect(workoutStateManager.hasSavedStateForUser('Alice'), isTrue);
    expect(workoutStateManager.getRestTimer(userId: 'Alice')?.totalSeconds, 90);
    expect(await syncQueueDataSource.getCursor('workouts', userId: 'Alice'), aliceSyncTime);

    // 2. Alice signs out -> notifications must be cancelled
    final initialCancelCount = notificationService.cancelAllCount;
    await authNotifier.signOut();
    expect(notificationService.cancelAllCount, initialCancelCount + 1);
    expect(container.read(currentUserIdProvider), isNull);

    // 3. Bob logs in
    authRepository.setCurrentUser(makeUser('bob'));
    authNotifier.state = AuthState(
      user: makeUser('bob'),
      isAuthenticated: true,
    );
    await Future<void>.delayed(Duration.zero);
    expect(container.read(currentUserIdProvider), 'bob');

    // Verify Bob does NOT see Alice's workout, rest timer, or sync cursor
    expect(workoutStateManager.hasSavedStateForUser('bob'), isFalse);
    expect(await workoutStateManager.restoreState(userId: 'bob'), isNull);
    expect(workoutStateManager.getRestTimer(userId: 'bob'), isNull);
    expect(await syncQueueDataSource.getCursor('workouts', userId: 'bob'), isNull);

    // Bob creates his own workout and rest timer
    final bobStart = DateTime(2026, 10, 21, 14, 0);
    await workoutStateManager.saveState(bobWorkout, bobStart, userId: 'bob');
    final bobTimerEnd = DateTime.now().add(const Duration(seconds: 120));
    await workoutStateManager.saveRestTimer(bobTimerEnd, 120, userId: 'bob');
    final bobSyncTime = DateTime(2026, 10, 21, 14, 30);
    await syncQueueDataSource.setCursor('workouts', bobSyncTime, userId: 'bob');

    expect(workoutStateManager.hasSavedStateForUser('bob'), isTrue);
    expect(workoutStateManager.getRestTimer(userId: 'bob')?.totalSeconds, 120);
    expect(await syncQueueDataSource.getCursor('workouts', userId: 'bob'), bobSyncTime);

    // 4. Bob signs out
    await authNotifier.signOut();
    expect(notificationService.cancelAllCount, initialCancelCount + 2);
    expect(container.read(currentUserIdProvider), isNull);

    // 5. Alice logs back in -> Alice's data is intact and contains no Bob data
    authRepository.setCurrentUser(makeUser('Alice'));
    authNotifier.state = AuthState(
      user: makeUser('Alice'),
      isAuthenticated: true,
    );
    await Future<void>.delayed(Duration.zero);
    expect(container.read(currentUserIdProvider), 'Alice');

    final restoredAlice = await workoutStateManager.restoreState(userId: 'Alice');
    expect(restoredAlice, isNotNull);
    expect(restoredAlice!.workout.id, 'workout_alice_1');
    expect(restoredAlice.workout.userId, 'Alice');
    expect(workoutStateManager.getRestTimer(userId: 'Alice')?.totalSeconds, 90);
    expect(await syncQueueDataSource.getCursor('workouts', userId: 'Alice'), aliceSyncTime);

    // Verify Bob's data was not corrupted or exposed to Alice
    expect(restoredAlice.workout.exercises.first.name, 'Bench Press');
    expect(restoredAlice.workout.exercises.first.name, isNot('Squat'));
  });

  test('Offline-to-online sync queue keeps separate markers for each account', () async {
    // Initial-push markers are stored separately
    await syncQueueDataSource.markInitialPushComplete('Alice');
    expect(await syncQueueDataSource.hasCompletedInitialPush('Alice'), isTrue);
    expect(await syncQueueDataSource.hasCompletedInitialPush('bob'), isFalse);

    await syncQueueDataSource.markInitialPushComplete('bob');
    expect(await syncQueueDataSource.hasCompletedInitialPush('bob'), isTrue);

    // Sync cursors are stored under canonical storage scope
    final t1 = DateTime(2026, 10, 22, 9, 0);
    final t2 = DateTime(2026, 10, 22, 10, 0);
    await syncQueueDataSource.setCursor('meals', t1, userId: 'Alice');
    await syncQueueDataSource.setCursor('meals', t2, userId: 'bob');

    expect(await syncQueueDataSource.getCursor('meals', userId: 'Alice'), t1);
    expect(await syncQueueDataSource.getCursor('meals', userId: 'bob'), t2);
  });
}
