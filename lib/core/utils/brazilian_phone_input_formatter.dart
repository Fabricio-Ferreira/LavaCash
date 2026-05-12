import 'package:flutter/services.dart';

import 'string_utils.dart';

/// Masks Brazilian national numbers: `(AA) 9NNNN-NNNN` (mobile) or
/// `(AA) NNNN-NNNN` (landline). Mobile is detected when the first digit
/// after the area code is `9`.
class BrazilianPhoneInputFormatter extends TextInputFormatter {
  /// Formats digits-only phone strings from storage for seeded text fields.
  static String maskedFromStored(String stored) {
    final String digits = AppStringUtils.digitsOnly(stored);
    final String capped = _capDigits(digits);
    return _formatBrazilianPhone(capped);
  }

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final String digits = AppStringUtils.digitsOnly(newValue.text);
    final String capped = _capDigits(digits);
    final String formatted = _formatBrazilianPhone(capped);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  static String _capDigits(String digits) {
    if (digits.length <= 2) {
      return digits;
    }
    final bool mobile = digits[2] == '9';
    if (mobile) {
      return digits.length > 11 ? digits.substring(0, 11) : digits;
    }
    return digits.length > 10 ? digits.substring(0, 10) : digits;
  }

  static String _formatBrazilianPhone(String digits) {
    if (digits.isEmpty) {
      return '';
    }
    if (digits.length <= 2) {
      return '($digits';
    }
    final String dd = digits.substring(0, 2);
    final String rest = digits.substring(2);
    if (rest.isEmpty) {
      return '($dd) ';
    }
    final bool mobile = rest[0] == '9';
    if (mobile) {
      if (rest.length <= 5) {
        return '($dd) $rest';
      }
      final String head = rest.substring(0, 5);
      final String tail = rest.substring(5);
      return '($dd) $head-$tail';
    }
    if (rest.length <= 4) {
      return '($dd) $rest';
    }
    final String head = rest.substring(0, 4);
    final String tail = rest.substring(4);
    return '($dd) $head-$tail';
  }
}
