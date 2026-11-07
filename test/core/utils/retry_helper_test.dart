import 'package:flutter_test/flutter_test.dart';
import 'package:progression_tracker/core/utils/retry_helper.dart';

void main() {
  group('RetryHelper withExponentialBackoff Tests', () {
    test('succeeds immediately on first attempt without delay', () async {
      var callCount = 0;
      final result = await RetryHelper.withExponentialBackoff(
        () async {
          callCount++;
          return 'ok';
        },
        maxAttempts: 3,
      );

      expect(result, 'ok');
      expect(callCount, 1);
    });

    test('retries on failure and succeeds when action eventually succeeds', () async {
      var callCount = 0;
      final retryLog = <int>[];

      final result = await RetryHelper.withExponentialBackoff(
        () async {
          callCount++;
          if (callCount < 3) {
            throw Exception('Transient network error');
          }
          return 'recovered';
        },
        maxAttempts: 4,
        initialDelay: const Duration(milliseconds: 10),
        useJitter: false,
        onRetry: (error, attempt, nextDelay) {
          retryLog.add(attempt);
        },
      );

      expect(result, 'recovered');
      expect(callCount, 3);
      expect(retryLog, [1, 2]);
    });

    test('rethrows error when maxAttempts exhausted', () async {
      var callCount = 0;

      expect(
        () => RetryHelper.withExponentialBackoff(
          () async {
            callCount++;
            throw FormatException('Permanent failure');
          },
          maxAttempts: 3,
          initialDelay: const Duration(milliseconds: 10),
          useJitter: false,
        ),
        throwsA(isA<FormatException>()),
      );
    });

    test('shouldRetry predicate aborts immediately on non-retryable error', () async {
      var callCount = 0;

      expect(
        () => RetryHelper.withExponentialBackoff(
          () async {
            callCount++;
            throw ArgumentError('Invalid argument, do not retry');
          },
          maxAttempts: 5,
          initialDelay: const Duration(milliseconds: 10),
          shouldRetry: (error) => error is! ArgumentError,
        ),
        throwsA(isA<ArgumentError>()),
      );

      expect(callCount, 1);
    });
  });
}

