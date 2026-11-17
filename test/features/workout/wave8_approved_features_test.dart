import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:progression_tracker/core/platform/browser_notifier.dart';
import 'package:progression_tracker/features/notifications/data/services/rest_timer_live_notification.dart';
import 'package:progression_tracker/features/notifications/domain/services/notification_service.dart';
import 'package:progression_tracker/features/settings/domain/services/backup_record_codec.dart';
import 'package:progression_tracker/features/workout/data/models/exercise_model.dart';
import 'package:progression_tracker/features/workout/domain/entities/entities.dart';
import 'package:progression_tracker/features/workout/domain/services/rest_timer_live_surface.dart';
import 'package:progression_tracker/features/workout/domain/services/rest_timer_service.dart';
import 'package:progression_tracker/features/workout/domain/services/strength_engine.dart';
import 'package:progression_tracker/features/workout/domain/usecases/workout_metrics.dart';
import 'package:progression_tracker/features/workout/presentation/managers/workout_state_manager.dart';

class _SpyNotificationGateway implements LocalNotificationGateway {
  final List<String> calls = [];
  int? lastShowId;
  String? lastShowTitle;
  String? lastShowBody;
  NotificationDetails? lastShowDetails;
  int? lastCancelId;

  @override
  Future<void> show(
    int id,
    String title,
    String body,
    NotificationDetails details, {
    String? payload,
  }) async {
    calls.add('show:$id:$title');
    lastShowId = id;
    lastShowTitle = title;
    lastShowBody = body;
    lastShowDetails = details;
  }

  @override
  Future<void> cancel(int id) async {
    calls.add('cancel:$id');
    lastCancelId = id;
  }
}

class _SpyBrowserNotifier extends BrowserNotifier {
  _SpyBrowserNotifier({
    this.hidden = false,
  });

  bool supported = true;
  String perm = 'default';
  bool hidden;
  bool requested = false;
  final List<String> shownTitles = [];

  @override
  bool get isSupported => supported;

  @override
  String get permission => perm;

  @override
  bool get isPageHidden => hidden;

  @override
  Future<bool> requestPermission() async {
    requested = true;
    perm = 'granted';
    return true;
  }

  @override
  void show({
    required String title,
    required String body,
    required String tag,
  }) {
    shownTitles.add('$title:$body:$tag');
  }
}

class _SpyLiveSurface implements RestTimerLiveSurface {
  final List<String> events = [];
  DateTime? lastRunningEnd;
  int? lastRunningTotal;
  int? lastPausedRemaining;

  @override
  void showRunning({required DateTime endTime, required int totalSeconds}) {
    events.add('running:$totalSeconds');
    lastRunningEnd = endTime;
    lastRunningTotal = totalSeconds;
  }

  @override
  void showPaused({required int remainingSeconds}) {
    events.add('paused:$remainingSeconds');
    lastPausedRemaining = remainingSeconds;
  }

  @override
  void showCompleted() {
    events.add('completed');
  }

  @override
  void clear() {
    events.add('clear');
  }
}

class _FakeNotificationService implements NotificationService {
  DateTime? scheduledTarget;
  bool cancelled = false;

  @override
  Future<void> scheduleRestTimer(DateTime targetEndTime) async {
    scheduledTarget = targetEndTime;
  }

