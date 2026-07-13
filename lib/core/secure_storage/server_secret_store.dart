import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract interface class ServerSecretStore {
  static String aliasFor(String serverId) => 'server-api-key:$serverId';

  Future<String?> read(String alias);

  Future<void> write(String alias, String value);

  Future<void> delete(String alias);
}

class FlutterServerSecretStore implements ServerSecretStore {
  FlutterServerSecretStore({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  @override
  Future<void> delete(String alias) => _storage.delete(key: alias);

  @override
  Future<String?> read(String alias) => _storage.read(key: alias);

  @override
  Future<void> write(String alias, String value) {
    return _storage.write(key: alias, value: value);
  }
}
