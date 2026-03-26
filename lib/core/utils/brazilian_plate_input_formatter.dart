import 'package:flutter/services.dart';

/// Mercosul or old plate: up to 7 alphanumeric characters, uppercase, with a
/// hyphen after the third character (e.g. `ABC-1D23`, `ABC-1234`).
class BrazilianPlateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final StringBuffer buffer = StringBuffer();
    for (final int r in newValue.text.toUpperCase().runes) {
      final bool isDigit = r >= 0x30 && r <= 0x39;
      final bool isLetter = r >= 0x41 && r <= 0x5A;
      if ((isDigit || isLetter) && buffer.length < 7) {
        buffer.writeCharCode(r);
      }
    }
    final String alnum = buffer.toString();
    final String formatted = _formatPlateDisplay(alnum);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  static String _formatPlateDisplay(String alnum) {
    if (alnum.length <= 3) {
      return alnum;
    }
    return '${alnum.substring(0, 3)}-${alnum.substring(3)}';
  }
}
