import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Dedicated Supabase project for license validation (separate from the main app DB).
///
/// **Credentials (first non-empty wins):**
/// 1. `--dart-define=LICENSE_SUPABASE_URL=...` and
///    `--dart-define=LICENSE_SUPABASE_ANON_KEY=...`, or
///    `--dart-define-from-file=dart_defines.json`.
/// 2. Optional fallbacks: [_defaultUrl] and [_defaultAnonKey] below.
abstract class LicenseSupabaseClient {
  LicenseSupabaseClient._();

  static const String _defaultUrl = 'https://kjqaktmovcfsajjccdhu.supabase.co';

  static const String _defaultAnonKey =
      'sb_publishable_A5WusANVApveSjB0E3jD2Q_qdRzDhNx';

  static const String _urlFromDefine = String.fromEnvironment(
    'LICENSE_SUPABASE_URL',
    defaultValue: '',
  );

  static const String _anonKeyFromDefine = String.fromEnvironment(
    'LICENSE_SUPABASE_ANON_KEY',
    defaultValue: '',
  );

  static String get _resolvedUrl {
    final String raw =
        _urlFromDefine.isNotEmpty ? _urlFromDefine : _defaultUrl;
    return raw.trim();
  }

  static String get _resolvedAnonKey {
    final String raw =
        _anonKeyFromDefine.isNotEmpty ? _anonKeyFromDefine : _defaultAnonKey;
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

  /// Resolved project URL (after defines + fallback).
  static String get url => _resolvedUrl;

  /// Resolved anon key (after defines + fallback).
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
