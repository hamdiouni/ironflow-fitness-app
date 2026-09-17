// Utility extensions for common operations
library;

extension DateTimeExtensions on DateTime {
  /// Returns true if this date is the same day as [other]
  bool isSameDay(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }

  /// Returns a DateTime with time set to midnight
  DateTime get dateOnly {
    return DateTime(year, month, day);
  }

  /// Returns a formatted string for display (e.g., "Jan 15, 2024")
  String toDisplayString() {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${months[month - 1]} $day, $year';
  }
}

extension DurationExtensions on Duration {
  /// Returns a formatted string for display (e.g., "1h 30m")
  String toDisplayString() {
    final hours = inHours;
    final minutes = inMinutes.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }
}

extension DoubleExtensions on double {
  /// Rounds to specified decimal places
  double roundToDecimal(int places) {
    if (places < 0) return this;
    final mod = _pow(10.0, places);
    return (this * mod).round() / mod;
  }

  /// Helper function to calculate power
  double _pow(double base, int exponent) {
    if (exponent == 0) return 1.0;
    double result = 1.0;
    for (int i = 0; i < exponent; i++) {
      result *= base;
    }
    return result;
  }
}

extension ListExtensions<T> on List<T> {
  /// Returns a new list with elements sampled evenly to reach [maxLength]
  List<T> sample(int maxLength) {
    if (length <= maxLength) return this;

    final step = length / maxLength;
    final sampled = <T>[];

    for (var i = 0; i < maxLength; i++) {
      final index = (i * step).floor();
      sampled.add(this[index]);
    }

    return sampled;
  }
}
