import 'dart:collection';
import 'package:flutter/foundation.dart';
import '../config/build_stamp.dart';
import 'telemetry_preferences.dart';

/// Severity levels for structured observability logs.
enum LogLevel {
  debug,
  info,
  warning,
  error,
  critical,
}

/// Immutable structured log entry stored in the diagnostic ring buffer.
@immutable
class StructuredLogEntry {
  const StructuredLogEntry({
    required this.timestamp,
    required this.level,
    required this.message,
    this.tag,
    this.context = const {},
  });

  final DateTime timestamp;
  final LogLevel level;
  final String message;
  final String? tag;
  final Map<String, Object?> context;

  Map<String, Object?> toJson() => {
        'timestamp': timestamp.toUtc().toIso8601String(),
        'level': level.name,
        if (tag != null) 'tag': tag,
        'message': message,
        if (context.isNotEmpty) 'context': context,
      };
}

/// Completed performance measurement span.
@immutable
class PerformanceSpanResult {
  const PerformanceSpanResult({
    required this.name,
    required this.durationMs,
    required this.succeeded,
    this.attributes = const {},
  });

  final String name;
  final int durationMs;
  final bool succeeded;
  final Map<String, String> attributes;
}

/// Active performance timer span started via [ObservabilityService.startSpan].
class PerformanceSpan {
  PerformanceSpan._(this.name, this._service, this._attributes)
      : _stopwatch = Stopwatch()..start();

  final String name;
  final ObservabilityService _service;
  final Map<String, String> _attributes;
  final Stopwatch _stopwatch;
  bool _stopped = false;

  void setAttribute(String key, String value) {
    _attributes[key] = ObservabilityService.scrubSensitiveText(value);
  }

  PerformanceSpanResult stop({bool succeeded = true}) {
    if (!_stopped) {
      _stopwatch.stop();
      _stopped = true;
    }
    final result = PerformanceSpanResult(
      name: name,
      durationMs: _stopwatch.elapsedMilliseconds,
      succeeded: succeeded,
      attributes: Map.unmodifiable(_attributes),
    );
    _service._recordCompletedSpan(result);
    return result;
  }
}

typedef CrashReportSink = Future<void> Function(
  Object error,
  StackTrace stackTrace, {
  String? reason,
  required bool fatal,
  required Map<String, String> buildStamp,
});

typedef AnalyticsEventSink = Future<void> Function(
  String name,
  Map<String, Object?> parameters,
);

/// Production observability service providing:
/// 1. Structured logging with severity levels and a bounded ring buffer.
/// 2. Automatic PII and secret scrubbing (emails, Bearer tokens, API keys).
/// 3. Consent-gated Crashlytics error reporting and Analytics events.
/// 4. Lightweight performance monitoring spans (`startSpan`, `traceAsync`).
class ObservabilityService {
  ObservabilityService({
    this.maxBufferEntries = 200,
    this.slowSpanThresholdMs = 500,
    Future<bool> Function()? isCrashReportingAllowed,
    Future<bool> Function()? isAnalyticsAllowed,
    CrashReportSink? crashSink,
    AnalyticsEventSink? analyticsSink,
    BuildStamp? buildStamp,
  })  : _isCrashReportingAllowed = isCrashReportingAllowed ??
            (() async {
              final enabled = await TelemetryPreferences.crashReportingEnabled();
              return TelemetryPreferences.effectiveCrashCollectionEnabled(
                preferenceEnabled: enabled,
                isDebugMode: kDebugMode,
              );
            }),
        _isAnalyticsAllowed = isAnalyticsAllowed ??
            (() async {
              final enabled = await TelemetryPreferences.analyticsEnabled();
              return TelemetryPreferences.effectiveAnalyticsCollectionEnabled(
                preferenceEnabled: enabled,
                isDebugMode: kDebugMode,
              );
            }),
        _crashSink = crashSink,
        _analyticsSink = analyticsSink,
        _buildStamp = buildStamp ?? BuildStamp.current;

  final int maxBufferEntries;
  final int slowSpanThresholdMs;
  final Future<bool> Function() _isCrashReportingAllowed;
  final Future<bool> Function() _isAnalyticsAllowed;
  final CrashReportSink? _crashSink;
  final AnalyticsEventSink? _analyticsSink;
  final BuildStamp _buildStamp;

  final ListQueue<StructuredLogEntry> _buffer = ListQueue<StructuredLogEntry>();
  final List<PerformanceSpanResult> _completedSpans = <PerformanceSpanResult>[];

  static final RegExp _emailPattern = RegExp(
    r'[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}',
  );
  static final RegExp _bearerPattern = RegExp(
    r'Bearer\s+[A-Za-z0-9\-._~+/]+=*',
    caseSensitive: false,
  );
  static final RegExp _googleKeyPattern = RegExp(r'AIza[0-9A-Za-z\-_]{20,}');
  static final RegExp _nvidiaKeyPattern = RegExp(r'nvapi-[0-9A-Za-z\-_]{15,}');

