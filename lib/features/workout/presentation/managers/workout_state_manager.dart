import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';

import '../../../../core/utils/user_scoped_hive_key.dart';
import '../../data/models/workout_model.dart';
import '../../domain/entities/entities.dart';

/// Manages persistence of the active workout state using Hive.
///
/// Saves the current [Workout] as JSON after each set so that data is not
/// lost if the app closes unexpectedly (Requirement 17.6).
class WorkoutStateManager {
  static const String _boxName = 'active_workout_state';
  static const String _workoutKey = 'current_workout';
  static const String _startTimeKey = 'start_time';

  final String? userId;

  WorkoutStateManager({this.userId});

  String get _workoutStorageKey => UserScopedHiveKey.encode(userId, _workoutKey);
  String get _startTimeStorageKey =>
      UserScopedHiveKey.encode(userId, _startTimeKey);

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

  /// Persists [workout] and [startTime] so they can be restored later.
  Future<void> saveState(Workout workout, DateTime startTime) async {
    final model = WorkoutModel.fromEntity(workout);
    final json = jsonEncode(model.toJson());
    await _openBox.put(_workoutStorageKey, json);
    await _openBox.put(_startTimeStorageKey, startTime.toIso8601String());
  }

  /// Returns the persisted [Workout] and start time, or `null` if none exists.
  Future<({Workout workout, DateTime startTime})?> restoreState() async {
    final workoutJson = _openBox.get(_workoutStorageKey) as String?;
    final startTimeStr = _openBox.get(_startTimeStorageKey) as String?;

    if (workoutJson == null || startTimeStr == null) return null;

    try {
      final map = jsonDecode(workoutJson) as Map<String, dynamic>;
      final model = WorkoutModel.fromJson(map);
      final workout = model.toEntity();
      final startTime = DateTime.parse(startTimeStr);
      return (workout: workout, startTime: startTime);
    } catch (_) {
      // Corrupted state – clear it and return null.
      await clearState();
      return null;
    }
  }

  /// Returns `true` if there is a saved active workout state.
  bool get hasSavedState {
    return _openBox.containsKey(_workoutStorageKey);
  }

  /// Removes the persisted workout state (call after workout completion).
  Future<void> clearState() async {
    await _openBox.delete(_workoutStorageKey);
    await _openBox.delete(_startTimeStorageKey);
  }
}
