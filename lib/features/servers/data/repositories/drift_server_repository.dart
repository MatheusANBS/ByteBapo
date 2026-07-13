import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart' as db;
import '../../../../core/secure_storage/server_secret_store.dart';
import '../server_avatar_store.dart';
import '../../domain/entities/server_profile.dart';
import '../../domain/repositories/server_repository.dart';

class DriftServerRepository implements ServerRepository {
  DriftServerRepository({
    required this.database,
    required this.secrets,
    this.avatarStore,
  });

  final db.AppDatabase database;
  final ServerSecretStore secrets;
  final ServerAvatarStore? avatarStore;

  @override
  Future<List<ServerProfile>> list() async {
    final rows = await (database.select(
      database.serverProfiles,
    )..orderBy([(row) => OrderingTerm.asc(row.createdAt)])).get();
    return Future.wait(rows.map(_toEntity));
  }

  @override
  Future<void> remove(String id) async {
    final row = await (database.select(
      database.serverProfiles,
    )..where((profile) => profile.id.equals(id))).getSingleOrNull();
    await database.deleteServer(id);
    if (row?.avatarPath case final avatarPath?) {
      await avatarStore?.delete(avatarPath);
    }
    if (row?.apiKeyAlias case final alias?) {
      await secrets.delete(alias);
    }
  }

  @override
  Future<void> recordConnection(
    String id, {
    required ServerConnectionStatus status,
    required DateTime checkedAt,
  }) {
    return (database.update(
      database.serverProfiles,
    )..where((profile) => profile.id.equals(id))).write(
      db.ServerProfilesCompanion(
        lastConnectionStatus: Value(status.name),
        lastCheckedAt: Value(checkedAt),
        lastConnectedAt: status == ServerConnectionStatus.connected
            ? Value(checkedAt)
            : const Value.absent(),
        updatedAt: Value(DateTime.now().toUtc()),
      ),
    );
  }

  @override
  Future<void> save(ServerProfile profile, {String? apiKey}) async {
    final existing = await (database.select(
      database.serverProfiles,
    )..where((row) => row.id.equals(profile.id))).getSingleOrNull();
    final shouldCopyAvatar =
        profile.avatarPath != null &&
        profile.avatarPath != existing?.avatarPath;
    final avatarPath = shouldCopyAvatar
        ? await avatarStore?.copyFrom(profile.avatarPath!) ?? profile.avatarPath
        : profile.avatarPath;
    final alias = apiKey == null || apiKey.isEmpty
        ? null
        : ServerSecretStore.aliasFor(profile.id);
    final previousSecret = alias == null ? null : await secrets.read(alias);

    if (alias != null && apiKey != null) {
      await secrets.write(alias, apiKey);
    }

    try {
      await database
          .into(database.serverProfiles)
          .insertOnConflictUpdate(
            db.ServerProfilesCompanion.insert(
              id: profile.id,
              name: profile.name,
              provider: profile.provider.name,
              protocol: profile.protocol,
              host: profile.host,
              port: profile.port,
              basePath: Value(profile.basePath),
              avatarPath: Value(avatarPath),
              apiKeyAlias: Value(alias),
              lastConnectionStatus: Value(profile.lastConnectionStatus.name),
              lastConnectedAt: Value(profile.lastConnectedAt),
              lastCheckedAt: Value(profile.lastCheckedAt),
              createdAt: profile.createdAt,
              updatedAt: DateTime.now().toUtc(),
            ),
          );
    } catch (_) {
      if (alias != null && apiKey != null) {
        if (previousSecret == null) {
          await secrets.delete(alias);
        } else {
          await secrets.write(alias, previousSecret);
        }
      }
      rethrow;
    }
    final previousAvatar = existing?.avatarPath;
    if (shouldCopyAvatar && previousAvatar != null) {
      await avatarStore?.delete(previousAvatar);
    }
  }

  @override
  Future<String?> getActiveServerId() {
    return database.readSetting(db.AppSettingKey.activeServerId);
  }

  @override
  Future<void> setActiveServerId(String? id) {
    return database.writeSetting(db.AppSettingKey.activeServerId, id);
  }

  Future<ServerProfile> _toEntity(db.ServerProfile row) async {
    final key = row.apiKeyAlias == null
        ? null
        : await secrets.read(row.apiKeyAlias!);
    return ServerProfile(
      id: row.id,
      name: row.name,
      protocol: row.protocol,
      host: row.host,
      port: row.port,
      basePath: row.basePath,
      headers: key == null ? const {} : {'Authorization': 'Bearer $key'},
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      lastConnectedAt: row.lastConnectedAt,
      lastCheckedAt: row.lastCheckedAt,
      lastConnectionStatus: ServerConnectionStatus.values.firstWhere(
        (status) => status.name == row.lastConnectionStatus,
        orElse: () => ServerConnectionStatus.unknown,
      ),
      avatarPath: row.avatarPath,
      provider: row.provider == 'nvidia'
          ? ApiProvider.nvidia
          : ApiProvider.ollama,
    );
  }
}
