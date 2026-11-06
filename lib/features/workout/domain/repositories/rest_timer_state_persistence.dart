/// Domain contract for persisting active rest-timer timestamps across app restarts.
abstract class RestTimerStatePersistence {
  Future<void> saveRestTimer(
    DateTime targetEndTime,
    int totalSeconds, {
    String? userId,
  });

  ({DateTime targetEndTime, int totalSeconds})? getRestTimer({
    String? userId,
  });

  Future<void> clearRestTimer({String? userId});
}

