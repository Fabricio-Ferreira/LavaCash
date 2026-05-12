import 'package:flutter/services.dart';

import 'formatters.dart';

/// Applies [AppFormatters.formatPlate] only for plate-like tokens (has at least
/// one digit, no whitespace). Names with spaces stay untouched; single-token
/// names without digits stay unmasked so `MARIA` does not become `MAR-IA`.
class PlateOrNameSearchInputFormatter extends TextInputFormatter {
  static final RegExp _whitespace = RegExp(r'\s');
  static final RegExp _plateStrip = RegExp(r'[^A-Za-z0-9]');
  static final RegExp _digit = RegExp(r'[0-9]');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final String text = newValue.text;
    if (_whitespace.hasMatch(text)) {
      return newValue;
    }
    final String alnumUpper =
        text.toUpperCase().replaceAll(_plateStrip, '');
    final bool plateLike =
        alnumUpper.isNotEmpty && _digit.hasMatch(alnumUpper);
    if (plateLike) {
      final String masked = AppFormatters.formatPlate(alnumUpper);
      return TextEditingValue(
        text: masked,
        selection: TextSelection.collapsed(offset: masked.length),
      );
    }
    final String sanitized = _sanitizeNameToken(text);
    return TextEditingValue(
      text: sanitized,
      selection: TextSelection.collapsed(offset: sanitized.length),
    );
  }

  static String _sanitizeNameToken(String text) {
    final StringBuffer buf = StringBuffer();
    for (final int rune in text.runes) {
      final String ch = String.fromCharCode(rune);
      if (_isAllowedNameCharacter(ch)) {
        buf.write(ch);
      }
    }
    return buf.toString();
  }

  static bool _isAllowedNameCharacter(String ch) {
    if (ch == '-' || ch == "'" || ch == '’') {
      return true;
    }
    if (ch.length == 1) {
      final int c = ch.codeUnitAt(0);
      final bool isAsciiLetter =
          (c >= 0x41 && c <= 0x5A) || (c >= 0x61 && c <= 0x7A);
      if (isAsciiLetter) {
        return true;
      }
      return c > 0x7F;
    }
    return true;
  }
}
