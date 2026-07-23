import 'package:intl/intl.dart';

/// Global format prefs, updated from provider at app boot and on user change.
/// Read by the format helpers below; screens re-render on Riverpod state
/// changes via [dateFormatProvider] / [firstDayOfWeekProvider] watchers.
class AppFormat {
  static String datePattern = 'MMM d, yyyy';
  static int firstDayOfWeek = 7; // ISO: 1=Monday, 7=Sunday
}

const List<String> supportedDatePatterns = [
  'MMM d, yyyy',
  'd MMM yyyy',
  'MM/dd/yyyy',
  'dd/MM/yyyy',
  'yyyy-MM-dd',
];

String formatCurrency(double value, {String symbol = '\$'}) {
  final f = NumberFormat.currency(symbol: symbol, decimalDigits: 2);
  return f.format(value);
}

String formatCompactCurrency(double value, {String symbol = '\$'}) {
  final f = NumberFormat.compactCurrency(symbol: symbol, decimalDigits: 1);
  return f.format(value);
}

String formatDate(DateTime date) => DateFormat(AppFormat.datePattern).format(date);

String formatShortDate(DateTime date) => DateFormat('MMM d').format(date);

String formatMonthYear(DateTime date) => DateFormat.yMMMM().format(date);

String formatTime(DateTime date) => DateFormat.jm().format(date);

String formatIsoDate(DateTime date) => date.toIso8601String();

DateTime parseIsoDate(String s) => DateTime.parse(s);

String monthKey(DateTime d) => '${d.year}-${d.month.toString().padLeft(2, '0')}';
