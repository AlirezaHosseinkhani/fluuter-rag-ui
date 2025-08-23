import 'package:intl/intl.dart';

class DateFormatter {
  static String formatTime(DateTime dateTime) {
    return DateFormat('HH:mm', 'fa_IR').format(dateTime);
  }

  static String formatDate(DateTime dateTime) {
    return DateFormat('yyyy/MM/dd', 'fa_IR').format(dateTime);
  }
}