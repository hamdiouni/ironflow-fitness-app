import 'dart:async';

import 'package:flutter/foundation.dart';

/// A utility class that debounces rapid calls to [run].
///
/// Only the last [run] call within [delay] will actually invoke the callback.
/// This is used in [ExerciseSelectionScreen] to prevent excessive state
/// updates while the user is typing.
///
/// Requirements: 16.5
class Debouncer {
  Debouncer(this.delay);

  /// The delay window. Calls within this window are collapsed into one.
  final Duration delay;

  Timer? _timer;

  /// Schedule [action] to run after [delay].
  ///
  /// If called again before [delay] elapses, the previous scheduled call is
  /// cancelled and the timer restarts.
  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(delay, action);
  }

  /// Cancel any pending callback and release resources.
  void dispose() {
    _timer?.cancel();
    _timer = null;
  }
}
