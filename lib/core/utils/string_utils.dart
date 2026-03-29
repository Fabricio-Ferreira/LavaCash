import 'package:intl/intl.dart';
import 'package:lava_cash/core/utils/license_type_enum.dart';

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

  /// Up to 2 uppercase letters from [name] (first letter of first two words,
  /// or first two letters of a single word).
  static String extractInitials(String name) {
    final String trimmed = name.trim();
    if (trimmed.isEmpty) {
      return '??';
    }
    final List<String> parts =
        trimmed
            .split(RegExp(r'\s+'))
            .where((String p) => p.isNotEmpty)
            .toList();
    if (parts.isEmpty) {
      return '??';
    }
    if (parts.length == 1) {
      final String word = parts.first;
      if (word.length >= 2) {
        return word.substring(0, 2).toUpperCase();
      }
      return word.toUpperCase();
    }
    final String first = _firstLetterUpper(parts[0]);
    final String second = _firstLetterUpper(parts[1]);
    return '$first$second';
  }

  static String _firstLetterUpper(String word) {
    if (word.isEmpty) {
      return '';
    }
    return String.fromCharCode(word.runes.first).toUpperCase();
  }

  /// Capitalizes each whitespace-separated word (display labels).
  static String capitalizeWords(String value) {
    final String trimmed = value.trim();
    if (trimmed.isEmpty) {
      return '';
    }
    return trimmed
        .split(RegExp(r'\s+'))
        .where((String w) => w.isNotEmpty)
        .map((String w) {
          final String lower = w.toLowerCase();
          return '${lower[0].toUpperCase()}${lower.substring(1)}';
        })
        .join(' ');
  }

  /// PT-BR greeting line for the current time of day (e.g. "Olá, bom dia").
  static String resolveGreetingLine(DateTime now) {
    final int hourOfDay = now.hour;
    if (hourOfDay >= 6 && hourOfDay < 12) {
      return 'Olá, bom dia';
    }
    if (hourOfDay >= 12 && hourOfDay < 18) {
      return 'Olá, boa tarde';
    }
    return 'Olá, boa noite';
  }

  /// Maps known license type codes to PT-BR labels; otherwise [capitalizeWords].
  static String formatLicenseTypeLabel(String raw) {
    final String trimmed = raw.trim();
    if (trimmed.isEmpty) {
      return '';
    }
    final LicenseTypeEnum? parsed = LicenseTypeEnum.tryParse(trimmed);
    if (parsed != null) {
      return parsed.label;
    }
    return capitalizeWords(trimmed);
  }
}
