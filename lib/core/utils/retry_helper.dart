import 'dart:async';
import 'dart:math';

/// Utility for retrying asynchronous operations with exponential backoff and jitter.
class RetryHelper {
  const RetryHelper._();

  /// Executes [action], automatically retrying with exponential backoff on failure.
  ///
  /// - [maxAttempts]: Maximum total executions before propagating the error (default: 3).
  /// - [initialDelay]: Delay before first retry (default: 200ms).
  /// - [multiplier]: Exponential factor for subsequent delays (default: 2.0).
  /// - [maxDelay]: Cap on delay duration (default: 5s).
  /// - [useJitter]: Whether to add randomized jitter (+/- 25%) to prevent synchronized retry storms.
  /// - [shouldRetry]: Optional predicate to inspect errors and decide whether to retry.
  static Future<T> withExponentialBackoff<T>(
    Future<T> Function() action, {
    int maxAttempts = 3,
    Duration initialDelay = const Duration(milliseconds: 200),
    double multiplier = 2.0,
    Duration maxDelay = const Duration(seconds: 5),
    bool useJitter = true,
    bool Function(Object error)? shouldRetry,
    void Function(Object error, int attempt, Duration nextDelay)? onRetry,
  }) async {
    assert(maxAttempts >= 1, 'maxAttempts must be at least 1');

    var attempt = 1;
    var currentDelayMs = initialDelay.inMilliseconds.toDouble();
    final random = Random();

    while (true) {
      try {
        return await action();
      } catch (error) {
        if (attempt >= maxAttempts) {
          rethrow;
        }

        if (shouldRetry != null && !shouldRetry(error)) {
          rethrow;
        }

        // Calculate jittered delay
        var delayMs = currentDelayMs;
        if (useJitter) {
          final jitterRange = delayMs * 0.25;
          final jitter = (random.nextDouble() * 2 - 1) * jitterRange;
          delayMs = max(0, delayMs + jitter);
        }

        final delay = Duration(
          milliseconds: min(delayMs.round(), maxDelay.inMilliseconds),
        );

        onRetry?.call(error, attempt, delay);

        await Future.delayed(delay);

        currentDelayMs = min(
          currentDelayMs * multiplier,
          maxDelay.inMilliseconds.toDouble(),
        );
        attempt++;
      }
    }
  }
}

