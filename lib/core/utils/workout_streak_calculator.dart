/// Single canonical workout streak calculator using local calendar dates.
///
/// Normalizes all timestamps with [DateTime.toLocal] to year/month/day calendar
/// dates and compares day gaps in UTC calendar-day space so DST transitions
/// (23h / 25h days) and multiple sessions on the same day never miscount.
class WorkoutStreakCalculator {
  const WorkoutStreakCalculator._();

  /// Returns the local calendar date `(year, month, day)` with time zeroed.
  static DateTime toLocalCalendarDate(DateTime dateTime) {
    final local = dateTime.toLocal();
    return DateTime(local.year, local.month, local.day);
  }

  /// Signed calendar day difference `later - earlier` immune to DST shifts.
  static int calendarDayDifference(DateTime earlier, DateTime later) {
    final a = DateTime.utc(earlier.year, earlier.month, earlier.day);
    final b = DateTime.utc(later.year, later.month, later.day);
    return b.difference(a).inDays;
  }

  /// Computes `{currentStreak, longestStreak}` from raw workout timestamps.
  ///
  /// - Deduplicates multiple workouts logged on the same local calendar day.
  /// - A [currentStreak] stays active if the most recent workout occurred today
  ///   or yesterday relative to [now]; if the gap is 2+ days, `currentStreak` is `0`.
  /// - [longestStreak] reflects the longest run of consecutive local calendar days
  ///   across the entire supplied date sequence.
  static ({int currentStreak, int longestStreak}) calculateFromDates(
    Iterable<DateTime> workoutDates, {
    DateTime? now,
  }) {
    final today = toLocalCalendarDate(now ?? DateTime.now());
    final uniqueDays = <DateTime>{
      for (final dt in workoutDates)
        if (!toLocalCalendarDate(dt).isAfter(today)) toLocalCalendarDate(dt),
    }.toList()
      ..sort();

    if (uniqueDays.isEmpty) {
      return (currentStreak: 0, longestStreak: 0);
    }

    var longest = 1;
    var running = 1;

    for (var i = 1; i < uniqueDays.length; i++) {
      final diff = calendarDayDifference(uniqueDays[i - 1], uniqueDays[i]);
      if (diff == 1) {
        running += 1;
        if (running > longest) {
          longest = running;
        }
      } else {
        running = 1;
      }
    }

    final latest = uniqueDays.last;
    final daysSinceLatest = calendarDayDifference(latest, today);
    final current = daysSinceLatest <= 1 ? running : 0;

    return (currentStreak: current, longestStreak: longest);
  }
}