  /// Redacts emails, Bearer tokens, and API key patterns from arbitrary text.
  static String scrubSensitiveText(String input) {
    return input
        .replaceAll(_emailPattern, '[REDACTED_EMAIL]')
        .replaceAll(_bearerPattern, 'Bearer [REDACTED_TOKEN]')
        .replaceAll(_googleKeyPattern, '[REDACTED_API_KEY]')
        .replaceAll(_nvidiaKeyPattern, '[REDACTED_API_KEY]');
  }

  /// Redacts sensitive values across a structured map.
  static Map<String, Object?> scrubMap(Map<String, Object?> raw) {
    final cleaned = <String, Object?>{};
    for (final entry in raw.entries) {
      final keyLower = entry.key.toLowerCase();
      if (keyLower.contains('password') ||
          keyLower.contains('secret') ||
          keyLower.contains('token') ||
          keyLower.contains('api_key') ||
          keyLower.contains('apikey')) {
        cleaned[entry.key] = '[REDACTED]';
      } else if (entry.value is String) {
        cleaned[entry.key] = scrubSensitiveText(entry.value as String);
      } else {
        cleaned[entry.key] = entry.value;
      }
    }
    return cleaned;
  }

  /// Unmodifiable snapshot of recent structured log entries.
  List<StructuredLogEntry> get recentLogs => List.unmodifiable(_buffer);

  /// Unmodifiable snapshot of completed performance spans.
  List<PerformanceSpanResult> get completedSpans =>
      List.unmodifiable(_completedSpans);

  /// Records a structured log entry with automatic PII/secret scrubbing.
  void log(
    LogLevel level,
    String message, {
    String? tag,
    Map<String, Object?> context = const {},
  }) {
    final entry = StructuredLogEntry(
      timestamp: DateTime.now().toUtc(),
      level: level,
      message: scrubSensitiveText(message),
      tag: tag,
      context: scrubMap(context),
    );
    _buffer.addLast(entry);
    while (_buffer.length > maxBufferEntries) {
      _buffer.removeFirst();
    }
  }

  /// Starts a latency measurement span for [name].
  PerformanceSpan startSpan(
    String name, {
    Map<String, String> attributes = const {},
  }) {
    final scrubbed = <String, String>{};
    for (final entry in attributes.entries) {
      scrubbed[entry.key] = scrubSensitiveText(entry.value);
    }
    return PerformanceSpan._(name, this, scrubbed);
  }

  /// Traces an asynchronous operation, recording its latency and logging slow
  /// spans or uncaught exceptions automatically.
  Future<T> traceAsync<T>(
    String name,
    Future<T> Function() action, {
    Map<String, String> attributes = const {},
  }) async {
    final span = startSpan(name, attributes: attributes);
    try {
      final result = await action();
      span.stop(succeeded: true);
      return result;
    } catch (e, st) {
      span.stop(succeeded: false);
      await recordError(e, st, context: 'span:$name');
      rethrow;
    }
  }

  void _recordCompletedSpan(PerformanceSpanResult span) {
    _completedSpans.add(span);
    if (_completedSpans.length > maxBufferEntries) {
      _completedSpans.removeAt(0);
    }
    if (span.durationMs >= slowSpanThresholdMs) {
      log(
        LogLevel.warning,
        'Slow operation detected: ${span.name} took ${span.durationMs}ms',
        tag: 'performance',
        context: {
          'duration_ms': span.durationMs,
          'succeeded': span.succeeded,
          ...span.attributes,
        },
      );
    }
  }

  /// Records an error into the structured log and forwards to the crash sink
  /// ONLY if user crash-reporting consent is granted.
  Future<bool> recordError(
    Object error,
    StackTrace stackTrace, {
    String? context,
    bool fatal = false,
  }) async {
    final scrubbedError = scrubSensitiveText(error.toString());
    final scrubbedContext =
        context != null ? scrubSensitiveText(context) : null;

    log(
      fatal ? LogLevel.critical : LogLevel.error,
      scrubbedError,
      tag: 'crash_reporter',
      context: {
        'reason': ?scrubbedContext,
        'fatal': fatal,
      },
    );

    final allowed = await _isCrashReportingAllowed();
    if (!allowed || _crashSink == null) {
      return false;
    }

    await _crashSink(
      scrubbedError,
      stackTrace,
      reason: scrubbedContext,
      fatal: fatal,
      buildStamp: _buildStamp.toMap(),
    );
    return true;
  }

  /// Records a minimal analytics event ONLY if user analytics consent is granted.
  Future<bool> recordEvent(
    String name, {
    Map<String, Object?> parameters = const {},
  }) async {
    final scrubbedParams = scrubMap(parameters);
    final allowed = await _isAnalyticsAllowed();
    if (!allowed || _analyticsSink == null) {
      return false;
    }
    await _analyticsSink(name, scrubbedParams);
    return true;
  }
}
