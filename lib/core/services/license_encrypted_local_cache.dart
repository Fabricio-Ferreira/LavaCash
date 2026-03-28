import 'dart:convert';
import 'dart:typed_data';

import 'package:encrypt/encrypt.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists the last successful license RPC row: AES-256 in SharedPreferences,
/// encryption key in [FlutterSecureStorage].
///
/// Keys default from [String.fromEnvironment] (`LICENSE_LOCAL_CACHE_PREFS_KEY`,
/// `LICENSE_LOCAL_CACHE_SECURE_KEY`) or `dart_defines.json`; see `.env.example`.
class LicenseEncryptedLocalCache {
  LicenseEncryptedLocalCache({
    FlutterSecureStorage? secureStorage,
  }) : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  static const String _prefsKeyFallback = 'license_row_enc_v1';
  static const String _secureKeyFallback = 'license_row_aes_key_b64';

  static const String _prefsKeyFromDefine = String.fromEnvironment(
    'LICENSE_LOCAL_CACHE_PREFS_KEY',
    defaultValue: '',
  );

  static const String _secureKeyFromDefine = String.fromEnvironment(
    'LICENSE_LOCAL_CACHE_SECURE_KEY',
    defaultValue: '',
  );

  static String get _prefsKey {
    final String t = _prefsKeyFromDefine.trim();
    return t.isNotEmpty ? t : _prefsKeyFallback;
  }

  static String get _secureKeyStorageKey {
    final String t = _secureKeyFromDefine.trim();
    return t.isNotEmpty ? t : _secureKeyFallback;
  }

  final FlutterSecureStorage _secureStorage;

  Future<Key> _getOrCreateAesKey() async {
    String? keyB64 = await _secureStorage.read(key: _secureKeyStorageKey);
    if (keyB64 == null || keyB64.isEmpty) {
      final Key key = Key.fromSecureRandom(32);
      keyB64 = base64Encode(key.bytes);
      await _secureStorage.write(key: _secureKeyStorageKey, value: keyB64);
    }
    return Key(Uint8List.fromList(base64Decode(keyB64)));
  }

  /// Stores [row] as encrypted JSON (Supabase RPC map).
  Future<void> saveLicenseRow(Map<String, dynamic> row) async {
    final String json = jsonEncode(row);
    final Key key = await _getOrCreateAesKey();
    final IV iv = IV.fromSecureRandom(16);
    final Encrypter encrypter = Encrypter(AES(key));
    final Encrypted encrypted = encrypter.encrypt(json, iv: iv);
    final String payload = '${iv.base64}:${encrypted.base64}';
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, payload);
  }

  /// Decrypts and returns the stored row, or null.
  Future<Map<String, dynamic>?> readLicenseRow() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? payload = prefs.getString(_prefsKey);
    if (payload == null || payload.isEmpty) {
      return null;
    }
    final int sep = payload.indexOf(':');
    if (sep <= 0 || sep >= payload.length - 1) {
      return null;
    }
    final String ivB64 = payload.substring(0, sep);
    final String cipherB64 = payload.substring(sep + 1);
    try {
      final IV iv = IV.fromBase64(ivB64);
      final Encrypted encrypted = Encrypted.fromBase64(cipherB64);
      final Key key = await _getOrCreateAesKey();
      final Encrypter encrypter = Encrypter(AES(key));
      final String json = encrypter.decrypt(encrypted, iv: iv);
      final Object? decoded = jsonDecode(json);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }
      return null;
    } on Exception {
      return null;
    }
  }

  Future<void> clear() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefsKey);
  }
}
