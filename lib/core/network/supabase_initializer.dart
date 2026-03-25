import 'package:supabase_flutter/supabase_flutter.dart';

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

  static String get _resolvedUrl =>
      _urlFromDefine.isNotEmpty ? _urlFromDefine : _url;

  static String get _resolvedAnonKey =>
      _anonKeyFromDefine.isNotEmpty ? _anonKeyFromDefine : _anonKey;

  static Future<void> ensureInitialized() async {
    if (_resolvedUrl.isEmpty || _resolvedAnonKey.isEmpty) {
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
