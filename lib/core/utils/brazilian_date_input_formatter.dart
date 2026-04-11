import 'package:flutter/services.dart';

import 'string_utils.dart';

/// Inserts slashes while typing: `dd/MM/yyyy` (digits only, max 8 digits).
class BrazilianDateInputFormatter extends TextInputFormatter {
  const BrazilianDateInputFormatter();

  static const int _maxDigits = 8;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final String digits = AppStringUtils.digitsOnly(newValue.text);
    if (digits.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }
    final String capped =
        digits.length > _maxDigits ? digits.substring(0, _maxDigits) : digits;
    final StringBuffer out = StringBuffer();
    for (int i = 0; i < capped.length; i++) {
      if (i == 2 || i == 4) {
        out.write('/');
      }
      out.write(capped[i]);
    }
    final String text = out.toString();
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
