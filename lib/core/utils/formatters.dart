import 'package:intl/intl.dart';
import 'package:lava_cash/core/utils/string_utils.dart';

abstract class AppFormatters {
  static final NumberFormat currency = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: r'R$',
  );

  /// BRL input mask: thousands `.`, decimals `,` (e.g. `1.234,56`), no symbol.
  static final NumberFormat _currencyInputMask = NumberFormat(
    '#,##0.00',
    'pt_BR',
  );

  static String formatCurrency(double value) {
    return currency.format(value);
  }

  static String formatCurrencyInputFromCentavos(int centavos) {
    int safe = centavos;
    if (safe < 0) {
      safe = 0;
    }
    return _currencyInputMask.format(safe / 100.0);
  }

  static String formatPlate(String raw) {
    final carPlate = AppStringUtils.stripWhitespace(raw).toUpperCase();
    if (carPlate.length == 7) {
      return '${carPlate.substring(0, 3)}-${carPlate.substring(3)}';
    }
    return carPlate;
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

  /// Hours and minutes only, for large timer display (e.g. `12:45`).
  static String formatElapsedHoursMinutes(int totalSeconds) {
    final int hours = totalSeconds ~/ 3600;
    final int minutes = (totalSeconds % 3600) ~/ 60;
    final String hh = hours.toString().padLeft(2, '0');
    final String mm = minutes.toString().padLeft(2, '0');
    return '$hh:$mm';
  }

  /// Parses money typed as `1.234,56`, `50`, or `50,5`.
  static double? parseMoneyInput(String raw) {
    final String trimmed = raw.trim().replaceAll(RegExp(r'[^\d,.]'), '');
    if (trimmed.isEmpty) {
      return null;
    }
    final bool hasComma = trimmed.contains(',');
    final bool hasDot = trimmed.contains('.');
    String normalized = trimmed;
    if (hasComma && hasDot) {
      normalized = trimmed.replaceAll('.', '').replaceAll(',', '.');
    } else if (hasComma) {
      normalized = trimmed.replaceAll(',', '.');
    }
    return double.tryParse(normalized);
  }

  static String formatDateTime(DateTime dateTime) {
    return DateFormat('dd/MM/yyyy HH:mm').format(dateTime.toLocal());
  }

  static String formatMonthYear(DateTime dateTime) {
    return DateFormat('MMMM yyyy', 'pt_BR').format(dateTime.toLocal());
  }
}
