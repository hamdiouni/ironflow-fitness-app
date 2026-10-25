import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';

import '../../../../core/utils/record_ownership.dart';
import '../../data/models/workout_model.dart';
import '../../domain/entities/entities.dart';

/// Manages persistence of the active workout state using Hive.
///
/// Saves the current [Workout] as JSON after each set so that data is not
/// lost if the app closes unexpectedly (Requirement 17.6).
///
/// Active state is personal data, so provider-wired callers pass the
/// current account id explicitly and this manager stores it under
/// account-scoped keys. Existing direct constructions that do not pass
/// a user id keep using the legacy keys.
class WorkoutStateManager {
  static const String _boxName = 'active_workout_state';
  static const String _workoutKey = 'current_workout';
  static const String _startTimeKey = 'start_time';
  static const String _restTimerEndTimeKey = 'rest_timer_end_time';
  static const String _restTimerTotalSecondsKey = 'rest_timer_total_seconds';

  Box<dynamic>? _box;

  /// Opens the Hive box. Must be called before any other method.
  Future<void> init() async {
    _box = await Hive.openBox<dynamic>(_boxName);
  }

  Box<dynamic> get _openBox {
    final box = _box;
    if (box == null || !box.isOpen) {
      throw StateError(
        'WorkoutStateManager has not been initialised. Call init() first.',
      );
    }
    return box;
  }

  String _scopedKey(String baseKey, String? userId) {
    final scopeUserId = RecordOwnershipRules.storageScope(userId);
    return scopeUserId == null ? baseKey : '${baseKey}_$scopeUserId';
  }

  String _workoutKeyFor(String? userId) => _scopedKey(_workoutKey, userId);

  String _startTimeKeyFor(String? userId) => _scopedKey(_startTimeKey, userId);

  String _restTimerEndTimeKeyFor(String? userId) =>
      _scopedKey(_restTimerEndTimeKey, userId);

  String _restTimerTotalSecondsKeyFor(String? userId) =>
      _scopedKey(_restTimerTotalSecondsKey, userId);

  Future<bool> _adoptLegacyStateIfSafe(String userId) async {
    final box = _openBox;
    final legacyWorkoutJson = box.get(_workoutKey) as String?;
    final legacyStartTime = box.get(_startTimeKey) as String?;
    if (legacyWorkoutJson == null || legacyStartTime == null) return false;

    try {
      final map = jsonDecode(legacyWorkoutJson) as Map<String, dynamic>;
      final model = WorkoutModel.fromJson(map);
      final ownership = RecordOwnershipRules.classify(
        ownerId: model.userId,
        currentUserId: userId,
      );
      final hasScopedWorkout = box.keys.any(
        (key) => key.toString().startsWith('${_workoutKey}_'),
      );
      final canAdopt = ownership == RecordOwnership.ownedByCurrentUser ||
          (ownership == RecordOwnership.legacyUnowned && !hasScopedWorkout);
      if (!canAdopt) return false;

      await box.put(_workoutKeyFor(userId), legacyWorkoutJson);
      await box.put(_startTimeKeyFor(userId), legacyStartTime);

      final legacyRestEndTime = box.get(_restTimerEndTimeKey);
      if (legacyRestEndTime != null) {
        await box.put(_restTimerEndTimeKeyFor(userId), legacyRestEndTime);
      }
      final legacyRestTotal = box.get(_restTimerTotalSecondsKey);
      if (legacyRestTotal != null) {
        await box.put(
          _restTimerTotalSecondsKeyFor(userId),
          legacyRestTotal,
        );
      }

      await box.delete(_workoutKey);
      await box.delete(_startTimeKey);
      await box.delete(_restTimerEndTimeKey);
      await box.delete(_restTimerTotalSecondsKey);
      return true;
    } catch (_) {
      // A corrupted legacy value cannot be attributed to this account.
      // Leave it for the existing unscoped restore path to clear.
      return false;
    }
  }

