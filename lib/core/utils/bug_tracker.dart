import 'package:flutter/foundation.dart';

/// Tracks and logs bugs for debugging.
class BugTracker {
  static final BugTracker _instance = BugTracker._internal();

  factory BugTracker() {
    return _instance;
  }

  BugTracker._internal();

  final List<BugReport> _bugs = [];

  /// Reports a bug.
  void reportBug({
    required String title,
    required String description,
    required String severity, // 'critical', 'high', 'medium', 'low'
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
  }) {
    final bug = BugReport(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: description,
      severity: severity,
      timestamp: DateTime.now(),
      stackTrace: stackTrace,
      context: context,
    );

    _bugs.add(bug);
    debugPrint('Bug reported: $title (${bug.id})');
  }

  /// Gets all reported bugs.
  List<BugReport> getAllBugs() => List.unmodifiable(_bugs);

  /// Gets bugs by severity.
  List<BugReport> getBugsBySeverity(String severity) =>
      _bugs.where((b) => b.severity == severity).toList();

  /// Gets critical bugs.
  List<BugReport> getCriticalBugs() => getBugsBySeverity('critical');

  /// Clears all bugs.
  void clearBugs() {
    _bugs.clear();
  }

  /// Prints bug report.
  void printReport() {
    debugPrint('=== Bug Report ===');
    debugPrint('Total bugs: ${_bugs.length}');

    final bySeverity = <String, int>{};
    for (final bug in _bugs) {
      bySeverity[bug.severity] = (bySeverity[bug.severity] ?? 0) + 1;
    }

    bySeverity.forEach((severity, count) {
      debugPrint('$severity: $count');
    });

    debugPrint('\nBugs:');
    for (final bug in _bugs) {
      debugPrint('- [${bug.severity.toUpperCase()}] ${bug.title}');
      debugPrint('  ${bug.description}');
      debugPrint('  Time: ${bug.timestamp}');
    }
  }
}

/// Represents a bug report.
class BugReport {
  final String id;
  final String title;
  final String description;
  final String severity;
  final DateTime timestamp;
  final StackTrace? stackTrace;
  final Map<String, dynamic>? context;

  BugReport({
    required this.id,
    required this.title,
    required this.description,
    required this.severity,
    required this.timestamp,
    this.stackTrace,
    this.context,
  });

  @override
  String toString() => 'BugReport($id: $title)';
}

/// Decorator for catching and reporting errors.
Future<T> trackBugAsync<T>(
  String operationName,
  Future<T> Function() fn, {
  Map<String, dynamic>? context,
}) async {
  try {
    return await fn();
  } catch (e, stackTrace) {
    BugTracker().reportBug(
      title: 'Error in $operationName',
      description: e.toString(),
      severity: 'high',
      stackTrace: stackTrace,
      context: context,
    );
    rethrow;
  }
}

/// Decorator for catching and reporting sync errors.
T trackBugSync<T>(
  String operationName,
  T Function() fn, {
  Map<String, dynamic>? context,
}) {
  try {
    return fn();
  } catch (e, stackTrace) {
    BugTracker().reportBug(
      title: 'Error in $operationName',
      description: e.toString(),
      severity: 'high',
      stackTrace: stackTrace,
      context: context,
    );
    rethrow;
  }
}
