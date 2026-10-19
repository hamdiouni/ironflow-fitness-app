import 'package:flutter/foundation.dart';

/// Centralized, production-safe application logger for IronFlow.
///
/// Features:
/// - Mutes debug logging in release mode (`kReleaseMode`).
/// - Standardized log prefixes: `[DEBUG]`, `[INFO]`, `[WARN]`, `[ERROR]`.
/// - Supports optional tag/category for domain/presentation tracing.
class AppLogger {
  AppLogger._();

  /// Logs a debug-level message (muted in release mode).
  static void debug(dynamic message, {String? tag, Object? error, StackTrace? stackTrace}) {
    if (kDebugMode) {
      _log('DEBUG', message, tag: tag, error: error, stackTrace: stackTrace);
    }
  }

  /// Logs an informational message (muted in release mode).
  static void info(dynamic message, {String? tag}) {
    if (kDebugMode) {
      _log('INFO', message, tag: tag);
    }
  }

  /// Logs a warning message.
  static void warning(dynamic message, {String? tag, Object? error, StackTrace? stackTrace}) {
    if (kDebugMode) {
      _log('WARN', message, tag: tag, error: error, stackTrace: stackTrace);
    }
  }

  /// Logs an error message.
  static void error(dynamic message, {String? tag, Object? error, StackTrace? stackTrace}) {
    _log('ERROR', message, tag: tag, error: error, stackTrace: stackTrace);
  }

  static void _log(String level, dynamic message, {String? tag, Object? error, StackTrace? stackTrace}) {
    final prefix = tag != null ? '[$level][$tag]' : '[$level]';
    debugPrint('$prefix $message');
    if (error != null) {
      debugPrint('$prefix Error: $error');
    }
    if (stackTrace != null) {
      debugPrint('$prefix StackTrace:\n$stackTrace');
    }
  }
}
