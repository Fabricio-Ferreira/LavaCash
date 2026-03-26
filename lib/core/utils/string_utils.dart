import 'package:intl/intl.dart';

import 'formatters.dart';

abstract class AppStringUtils {
  static String digitsOnly(String value) {
    final StringBuffer buffer = StringBuffer();
    for (final int r in value.runes) {
      if (r >= 0x30 && r <= 0x39) {
        buffer.writeCharCode(r);
      }
    }
    return buffer.toString();
  }

  /// Removes ASCII whitespace (ECMAScript `\s` subset used for plates).
  static String stripWhitespace(String value) {
    return String.fromCharCodes(
      value.runes.where((int r) => !_isWhitespaceRune(r)),
    );
  }

  static bool _isWhitespaceRune(int r) {
    return r == 0x20 ||
        r == 0x09 ||
        r == 0x0A ||
        r == 0x0D ||
        r == 0x0C ||
        r == 0x0B;
  }

  static String formatNomeServico(String? raw) {
    if (raw == null || raw.trim().isEmpty) {
      return '—';
    }
    return raw.trim();
  }

  static String formatVeiculo(String? raw) {
    if (raw == null || raw.trim().isEmpty) {
      return '—';
    }
    return AppFormatters.formatPlate(raw.trim());
  }

  static String formatDataHora(DateTime? dt) {
    if (dt == null) {
      return '—';
    }
    final DateTime local = dt.toLocal();
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    final DateTime day = DateTime(local.year, local.month, local.day);
    if (day == today) {
      return 'Hoje, ${DateFormat('HH:mm').format(local)}';
    }
    return DateFormat("dd/MM/yyyy 'às' HH:mm").format(local);
  }
}
