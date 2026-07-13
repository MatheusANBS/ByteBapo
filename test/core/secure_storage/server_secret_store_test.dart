import 'package:byte_papo/core/secure_storage/server_secret_store.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('creates a deterministic alias for each server API key', () {
    expect(ServerSecretStore.aliasFor('server-1'), 'server-api-key:server-1');
    expect(ServerSecretStore.aliasFor('server-2'), 'server-api-key:server-2');
  });
}
