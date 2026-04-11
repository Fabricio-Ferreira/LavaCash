enum LicenseTypeEnum {
  trial,
  monthly;

  String get label {
    switch (this) {
      case LicenseTypeEnum.trial:
        return 'Teste';
      case LicenseTypeEnum.monthly:
        return 'Mensal';
    }
  }

  /// Parses API / storage values such as `trial`, `monthly`.
  static LicenseTypeEnum? tryParse(String value) {
    switch (value.trim().toLowerCase()) {
      case 'trial':
        return LicenseTypeEnum.trial;
      case 'monthly':
        return LicenseTypeEnum.monthly;
      default:
        return null;
    }
  }
}