  @override
  Future<void> cancelRestTimer() async {
    cancelled = true;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeWorkoutStateManager implements WorkoutStateManager {
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
  ({DateTime targetEndTime, int totalSeconds})? getRestTimer({String? userId}) {
    if (savedTargetEndTime == null || savedTotalSeconds == null) return null;
    return (
      targetEndTime: savedTargetEndTime!,
      totalSeconds: savedTotalSeconds!,
    );
  }

  @override
  Future<void> clearRestTimer({String? userId}) async {
    cleared = true;
    savedTargetEndTime = null;
    savedTotalSeconds = null;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Wave 8.1 — Lock-Screen Rest Timer & Browser Notifier (ADR-004)', () {
    test('RestTimerService mirrors start/pause/resume/skip to RestTimerLiveSurface', () {
      final surface = _SpyLiveSurface();
      final service = RestTimerService(
        notificationService: _FakeNotificationService(),
        stateManager: _FakeWorkoutStateManager(),
        liveSurface: surface,
      );

      service.start(90);
      expect(surface.events, contains('running:90'));
      expect(surface.lastRunningTotal, 90);
      expect(service.isRunning, isTrue);

      service.pause();
      expect(surface.events, contains('clear'));
      expect(surface.events.last, startsWith('paused:'));
      expect(service.isPaused, isTrue);

      service.resume();
      expect(surface.events.last, startsWith('running:'));

      service.skip();
      expect(surface.events.last, 'clear');
      // Natural completion did not occur because the user skipped
      expect(surface.events.contains('completed'), isFalse);
    });

    test('Android RestTimerLiveNotification uses chronometerCountDown and ongoing details', () {
      final gateway = _SpyNotificationGateway();
      final now = DateTime(2026, 11, 17, 12, 0, 0);
      final liveNotif = RestTimerLiveNotification(
        gateway: gateway,
        platform: RestTimerSurfacePlatform.android,
        isAppInForeground: () => false,
        clock: () => now,
      );

      final endTime = now.add(const Duration(seconds: 90));
      liveNotif.showRunning(endTime: endTime, totalSeconds: 90);

      expect(gateway.calls, contains('show:98:Resting'));
      final details = gateway.lastShowDetails?.android;
      expect(details, isNotNull);
      expect(details!.channelId, 'rest_timer_live');
      expect(details.ongoing, isTrue);
      expect(details.usesChronometer, isTrue);
      expect(details.chronometerCountDown, isTrue);
      expect(details.onlyAlertOnce, isTrue);
      expect(details.playSound, isFalse);
      expect(details.when, endTime.millisecondsSinceEpoch);
      expect(details.timeoutAfter, 90000);
      expect(details.category, AndroidNotificationCategory.stopwatch);

      // Paused state
      liveNotif.showPaused(remainingSeconds: 45);
      expect(gateway.calls, contains('show:98:Rest paused'));
      final pausedDetails = gateway.lastShowDetails?.android;
      expect(pausedDetails!.usesChronometer, isFalse);

      // Completed in background -> cancels live, posts heads-up alert
      liveNotif.showCompleted();
      expect(gateway.calls, contains('cancel:98'));
      expect(gateway.calls, contains('show:99:⏱️ Rest Complete!'));

      // Clear removes live notification
      liveNotif.clear();
      expect(gateway.calls.last, 'cancel:98');
    });

    test('Web RestTimerLiveNotification requests permission on gesture and shows alert when tab hidden', () {
      final browser = _SpyBrowserNotifier(hidden: true);
      final liveNotif = RestTimerLiveNotification(
        browser: browser,
        platform: RestTimerSurfacePlatform.web,
      );

      liveNotif.showRunning(
        endTime: DateTime.now().add(const Duration(seconds: 60)),
        totalSeconds: 60,
      );
      expect(browser.requested, isTrue);
      expect(browser.permission, 'granted');

      liveNotif.showCompleted();
      expect(browser.shownTitles.length, 1);
      expect(browser.shownTitles.first, startsWith('Rest complete:'));
    });

    test('formatClock handles edge values correctly', () {
      expect(RestTimerLiveNotification.formatClock(0), '0:00');
      expect(RestTimerLiveNotification.formatClock(-5), '0:00');
      expect(RestTimerLiveNotification.formatClock(45), '0:45');
      expect(RestTimerLiveNotification.formatClock(90), '1:30');
      expect(RestTimerLiveNotification.formatClock(3600), '60:00');
    });
  });

  group('Wave 8.3 — e1RM Engine (ADR-004)', () {
    test('E1rmEngine.estimate matches Epley formula with 10-rep cap and 1-rep identity', () {
      // 1 rep returns exact weight
      expect(E1rmEngine.estimate(100.0, 1), 100.0);
      expect(E1rmEngine.estimate(100.0, 1, formula: E1rmFormula.brzycki), 100.0);

      // 5 reps at 140 kg -> 140 * (1 + 5/30) = 163.33 kg
      expect(E1rmEngine.estimate(140.0, 5), closeTo(163.33, 0.01));

      // 15 reps at 50 kg is capped at 10 reps -> 50 * (1 + 10/30) = 66.67 kg
      expect(E1rmEngine.estimate(50.0, 15), closeTo(66.67, 0.01));
      expect(E1rmEngine.estimate(50.0, 10), closeTo(66.67, 0.01));

      // Brzycki formula check: 100 kg x 5 reps -> 100 * 36 / (37 - 5) = 112.5 kg
      expect(
        E1rmEngine.estimate(100.0, 5, formula: E1rmFormula.brzycki),
        closeTo(112.5, 0.01),
      );

      // Invalid inputs return 0.0
      expect(E1rmEngine.estimate(0.0, 5), 0.0);
      expect(E1rmEngine.estimate(-10.0, 5), 0.0);
      expect(E1rmEngine.estimate(100.0, 0), 0.0);
      expect(E1rmEngine.estimate(double.infinity, 5), 0.0);
    });

    test('E1rmEngine.weightForReps inverts Epley formula', () {
      final e1rm = E1rmEngine.estimate(100.0, 5);
      expect(E1rmEngine.weightForReps(e1rm, 5), closeTo(100.0, 0.01));
      expect(E1rmEngine.weightForReps(100.0, 1), 100.0);
    });

    test('countsForE1rm excludes warmups, drop sets, and invalid weights', () {
      final now = DateTime.now();
      expect(
        E1rmEngine.countsForE1rm(
          SetEntry(id: '1', reps: 5, weight: 100, timestamp: now, type: SetType.normal),
        ),
        isTrue,
      );
      expect(
        E1rmEngine.countsForE1rm(
          SetEntry(id: '2', reps: 5, weight: 100, timestamp: now, type: SetType.warmup),
        ),
        isFalse,
      );
      expect(
        E1rmEngine.countsForE1rm(
          SetEntry(id: '3', reps: 5, weight: 80, timestamp: now, type: SetType.drop),
        ),
        isFalse,
      );
      expect(
        E1rmEngine.countsForE1rm(
          SetEntry(id: '4', reps: 0, weight: 100, timestamp: now, type: SetType.normal),
        ),
        isFalse,
      );
      expect(
        E1rmEngine.countsForE1rm(
          SetEntry(id: '5', reps: 5, weight: 0, timestamp: now, type: SetType.normal),
        ),
        isFalse,
      );
    });

    test('WorkoutMetrics.calculateEstimated1RM delegates cleanly to E1rmEngine', () {
      expect(
        WorkoutMetrics.calculateEstimated1RM(140.0, 5),
        E1rmEngine.estimate(140.0, 5),
      );
      expect(
        WorkoutMetrics.calculateEstimated1RM(50.0, 15),
        E1rmEngine.estimate(50.0, 15),
      );
    });

    test('E1rmEngine.trend calculates progression points across sessions', () {
      final d1 = DateTime(2026, 11, 1);
      final d2 = DateTime(2026, 11, 5);
      final workouts = [
        Workout(
          id: 'w1',
          date: d1,
          duration: const Duration(minutes: 45),
          totalVolume: 1000,
          exercises: [
            Exercise(
              id: 'e1',
              name: 'Bench Press',
              type: ExerciseType.strength,
              exerciseDefinitionId: 'bench-press',
              sets: [
                SetEntry(id: 's1', reps: 5, weight: 100, timestamp: d1, type: SetType.normal),
                SetEntry(id: 's2', reps: 5, weight: 105, timestamp: d1, type: SetType.normal),
              ],
            ),
          ],
        ),
        Workout(
          id: 'w2',
          date: d2,
          duration: const Duration(minutes: 45),
          totalVolume: 1000,
          exercises: [
            Exercise(
              id: 'e2',
              name: 'Bench Press',
              type: ExerciseType.strength,
              exerciseDefinitionId: 'bench-press',
              sets: [
                SetEntry(id: 's3', reps: 5, weight: 110, timestamp: d2, type: SetType.normal),
              ],
            ),
          ],
        ),
      ];

      final trend = E1rmEngine.trend(workouts, 'bench-press');
      expect(trend.length, 2);
      expect(trend[0].weight, 105.0);
      expect(trend[1].weight, 110.0);
      expect(trend[1].e1rm, greaterThan(trend[0].e1rm));
    });
  });

  group('Wave 8.3 — Drop Set Planner (ADR-004)', () {
    test('DropSetPlanner.plan generates stepped weight drops rounded down', () {
      final drops = DropSetPlanner.plan(
        startWeight: 100.0,
        drops: 2,
        dropPercent: 0.2, // 20% drops
        increment: 2.5,
      );
      // 100 * 0.8 = 80.0
      // 80 * 0.8 = 64.0 -> rounded down to 2.5 step: 62.5
      expect(drops, [80.0, 62.5]);
    });

    test('DropSetPlanner.chains groups top set with subsequent drop sets', () {
      final now = DateTime.now();
      final sets = [
        SetEntry(id: '1', reps: 10, weight: 100, timestamp: now, type: SetType.normal),
        SetEntry(id: '2', reps: 10, weight: 80, timestamp: now, type: SetType.drop),
        SetEntry(id: '3', reps: 12, weight: 60, timestamp: now, type: SetType.drop),
        SetEntry(id: '4', reps: 8, weight: 105, timestamp: now, type: SetType.normal),
      ];

      final chains = DropSetPlanner.chains(sets);
      expect(chains.length, 2);
      expect(chains[0].topSet.weight, 100.0);
      expect(chains[0].drops.length, 2);
      expect(chains[0].totalReps, 32);
      expect(chains[0].totalVolume, 100 * 10 + 80 * 10 + 60 * 12);
      expect(chains[1].topSet.weight, 105.0);
      expect(chains[1].drops.isEmpty, isTrue);
    });
  });

  group('Wave 8.3 — Superset Engine & Storage (ADR-004)', () {
    test('SupersetEngine partitions exercises, labels blocks, and detects transitions', () {
      final exercises = [
        const Exercise(
          id: '1',
          name: 'Bench Press',
          type: ExerciseType.strength,
          sets: [],
          supersetGroupId: 'group_alpha',
        ),
        const Exercise(
          id: '2',
          name: 'Bent Over Row',
          type: ExerciseType.strength,
          sets: [],
          supersetGroupId: 'group_alpha',
        ),
        const Exercise(
          id: '3',
          name: 'Bicep Curl',
          type: ExerciseType.strength,
          sets: [],
          supersetGroupId: null,
        ),
      ];

      final blocks = SupersetEngine.blocks(exercises);
      expect(blocks.length, 2);
      expect(blocks[0].isSuperset, isTrue);
      expect(blocks[0].letter, 'A');
      expect(blocks[1].isSuperset, isFalse);

      expect(SupersetEngine.labelFor(exercises, 0), 'A1');
      expect(SupersetEngine.labelFor(exercises, 1), 'A2');
      expect(SupersetEngine.labelFor(exercises, 2), isNull);

      expect(SupersetEngine.isLinkedWithNext(exercises, 0), isTrue);
      expect(SupersetEngine.isLinkedWithNext(exercises, 1), isFalse);

      // Auto-rotation
      expect(SupersetEngine.nextInRotation(exercises, 0), 1);
      expect(SupersetEngine.nextInRotation(exercises, 1), 0);
      expect(SupersetEngine.nextInRotation(exercises, 2), isNull);

      // Rest conditions: inside superset, don't rest until last round exercise
      expect(SupersetEngine.shouldRestAfter(exercises, 0), isFalse);
      expect(SupersetEngine.shouldRestAfter(exercises, 1), isTrue);
      expect(SupersetEngine.shouldRestAfter(exercises, 2), isTrue);
      // Drop set never rests
      expect(SupersetEngine.shouldRestAfter(exercises, 1, type: SetType.drop), isFalse);
    });

    test('SupersetEngine.toggleLinkWithNext links and unlinks adjacent exercises', () {
      final e1 = const Exercise(id: '1', name: 'Ex1', type: ExerciseType.strength, sets: []);
      final e2 = const Exercise(id: '2', name: 'Ex2', type: ExerciseType.strength, sets: []);
      final initial = [e1, e2];

      // Link 0 with 1
      final linked = SupersetEngine.toggleLinkWithNext(
        initial,
        0,
        newGroupId: () => 'group_1',
      );
      expect(linked[0].supersetGroupId, 'group_1');
      expect(linked[1].supersetGroupId, 'group_1');

      // Unlink 0 and 1 clears singletons
      final unlinked = SupersetEngine.toggleLinkWithNext(
        linked,
        0,
        newGroupId: () => 'group_2',
      );
      expect(unlinked[0].supersetGroupId, isNull);
      expect(unlinked[1].supersetGroupId, isNull);
    });

    test('ExerciseModel and BackupRecordCodec preserve supersetGroupId across serialization', () {
      final now = DateTime.now();
      final exercise = Exercise(
        id: 'ex_test',
        name: 'Incline Dumbbell Press',
        type: ExerciseType.strength,
        sets: [
          SetEntry(id: 's1', reps: 10, weight: 30, timestamp: now, type: SetType.normal),
        ],
        exerciseDefinitionId: 'incline-db-press',
        supersetGroupId: 'ss_chest_back_01',
      );

      // Model round-trip
      final model = ExerciseModel.fromEntity(exercise);
      expect(model.supersetGroupId, 'ss_chest_back_01');
      final json = model.toJson();
      expect(json['supersetGroupId'], 'ss_chest_back_01');
      final loadedModel = ExerciseModel.fromJson(json);
      final restored = loadedModel.toEntity();
      expect(restored.supersetGroupId, 'ss_chest_back_01');

      // Backup codec round-trip
      final workout = Workout(
        id: 'w_test',
        date: now,
        duration: const Duration(minutes: 30),
        totalVolume: 300,
        exercises: [exercise],
      );
      final backupJson = BackupRecordCodec.workoutToMap(workout);
      final parsedWorkout = BackupRecordCodec.parseWorkout(backupJson);
      expect(parsedWorkout.exercises.first.supersetGroupId, 'ss_chest_back_01');
    });
  });
}
