import 'package:lava_cash/core/utils/string_utils.dart';
import 'package:url_launcher/url_launcher.dart';

abstract class WhatsAppService {
  static Future<bool> sendReadyMessage({
    required String phone,
    required String name,
    required String plate,
  }) async {
    final String normalizedPhone = AppStringUtils.digitsOnly(phone);
    if (normalizedPhone.isEmpty) {
      return false;
    }
    final String message = Uri.encodeComponent(
      'Olá $name! Seu veículo de placa $plate está pronto para retirada.',
    );
    final Uri url = Uri.parse(
      'https://wa.me/55$normalizedPhone?text=$message',
    );
    if (!await canLaunchUrl(url)) {
      return false;
    }
    return launchUrl(url, mode: LaunchMode.externalApplication);
  }
}
