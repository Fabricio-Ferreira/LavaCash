import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Loads Supabase credentials for [Supabase.initialize].
///
/// **Where values come from (first non-empty wins for URL/key):**
/// 1. Compile-time `--dart-define=SUPABASE_URL=...` and
///    `--dart-define=SUPABASE_ANON_KEY=...`, or
///    `--dart-define-from-file=dart_defines.json` (see repository README).
/// 2. Optional fallbacks: [_url] and [_anonKey] below (normally left empty).
///
/// Copy **Project URL** and **anon public** key from Supabase Dashboard →
/// Project Settings → API. The hostname must match your project exactly
/// (e.g. `https://<project-ref>.supabase.co`).
///
/// If you see **Failed host lookup** for `*.supabase.co`, that is a DNS /
/// network issue on the device or emulator (not a wrong client API). Confirm
/// internet access, try `ping` / browser to the same host, emulator cold boot,
/// or another DNS. Trailing spaces in defines are trimmed here.
abstract class SupabaseInitializer {
  /// Paste from Supabase Dashboard → Project Settings → API (Project URL).
  static const String _url = '';

  /// Paste the anon (public) key here.
  static const String _anonKey = '';

  static const String _urlFromDefine = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: '',
  );

  static const String _anonKeyFromDefine = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '',
  );

  static String get _resolvedUrl {
    final String raw =
        _urlFromDefine.isNotEmpty ? _urlFromDefine : _url;
    return raw.trim();
  }

  static String get _resolvedAnonKey {
    final String raw =
        _anonKeyFromDefine.isNotEmpty ? _anonKeyFromDefine : _anonKey;
    return raw.trim();
  }

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

  static Future<void> ensureInitialized() async {
    if (_resolvedUrl.isEmpty || _resolvedAnonKey.isEmpty) {
      return;
    }
    if (!_isPlausibleSupabaseProjectUrl(_resolvedUrl)) {
      if (kDebugMode) {
        debugPrint(
          'SupabaseInitializer: SUPABASE_URL is not a valid http(s) URL: '
          '${_resolvedUrl.isEmpty ? "(empty)" : _resolvedUrl}',
        );
      }
      return;
    }
    await Supabase.initialize(url: _resolvedUrl, anonKey: _resolvedAnonKey);
  }

  static bool get isConfigured {
    return _resolvedUrl.isNotEmpty && _resolvedAnonKey.isNotEmpty;
  }

  static SupabaseClient? get clientOrNull {
    if (!isConfigured) {
      return null;
    }
    try {
      return Supabase.instance.client;
    } on Exception {
      return null;
    }
  }
}