  /// Persists [workout] and [startTime] so they can be restored later.
  Future<void> saveState(
    Workout workout,
    DateTime startTime, {
    String? userId,
  }) async {
    final explicitUserId = RecordOwnershipRules.normalizeUserId(userId);
    if (explicitUserId != null &&
        RecordOwnershipRules.isForeignToCurrentUser(
          ownerId: workout.userId,
          currentUserId: explicitUserId,
        )) {
      return;
    }

    final scopeUserId =
        explicitUserId ?? RecordOwnershipRules.normalizeUserId(workout.userId);
    final model = WorkoutModel.fromEntity(workout);
    final json = jsonEncode(model.toJson());
    await _openBox.put(_workoutKeyFor(scopeUserId), json);
    await _openBox.put(
      _startTimeKeyFor(scopeUserId),
      startTime.toIso8601String(),
    );
  }

  /// Returns the persisted [Workout] and start time, or `null` if none exists.
  Future<({Workout workout, DateTime startTime})?> restoreState({
    String? userId,
  }) async {
    final scopeUserId = RecordOwnershipRules.normalizeUserId(userId);
    var workoutJson = _openBox.get(_workoutKeyFor(scopeUserId)) as String?;
    var startTimeStr = _openBox.get(_startTimeKeyFor(scopeUserId)) as String?;

    if (scopeUserId != null && (workoutJson == null || startTimeStr == null)) {
      final adopted = await _adoptLegacyStateIfSafe(scopeUserId);
      if (adopted) {
        workoutJson = _openBox.get(_workoutKeyFor(scopeUserId)) as String?;
        startTimeStr = _openBox.get(_startTimeKeyFor(scopeUserId)) as String?;
      }
    }

    if (workoutJson == null || startTimeStr == null) return null;

    try {
      final map = jsonDecode(workoutJson) as Map<String, dynamic>;
      final model = WorkoutModel.fromJson(map);
      if (RecordOwnershipRules.isForeignToCurrentUser(
        ownerId: model.userId,
        currentUserId: scopeUserId,
      )) {
        return null;
      }
      final workout = model.toEntity();
      final startTime = DateTime.parse(startTimeStr);
      return (workout: workout, startTime: startTime);
    } catch (_) {
      // Corrupted state – clear only this scope and return null.
      await clearState(userId: scopeUserId);
      return null;
    }
  }

  /// Returns `true` if legacy/unscoped active workout state exists.
  ///
  /// Kept for existing direct callers. Provider-wired code restores with
  /// an explicit user id, which also handles safe legacy adoption.
  bool get hasSavedState {
    return _openBox.containsKey(_workoutKey);
  }

  /// Returns `true` if active workout state exists under [userId]'s key.
  bool hasSavedStateForUser(String? userId) {
    return _openBox.containsKey(_workoutKeyFor(userId));
  }

  /// Persists the rest timer target end timestamp and total duration (TRN-02)
  Future<void> saveRestTimer(
    DateTime targetEndTime,
    int totalSeconds, {
    String? userId,
  }) async {
    if (_box == null || !_box!.isOpen) return;
    await _openBox.put(
      _restTimerEndTimeKeyFor(userId),
      targetEndTime.toIso8601String(),
    );
    await _openBox.put(
      _restTimerTotalSecondsKeyFor(userId),
      totalSeconds,
    );
  }

  /// Returns the persisted rest timer target end time and total duration, or null
  ({DateTime targetEndTime, int totalSeconds})? getRestTimer({
    String? userId,
  }) {
    if (_box == null || !_box!.isOpen) return null;
    final timeStr = _openBox.get(_restTimerEndTimeKeyFor(userId)) as String?;
    final total = _openBox.get(_restTimerTotalSecondsKeyFor(userId)) as int?;
    if (timeStr == null || total == null) return null;
    try {
      return (targetEndTime: DateTime.parse(timeStr), totalSeconds: total);
    } catch (_) {
      return null;
    }
  }

  /// Clears persisted rest timer state
  Future<void> clearRestTimer({String? userId}) async {
    if (_box == null || !_box!.isOpen) return;
    await _openBox.delete(_restTimerEndTimeKeyFor(userId));
    await _openBox.delete(_restTimerTotalSecondsKeyFor(userId));
  }

  /// Removes the persisted workout state (call after workout completion).
  Future<void> clearState({String? userId}) async {
    await _openBox.delete(_workoutKeyFor(userId));
    await _openBox.delete(_startTimeKeyFor(userId));
    await clearRestTimer(userId: userId);
  }
}
