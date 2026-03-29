import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Dedicated Supabase project for license validation (separate from the main app DB).
///
/// **Credentials (required at compile time):**
/// - `--dart-define=LICENSE_SUPABASE_URL=...` and
///   `--dart-define=LICENSE_SUPABASE_ANON_KEY=...`, or
///   `--dart-define-from-file=dart_defines.json` (see repository README).
///
/// Do not embed fallbacks in source: keys are still visible in the binary when
/// passed via [String.fromEnvironment], but hardcoding them in code is worse.
abstract class LicenseSupabaseClient {
  LicenseSupabaseClient._();

  static const String _urlFromDefine = String.fromEnvironment(
    'LICENSE_SUPABASE_URL',
    defaultValue: '',
  );

  static const String _anonKeyFromDefine = String.fromEnvironment(
    'LICENSE_SUPABASE_ANON_KEY',
    defaultValue: '',
  );

  static String get _resolvedUrl => _urlFromDefine.trim();

  static String get _resolvedAnonKey => _anonKeyFromDefine.trim();

  static bool _isPlausibleSupabaseProjectUrl(String url) {
    final Uri? uri = Uri.tryParse(url);
    if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
      return false;
    }
    if (uri.scheme != 'https' && uri.scheme != 'http') {
      return false;
    }
    return true;
  }

  /// Resolved project URL (from defines only).
  static String get url => _resolvedUrl;

  /// Resolved anon key (from defines only).
  static String get anonKey => _resolvedAnonKey;

  static bool get isConfigured {
    return _resolvedUrl.isNotEmpty &&
        _resolvedAnonKey.isNotEmpty &&
        _isPlausibleSupabaseProjectUrl(_resolvedUrl);
  }

  /// Standalone client (does not use [Supabase.initialize] singleton).
  static SupabaseClient create() {
    if (!isConfigured) {
      if (kDebugMode) {
        debugPrint(
          'LicenseSupabaseClient: invalid or empty LICENSE_SUPABASE_URL / '
          'LICENSE_SUPABASE_ANON_KEY',
        );
      }
      throw StateError(
        'License Supabase is not configured. Set LICENSE_SUPABASE_URL and '
        'LICENSE_SUPABASE_ANON_KEY via --dart-define or dart_defines.json.',
      );
    }
    return SupabaseClient(_resolvedUrl, _resolvedAnonKey);
  }
}
