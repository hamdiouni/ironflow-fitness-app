import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:progression_tracker/features/notifications/domain/services/notification_service.dart';
import 'package:progression_tracker/features/notifications/presentation/providers/notification_providers.dart';
import 'package:progression_tracker/features/workout/presentation/managers/workout_state_manager.dart';
import 'package:progression_tracker/features/workout/presentation/providers/rest_timer_provider.dart';
import 'package:progression_tracker/features/workout/presentation/providers/workout_providers.dart';

class FakeNotificationService implements NotificationService {
  DateTime? scheduledTargetTime;
  bool cancelled = false;

  @override
  Future<void> scheduleRestTimer(DateTime targetEndTime) async {
    scheduledTargetTime = targetEndTime;
  }

  @override
  Future<void> cancelRestTimer() async {
    cancelled = true;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeWorkoutStateManager implements WorkoutStateManager {
  DateTime? savedTargetEndTime;
  int? savedTotalSeconds;
  bool cleared = false;

  @override
  Future<void> saveRestTimer(
    DateTime targetEndTime,
    int totalSeconds, {
    String? userId,
  }) async {
    savedTargetEndTime = targetEndTime;
    savedTotalSeconds = totalSeconds;
  }

  @override
  ({DateTime targetEndTime, int totalSeconds})? getRestTimer({
    String? userId,
  }) {
    if (savedTargetEndTime == null || savedTotalSeconds == null) return null;
    return (targetEndTime: savedTargetEndTime!, totalSeconds: savedTotalSeconds!);
  }

  @override
  Future<void> clearRestTimer({String? userId}) async {
    savedTargetEndTime = null;
    savedTotalSeconds = null;
    cleared = true;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('RestTimerProvider (TRN-02)', () {
    late FakeNotificationService notificationService;
    late FakeWorkoutStateManager stateManager;
    late ProviderContainer container;

    setUp(() {
      notificationService = FakeNotificationService();
      stateManager = FakeWorkoutStateManager();

      container = ProviderContainer(
        overrides: [
          notificationServiceProvider.overrideWithValue(notificationService),
          workoutStateManagerProvider.overrideWithValue(stateManager),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state has default zeroed values', () {
      final state = container.read(restTimerProvider);
      expect(state.remainingSeconds, 0);
      expect(state.totalSeconds, 0);
      expect(state.isRunning, isFalse);
      expect(state.isPaused, isFalse);
      expect(state.isComplete, isFalse);
      expect(state.targetEndTime, isNull);
      expect(state.progress, 0.0);
      expect(state.formattedTime, '00:00');
    });

    test('start() populates state and records targetEndTime', () {
      final notifier = container.read(restTimerProvider.notifier);
      notifier.start(90);

      final state = container.read(restTimerProvider);
      expect(state.remainingSeconds, 90);
      expect(state.totalSeconds, 90);
      expect(state.isRunning, isTrue);
      expect(state.isPaused, isFalse);
      expect(state.isComplete, isFalse);
      expect(state.targetEndTime, isNotNull);
      expect(state.formattedTime, '01:30');
    });

    test('pause() and resume() update isPaused and targetEndTime correctly', () {
      final notifier = container.read(restTimerProvider.notifier);
      notifier.start(60);

      notifier.pause();
      var state = container.read(restTimerProvider);
      expect(state.isRunning, isFalse);
      expect(state.isPaused, isTrue);
      expect(state.targetEndTime, isNull);

      notifier.resume();
      state = container.read(restTimerProvider);
      expect(state.isRunning, isTrue);
      expect(state.isPaused, isFalse);
      expect(state.targetEndTime, isNotNull);
    });

    test('addTime() extends timer state', () {
      final notifier = container.read(restTimerProvider.notifier);
      notifier.start(60);
      final initialTarget = container.read(restTimerProvider).targetEndTime!;

      notifier.addTime(30);
      final state = container.read(restTimerProvider);
      expect(state.totalSeconds, 90);
      expect(state.targetEndTime, initialTarget.add(const Duration(seconds: 30)));
    });

    test('stop() resets state completely', () {
      final notifier = container.read(restTimerProvider.notifier);
      notifier.start(60);

      notifier.stop();
      final state = container.read(restTimerProvider);
      expect(state.isRunning, isFalse);
      expect(state.remainingSeconds, 0);
      expect(state.totalSeconds, 0);
      expect(state.targetEndTime, isNull);
    });

    test('sync() recomputes remaining seconds from service timestamp', () {
      final futureTarget = DateTime.now().add(const Duration(seconds: 45));
      stateManager.saveRestTimer(futureTarget, 90);

      final notifier = container.read(restTimerProvider.notifier);
      notifier.sync();

      final state = container.read(restTimerProvider);
      expect(state.isRunning, isTrue);
      expect(state.remainingSeconds, closeTo(45, 2));
      expect(state.totalSeconds, 90);
      expect(state.targetEndTime, futureTarget);
    });
  });
}
