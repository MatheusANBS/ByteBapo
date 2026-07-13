import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart' as db;
import '../../../../core/secure_storage/server_secret_store.dart';
import '../../domain/entities/server_profile.dart';
import '../../domain/repositories/server_repository.dart';

class DriftServerRepository implements ServerRepository {
  DriftServerRepository({required this.database, required this.secrets});

  final db.AppDatabase database;
  final ServerSecretStore secrets;

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
    if (row?.apiKeyAlias case final alias?) {
      await secrets.delete(alias);
    }
  }

  @override
  Future<void> save(ServerProfile profile, {String? apiKey}) async {
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
              apiKeyAlias: Value(alias),
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
      provider: row.provider == 'nvidia'
          ? ApiProvider.nvidia
          : ApiProvider.ollama,
    );
  }
}
