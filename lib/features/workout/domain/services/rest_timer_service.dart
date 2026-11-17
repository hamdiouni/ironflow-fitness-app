import 'dart:async';
import '../../../notifications/domain/services/notification_service.dart';
import '../repositories/rest_timer_state_persistence.dart';
import 'rest_timer_live_surface.dart';

/// Service for managing rest timer between sets using an absolute end timestamp
/// as the source of truth, integrated with inexact local notifications (TRN-02)
/// and an optional lock-screen / browser live surface (Wave 8.1, ADR-004).
class RestTimerService {
  final NotificationService? _notificationService;
  final RestTimerStatePersistence? _stateManager;
  final String? Function()? _currentUserId;
  final RestTimerLiveSurface? _liveSurface;

  Timer? _timer;
  DateTime? _targetEndTime;
  int _totalSeconds = 0;
  int _remainingSeconds = 0;
  int? _pausedRemainingSeconds;
  bool _isRunning = false;

  // Callbacks
  Function(int)? onTick;
  Function()? onComplete;

  RestTimerService({
    NotificationService? notificationService,
    RestTimerStatePersistence? stateManager,
    String? Function()? currentUserId,
    RestTimerLiveSurface? liveSurface,
  })  : _notificationService = notificationService,
        _stateManager = stateManager,
        _currentUserId = currentUserId,
        _liveSurface = liveSurface;

  void _safeSurface(void Function(RestTimerLiveSurface surface) action) {
    final surface = _liveSurface;
    if (surface == null) return;
    try {
      action(surface);
    } catch (_) {
      // A live surface must never break the rest timer.
    }
  }

  String? get _scopedUserId {
    try {
      return _currentUserId?.call();
    } catch (_) {
      return null;
    }
  }

  DateTime? get targetEndTime => _targetEndTime;
  int get totalSeconds => _totalSeconds;
  int get remainingSeconds => _remainingSeconds;
  bool get isRunning => _isRunning;
  bool get isPaused => _pausedRemainingSeconds != null && !_isRunning;

  /// Start the rest timer with an absolute target end timestamp (TRN-02)
  void start(int durationSeconds) {
    stop(); // Stop any existing timer or notifications

    _totalSeconds = durationSeconds;
    _remainingSeconds = durationSeconds;
    _pausedRemainingSeconds = null;
    _targetEndTime = DateTime.now().add(Duration(seconds: durationSeconds));
    _isRunning = true;

    // Persist timestamp and schedule inexact local notification
    _stateManager?.saveRestTimer(
      _targetEndTime!,
      durationSeconds,
      userId: _scopedUserId,
    );
    _notificationService?.scheduleRestTimer(_targetEndTime!);
    final endTime = _targetEndTime!;
    _safeSurface(
      (s) => s.showRunning(endTime: endTime, totalSeconds: durationSeconds),
    );

    // Notify initial state
    onTick?.call(_remainingSeconds);

    // Foreground 1-second ticker using absolute timestamp as source of truth
    _startForegroundTicker();
  }

