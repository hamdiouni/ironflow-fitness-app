/// A surface that mirrors the rest timer outside the app UI, such as an
/// Android lock-screen notification or a browser notification (Wave 8.1,
/// ADR-004).
///
/// Every method is fire-and-forget: the rest timer must keep working when a
/// surface is unavailable, denied, or throws.
abstract class RestTimerLiveSurface {
  /// Shows a live countdown that ends at [endTime].
  void showRunning({required DateTime endTime, required int totalSeconds});

  /// Shows a paused state with [remainingSeconds] left.
  void showPaused({required int remainingSeconds});

  /// Called once when the rest interval finishes (not when it is stopped).
  void showCompleted();

  /// Removes the live surface (stop, skip, or after completion).
  void clear();
}
