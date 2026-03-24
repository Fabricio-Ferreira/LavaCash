import 'package:intl/intl.dart';
import 'package:lava_cash/core/utils/string_utils.dart';

abstract class AppFormatters {
  static final NumberFormat currency = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: r'R$',
  );

  static String formatCurrency(double value) {
    return currency.format(value);
  }

  static String formatPlate(String raw) {
    return AppStringUtils.stripWhitespace(raw).toUpperCase();
  }

  static String formatDurationFromSeconds(int totalSeconds) {
    final int hours = totalSeconds ~/ 3600;
    final int minutes = (totalSeconds % 3600) ~/ 60;
    final int seconds = totalSeconds % 60;
    final String hh = hours.toString().padLeft(2, '0');
    final String mm = minutes.toString().padLeft(2, '0');
    final String ss = seconds.toString().padLeft(2, '0');
    return '$hh:$mm:$ss';
  }

  static String formatDateTime(DateTime dateTime) {
    return DateFormat('dd/MM/yyyy HH:mm').format(dateTime.toLocal());
  }

  static String formatMonthYear(DateTime dateTime) {
    return DateFormat('MMMM yyyy', 'pt_BR').format(dateTime.toLocal());
  }
}
