import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/services/rest_timer_service.dart';
import '../../../../core/providers/analytics_provider.dart';
import '../../../../shared/presentation/services/app_haptics.dart';
import '../../../notifications/presentation/providers/notification_providers.dart';
import 'workout_providers.dart';

/// State for rest timer
class RestTimerState {
  final int remainingSeconds;
  final int totalSeconds;
  final bool isRunning;
  final bool isPaused;
  final bool isComplete;
  final DateTime? targetEndTime;

  RestTimerState({
    this.remainingSeconds = 0,
    this.totalSeconds = 0,
    this.isRunning = false,
    this.isPaused = false,
    this.isComplete = false,
    this.targetEndTime,
  });

  RestTimerState copyWith({
    int? remainingSeconds,
    int? totalSeconds,
    bool? isRunning,
    bool? isPaused,
    bool? isComplete,
    DateTime? targetEndTime,
    bool clearTargetEndTime = false,
  }) {
    return RestTimerState(
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      totalSeconds: totalSeconds ?? this.totalSeconds,
      isRunning: isRunning ?? this.isRunning,
      isPaused: isPaused ?? this.isPaused,
      isComplete: isComplete ?? this.isComplete,
      targetEndTime:
          clearTargetEndTime ? null : (targetEndTime ?? this.targetEndTime),
    );
  }

  /// Get progress (0.0 to 1.0)
  double get progress {
    if (totalSeconds == 0) return 0.0;
    return 1.0 - (remainingSeconds / totalSeconds);
  }

  /// Format remaining time as MM:SS
  String get formattedTime {
    final minutes = remainingSeconds ~/ 60;
    final seconds = remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}

/// Provider for rest timer service
final restTimerServiceProvider = Provider<RestTimerService>((ref) {
  final notificationService = ref.watch(notificationServiceProvider);
  final stateManager = ref.watch(workoutStateManagerProvider);
  final service = RestTimerService(
    notificationService: notificationService,
    stateManager: stateManager,
  );
  ref.onDispose(() => service.dispose());
  return service;
});

/// Provider for rest timer state
class RestTimerNotifier extends StateNotifier<RestTimerState> {
  final RestTimerService _service;
  final Ref _ref;

  RestTimerNotifier(this._service, this._ref) : super(RestTimerState()) {
    // Set up callbacks
    _service.onTick = _onTick;
    _service.onComplete = _onComplete;
  }

  /// Start the timer
  void start(int durationSeconds) {
    _service.start(durationSeconds);
    state = state.copyWith(
      totalSeconds: durationSeconds,
      remainingSeconds: durationSeconds,
      isRunning: true,
      isPaused: false,
      isComplete: false,
      targetEndTime: _service.targetEndTime,
    );
    
    // Track rest timer started
    try {
      final analytics = _ref.read(analyticsServiceProvider);
      analytics.logRestTimerStarted(durationSeconds: durationSeconds);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ [Analytics] Failed to log rest timer started: $e');
      }
    }
  }

  /// Stop the timer
  void stop() {
    _service.stop();
    state = RestTimerState();
  }

  /// Pause the timer
  void pause() {
    _service.pause();
    state = state.copyWith(
      isRunning: false,
      isPaused: true,
      clearTargetEndTime: true,
    );
  }

  /// Resume the timer
  void resume() {
    _service.resume();
    state = state.copyWith(
      isRunning: true,
      isPaused: false,
      targetEndTime: _service.targetEndTime,
    );
  }

  /// Add time to the timer
  void addTime(int seconds) {
    _service.addTime(seconds);
    state = state.copyWith(
      remainingSeconds: _service.remainingSeconds,
      totalSeconds: _service.totalSeconds,
      targetEndTime: _service.targetEndTime,
    );
  }

  /// Skip the timer
  void skip() {
    final remainingSeconds = state.remainingSeconds;
    _service.skip();
    
    // Track rest timer skipped
    try {
      final analytics = _ref.read(analyticsServiceProvider);
      analytics.logRestTimerSkipped(remainingSeconds: remainingSeconds);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ [Analytics] Failed to log rest timer skipped: $e');
      }
    }
  }

  /// Recomputes remaining seconds from absolute target timestamp (TRN-02)
  void sync() {
    _service.sync();
    state = state.copyWith(
      remainingSeconds: _service.remainingSeconds,
      totalSeconds: _service.totalSeconds,
      isRunning: _service.isRunning,
      isPaused: _service.isPaused,
      targetEndTime: _service.targetEndTime,
      clearTargetEndTime: _service.targetEndTime == null,
    );
  }

  /// Handle tick callback
  void _onTick(int remainingSeconds) {
    state = state.copyWith(
      remainingSeconds: remainingSeconds,
      targetEndTime: _service.targetEndTime,
      isRunning: _service.isRunning,
    );
  }

  /// Handle completion callback
  void _onComplete() {
    final durationSeconds = state.totalSeconds;
    
    state = state.copyWith(
      remainingSeconds: 0,
      isRunning: false,
      isPaused: false,
      isComplete: true,
      clearTargetEndTime: true,
    );
    
    // Trigger haptic feedback for rest timer completion
    _ref.read(appHapticsProvider).restTimerComplete();
    
    // Track rest timer completed
    try {
      final analytics = _ref.read(analyticsServiceProvider);
      analytics.logRestTimerCompleted(durationSeconds: durationSeconds);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ [Analytics] Failed to log rest timer completed: $e');
      }
    }
  }
}

/// Provider for rest timer notifier
final restTimerProvider =
    StateNotifierProvider<RestTimerNotifier, RestTimerState>((ref) {
  final service = ref.watch(restTimerServiceProvider);
  return RestTimerNotifier(service, ref);
});

/// Common rest durations (in seconds)
class RestDurations {
  static const int short = 30;
  static const int medium = 60;
  static const int standard = 90;
  static const int long = 120;
  static const int veryLong = 180;

  static const List<int> all = [short, medium, standard, long, veryLong];

  static String label(int seconds) {
    switch (seconds) {
      case short:
        return '30s';
      case medium:
        return '1m';
      case standard:
        return '1m 30s';
      case long:
        return '2m';
      case veryLong:
        return '3m';
      default:
        final minutes = seconds ~/ 60;
        final secs = seconds % 60;
        if (secs == 0) {
          return '${minutes}m';
        } else {
          return '${minutes}m ${secs}s';
        }
    }
  }
}
