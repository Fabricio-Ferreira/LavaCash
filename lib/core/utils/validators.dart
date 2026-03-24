import 'package:lava_cash/core/utils/string_utils.dart';

abstract class AppValidators {
  static bool isValidPlate(String value) {
    final String cleaned = AppStringUtils.stripWhitespace(value).toUpperCase();
    if (cleaned.length < 7 || cleaned.length > 8) {
      return false;
    }
    return _matchesMercosulPlate(cleaned) || _matchesOldPlate(cleaned);
  }

  static bool isValidPhone(String value) {
    final String digits = AppStringUtils.digitsOnly(value);
    return digits.length >= 10 && digits.length <= 13;
  }

  static bool _matchesOldPlate(String cleaned) {
    if (cleaned.length != 7) {
      return false;
    }
    if (!_isAsciiUpperLetter(cleaned.codeUnitAt(0)) ||
        !_isAsciiUpperLetter(cleaned.codeUnitAt(1)) ||
        !_isAsciiUpperLetter(cleaned.codeUnitAt(2))) {
      return false;
    }
    if (!_isAsciiDigit(cleaned.codeUnitAt(3)) ||
        !_isAsciiDigit(cleaned.codeUnitAt(4)) ||
        !_isAsciiDigit(cleaned.codeUnitAt(5)) ||
        !_isAsciiDigit(cleaned.codeUnitAt(6))) {
      return false;
    }
    return true;
  }

  static bool _matchesMercosulPlate(String cleaned) {
    if (cleaned.length != 7) {
      return false;
    }
    if (!_isAsciiUpperLetter(cleaned.codeUnitAt(0)) ||
        !_isAsciiUpperLetter(cleaned.codeUnitAt(1)) ||
        !_isAsciiUpperLetter(cleaned.codeUnitAt(2))) {
      return false;
    }
    if (!_isAsciiDigit(cleaned.codeUnitAt(3))) {
      return false;
    }
    final int fourth = cleaned.codeUnitAt(4);
    if (!_isAsciiUpperLetter(fourth) && !_isAsciiDigit(fourth)) {
      return false;
    }
    if (!_isAsciiDigit(cleaned.codeUnitAt(5)) ||
        !_isAsciiDigit(cleaned.codeUnitAt(6))) {
      return false;
    }
    return true;
  }

  static bool _isAsciiUpperLetter(int unit) {
    return unit >= 0x41 && unit <= 0x5A;
  }

  static bool _isAsciiDigit(int unit) {
    return unit >= 0x30 && unit <= 0x39;
  }
}
