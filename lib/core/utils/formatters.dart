import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lava_cash/core/utils/string_utils.dart';

abstract class AppFormatters {
  static final RegExp _plateNonAlphanumeric = RegExp(r'[^A-Z0-9]');

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

  /// Expense line on dark backgrounds: always `- R$ …` (minus before currency).
  static String formatCurrencyExpenseOutflow(double value) {
    final double safe = value < 0 ? 0 : value;
    return '- ${currency.format(safe)}';
  }

  static String formatCurrencyInputFromCentavos(int centavos) {
    int safe = centavos;
    if (safe < 0) {
      safe = 0;
    }
    return _currencyInputMask.format(safe / 100.0);
  }

  /// Full or partial plate (Mercosul / old): hyphen after third character when
  /// length is greater than 3 (matches input mask while typing).
  static String formatPlate(String raw) {
    final String carPlate = AppStringUtils.stripWhitespace(raw).toUpperCase();
    final String alnumOnly = carPlate.replaceAll(_plateNonAlphanumeric, '');
    if (alnumOnly.isEmpty) {
      return '';
    }
    if (alnumOnly.length <= 3) {
      return alnumOnly;
    }
    final String core =
        alnumOnly.length > 7 ? alnumOnly.substring(0, 7) : alnumOnly;
    return '${core.substring(0, 3)}-${core.substring(3)}';
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

  /// Parses `dd/MM/yyyy` from masked input; returns null if invalid.
  static DateTime? tryParseBrazilianDateDdMmYyyy(String raw) {
    final String t = AppStringUtils.stripWhitespace(raw);
    if (t.length != 10) {
      return null;
    }
    final RegExp re = RegExp(r'^(\d{2})/(\d{2})/(\d{4})$');
    final Match? m = re.firstMatch(t);
    if (m == null) {
      return null;
    }
    final int? dd = int.tryParse(m[1]!);
    final int? mm = int.tryParse(m[2]!);
    final int? yyyy = int.tryParse(m[3]!);
    if (dd == null || mm == null || yyyy == null) {
      return null;
    }
    final DateTime constructed = DateTime(yyyy, mm, dd);
    if (constructed.year != yyyy ||
        constructed.month != mm ||
        constructed.day != dd) {
      return null;
    }
    return constructed;
  }

  static String formatMonthYear(DateTime dateTime) {
    return DateFormat('MMMM yyyy', 'pt_BR').format(dateTime.toLocal());
  }

  /// Icon for a payment method key from reports (e.g. `pix`, `dinheiro`).
  static IconData iconForPaymentMethodKey(String raw) {
    final String k = raw.toLowerCase();
    if (k.contains('pix')) {
      return Icons.qr_code_2;
    }
    if (k.contains('dinheiro') || k.contains('espécie')) {
      return Icons.payments_outlined;
    }
    if (k.contains('débito') || k.contains('debito')) {
      return Icons.credit_card;
    }
    if (k.contains('crédito') || k.contains('credito')) {
      return Icons.credit_score;
    }
    return Icons.payment;
  }

  /// Human-readable label for a payment method key from reports.
  static String labelForPaymentMethodKey(String raw) {
    return raw.replaceAll('_', ' ');
  }
}
