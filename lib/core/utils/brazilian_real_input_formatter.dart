import 'package:flutter/services.dart';

import 'formatters.dart';

/// Keeps only digits as centavos and displays `1.234,56` (BRL, no symbol).
class BrazilianRealInputFormatter extends TextInputFormatter {
  const BrazilianRealInputFormatter();

  static const int _maxDigits = 14;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final String digitsOnly =
        newValue.text.replaceAll(RegExp(r'\D'), '');
    if (digitsOnly.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }
    String capped = digitsOnly;
    if (capped.length > _maxDigits) {
      capped = capped.substring(0, _maxDigits);
    }
    final int? centavos = int.tryParse(capped);
    if (centavos == null) {
      return oldValue;
    }
    final String formatted =
        AppFormatters.formatCurrencyInputFromCentavos(centavos);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
