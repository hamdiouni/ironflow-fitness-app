import 'package:flutter_test/flutter_test.dart';
import 'package:progression_tracker/features/notifications/domain/services/notification_service.dart';
import 'package:progression_tracker/features/workout/domain/services/rest_timer_service.dart';
import 'package:progression_tracker/features/workout/presentation/managers/workout_state_manager.dart';

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
  group('RestTimerService (TRN-02 Absolute Timestamp & Notifications)', () {
    late FakeNotificationService notificationService;
    late FakeWorkoutStateManager stateManager;
    late RestTimerService service;

    setUp(() {
      notificationService = FakeNotificationService();
      stateManager = FakeWorkoutStateManager();
      service = RestTimerService(
        notificationService: notificationService,
        stateManager: stateManager,
      );
    });

    tearDown(() {
      service.dispose();
    });

    test('start() uses absolute target timestamp and notifies dependencies', () {
      final before = DateTime.now();
      int? tickedSeconds;
      service.onTick = (secs) => tickedSeconds = secs;

      service.start(90);

      final after = DateTime.now();

      expect(service.isRunning, isTrue);
      expect(service.isPaused, isFalse);
      expect(service.totalSeconds, 90);
      expect(service.remainingSeconds, 90);
      expect(tickedSeconds, 90);

      expect(service.targetEndTime, isNotNull);
      expect(
        service.targetEndTime!.isAfter(before.add(const Duration(seconds: 89))),
        isTrue,
      );
      expect(
        service.targetEndTime!.isBefore(after.add(const Duration(seconds: 91))),
        isTrue,
      );

      // Verify persisted state & scheduled notification
      expect(stateManager.savedTargetEndTime, service.targetEndTime);
      expect(stateManager.savedTotalSeconds, 90);
      expect(notificationService.scheduledTargetTime, service.targetEndTime);
    });

    test('stop() cancels ticker, clears state, and cancels scheduled notification', () {
      service.start(60);
      expect(service.isRunning, isTrue);

      service.stop();

      expect(service.isRunning, isFalse);
      expect(service.remainingSeconds, 0);
      expect(service.targetEndTime, isNull);
      expect(stateManager.cleared, isTrue);
      expect(notificationService.cancelled, isTrue);
    });

    test('pause() and resume() preserve remaining seconds and recompute target timestamp', () {
      service.start(60);
      notificationService.cancelled = false;

      service.pause();

      expect(service.isRunning, isFalse);
      expect(service.isPaused, isTrue);
      expect(service.targetEndTime, isNull);
      expect(notificationService.cancelled, isTrue);

      // Resume
      service.resume();

      expect(service.isRunning, isTrue);
      expect(service.isPaused, isFalse);
      expect(service.targetEndTime, isNotNull);
      expect(notificationService.scheduledTargetTime, service.targetEndTime);
    });

    test('addTime() extends targetEndTime and reschedules notification', () {
      service.start(60);
      final initialTarget = service.targetEndTime!;

      service.addTime(30);

      expect(service.totalSeconds, 90);
      expect(service.targetEndTime, initialTarget.add(const Duration(seconds: 30)));
      expect(notificationService.scheduledTargetTime, service.targetEndTime);
    });

    test('addTime(-100) completing remaining seconds triggers completion safely', () {
      bool completed = false;
      service.onComplete = () => completed = true;

      service.start(60);
      service.addTime(-120);

      expect(completed, isTrue);
      expect(service.isRunning, isFalse);
    });

    test('skip() triggers onComplete and stops timer', () {
      bool completed = false;
      service.onComplete = () => completed = true;

      service.start(60);
      service.skip();

      expect(completed, isTrue);
      expect(service.isRunning, isFalse);
    });

    test('sync() recomputes remaining seconds from absolute timestamp upon resume', () {
      service.start(60);
      // Simulate that the target end time is 25 seconds in the future
      final futureTarget = DateTime.now().add(const Duration(seconds: 25));
      stateManager.saveRestTimer(futureTarget, 60);

      // Create new service instance to simulate cold resume
      final resumedService = RestTimerService(
        notificationService: notificationService,
        stateManager: stateManager,
      );

      resumedService.sync();

      expect(resumedService.isRunning, isTrue);
      expect(resumedService.remainingSeconds, closeTo(25, 2));
      expect(resumedService.totalSeconds, 60);
      resumedService.dispose();
    });

    test('sync() triggers completion if target timestamp passed during backgrounding', () {
      bool completed = false;
      final pastTarget = DateTime.now().subtract(const Duration(seconds: 10));
      stateManager.saveRestTimer(pastTarget, 60);

      final resumedService = RestTimerService(
        notificationService: notificationService,
        stateManager: stateManager,
      );
      resumedService.onComplete = () => completed = true;

      resumedService.sync();

      expect(completed, isTrue);
      expect(resumedService.isRunning, isFalse);
      expect(stateManager.cleared, isTrue);
      resumedService.dispose();
    });

    test('formatTime formats MM:SS correctly', () {
      expect(service.formatTime(0), '00:00');
      expect(service.formatTime(9), '00:09');
      expect(service.formatTime(65), '01:05');
      expect(service.formatTime(120), '02:00');
    });
  });
}
