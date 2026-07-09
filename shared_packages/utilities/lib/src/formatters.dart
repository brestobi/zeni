import 'package:intl/intl.dart';

/// Formatting helpers for currency, dates, and distances.
class Formatters {
  Formatters._();

  static final _currencyFormat = NumberFormat.currency(
    symbol: 'R',
    decimalDigits: 2,
  );

  static final _dateFormat = DateFormat('MMM dd, yyyy');
  static final _timeFormat = DateFormat('hh:mm a');
  static final _dateTimeFormat = DateFormat('MMM dd, yyyy hh:mm a');

  static String currency(double amount) => _currencyFormat.format(amount);

  static String date(DateTime date) => _dateFormat.format(date);

  static String time(DateTime date) => _timeFormat.format(date);

  static String dateTime(DateTime date) => _dateTimeFormat.format(date);

  static String distance(double meters) {
    if (meters < 1000) {
      return '${meters.round()} m';
    }
    return '${(meters / 1000).toStringAsFixed(1)} km';
  }

  static String duration(int seconds) {
    final minutes = seconds ~/ 60;
    if (minutes < 60) {
      return '$minutes min';
    }
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    return '${hours}h ${remainingMinutes}m';
  }
}
