import 'package:byte_papo/core/database/app_database.dart' hide ServerProfile;
import 'package:byte_papo/core/secure_storage/server_secret_store.dart';
import 'package:byte_papo/features/servers/data/repositories/drift_server_repository.dart';
import 'package:byte_papo/features/servers/data/server_avatar_store.dart';
import 'package:byte_papo/features/servers/domain/entities/server_profile.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase database;
  late _MemorySecretStore secrets;
  late DriftServerRepository repository;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    secrets = _MemorySecretStore();
    repository = DriftServerRepository(database: database, secrets: secrets);
  });

  tearDown(() => database.close());

  test('stores NVIDIA keys only in secure storage', () async {
    final profile = _nvidiaProfile();

    await repository.save(profile, apiKey: 'nvapi-secret');

    expect(
      await secrets.read(ServerSecretStore.aliasFor(profile.id)),
      'nvapi-secret',
    );
    final row = await database.select(database.serverProfiles).getSingle();
    expect(row.apiKeyAlias, ServerSecretStore.aliasFor(profile.id));
    expect(row.toString(), isNot(contains('nvapi-secret')));
  });

  test('removes the database row and its secret', () async {
    final profile = _nvidiaProfile();
    await repository.save(profile, apiKey: 'nvapi-secret');

    await repository.remove(profile.id);

    expect(await repository.list(), isEmpty);
    expect(await secrets.read(ServerSecretStore.aliasFor(profile.id)), isNull);
  });

  test('persists avatar and latest connection state with the server', () async {
    final profile = _nvidiaProfile().copyWith(
      avatarPath: '/managed/server.png',
      lastConnectionStatus: ServerConnectionStatus.connected,
      lastCheckedAt: DateTime.utc(2026, 7, 13, 10),
      lastConnectedAt: DateTime.utc(2026, 7, 13, 10),
    );

    await repository.save(profile);

    final saved = (await repository.list()).single;
    expect(saved.avatarPath, '/managed/server.png');
    expect(saved.lastConnectionStatus, ServerConnectionStatus.connected);
    expect(saved.lastCheckedAt!.toUtc(), DateTime.utc(2026, 7, 13, 10));
  });

  test(
    'copies a selected avatar and removes the replaced managed photo',
    () async {
      final photos = _PhotoStore();
      repository = DriftServerRepository(
        database: database,
        secrets: secrets,
        avatarStore: photos,
      );
      await repository.save(
        _nvidiaProfile().copyWith(avatarPath: 'old-managed'),
      );

      await repository.save(
        _nvidiaProfile().copyWith(avatarPath: 'temporary-selection'),
      );

      expect(photos.copied, ['old-managed', 'temporary-selection']);
      expect(photos.deleted, ['managed/old-managed']);
      expect(
        (await repository.list()).single.avatarPath,
        'managed/temporary-selection',
      );
    },
  );
}

ServerProfile _nvidiaProfile() => ServerProfile.create(
  id: 'server-1',
  name: 'NVIDIA',
  input: 'https://integrate.api.nvidia.com',
  provider: ApiProvider.nvidia,
);

class _MemorySecretStore implements ServerSecretStore {
  final _values = <String, String>{};

  @override
  Future<void> delete(String alias) async => _values.remove(alias);

  @override
  Future<String?> read(String alias) async => _values[alias];

  @override
  Future<void> write(String alias, String value) async {
    _values[alias] = value;
  }
}

class _PhotoStore implements ServerAvatarStore {
  final copied = <String>[];
  final deleted = <String>[];

  @override
  Future<String> copyFrom(String sourcePath) async {
    copied.add(sourcePath);
    return 'managed/$sourcePath';
  }

  @override
  Future<void> delete(String path) async => deleted.add(path);
}