  void _startForegroundTicker() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_targetEndTime == null) {
        stop();
        return;
      }

      final remaining = _targetEndTime!.difference(DateTime.now()).inSeconds;
      if (remaining <= 0) {
        _complete();
      } else {
        _remainingSeconds = remaining;
        onTick?.call(_remainingSeconds);
      }
    });
  }

  /// Stop the timer and cancel scheduled notifications
  void stop() {
    _timer?.cancel();
    _timer = null;
    _isRunning = false;
    _remainingSeconds = 0;
    _targetEndTime = null;
    _pausedRemainingSeconds = null;
    _stateManager?.clearRestTimer(userId: _scopedUserId);
    _notificationService?.cancelRestTimer();
    _safeSurface((s) => s.clear());
  }

  /// Pause the timer
  void pause() {
    if (!_isRunning) return;

    _timer?.cancel();
    _timer = null;
    _isRunning = false;

    if (_targetEndTime != null) {
      _pausedRemainingSeconds =
          _targetEndTime!.difference(DateTime.now()).inSeconds;
      if (_pausedRemainingSeconds! <= 0) {
        _complete();
        return;
      }
    } else {
      _pausedRemainingSeconds = _remainingSeconds;
    }

    _targetEndTime = null;
    _stateManager?.clearRestTimer(userId: _scopedUserId);
    _notificationService?.cancelRestTimer();
    final paused = _pausedRemainingSeconds!;
    _safeSurface((s) => s.showPaused(remainingSeconds: paused));
  }

  /// Resume the timer with a recomputed target timestamp
  void resume() {
    final remaining = _pausedRemainingSeconds ?? _remainingSeconds;
    if (remaining > 0 && !_isRunning) {
      start(remaining);
    }
  }

  /// Add time to the timer and reschedule notification
  void addTime(int seconds) {
    if (_targetEndTime != null) {
      _targetEndTime = _targetEndTime!.add(Duration(seconds: seconds));
      _totalSeconds = (_totalSeconds + seconds).clamp(1, 3600);
      final remaining = _targetEndTime!.difference(DateTime.now()).inSeconds;
      if (remaining <= 0) {
        _complete();
        return;
      }
      _remainingSeconds = remaining;
      _stateManager?.saveRestTimer(
        _targetEndTime!,
        _totalSeconds,
        userId: _scopedUserId,
      );
      _notificationService?.scheduleRestTimer(_targetEndTime!);
      final endTime = _targetEndTime!;
      final total = _totalSeconds;
      _safeSurface(
        (s) => s.showRunning(endTime: endTime, totalSeconds: total),
      );
      onTick?.call(_remainingSeconds);
    } else if (_pausedRemainingSeconds != null) {
      _pausedRemainingSeconds =
          (_pausedRemainingSeconds! + seconds).clamp(0, 3600);
      _totalSeconds = (_totalSeconds + seconds).clamp(1, 3600);
      if (_pausedRemainingSeconds! <= 0) {
        _complete();
        return;
      }
      _remainingSeconds = _pausedRemainingSeconds!;
      final paused = _pausedRemainingSeconds!;
      _safeSurface((s) => s.showPaused(remainingSeconds: paused));
      onTick?.call(_remainingSeconds);
    }
  }

  /// Recompute remaining seconds from the absolute target timestamp.
  /// Must be called when app resumes from background or lifecycle change (TRN-02).
  void sync() {
    if (_targetEndTime == null) {
      // Check if there is a saved rest timer from prior process death
      final saved = _stateManager?.getRestTimer(userId: _scopedUserId);
      if (saved != null) {
        final now = DateTime.now();
        if (saved.targetEndTime.isAfter(now)) {
          _targetEndTime = saved.targetEndTime;
          _totalSeconds = saved.totalSeconds;
          _remainingSeconds = _targetEndTime!.difference(now).inSeconds;
          _isRunning = true;
          final endTime = saved.targetEndTime;
          final total = saved.totalSeconds;
          _safeSurface(
            (s) => s.showRunning(endTime: endTime, totalSeconds: total),
          );
          onTick?.call(_remainingSeconds);
          _startForegroundTicker();
          return;
        } else {
          // Timer finished while dead/backgrounded
          _stateManager?.clearRestTimer(userId: _scopedUserId);
          _complete();
          return;
        }
      }
    }

    if (_targetEndTime != null) {
      final remaining = _targetEndTime!.difference(DateTime.now()).inSeconds;
      if (remaining <= 0) {
        _complete();
      } else {
        _remainingSeconds = remaining;
        onTick?.call(_remainingSeconds);
      }
    }
  }

  /// Complete the timer. [natural] is false when the user skipped, so live
  /// surfaces do not announce "rest complete" for a skip.
  void _complete({bool natural = true}) {
    stop();
    if (natural) {
      _safeSurface((s) => s.showCompleted());
    }
    onComplete?.call();
  }

  /// Skip the timer
  void skip() {
    _complete(natural: false);
  }

  /// Format time as MM:SS
  String formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  /// Dispose the service
  void dispose() {
    stop();
  }
}
