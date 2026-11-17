/// Canonical local-midnight date window helpers.
///
/// Replaces raw `now.subtract(Duration(days: ...))` checks so 7-day and N-day
/// windows align cleanly with local calendar boundaries instead of dropping
/// workouts/logs logged earlier on the start day.
class LocalDateWindow {
  const LocalDateWindow._();

  /// Returns `00:00:00` local time for [date].
  static DateTime localMidnight(DateTime date) {
    final local = date.toLocal();
    return DateTime(local.year, local.month, local.day);
  }

  /// Returns inclusive start (`todayMidnight - (days - 1)`) and exclusive end
  /// (`tomorrowMidnight`) for an N-day calendar window ending today.
  ///
  /// For a 7-day rolling window (`days = 7`), this spans today plus the
  /// previous 6 local calendar days.
  static ({DateTime start, DateTime endExclusive}) rollingDaysWindow(
    int days, {
    DateTime? now,
  }) {
    assert(days >= 1);
    final today = localMidnight(now ?? DateTime.now());
    final start = DateTime(today.year, today.month, today.day - (days - 1));
    final endExclusive = DateTime(today.year, today.month, today.day + 1);
    return (start: start, endExclusive: endExclusive);
  }

  /// Returns start (`Monday 00:00` local time) and exclusive end
  /// (`next Monday 00:00` local time) of the current ISO week.
  static ({DateTime start, DateTime endExclusive}) currentWeekWindow({
    DateTime? now,
  }) {
    final today = localMidnight(now ?? DateTime.now());
    final start = DateTime(
      today.year,
      today.month,
      today.day - (today.weekday - 1),
    );
    final endExclusive = DateTime(start.year, start.month, start.day + 7);
    return (start: start, endExclusive: endExclusive);
  }

  /// True when [date]'s local timestamp falls inside `[start, endExclusive)`.
  static bool contains(
    DateTime date,
    DateTime start,
    DateTime endExclusive,
  ) {
    final local = date.toLocal();
    return !local.isBefore(start) && local.isBefore(endExclusive);
  }
}
