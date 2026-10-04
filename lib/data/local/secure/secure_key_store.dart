import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../domain/entities/ai_provider_config.dart';

/// Android Keystore-backed storage for API keys only. Never touches
/// Drift/SQLite and never logs a key value — this is the one and only
/// place a raw key is read or written.
class SecureKeyStore {
  const SecureKeyStore();

  // flutter_secure_storage is held at 10.x on purpose (pubspec.yaml):
  // builds up to Phase 1 stored keys with Jetpack Security
  // (EncryptedSharedPreferences), which v11 can no longer read. With the
  // flag below still set, v10 migrates those keys to its own cipher on
  // first read (migrateOnAlgorithmChange defaults to true), keeping a
  // backup until the migration completes. Move to v11 only once every
  // install has run a 10.x build.
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      // ignore: deprecated_member_use
      encryptedSharedPreferences: true,
      migrateWithBackup: true,
      // If the stored values can't be decrypted (the Keystore key is gone,
      // e.g. data restored onto a new phone), wipe them instead of failing
      // every read: the user re-enters a key, which beats a broken screen.
      resetOnError: true,
    ),
  );

  String _storageKey(AIProviderId id) => 'atomic_assist_ai_api_key_${id.name}';

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
