import 'package:supabase_flutter/supabase_flutter.dart';

abstract class SupabaseInitializer {
  static const String _url = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: '',
  );

  static const String _anonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '',
  );

  static Future<void> ensureInitialized() async {
    if (_url.isEmpty || _anonKey.isEmpty) {
      return;
    }
    await Supabase.initialize(
      url: _url,
      anonKey: _anonKey,
    );
  }

  static bool get isConfigured {
    return _url.isNotEmpty && _anonKey.isNotEmpty;
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
