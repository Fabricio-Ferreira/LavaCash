abstract class AppConstants {
  static const String appName = 'Lava Cash';

  static const Duration searchDebounce = Duration(milliseconds: 350);

  static const int minPhoneDigits = 10;

  /// Digits only (DDD + number, no country code). Used for license support
  /// WhatsApp on the blocked screen. Empty disables opening WhatsApp.
  static const String licenseSupportWhatsAppDigits = '51982145023';
}
