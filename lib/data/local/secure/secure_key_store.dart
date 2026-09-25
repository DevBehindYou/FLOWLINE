import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../domain/entities/ai_provider_config.dart';

/// Android Keystore-backed storage for API keys only. Never touches
/// Drift/SQLite and never logs a key value — this is the one and only
/// place a raw key is read or written.
class SecureKeyStore {
  const SecureKeyStore();

  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  String _storageKey(AIProviderId id) => 'flowline_ai_api_key_${id.name}';

  Future<String?> getKey(AIProviderId id) => _storage.read(key: _storageKey(id));

  Future<void> setKey(AIProviderId id, String value) =>
      _storage.write(key: _storageKey(id), value: value);

  Future<void> deleteKey(AIProviderId id) => _storage.delete(key: _storageKey(id));
}
