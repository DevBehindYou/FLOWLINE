import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../domain/entities/ai_provider_config.dart';

/// Android Keystore-backed storage for API keys only. Never touches
/// Drift/SQLite and never logs a key value — this is the one and only
/// place a raw key is read or written.
class SecureKeyStore {
  const SecureKeyStore();

  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
      // If the stored values can't be decrypted (the Keystore key is gone,
      // e.g. data restored onto a new phone), wipe them instead of failing
      // every read: the user re-enters a key, which beats a broken screen.
      resetOnError: true,
    ),
  );

  String _storageKey(AIProviderId id) => 'flowline_ai_api_key_${id.name}';

  /// Null when no key is saved, and also when the stored one can't be
  /// read: an unreadable key is treated as "not connected" so the UI can
  /// ask for it again rather than surfacing a platform exception.
  Future<String?> getKey(AIProviderId id) async {
    try {
      return await _storage.read(key: _storageKey(id));
    } catch (_) {
      return null;
    }
  }

  Future<void> setKey(AIProviderId id, String value) =>
      _storage.write(key: _storageKey(id), value: value);

  Future<void> deleteKey(AIProviderId id) =>
      _storage.delete(key: _storageKey(id));
}
