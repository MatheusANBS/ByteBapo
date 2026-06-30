import '../entities/server_profile.dart';

abstract class ServerRepository {
  Future<List<ServerProfile>> list();

  Future<void> save(ServerProfile profile);

  Future<void> remove(String id);

  Future<String?> getActiveServerId();

  Future<void> setActiveServerId(String? id);
}
