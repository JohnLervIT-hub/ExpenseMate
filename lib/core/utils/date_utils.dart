DateTime firstDayOfMonth(DateTime d) => DateTime(d.year, d.month, 1);

DateTime lastDayOfMonth(DateTime d) => DateTime(d.year, d.month + 1, 0, 23, 59, 59, 999);

DateTime firstDayOfYear(DateTime d) => DateTime(d.year, 1, 1);

DateTime lastDayOfYear(DateTime d) => DateTime(d.year, 12, 31, 23, 59, 59, 999);

int daysBetween(DateTime a, DateTime b) {
  final aa = DateTime(a.year, a.month, a.day);
  final bb = DateTime(b.year, b.month, b.day);
  return bb.difference(aa).inDays;
}

int daysInMonth(int year, int month) => DateTime(year, month + 1, 0).day;

List<String> monthLabels() => const [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];

/// Returns [year, month] pairs for the last [count] months ending at [end].
List<(int year, int month)> lastNMonths(DateTime end, int count) {
  final result = <(int, int)>[];
  var y = end.year;
  var m = end.month;
  for (var i = 0; i < count; i++) {
    result.add((y, m));
    m -= 1;
    if (m == 0) {
      m = 12;
      y -= 1;
    }
  }
  return result.reversed.toList();
}
