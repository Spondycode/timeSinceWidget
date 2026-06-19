/// A utility class for date calculations, independent of any UI framework.
class DateCounter {
  /// Calculates the positive (absolute) difference in days between two [DateTime] objects,
  /// ignoring the time component (hour, minute, second, etc.) to ensure accurate calendar day differences.
  static int differenceInDays(DateTime start, DateTime end) {
    final startDateOnly = DateTime(start.year, start.month, start.day);
    final endDateOnly = DateTime(end.year, end.month, end.day);
    
    return endDateOnly.difference(startDateOnly).inDays.abs();
  }

  /// Calculates the difference in weeks and remaining days between two [DateTime] objects.
  /// Returns a map with keys 'weeks' and 'days'.
  static Map<String, int> differenceInWeeksAndDays(DateTime start, DateTime end) {
    final totalDays = differenceInDays(start, end);
    final weeks = totalDays ~/ 7;
    final remainingDays = totalDays % 7;
    
    return {
      'weeks': weeks,
      'days': remainingDays,
    };
  }
}
