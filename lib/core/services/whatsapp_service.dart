import 'package:lava_cash/core/utils/app_snackbar.dart';
import 'package:lava_cash/core/utils/string_utils.dart';
import 'package:url_launcher/url_launcher.dart';

abstract class WhatsAppService {
  /// Opens WhatsApp with a prefilled message (Brazil country code 55).
  static Future<bool> openChatWithPrefilledText({
    required String phoneDigitsOnly,
    required String message,
  }) async {
    final String normalized = AppStringUtils.digitsOnly(phoneDigitsOnly);
    if (normalized.isEmpty) {
      return false;
    }
    final Uri url = Uri.parse('https://wa.me/55$normalized?text=$message');
    if (!await canLaunchUrl(url)) {
      AppSnackbar.showError('Não foi possível abrir o WhatsApp.');
      return false;
    }
    return launchUrl(url, mode: LaunchMode.externalApplication);
  }

  /// Opens the native phone dialer with [phoneDigitsOnly] (non-digits stripped).
  static Future<bool> openSystemDialer({
    required String phoneDigitsOnly,
  }) async {
    final String normalized = AppStringUtils.digitsOnly(phoneDigitsOnly);
    if (normalized.isEmpty) {
      AppSnackbar.showError('Telefone inválido.');
      return false;
    }
    final Uri url = Uri.parse('tel: $normalized');
    if (!await canLaunchUrl(url)) {
      AppSnackbar.showError('Não foi possível abrir o discador.');
      return false;
    }
    return launchUrl(url, mode: LaunchMode.externalApplication);
  }
}
