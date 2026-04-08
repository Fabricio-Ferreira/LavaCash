import 'package:supabase_flutter/supabase_flutter.dart';

/// Maps known license RPC errors to user-facing Portuguese messages.
String mapLicensePostgrestMessage(PostgrestException exception) {
  final String raw = exception.message.trim();
  final String lower = raw.toLowerCase();
  if (lower.contains('já vinculada') && lower.contains('dispositivo')) {
    return 'Esta licença já está vinculada a outro aparelho. '
        'Cada código de ativação vale para um dispositivo. '
        'Para usar neste aparelho, fale com o suporte para '
        'desvincular o aparelho anterior.';
  }
  return raw;
}
