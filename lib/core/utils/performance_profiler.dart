import 'package:flutter/foundation.dart';

/// Utility for profiling app performance.
///
/// Measures screen transition times, list scroll performance, and other metrics.
class PerformanceProfiler {
  static final PerformanceProfiler _instance = PerformanceProfiler._internal();

  factory PerformanceProfiler() {
    return _instance;
  }

  PerformanceProfiler._internal();

  final Map<String, Stopwatch> _timers = {};
  final Map<String, List<int>> _measurements = {};

  /// Starts measuring a metric.
  void startMeasure(String name) {
    _timers[name] = Stopwatch()..start();
  }

  /// Stops measuring and records the duration.
  int stopMeasure(String name) {
    final timer = _timers[name];
    if (timer == null) {
      debugPrint('Timer $name not found');
      return 0;
    }

    timer.stop();
    final duration = timer.elapsedMilliseconds;

    _measurements.putIfAbsent(name, () => []).add(duration);
    _timers.remove(name);

    debugPrint('$name: ${duration}ms');
    return duration;
  }

  /// Gets average duration for a metric.
  double getAverageDuration(String name) {
    final measurements = _measurements[name];
    if (measurements == null || measurements.isEmpty) {
      return 0;
    }

    final sum = measurements.fold<int>(0, (a, b) => a + b);
    return sum / measurements.length;
  }

  /// Gets all measurements for a metric.
  List<int> getMeasurements(String name) {
    return _measurements[name] ?? [];
  }

  /// Clears all measurements.
  void clearMeasurements() {
    _measurements.clear();
    _timers.clear();
  }

  /// Prints performance report.
  void printReport() {
    debugPrint('=== Performance Report ===');
    _measurements.forEach((name, measurements) {
      final avg = measurements.fold<int>(0, (a, b) => a + b) / measurements.length;
      final min = measurements.reduce((a, b) => a < b ? a : b);
      final max = measurements.reduce((a, b) => a > b ? a : b);

      debugPrint('$name:');
      debugPrint('  Average: ${avg.toStringAsFixed(2)}ms');
      debugPrint('  Min: ${min}ms');
      debugPrint('  Max: ${max}ms');
      debugPrint('  Count: ${measurements.length}');
    });
  }
}

/// Decorator for measuring function execution time.
Future<T> measureAsync<T>(
  String name,
  Future<T> Function() fn,
) async {
  final profiler = PerformanceProfiler();
  profiler.startMeasure(name);
  try {
    return await fn();
  } finally {
    profiler.stopMeasure(name);
  }
}

/// Decorator for measuring sync function execution time.
T measureSync<T>(
  String name,
  T Function() fn,
) {
  final profiler = PerformanceProfiler();
  profiler.startMeasure(name);
  try {
    return fn();
  } finally {
    profiler.stopMeasure(name);
  }
}

/// Performance metrics thresholds.
class PerformanceThresholds {
  static const int screenTransitionMs = 300;
  static const int macroUpdateMs = 200;
  static const int listScrollMs = 60; // 60fps = 16.67ms per frame
  static const int storageQueryMs = 100;

  static bool isScreenTransitionAcceptable(int duration) =>
      duration <= screenTransitionMs;

  static bool isMacroUpdateAcceptable(int duration) =>
      duration <= macroUpdateMs;

  static bool isListScrollAcceptable(int duration) =>
      duration <= listScrollMs;

  static bool isStorageQueryAcceptable(int duration) =>
      duration <= storageQueryMs;
}
